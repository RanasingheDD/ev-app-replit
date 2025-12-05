import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/charging_provider.dart';
import '../../models/charging_session.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChargingProvider>().loadSessionHistory(limit: 50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging History'),
      ),
      body: Consumer<ChargingProvider>(
        builder: (context, chargingProvider, _) {
          if (chargingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chargingProvider.sessionHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 64,
                    color: AppTheme.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No charging history yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your completed sessions will appear here',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textHint,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => chargingProvider.loadSessionHistory(limit: 50),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chargingProvider.sessionHistory.length,
              itemBuilder: (context, index) {
                final session = chargingProvider.sessionHistory[index];
                return _SessionCard(session: session);
              },
            ),
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ChargingSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(session.startTimestamp),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          DateFormat('hh:mm a').format(session.startTimestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        session.finalCost != null
                            ? 'Rs. ${session.finalCost!.toStringAsFixed(2)}'
                            : '--',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          session.statusString.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.electric_bolt,
                    value: '${session.energyKwh.toStringAsFixed(2)} kWh',
                    label: 'Energy',
                  ),
                  _StatItem(
                    icon: Icons.access_time,
                    value: session.durationDisplay,
                    label: 'Duration',
                  ),
                  _StatItem(
                    icon: Icons.ev_station,
                    value: session.chargerId.substring(0, 6).toUpperCase(),
                    label: 'Charger',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (session.status) {
      case SessionStatus.completed:
        return AppTheme.successColor;
      case SessionStatus.charging:
        return AppTheme.chargingColor;
      case SessionStatus.failed:
      case SessionStatus.cancelled:
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (session.status) {
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.charging:
        return Icons.bolt;
      case SessionStatus.failed:
      case SessionStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.history;
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textHint,
              ),
        ),
      ],
    );
  }
}

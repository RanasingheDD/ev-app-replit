import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/charging_provider.dart';
import '../../models/charging_session.dart';

class ActiveSessionScreen extends StatefulWidget {
  final String sessionId;

  const ActiveSessionScreen({super.key, required this.sessionId});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await context.read<ChargingProvider>().getSessionById(widget.sessionId);
    if (session != null && session.isActive) {
      context.read<ChargingProvider>().checkActiveSession();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChargingProvider>(
      builder: (context, chargingProvider, _) {
        final session = chargingProvider.activeSession;
        final telemetry = chargingProvider.telemetry;

        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Charging Session')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.primaryColor,
          appBar: AppBar(
            title: const Text('Charging'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => chargingProvider.refreshSessionStatus(),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryDark,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildChargingAnimation(session),
                          const SizedBox(height: 32),
                          _buildMainStats(session, telemetry),
                          const SizedBox(height: 24),
                          _buildDetailedStats(session, telemetry),
                          const SizedBox(height: 24),
                          _buildSessionInfo(session),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActions(session, chargingProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChargingAnimation(ChargingSession session) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.1);
        return Transform.scale(
          scale: session.isActive ? scale : 1.0,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Icon(
                    session.isActive ? Icons.bolt : Icons.check_circle,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainStats(ChargingSession session, ChargingTelemetry? telemetry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MainStat(
          value: telemetry?.energyDisplay ?? '${session.energyKwh.toStringAsFixed(2)} kWh',
          label: 'Energy',
          icon: Icons.electric_bolt,
        ),
        _MainStat(
          value: session.durationDisplay,
          label: 'Duration',
          icon: Icons.access_time,
        ),
        _MainStat(
          value: telemetry?.costDisplay ?? 'Rs. 0.00',
          label: 'Cost',
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }

  Widget _buildDetailedStats(ChargingSession session, ChargingTelemetry? telemetry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _DetailRow(
            label: 'Current Power',
            value: telemetry?.powerDisplay ?? '-- kW',
            icon: Icons.speed,
          ),
          const Divider(color: Colors.white24, height: 24),
          _DetailRow(
            label: 'State of Charge',
            value: telemetry?.socDisplay ?? '--%',
            icon: Icons.battery_charging_full,
          ),
          const Divider(color: Colors.white24, height: 24),
          _DetailRow(
            label: 'Voltage',
            value: telemetry != null ? '${telemetry.voltage.toStringAsFixed(0)} V' : '-- V',
            icon: Icons.electrical_services,
          ),
          const Divider(color: Colors.white24, height: 24),
          _DetailRow(
            label: 'Current',
            value: telemetry != null ? '${telemetry.current.toStringAsFixed(1)} A' : '-- A',
            icon: Icons.show_chart,
          ),
          if (telemetry?.timeRemainingDisplay != null) ...[
            const Divider(color: Colors.white24, height: 24),
            _DetailRow(
              label: 'Time Remaining',
              value: telemetry!.timeRemainingDisplay!,
              icon: Icons.timer,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionInfo(ChargingSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Session ID: ${session.id.substring(0, 12).toUpperCase()}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ChargingSession session, ChargingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: session.isActive
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await provider.stopCharging();
                        if (result != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Charging stopped successfully'),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                          context.go(AppRoutes.history);
                        }
                      },
                      icon: const Icon(Icons.stop_circle),
                      label: const Text('Stop Charging'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _showEmergencyStopDialog(provider),
                    icon: const Icon(Icons.warning, color: AppTheme.errorColor),
                    label: const Text(
                      'Emergency Stop',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Back to Home'),
                ),
              ),
      ),
    );
  }

  void _showEmergencyStopDialog(ChargingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            const Text('Emergency Stop'),
          ],
        ),
        content: const Text(
          'This will immediately stop charging. Use only in emergencies.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.emergencyStop();
              if (mounted) {
                context.go(AppRoutes.home);
              }
            },
            child: const Text(
              'Emergency Stop',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _MainStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

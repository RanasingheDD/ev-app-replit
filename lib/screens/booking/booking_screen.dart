import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/providers.dart';
import '../../widgets/loading_overlay.dart';

class BookingScreen extends StatefulWidget {
  final String stationId;
  final String chargerId;

  const BookingScreen({
    super.key,
    required this.stationId,
    required this.chargerId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _durationMinutes = 60;
  bool _isImmediate = true;

  @override
  void initState() {
    super.initState();
    context.read<StationProvider>().loadStationById(widget.stationId);
    context.read<EVProvider>().loadEVs();
  }

  DateTime get _startDateTime {
    if (_isImmediate) return DateTime.now();
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  DateTime get _endDateTime =>
      _startDateTime.add(Duration(minutes: _durationMinutes));

  Future<void> _getQuote() async {
    final evProvider = context.read<EVProvider>();
    final bookingProvider = context.read<BookingProvider>();

    await bookingProvider.getQuote(
      chargerId: widget.chargerId,
      stationId: widget.stationId,
      startAt: _startDateTime,
      endAt: _endDateTime,
      evId: evProvider.selectedEv?.id,
    );
  }

  Future<void> _confirmBooking() async {
    await _getQuote();

    if (!mounted) return;

    final bookingProvider = context.read<BookingProvider>();
    final quote = bookingProvider.currentQuote;

    if (quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.error ?? 'Failed to get quote'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!quote.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(quote.unavailableReason ?? 'Slot not available'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    print("quote get success");

    final evProvider = context.read<EVProvider>();
    final booking = await bookingProvider.createBooking(
      chargerId: widget.chargerId,
      stationId: widget.stationId,
      startAt: _startDateTime,
      endAt: _endDateTime,
      paymentIntentId: 'mock_payment_${DateTime.now().millisecondsSinceEpoch}',
      evId: evProvider.selectedEv?.id,
    );

    if (!mounted) return;

    if (booking != null) {
      context.go('/booking-confirmation/${booking.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.error ?? 'Booking failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StationProvider, BookingProvider>(
      builder: (context, stationProvider, bookingProvider, _) {
        final station = stationProvider.selectedStation;
        final charger = station?.chargers.firstWhere(
          (c) => c.id == widget.chargerId,
          orElse: () => station!.chargers.first,
        );

        return LoadingOverlay(
          isLoading: bookingProvider.isLoading,
          message: 'Processing booking...',
          child: Scaffold(
            appBar: AppBar(title: const Text('Book Charger')),
            body: station == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStationInfo(station, charger),
                        const SizedBox(height: 24),
                        _buildVehicleSelection(),
                        const SizedBox(height: 24),
                        _buildTimeSelection(),
                        const SizedBox(height: 24),
                        _buildDurationSelection(),
                        const SizedBox(height: 24),
                        _buildSummary(station),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('Confirm Booking'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStationInfo(dynamic station, dynamic charger) {
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.ev_station,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${charger?.displayName ?? 'Charger'} • ${charger?.connectorType ?? ''} • ${charger?.powerDisplay ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return Consumer<EVProvider>(
      builder: (context, evProvider, _) {
        if (evProvider.evs.isEmpty) {
          return Card(
            color: AppTheme.surfaceColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 48,
                    color: AppTheme.textHint,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No vehicles added',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.offlineColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/add-ev'),
                    child: const Text('Add Vehicle'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Vehicle',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.offlineColor),
            ),
            const SizedBox(height: 12),
            ...evProvider.evs.map((ev) {
              final isSelected = evProvider.selectedEv?.id == ev.id;
              return Card(
                color: isSelected ? AppTheme.surfaceColor : null,
                child: RadioListTile(
                  value: ev.id,
                  groupValue: evProvider.selectedEv?.id,
                  onChanged: (_) => evProvider.selectEV(ev),
                  title: Text(
                    ev.displayName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${ev.batteryKwh} kWh • ${ev.connectorTypesDisplay}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When to charge?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppTheme.offlineColor),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SelectionCard(
                title: 'Now',
                subtitle: 'Start immediately',
                icon: Icons.bolt,
                isSelected: _isImmediate,
                onTap: () => setState(() => _isImmediate = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SelectionCard(
                title: 'Schedule',
                subtitle: 'Pick a time',
                icon: Icons.schedule,
                isSelected: !_isImmediate,
                onTap: () => setState(() => _isImmediate = false),
              ),
            ),
          ],
        ),
        if (!_isImmediate) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('MMM dd').format(_selectedDate)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() => _selectedTime = time);
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedTime.format(context)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDurationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppTheme.offlineColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [30, 60, 90, 120, 180].map((minutes) {
            final isSelected = _durationMinutes == minutes;
            final hours = minutes ~/ 60;
            final mins = minutes % 60;
            final label = hours > 0
                ? mins > 0
                      ? '${hours}h ${mins}m'
                      : '${hours}h'
                : '${mins}m';

            return ChoiceChip(
              backgroundColor: AppTheme.surfaceColor,
              label: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _durationMinutes = minutes),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummary(dynamic station) {
    final tariff = station.tariffRules.isNotEmpty
        ? station.tariffRules.first
        : null;
    final estimatedCost = tariff != null
        ? tariff.calculateCost(
            durationMinutes: _durationMinutes,
            energyKwh: 20.0,
          )
        : 0.0;

    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Start Time',
              value: _isImmediate
                  ? 'Now'
                  : DateFormat('MMM dd, hh:mm a').format(_startDateTime),
            ),
            _SummaryRow(
              label: 'Duration',
              value: '${_durationMinutes ~/ 60}h ${_durationMinutes % 60}m',
            ),
            _SummaryRow(
              label: 'End Time',
              value: DateFormat('MMM dd, hh:mm a').format(_endDateTime),
            ),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Estimated Cost',
              value: 'Rs. ${estimatedCost.toStringAsFixed(2)}',
              valueStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? AppTheme.surfaceColor : AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: valueStyle ?? Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

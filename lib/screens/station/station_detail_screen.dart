import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/station_provider.dart';
import '../../models/station.dart';
import '../../models/charger.dart';
import '../../models/tariff.dart';
import '../../widgets/station_card.dart';

class StationDetailScreen extends StatefulWidget {
  final String stationId;

  const StationDetailScreen({super.key, required this.stationId});

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StationProvider>().loadStationById(widget.stationId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StationProvider>(
      builder: (context, stationProvider, _) {
        final station = stationProvider.selectedStation;

        if (stationProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (station == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(stationProvider.error ?? 'Station not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    station.name,
                    style: const TextStyle(
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                  background: station.images.isNotEmpty
                      ? Image.network(
                          station.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.primaryColor,
                            child: const Icon(
                              Icons.ev_station,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.primaryColor,
                          child: const Icon(
                            Icons.ev_station,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusRow(station),
                      const SizedBox(height: 16),
                      _buildLocationCard(station),
                      const SizedBox(height: 16),
                      _buildPricingCard(station),
                      const SizedBox(height: 16),
                      _buildChargersSection(station),
                      const SizedBox(height: 16),
                      _buildAmenitiesSection(station),
                      const SizedBox(height: 16),
                      if (station.description != null &&
                          station.description!.isNotEmpty)
                        _buildDescriptionSection(station),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: station.availableChargerCount > 0
                          ? () => _showChargerSelection(station)
                          : null,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(Station station) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: station.isOpen ? AppTheme.successColor : AppTheme.errorColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            station.isOpen ? 'Open Now' : 'Closed',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: station.availableChargerCount > 0
                ? AppTheme.availableColor.withValues(alpha: 0.1)
                : AppTheme.occupiedColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${station.availableChargerCount}/${station.totalChargerCount} Available',
            style: TextStyle(
              color: station.availableChargerCount > 0
                  ? AppTheme.availableColor
                  : AppTheme.occupiedColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const Spacer(),
        if (station.rating > 0)
          Row(
            children: [
              const Icon(Icons.star, color: AppTheme.accentColor, size: 20),
              const SizedBox(width: 4),
              Text(
                '${station.rating.toStringAsFixed(1)} (${station.reviewCount})',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildLocationCard(Station station) {
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(station.address, style: Theme.of(context).textTheme.bodyLarge),
            if (station.distanceDisplay.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${station.distanceDisplay} from your location',
                style: Theme.of(context).textTheme.bodySmall,
                //?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
            if (station.operatorName != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.business,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Operated by ${station.operatorName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(Station station) {
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pricing',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (station.tariffRules.isEmpty)
              const Text('Contact station for pricing details')
            else
              ...station.tariffRules.map(
                (rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rule.connectorType ?? 'All connectors',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                      Text(
                        rule.displayPrice,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargersSection(Station station) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chargers',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppTheme.offlineColor),
        ),
        const SizedBox(height: 12),
        ...station.chargers.map(
          (charger) => Card(
            color: AppTheme.surfaceColor,
            margin: const EdgeInsets.only(bottom: 8),
            child: ChargerListTile(
              charger: charger,
              onTap: charger.isAvailable
                  ? () => context.push('/booking/${station.id}/${charger.id}')
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(Station station) {
    if (station.amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppTheme.offlineColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: station.amenities.map((amenity) {
            return Chip(
              avatar: Icon(
                _getAmenityIcon(amenity),
                size: 16,
                color: AppTheme.primaryColor,
              ),
              label: Text(
                amenity,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.white),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Station station) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppTheme.offlineColor),
        ),
        const SizedBox(height: 12),
        Text(
          station.description!,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'restroom':
        return Icons.wc;
      case 'cafe':
      case 'coffee':
        return Icons.coffee;
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'parking':
        return Icons.local_parking;
      case '24/7':
        return Icons.access_time;
      default:
        return Icons.check_circle;
    }
  }

  void _showChargerSelection(Station station) {
    final availableChargers = station.chargers
        .where((c) => c.isAvailable)
        .toList();

    if (availableChargers.length == 1) {
      context.push('/booking/${station.id}/${availableChargers.first.id}');
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Charger',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...availableChargers.map(
                (charger) => ChargerListTile(
                  charger: charger,
                  showStatus: false,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/booking/${station.id}/${charger.id}');
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

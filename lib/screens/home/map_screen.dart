import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/station_provider.dart';
import '../../models/station.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Station? _selectedStation;

  @override
  void initState() {
    super.initState();
    context.read<StationProvider>().loadStations(lat: 6.9271, lng: 79.8612, radius: 50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Stations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.push('/stations'),
          ),
        ],
      ),
      body: Consumer<StationProvider>(
        builder: (context, stationProvider, _) {
          if (stationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryLight.withValues(alpha: 0.3),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 80,
                        color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Map View',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Interactive map with ${stationProvider.stations.length} charging stations in your area',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: stationProvider.stations.take(5).map((station) {
                          return ActionChip(
                            avatar: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: station.availableChargerCount > 0
                                    ? AppTheme.availableColor
                                    : AppTheme.occupiedColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            label: Text(station.name),
                            onPressed: () => context.push('/station/${station.id}'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedStation != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedStation!.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() => _selectedStation = null),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedStation!.address,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _InfoChip(
                                icon: Icons.ev_station,
                                label: '${_selectedStation!.availableChargerCount}/${_selectedStation!.totalChargerCount}',
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.bolt,
                                label: '${_selectedStation!.maxPower.toInt()} kW',
                                color: AppTheme.secondaryColor,
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () => context.push('/station/${_selectedStation!.id}'),
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'location',
            mini: true,
            onPressed: () {
              context.read<StationProvider>().loadStations(lat: 6.9271, lng: 79.8612, radius: 50);
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'refresh',
            mini: true,
            onPressed: () {
              context.read<StationProvider>().loadStations(lat: 6.9271, lng: 79.8612, radius: 50);
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

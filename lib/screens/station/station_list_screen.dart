import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/api_config.dart';
import '../../providers/station_provider.dart';
import '../../models/station.dart';
import '../../widgets/station_card.dart';

class StationListScreen extends StatefulWidget {
  const StationListScreen({super.key});

  @override
  State<StationListScreen> createState() => _StationListScreenState();
}

class _StationListScreenState extends State<StationListScreen> {
  final _searchController = TextEditingController();
  bool _showFilters = false;

  List<String> _selectedConnectors = [];
  double? _minPower;
  bool _availableOnly = false;

  @override
  void initState() {
    super.initState();
    context.read<StationProvider>().loadStations(lat: 6.9271, lng: 79.8612, radius: 50);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filter = StationFilter(
      connectorTypes: _selectedConnectors.isNotEmpty ? _selectedConnectors : null,
      minPower: _minPower,
      availableOnly: _availableOnly,
    );

    context.read<StationProvider>().setFilter(filter);
    context.read<StationProvider>().loadStations(lat: 6.9271, lng: 79.8612, radius: 50);
    setState(() => _showFilters = false);
  }

  void _clearFilters() {
    setState(() {
      _selectedConnectors = [];
      _minPower = null;
      _availableOnly = false;
    });
    context.read<StationProvider>().clearFilter();
    context.read<StationProvider>().loadStations(lat: 6.9271, lng: 79.8612, radius: 50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Stations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push('/map'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search stations...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<StationProvider>().loadStations(
                                      lat: 6.9271,
                                      lng: 79.8612,
                                      radius: 50,
                                    );
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<StationProvider>().searchStations(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _showFilters || _hasActiveFilters
                        ? AppTheme.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.textHint),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: _showFilters || _hasActiveFilters
                          ? Colors.white
                          : AppTheme.textPrimary,
                    ),
                    onPressed: () => setState(() => _showFilters = !_showFilters),
                  ),
                ),
              ],
            ),
          ),
          if (_showFilters) _buildFilterPanel(),
          Expanded(
            child: Consumer<StationProvider>(
              builder: (context, stationProvider, _) {
                if (stationProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (stationProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                        const SizedBox(height: 16),
                        Text(stationProvider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => stationProvider.loadStations(
                            lat: 6.9271,
                            lng: 79.8612,
                            radius: 50,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (stationProvider.stations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.ev_station_outlined,
                          size: 64,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stations found',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        if (_hasActiveFilters) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => stationProvider.loadStations(
                    lat: 6.9271,
                    lng: 79.8612,
                    radius: 50,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: stationProvider.stations.length,
                    itemBuilder: (context, index) {
                      final station = stationProvider.stations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: StationCard(
                          station: station,
                          onTap: () => context.push('/station/${station.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedConnectors.isNotEmpty || _minPower != null || _availableOnly;

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connector Types',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConfig.connectorTypes.map((connector) {
              final isSelected = _selectedConnectors.contains(connector);
              return FilterChip(
                label: Text(connector),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedConnectors.add(connector);
                    } else {
                      _selectedConnectors.remove(connector);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Minimum Power',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConfig.powerLevels.map((power) {
              final isSelected = _minPower == power.toDouble();
              return FilterChip(
                label: Text('$power kW+'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _minPower = selected ? power.toDouble() : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Available chargers only'),
            value: _availableOnly,
            onChanged: (value) => setState(() => _availableOnly = value),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

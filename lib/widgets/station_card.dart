import 'package:flutter/material.dart';
import '../models/station.dart';
import '../models/charger.dart';
import '../config/theme.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final VoidCallback? onTap;
  final bool showDistance;

  const StationCard({
    super.key,
    required this.station,
    this.onTap,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    print(station.images.first);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (station.images.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  station.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.backgroundColor,
                    child: const Icon(
                      Icons.ev_station,
                      size: 48,
                      color: AppTheme.textHint,
                    ),
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: AppTheme.backgroundColor,
                  child: const Icon(
                    Icons.ev_station,
                    size: 48,
                    color: AppTheme.textHint,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          station.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showDistance && station.distance != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            station.distanceDisplay,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          station.address,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatusBadge(
                        available: station.availableChargerCount,
                        total: station.totalChargerCount,
                      ),
                      const SizedBox(width: 12),
                      _PowerBadge(maxPower: station.maxPower),
                      const Spacer(),
                      if (station.rating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: AppTheme.accentColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              station.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: station.supportsConnectors
                        .take(3)
                        .map(
                          (connector) => _ConnectorChip(connector: connector),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    station.priceDisplay,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
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
}

class _StatusBadge extends StatelessWidget {
  final int available;
  final int total;

  const _StatusBadge({required this.available, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = available > 0
        ? AppTheme.availableColor
        : AppTheme.occupiedColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$available/$total',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerBadge extends StatelessWidget {
  final double maxPower;

  const _PowerBadge({required this.maxPower});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 14, color: AppTheme.secondaryColor),
          const SizedBox(width: 4),
          Text(
            '${maxPower.toInt()} kW',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectorChip extends StatelessWidget {
  final String connector;

  const _ConnectorChip({required this.connector});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(connector, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class ChargerListTile extends StatelessWidget {
  final Charger charger;
  final VoidCallback? onTap;
  final bool showStatus;

  const ChargerListTile({
    super.key,
    required this.charger,
    this.onTap,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _getStatusColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.ev_station, color: _getStatusColor()),
      ),
      title: Text(
        charger.displayName,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
      ),
      subtitle: Row(
        children: [
          Text(
            charger.connectorType,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          Text(
            ' • ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          Text(
            charger.powerDisplay,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
      trailing: showStatus
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            )
          : null,
      onTap: charger.isAvailable ? onTap : null,
    );
  }

  Color _getStatusColor() {
    switch (charger.status) {
      case ChargerStatus.available:
        return AppTheme.availableColor;
      case ChargerStatus.occupied:
      case ChargerStatus.charging:
        return AppTheme.occupiedColor;
      case ChargerStatus.reserved:
        return AppTheme.secondaryColor;
      case ChargerStatus.outOfService:
        return AppTheme.offlineColor;
    }
  }

  String _getStatusText() {
    switch (charger.status) {
      case ChargerStatus.available:
        return 'Available';
      case ChargerStatus.occupied:
        return 'Occupied';
      case ChargerStatus.charging:
        return 'Charging';
      case ChargerStatus.reserved:
        return 'Reserved';
      case ChargerStatus.outOfService:
        return 'Offline';
    }
  }
}

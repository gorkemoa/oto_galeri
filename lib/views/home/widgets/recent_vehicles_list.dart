import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/models/vehicle_model.dart';

/// RecentVehiclesList - Son eklenen araçlar listesi
class RecentVehiclesList extends StatelessWidget {
  final List<VehicleModel> vehicles;

  const RecentVehiclesList({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              SizeTokens.spacingMd,
              SizeTokens.spacingMd,
              SizeTokens.spacingMd,
              SizeTokens.spacingXs,
            ),
            child: Text(
              'SON EKLENEN ARAÇLAR',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.6,
                  ),
            ),
          ),
          Divider(height: SizeTokens.borderThin, color: AppTheme.divider),
          ...List.generate(vehicles.length, (index) {
            final vehicle = vehicles[index];
            return Column(
              children: [
                _VehicleRow(vehicle: vehicle),
                if (index < vehicles.length - 1)
                  Divider(
                    height: SizeTokens.borderThin,
                    color: AppTheme.divider,
                    indent: SizeTokens.spacingMd,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final VehicleModel vehicle;

  const _VehicleRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );
    final kmFormat = NumberFormat('#,###', 'tr_TR');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingMd,
        vertical: SizeTokens.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            width: SizeTokens.avatarMd,
            height: SizeTokens.avatarMd,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
              child: vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty
                  ? (vehicle.imageUrl!.startsWith('http')
                      ? Image.network(
                          vehicle.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.directions_car,
                            color: AppTheme.accent,
                            size: SizeTokens.iconSm,
                          ),
                        )
                      : Image.asset(
                          vehicle.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.directions_car,
                            color: AppTheme.accent,
                            size: SizeTokens.iconSm,
                          ),
                        ))
                  : Icon(
                      Icons.directions_car,
                      color: AppTheme.accent,
                      size: SizeTokens.iconSm,
                    ),
            ),
          ),
          SizedBox(width: SizeTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.fullName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
                SizedBox(height: SizeTokens.spacingXxs),
                Text(
                  '${vehicle.year ?? ''} · ${kmFormat.format(vehicle.kilometer ?? 0)} KM',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(vehicle.purchasePrice ?? 0),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: SizeTokens.spacingXxs),
              Text(
                'Alış',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

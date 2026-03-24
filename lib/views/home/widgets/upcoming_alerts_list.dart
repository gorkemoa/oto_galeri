import 'package:flutter/material.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/models/alert_model.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/viewmodels/vehicle_detail_view_model.dart';
import 'package:oto_galeri/views/vehicles/vehicle_detail_view.dart';
import 'package:provider/provider.dart';

/// UpcomingAlertsList - Yaklaşan sigorta/muayene uyarıları
class UpcomingAlertsList extends StatelessWidget {
  final List<AlertModel> alerts;

  const UpcomingAlertsList({super.key, required this.alerts});

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
              'YAKLAŞAN UYARILAR',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.6,
                  ),
            ),
          ),
          Divider(height: SizeTokens.borderThin, color: AppTheme.divider),
          ...List.generate(alerts.length, (index) {
            final alert = alerts[index];
            return Column(
              children: [
                _AlertRow(alert: alert),
                if (index < alerts.length - 1)
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

class _AlertRow extends StatelessWidget {
  final AlertModel alert;

  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isUrgent = (alert.remainingDays ?? 0) <= 7;
    final alertColor = isUrgent ? AppTheme.error : AppTheme.warning;

    final String alertTypeLabel = switch (alert.alertType) {
      'sigorta' => 'Sigorta',
      'kasko' => 'Kasko',
      'muayene' => 'Muayene',
      _ => alert.alertType ?? '',
    };

    return InkWell(
      onTap: () {
        if (alert.vehicleId != null) {
          final vehicle = VehicleModel(
            id: alert.vehicleId,
            brand: alert.vehicleName?.split(' ').first,
            model: alert.vehicleName?.split(' ').skip(1).join(' '),
            imageUrl: alert.imageUrl,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => VehicleDetailViewModel(vehicleId: alert.vehicleId!),
                child: VehicleDetailView(initialVehicle: vehicle),
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.spacingMd,
          vertical: SizeTokens.spacingMd,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
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
                    child: alert.imageUrl != null && alert.imageUrl!.isNotEmpty
                        ? (alert.imageUrl!.startsWith('http')
                            ? Image.network(
                                alert.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.directions_car,
                                  color: AppTheme.accent,
                                  size: SizeTokens.iconSm,
                                ),
                              )
                            : Image.asset(
                                alert.imageUrl!,
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
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isUrgent ? Icons.warning_amber_rounded : Icons.schedule_outlined,
                      color: alertColor,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: SizeTokens.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.vehicleName ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  SizedBox(height: SizeTokens.spacingXxs),
                  Text(
                    '${alertTypeLabel} bitmesine ${alert.remainingDays ?? 0} gün kaldı',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textTertiary,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.spacingSm,
                vertical: SizeTokens.spacingXxs,
              ),
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(SizeTokens.radiusFull),
              ),
              child: Text(
                '${alert.remainingDays ?? 0} gün',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: alertColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

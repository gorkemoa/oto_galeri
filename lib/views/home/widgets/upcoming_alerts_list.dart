import 'package:flutter/material.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/models/alert_model.dart';

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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingMd,
        vertical: SizeTokens.spacingMd,
      ),
      child: Row(
        children: [
          Icon(
            isUrgent ? Icons.warning_amber_rounded : Icons.schedule_outlined,
            color: alertColor,
            size: SizeTokens.iconSm,
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
                  '$alertTypeLabel bitmesine ${alert.remainingDays ?? 0} gün kaldı',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
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
    );
  }
}

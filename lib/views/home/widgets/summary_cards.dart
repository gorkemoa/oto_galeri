import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/models/dashboard_summary_model.dart';

/// SummaryCards - Dashboard özet kartları
class SummaryCards extends StatelessWidget {
  final DashboardSummaryModel summary;

  const SummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: SizeTokens.spacingSm,
      mainAxisSpacing: SizeTokens.spacingSm,
      childAspectRatio: 2.2,
      children: [
        _SummaryCard(
          title: 'Toplam Araç',
          value: '${summary.totalVehicles ?? 0}',
          icon: Icons.directions_car,
          iconColor: AppTheme.primary,
        ),
        _SummaryCard(
          title: 'Stokta',
          value: '${summary.inStockVehicles ?? 0}',
          icon: Icons.inventory_2,
          iconColor: AppTheme.statusStokta,
        ),
        _SummaryCard(
          title: 'Satıldı',
          value: '${summary.soldVehicles ?? 0}',
          icon: Icons.sell,
          iconColor: AppTheme.statusSatildi,
        ),
        _SummaryCard(
          title: 'Toplam Kâr',
          value: currencyFormat.format(summary.totalProfit ?? 0),
          icon: Icons.trending_up,
          iconColor: AppTheme.success,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingMd,
        vertical: SizeTokens.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(SizeTokens.spacingXs),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
            ),
            child: Icon(icon, size: SizeTokens.iconSm, color: iconColor),
          ),
          SizedBox(width: SizeTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                SizedBox(height: SizeTokens.spacingXxs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

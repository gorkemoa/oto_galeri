import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/models/report_summary_model.dart';

/// KpiRow - 4 adet KPI metrik kartı (2x2 grid)
class KpiRow extends StatelessWidget {
  final ReportSummaryModel summary;

  const KpiRow({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
        locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    final netProfit = summary.netProfit ?? 0;
    final isProfit = netProfit >= 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Net Kâr / Zarar',
                value: '${isProfit ? '+' : ''}${fmt.format(netProfit)}',
                icon: isProfit
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                valueColor: isProfit ? AppTheme.success : AppTheme.error,
                bgColor: (isProfit ? AppTheme.success : AppTheme.error)
                    .withValues(alpha: 0.08),
                sub:
                    '${summary.soldVehicles ?? 0} araç satıldı',
              ),
            ),
            SizedBox(width: SizeTokens.spacingMd),
            Expanded(
              child: _KpiCard(
                label: 'Satış Geliri',
                value: fmt.format(summary.totalRevenue ?? 0),
                icon: Icons.sell_outlined,
                valueColor: AppTheme.textPrimary,
                bgColor: AppTheme.accent.withValues(alpha: 0.08),
                sub: 'Toplam tahsilat',
              ),
            ),
          ],
        ),
        SizedBox(height: SizeTokens.spacingMd),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Alış Maliyeti',
                value: fmt.format(summary.totalPurchaseCost ?? 0),
                icon: Icons.shopping_cart_outlined,
                valueColor: AppTheme.textPrimary,
                bgColor: AppTheme.background,
                sub: 'Satılan araçlar',
              ),
            ),
            SizedBox(width: SizeTokens.spacingMd),
            Expanded(
              child: _KpiCard(
                label: 'Op. Gider',
                value: fmt.format(summary.totalOperationExpenses ?? 0),
                icon: Icons.receipt_long_outlined,
                valueColor: AppTheme.warning,
                bgColor: AppTheme.warning.withValues(alpha: 0.08),
                sub: 'Satılan araçlar',
              ),
            ),
          ],
        ),
        // Stok yatırım kartı
        if ((summary.stockInvestment ?? 0) > 0) ...[
          SizedBox(height: SizeTokens.spacingMd),
          _StockInvestmentBar(
            stockVehicles: summary.stockVehicles ?? 0,
            stockInvestment: summary.stockInvestment ?? 0,
            fmt: fmt,
          ),
        ],
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color valueColor;
  final Color bgColor;
  final String sub;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.valueColor,
    required this.bgColor,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(
            color: AppTheme.border, width: SizeTokens.borderThin),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(SizeTokens.spacingXs),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
            ),
            child: Icon(icon, size: SizeTokens.iconXs, color: valueColor),
          ),
          SizedBox(height: SizeTokens.spacingSm),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeTokens.fontSm,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: SizeTokens.spacingXxs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeTokens.fontXxs,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: SizeTokens.spacingXxs),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeTokens.fontXxs,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockInvestmentBar extends StatelessWidget {
  final int stockVehicles;
  final int stockInvestment;
  final NumberFormat fmt;

  const _StockInvestmentBar({
    required this.stockVehicles,
    required this.stockInvestment,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingLg,
        vertical: SizeTokens.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: SizeTokens.iconSm,
            color: AppTheme.textOnPrimary.withValues(alpha: 0.7),
          ),
          SizedBox(width: SizeTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stok Yatırımı',
                  style: TextStyle(
                    fontSize: SizeTokens.fontXxs,
                    color: AppTheme.textOnPrimary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  fmt.format(stockInvestment),
                  style: TextStyle(
                    fontSize: SizeTokens.fontSm,
                    color: AppTheme.textOnPrimary,
                    fontWeight: FontWeight.w700,
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
              color: AppTheme.textOnPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(SizeTokens.radiusFull),
            ),
            child: Text(
              '$stockVehicles araç stokta',
              style: TextStyle(
                fontSize: SizeTokens.fontXxs,
                color: AppTheme.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

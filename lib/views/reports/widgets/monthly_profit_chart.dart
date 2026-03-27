import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';

/// MonthlyProfitChart - Aylık kâr bar grafiği
class MonthlyProfitChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const MonthlyProfitChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmpty(context);
    }

    final fmt =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    // Değer aralığı
    double maxAbsValue = 0;
    for (final d in data) {
      final v = (d['profit'] as num).toDouble().abs();
      if (v > maxAbsValue) maxAbsValue = v;
    }
    if (maxAbsValue == 0) maxAbsValue = 1;

    return Column(
      children: data.map((d) {
        final profit = (d['profit'] as num).toDouble();
        final label = d['month'] as String;
        final isProfit = profit >= 0;
        final ratio = profit.abs() / maxAbsValue;
        final color = profit == 0
            ? AppTheme.divider
            : (isProfit ? AppTheme.success : AppTheme.error);

        return Padding(
          padding: EdgeInsets.only(bottom: SizeTokens.spacingMd),
          child: Row(
            children: [
              SizedBox(
                width: SizeTokens.spacing3xl,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeTokens.fontXs,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spacingSm),
              Expanded(
                child: Stack(
                  children: [
                    // Arka plan
                    Container(
                      height: SizeTokens.spacingXxl,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius:
                            BorderRadius.circular(SizeTokens.radiusSm),
                      ),
                    ),
                    // Bar
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: SizeTokens.spacingXxl,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius:
                              BorderRadius.circular(SizeTokens.radiusSm),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: SizeTokens.spacingMd),
              SizedBox(
                width: SizeTokens.spacing5xl + SizeTokens.spacingXxl,
                child: Text(
                  profit == 0 ? '—' : fmt.format(profit),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: SizeTokens.fontXs,
                    fontWeight: FontWeight.w700,
                    color: profit == 0
                        ? AppTheme.textTertiary
                        : (isProfit ? AppTheme.success : AppTheme.error),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeTokens.spacingXxl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bar_chart_outlined,
                size: SizeTokens.spacing4xl, color: AppTheme.textTertiary),
            SizedBox(height: SizeTokens.spacingSm),
            Text(
              'Bu dönemde satış verisi bulunmuyor',
              style: TextStyle(
                fontSize: SizeTokens.fontXs,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

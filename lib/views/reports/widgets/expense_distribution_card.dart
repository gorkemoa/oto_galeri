import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';

/// ExpenseDistributionCard - Gider kategori dağılımı listesi
class ExpenseDistributionCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const ExpenseDistributionCard({super.key, required this.data});

  static const _categoryColors = <String, Color>{
    'Servis': AppTheme.accent,
    'Tamir': AppTheme.error,
    'Lastik': AppTheme.warning,
    'Yakıt': Color(0xFF10B981),
    'Temizlik': Color(0xFF8B5CF6),
    'Ekspertiz': AppTheme.secondary,
    'Noter': AppTheme.textSecondary,
    'Diğer': Color(0xFF64748B),
  };

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: SizeTokens.spacingXxl),
        child: Center(
          child: Text(
            'Bu dönemde gider verisi bulunmuyor',
            style: TextStyle(
              fontSize: SizeTokens.fontXs,
              color: AppTheme.textTertiary,
            ),
          ),
        ),
      );
    }

    final fmt =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    final total = data.fold<double>(
        0, (s, e) => s + (e['amount'] as num).toDouble());

    return Column(
      children: [
        // Toplam
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Toplam Gider',
              style: TextStyle(
                fontSize: SizeTokens.fontXs,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              fmt.format(total),
              style: TextStyle(
                fontSize: SizeTokens.fontSm,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeTokens.spacingMd),
        // Yığılmış bar
        ClipRRect(
          borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
          child: SizedBox(
            height: SizeTokens.spacingSm,
            child: Row(
              children: data.asMap().entries.map((entry) {
                final amount = (entry.value['amount'] as num).toDouble();
                final ratio = total > 0 ? amount / total : 0.0;
                final cat = entry.value['type'] as String;
                final color = _colorFor(cat, entry.key);
                return Expanded(
                  flex: (ratio * 1000).round(),
                  child: Container(color: color),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: SizeTokens.spacingMd),
        // Liste
        ...data.asMap().entries.map((entry) {
          final item = entry.value;
          final amount = (item['amount'] as num).toDouble();
          final category = item['type'] as String;
          final ratio = total > 0 ? amount / total : 0.0;
          final color = _colorFor(category, entry.key);

          return Padding(
            padding: EdgeInsets.only(bottom: SizeTokens.spacingSm),
            child: Row(
              children: [
                Container(
                  width: SizeTokens.spacingMd,
                  height: SizeTokens.spacingMd,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                        BorderRadius.circular(SizeTokens.radiusSm),
                  ),
                ),
                SizedBox(width: SizeTokens.spacingSm),
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: SizeTokens.fontSm,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${(ratio * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: SizeTokens.fontXs,
                    color: AppTheme.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: SizeTokens.spacingSm),
                SizedBox(
                  width: SizeTokens.spacing5xl + SizeTokens.spacingLg,
                  child: Text(
                    fmt.format(amount),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: SizeTokens.fontXs,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _colorFor(String category, int index) {
    return _categoryColors[category] ??
        _fallbackColors[index % _fallbackColors.length];
  }

  static const _fallbackColors = [
    AppTheme.accent,
    AppTheme.success,
    AppTheme.warning,
    AppTheme.error,
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
  ];
}

import 'package:flutter/material.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/viewmodels/reports_view_model.dart';

/// PeriodFilterBar - Dönem seçici chip listesi
class PeriodFilterBar extends StatelessWidget {
  final ReportsViewModel viewModel;

  const PeriodFilterBar({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeTokens.spacing4xl,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingLg),
        itemCount: ReportsViewModel.periods.length,
        separatorBuilder: (_, __) => SizedBox(width: SizeTokens.spacingSm),
        itemBuilder: (context, index) {
          final period = ReportsViewModel.periods[index];
          final isSelected = viewModel.selectedPeriod == period;
          return GestureDetector(
            onTap: () {
              if (isSelected) return;
              viewModel.setPeriod(period);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.spacingLg,
                vertical: SizeTokens.spacingSm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(SizeTokens.radiusFull),
                boxShadow: isSelected ? AppTheme.cardShadow : null,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                  width: SizeTokens.borderThin,
                ),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: SizeTokens.fontXs,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.textOnPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

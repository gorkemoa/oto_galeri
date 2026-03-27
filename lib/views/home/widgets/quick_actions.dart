import 'package:flutter/material.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/viewmodels/expense_add_view_model.dart';
import 'package:oto_galeri/viewmodels/vehicle_sale_view_model.dart';
import 'package:oto_galeri/views/expenses/expense_add_view.dart';
import 'package:oto_galeri/views/vehicle_sale/vehicle_sale_view.dart';
import 'package:oto_galeri/views/vehicles/vehicle_add_view.dart';
import 'package:provider/provider.dart';

/// QuickActions - Hızlı işlem butonları
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

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
              'HIZLI İŞLEMLER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.6,
                  ),
            ),
          ),
          Divider(height: SizeTokens.borderThin, color: AppTheme.divider),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.spacingXs,
              vertical: SizeTokens.spacingSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Araç Ekle',
                    color: AppTheme.accent,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VehicleAddView()),
                    ),
                  ),
                ),
                SizedBox(width: SizeTokens.spacingXxs),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Masraf Ekle',
                    color: AppTheme.warning,
                    onTap: () {
                      final vm = context.read<ExpenseAddViewModel>();
                      vm.reset();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            child: const ExpenseAddView(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: SizeTokens.spacingXxs),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.sell_outlined,
                    label: 'Araç Sat',
                    color: AppTheme.success,
                    onTap: () {
                      final vm = context.read<VehicleSaleViewModel>();
                      vm.reset();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            child: const VehicleSaleView(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: SizeTokens.spacingSm,
          horizontal: SizeTokens.spacingXs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.spacingSm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
              ),
              child: Icon(icon, color: color, size: SizeTokens.iconSm),
            ),
            SizedBox(height: SizeTokens.spacingXs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

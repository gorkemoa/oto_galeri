import 'package:flutter/material.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/viewmodels/reports_view_model.dart';
import 'package:oto_galeri/views/reports/widgets/expense_distribution_card.dart';
import 'package:oto_galeri/views/reports/widgets/kpi_row.dart';
import 'package:oto_galeri/views/reports/widgets/monthly_profit_chart.dart';

import 'package:oto_galeri/views/reports/widgets/vehicle_profit_list.dart';
import 'package:provider/provider.dart';

/// ReportsView - Araç bazlı kârlılık raporu ekranı
class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReportsViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raporlar',
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: SizeTokens.fontMd,
              ),
            ),
            Text(
              viewModel.selectedPeriod,
              style: TextStyle(
                color: AppTheme.textOnPrimary.withValues(alpha: 0.7),
                fontSize: SizeTokens.fontXs,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppTheme.textOnPrimary,
              size: SizeTokens.iconSm,
            ),
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
            ),
            onSelected: (period) => viewModel.setPeriod(period),
            itemBuilder: (_) => ReportsViewModel.periods.map((period) {
              final isSelected = viewModel.selectedPeriod == period;
              return PopupMenuItem<String>(
                value: period,
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: SizeTokens.iconXs,
                      color:
                          isSelected ? AppTheme.primary : AppTheme.textTertiary,
                    ),
                    SizedBox(width: SizeTokens.spacingSm),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: SizeTokens.fontSm,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(width: SizeTokens.spacingXs),
        ],
      ),
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accent))
            : viewModel.errorMessage != null
                ? _buildError(viewModel)
                : Column(
                    children: [
                      SizedBox(height: SizeTokens.spacingMd),

                      // ─── TAB SEÇİCİ ────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeTokens.spacingLg),
                        child: _TabToggle(viewModel: viewModel),
                      ),
                      SizedBox(height: SizeTokens.spacingMd),

                      // ─── İÇERİK ────────────────────────────────
                      Expanded(
                        child: RefreshIndicator(
                          color: AppTheme.accent,
                          onRefresh: viewModel.refresh,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              SizeTokens.spacingLg,
                              SizeTokens.spacingXs,
                              SizeTokens.spacingLg,
                              SizeTokens.spacing3xl,
                            ),
                            child: viewModel.selectedTab == 0
                                ? _buildOzetTab(viewModel)
                                : _buildAracBazliTab(viewModel),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  /// ─── ÖZET TABI ─────────────────────────────────────────
  Widget _buildOzetTab(ReportsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI kartları
        if (viewModel.summary != null) ...[
          KpiRow(summary: viewModel.summary!),
          SizedBox(height: SizeTokens.spacingLg),
        ],

        // Aylık kâr grafiği
        _ReportCard(
          title: 'Aylık Kâr Grafiği',
          icon: Icons.bar_chart_rounded,
          child: MonthlyProfitChart(data: viewModel.monthlyProfitData),
        ),
        SizedBox(height: SizeTokens.spacingLg),

        // Gider dağılımı
        _ReportCard(
          title: 'Gider Kategori Dağılımı',
          icon: Icons.pie_chart_outline_rounded,
          child:
              ExpenseDistributionCard(data: viewModel.expenseDistributionData),
        ),
        SizedBox(height: SizeTokens.spacingLg),

        // En kârlı & en çok masraf
        if (viewModel.summary?.mostProfitableVehicle != null ||
            viewModel.summary?.highestExpenseVehicle != null)
          _buildHighlights(viewModel),
      ],
    );
  }

  Widget _buildHighlights(ReportsViewModel viewModel) {
    return Row(
      children: [
        if (viewModel.summary?.mostProfitableVehicle != null)
          Expanded(
            child: _HighlightCard(
              label: 'En Kârlı Araç',
              value: viewModel.summary!.mostProfitableVehicle!,
              icon: Icons.emoji_events_outlined,
              color: AppTheme.success,
            ),
          ),
        if (viewModel.summary?.mostProfitableVehicle != null &&
            viewModel.summary?.highestExpenseVehicle != null)
          SizedBox(width: SizeTokens.spacingMd),
        if (viewModel.summary?.highestExpenseVehicle != null)
          Expanded(
            child: _HighlightCard(
              label: 'En Yüksek Gider',
              value: viewModel.summary!.highestExpenseVehicle!,
              icon: Icons.money_off_outlined,
              color: AppTheme.warning,
            ),
          ),
      ],
    );
  }

  /// ─── ARAÇ BAZLI TABI ───────────────────────────────────
  Widget _buildAracBazliTab(ReportsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık satırı
        Row(
          children: [
            Expanded(
              child: Text(
                '${viewModel.vehicleProfits.length} Araç',
                style: TextStyle(
                  fontSize: SizeTokens.fontSm,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (viewModel.summary != null) ...[
              _StatusCount(
                label: 'Satıldı',
                count: viewModel.summary!.soldVehicles ?? 0,
                color: AppTheme.statusSatildi,
              ),
              SizedBox(width: SizeTokens.spacingSm),
              _StatusCount(
                label: 'Stokta',
                count: viewModel.summary!.stockVehicles ?? 0,
                color: AppTheme.statusStokta,
              ),
            ],
          ],
        ),
        SizedBox(height: SizeTokens.spacingMd),

        VehicleProfitList(vehicles: viewModel.vehicleProfits),
      ],
    );
  }

  Widget _buildError(ReportsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.spacing3xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: SizeTokens.spacing5xl, color: AppTheme.error),
            SizedBox(height: SizeTokens.spacingLg),
            Text(
              viewModel.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeTokens.spacingLg),
            ElevatedButton(
              onPressed: viewModel.onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// YARDIMCI WİDGETLER
// ─────────────────────────────────────────────────────

class _TabToggle extends StatelessWidget {
  final ReportsViewModel viewModel;

  const _TabToggle({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.spacingXxs),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Özet',
              icon: Icons.dashboard_outlined,
              isSelected: viewModel.selectedTab == 0,
              onTap: () => viewModel.setTab(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Araç Bazlı',
              icon: Icons.directions_car_outlined,
              isSelected: viewModel.selectedTab == 1,
              onTap: () => viewModel.setTab(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: SizeTokens.spacingSm),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: SizeTokens.iconXs,
              color: isSelected ? AppTheme.textPrimary : AppTheme.textTertiary,
            ),
            SizedBox(width: SizeTokens.spacingXs),
            Text(
              label,
              style: TextStyle(
                fontSize: SizeTokens.fontXs,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? AppTheme.textPrimary : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
        border:
            Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(SizeTokens.spacingXs),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
                ),
                child: Icon(icon,
                    size: SizeTokens.iconXs, color: AppTheme.primary),
              ),
              SizedBox(width: SizeTokens.spacingSm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: SizeTokens.spacingLg),
          child,
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HighlightCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: SizeTokens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: SizeTokens.iconSm, color: color),
          SizedBox(width: SizeTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeTokens.fontXxs,
                    color: AppTheme.textTertiary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: SizeTokens.fontXs,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
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

class _StatusCount extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusCount({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingSm,
        vertical: SizeTokens.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SizeTokens.radiusFull),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: SizeTokens.fontXxs,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

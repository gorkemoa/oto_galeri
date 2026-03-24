import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/viewmodels/reports_view_model.dart';
import 'package:provider/provider.dart';

/// ReportsView - Raporlar ekranı (grafikler)
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
        title: const Text(
          'Raporlar',
          style: TextStyle(
            color: AppTheme.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : viewModel.errorMessage != null
              ? _buildError(viewModel)
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: viewModel.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: SizeTokens.spacingXxl),

                        // ─── AYLIK KAR GRAFİĞİ ───────────────
                        _ReportCard(
                          title: 'Aylık Kar',
                          icon: Icons.trending_up,
                          child: _buildMonthlyProfitChart(viewModel),
                        ),
                        SizedBox(height: SizeTokens.spacingLg),

                        // ─── GİDER DAĞILIMI ──────────────────
                        _ReportCard(
                          title: 'Gider Dağılımı',
                          icon: Icons.pie_chart_outline,
                          child: _buildExpenseDistribution(viewModel),
                        ),
                        SizedBox(height: SizeTokens.spacingLg),

                        // ─── EN KARLI ARAÇLAR ─────────────────
                        _ReportCard(
                          title: 'En Karlı Araçlar',
                          icon: Icons.emoji_events_outlined,
                          child: _buildRankingList(
                            viewModel.mostProfitableData,
                            'vehicle',
                            'profit',
                            AppTheme.success,
                          ),
                        ),
                        SizedBox(height: SizeTokens.spacingLg),

                        // ─── EN ÇOK MASRAF YAPILAN ────────────
                        _ReportCard(
                          title: 'En Çok Masraf Yapılan',
                          icon: Icons.money_off_outlined,
                          child: _buildRankingList(
                            viewModel.mostExpenseData,
                            'vehicle',
                            'expense',
                            AppTheme.error,
                          ),
                        ),
                        SizedBox(height: SizeTokens.spacingLg),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildMonthlyProfitChart(ReportsViewModel viewModel) {
    if (viewModel.monthlyProfitData == null) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    final maxProfit = viewModel.monthlyProfitData!.fold<double>(
      0,
      (prev, e) => (e['profit'] as double) > prev ? (e['profit'] as double) : prev,
    );

    return Column(
      children: viewModel.monthlyProfitData!.map((data) {
        final profit = data['profit'] as double;
        final ratio = maxProfit > 0 ? profit / maxProfit : 0.0;

        return Padding(
          padding: EdgeInsets.only(bottom: SizeTokens.spacingMd),
          child: Row(
            children: [
              SizedBox(
                width: SizeTokens.spacing3xl,
                child: Text(
                  data['month'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(width: SizeTokens.spacingSm),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: AppTheme.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    minHeight: SizeTokens.spacingXxl,
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spacingSm),
              Text(
                currencyFormat.format(profit),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpenseDistribution(ReportsViewModel viewModel) {
    if (viewModel.expenseDistributionData == null) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    final colors = [
      AppTheme.accent,
      AppTheme.success,
      AppTheme.warning,
      AppTheme.error,
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
    ];

    return Column(
      children: viewModel.expenseDistributionData!.asMap().entries.map((entry) {
        final data = entry.value;
        final color = colors[entry.key % colors.length];

        return Padding(
          padding: EdgeInsets.only(bottom: SizeTokens.spacingMd),
          child: Row(
            children: [
              Container(
                width: SizeTokens.spacingMd,
                height: SizeTokens.spacingMd,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
                ),
              ),
              SizedBox(width: SizeTokens.spacingSm),
              Expanded(
                child: Text(
                  data['type'] as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                currencyFormat.format(data['amount'] as double),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRankingList(
    List<Map<String, dynamic>>? data,
    String nameKey,
    String valueKey,
    Color valueColor,
  ) {
    if (data == null) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    return Column(
      children: data.asMap().entries.map((entry) {
        final item = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: SizeTokens.spacingMd),
          child: Row(
            children: [
              Container(
                width: SizeTokens.spacingXxl,
                height: SizeTokens.spacingXxl,
                decoration: BoxDecoration(
                  color: valueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
                ),
                child: Center(
                  child: Text(
                    '#${entry.key + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: valueColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spacingMd),
              Expanded(
                child: Text(
                  item[nameKey] as String,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text(
                currencyFormat.format(item[valueKey] as double),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildError(ReportsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: SizeTokens.spacing5xl, color: AppTheme.error),
          SizedBox(height: SizeTokens.spacingLg),
          Text(viewModel.errorMessage!, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: SizeTokens.spacingLg),
          ElevatedButton(onPressed: viewModel.onRetry, child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ReportCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
        border: Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: SizeTokens.iconSm, color: AppTheme.accent),
              SizedBox(width: SizeTokens.spacingSm),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          SizedBox(height: SizeTokens.spacingLg),
          child,
        ],
      ),
    );
  }
}

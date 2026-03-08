import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/viewmodels/dashboard_view_model.dart';
import 'package:provider/provider.dart';
import 'package:oto_galeri/views/home/widgets/summary_cards.dart';
import 'package:oto_galeri/views/home/widgets/recent_vehicles_list.dart';
import 'package:oto_galeri/views/home/widgets/upcoming_alerts_list.dart';
import 'package:oto_galeri/views/home/widgets/quick_actions.dart';

/// HomeView - Dashboard / Ana Sayfa
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merhaba, Görkem',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              'Fikret Auto Gallery',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textOnPrimary.withValues(alpha: 0.65),
                  ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SizeTokens.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  color: AppTheme.textOnPrimary.withValues(alpha: 0.75),
                  size: SizeTokens.iconSm,
                ),
                Text(
                  DateFormat('d MMM yyyy', 'tr_TR').format(DateTime.now()),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textOnPrimary.withValues(alpha: 0.5),
                        fontSize: SizeTokens.fontXxs,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
            : viewModel.errorMessage != null
                ? _buildError(viewModel)
                : RefreshIndicator(
                    color: AppTheme.accent,
                    onRefresh: viewModel.refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── ÖZET KARTLARI ────────────────────
                          if (viewModel.summary != null)
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                SizeTokens.spacingLg,
                                SizeTokens.spacingLg,
                                SizeTokens.spacingLg,
                                0,
                              ),
                              child: SummaryCards(summary: viewModel.summary!),
                            ),

                          // ─── HIZLI İŞLEMLER ──────────────────
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              SizeTokens.spacingLg,
                              SizeTokens.spacingMd,
                              SizeTokens.spacingLg,
                              0,
                            ),
                            child: const QuickActions(),
                          ),

                          // ─── YAKLAŞAN UYARILAR ────────────────
                          if (viewModel.upcomingAlerts != null &&
                              viewModel.upcomingAlerts!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                SizeTokens.spacingLg,
                                SizeTokens.spacingMd,
                                SizeTokens.spacingLg,
                                0,
                              ),
                              child: UpcomingAlertsList(
                                  alerts: viewModel.upcomingAlerts!),
                            ),

                          // ─── SON EKLENEN ARAÇLAR ──────────────
                          if (viewModel.recentVehicles != null &&
                              viewModel.recentVehicles!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                SizeTokens.spacingLg,
                                SizeTokens.spacingMd,
                                SizeTokens.spacingLg,
                                0,
                              ),
                              child: RecentVehiclesList(
                                  vehicles: viewModel.recentVehicles!),
                            ),

                          SizedBox(height: SizeTokens.spacing3xl),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildError(DashboardViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.spacing3xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: SizeTokens.spacing5xl,
              color: AppTheme.error,
            ),
            SizedBox(height: SizeTokens.spacingLg),
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: SizeTokens.spacingXxl),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/core/utils/vehicle_image_helper.dart';
import 'package:oto_galeri/viewmodels/vehicles_view_model.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/views/vehicles/widgets/vehicle_bottom_sheet.dart';
import 'package:oto_galeri/views/vehicles/vehicle_add_view.dart';
import 'package:provider/provider.dart';

/// VehiclesView - Araçlar listesi ekranı
class VehiclesView extends StatefulWidget {
  const VehiclesView({super.key});

  @override
  State<VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<VehiclesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiclesViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VehiclesViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Araçlar', style: TextStyle(color: AppTheme.primary),),
        backgroundColor: AppTheme.background,
        surfaceTintColor: AppTheme.background,
        actions: [
          _buildFilterIcon(context, viewModel),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddVehicle(context, viewModel),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 3,
        child: Icon(Icons.add, size: SizeTokens.iconMd),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: viewModel.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ─── ARAMA & FİLTRE CHIPS (SCROLLABLE) ──────
              SliverToBoxAdapter(child: _buildHeader(context, viewModel)),
              // ─── İÇERİK ─────────────────────────────────
              if (viewModel.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                )
              else if (viewModel.errorMessage != null)
                SliverFillRemaining(child: _buildError(viewModel))
              else if (viewModel.vehicles == null ||
                  viewModel.vehicles!.isEmpty)
                SliverFillRemaining(child: _buildEmpty())
              else ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    SizeTokens.spacingLg,
                    SizeTokens.spacingLg,
                    SizeTokens.spacingLg,
                    SizeTokens.spacing5xl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _VehicleCard(vehicle: viewModel.vehicles![index]),
                      childCount: viewModel.vehicles!.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VehiclesViewModel viewModel) {
    return Container(
      color: AppTheme.surface,
      padding: EdgeInsets.fromLTRB(
        SizeTokens.spacingLg,
        SizeTokens.spacingMd,
        SizeTokens.spacingLg,
        SizeTokens.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: viewModel.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Araç ara...',
              prefixIcon: Icon(Icons.search, size: SizeTokens.iconSm),
            ),
          ),
          SizedBox(height: SizeTokens.spacingMd),
          _buildFilterChips(viewModel),
        ],
      ),
    );
  }

  Widget _buildFilterChips(VehiclesViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Tümü',
            isSelected: viewModel.selectedStatus == null,
            onTap: () => viewModel.setStatusFilter(null),
          ),
          SizedBox(width: SizeTokens.spacingSm),
          _FilterChip(
            label: 'Stokta',
            isSelected: viewModel.selectedStatus == 'STOKTA',
            onTap: () => viewModel.setStatusFilter('STOKTA'),
          ),
          SizedBox(width: SizeTokens.spacingSm),
          _FilterChip(
            label: 'Satıldı',
            isSelected: viewModel.selectedStatus == 'SATILDI',
            onTap: () => viewModel.setStatusFilter('SATILDI'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(VehiclesViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: SizeTokens.spacing5xl, color: AppTheme.error),
          SizedBox(height: SizeTokens.spacingLg),
          Text(viewModel.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: SizeTokens.spacingLg),
          ElevatedButton(
              onPressed: viewModel.onRetry, child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined,
              size: SizeTokens.spacing5xl, color: AppTheme.textTertiary),
          SizedBox(height: SizeTokens.spacingLg),
          Text('Araç bulunamadı',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildFilterIcon(BuildContext context, VehiclesViewModel viewModel) {
    final hasFilter = viewModel.selectedStatus != null;
    return IconButton(
      icon: Badge(
        isLabelVisible: hasFilter,
        smallSize: 7,
        backgroundColor: AppTheme.primary,
        child: Icon(
          Icons.tune,
          size: SizeTokens.iconSm,
          color: hasFilter ? AppTheme.primary : AppTheme.secondary,
        ),
      ),
      onPressed: () => _showFilterPanel(context, viewModel),
    );
  }

  Future<void> _openAddVehicle(BuildContext context, VehiclesViewModel viewModel) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const VehicleAddView()),
    );
    if (added == true) {
      viewModel.refresh();
    }
  }

  void _showFilterPanel(BuildContext context, VehiclesViewModel viewModel) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Kapat',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, _, __) => Align(
        alignment: Alignment.centerRight,
        child: _FilterPanel(viewModel: viewModel),
      ),
      transitionBuilder: (ctx, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.spacingLg,
          vertical: SizeTokens.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(SizeTokens.radiusFull),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: SizeTokens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? AppTheme.textOnPrimary : AppTheme.primary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;

  const _VehicleCard({required this.vehicle});

  void _openDetail(BuildContext context) {
    showVehicleBottomSheet(context, vehicle);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    final kmFormat = NumberFormat('#,###', 'tr_TR');
    final imageUrl = vehicle.imageUrl?.isNotEmpty == true
        ? vehicle.imageUrl!
        : VehicleImageHelper.getImageUrl(vehicle.brand, vehicle.model);

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        margin: EdgeInsets.only(bottom: SizeTokens.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          border: Border.all(
            color: vehicle.isSold
                ? AppTheme.statusSatildi.withValues(alpha: 0.35)
                : AppTheme.border,
            width: SizeTokens.borderThin,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Sol: Araç Görseli ──────────────────
                SizedBox(
                  width: SizeTokens.spacing5xl * 2,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.background,
                            child: Center(
                              child: Icon(
                                Icons.directions_car_outlined,
                                color: AppTheme.textTertiary,
                                size: SizeTokens.iconXl,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (vehicle.isSold) const _SoldStamp(),
                    ],
                  ),
                ),
                // ── Sağ: Bilgiler ──────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.spacingMd,
                      vertical: SizeTokens.spacingXs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Araç adı
                        Text(
                          vehicle.fullName,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: SizeTokens.spacingXs),
                        // Yıl + KM + Yakıt
                        Text(
                          [
                            if (vehicle.year != null) '${vehicle.year}',
                            '${kmFormat.format(vehicle.kilometer ?? 0)} KM',
                            if (vehicle.fuelType != null) vehicle.fuelType!,
                          ].join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: SizeTokens.spacingXs),
                        // Fiyat satırı
                        Row(
                          children: [
                            _PriceChip(
                              label: 'Alış',
                              value: currencyFormat
                                  .format(vehicle.purchasePrice ?? 0),
                              valueColor: AppTheme.textPrimary,
                            ),
                            SizedBox(width: SizeTokens.spacingSm),
                            _PriceChip(
                              label: 'Masraf',
                              value: currencyFormat
                                  .format(vehicle.totalExpense ?? 0),
                              valueColor: (vehicle.totalExpense ?? 0) > 0
                                  ? AppTheme.error
                                  : AppTheme.textTertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _PriceChip(
      {required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$label ',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: SizeTokens.fontXxs, color: AppTheme.textTertiary),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}

/// Görselin sağ alt köşesinde çapraz "SATILDI" damgası
/// Positioned ile doğrudan sağ-alt köşeye sabitlenir; strip merkezi köşe noktasında.
class _SoldStamp extends StatelessWidget {
  const _SoldStamp();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 45,
      right: -SizeTokens.spacingXl,
      child: Transform.rotate(
        angle: -0.576, // ~-33° saat yönünde
        alignment: Alignment.center,
        child: Container(
          width: SizeTokens.spacing5xl + SizeTokens.spacing4xl,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: SizeTokens.spacingXs),
          decoration: BoxDecoration(
            color: AppTheme.statusSatildi,
            boxShadow: [
              BoxShadow(
                color: AppTheme.statusSatildi.withValues(alpha: 0.65),
                blurRadius: SizeTokens.spacingMd,
                spreadRadius: SizeTokens.borderThick,
              ),
            ],
          ),
          child: Text(
            'SATILDI',
            style: TextStyle(
              color: AppTheme.surface,
              fontSize: SizeTokens.fontXxs,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  blurRadius: SizeTokens.spacingXs,
                  offset: Offset(0, SizeTokens.borderThin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// FİLTRE PANELİ (sağdan kayarak açılır)
// ─────────────────────────────────────────────────────

class _FilterPanel extends StatefulWidget {
  final VehiclesViewModel viewModel;
  const _FilterPanel({required this.viewModel});

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.viewModel.selectedStatus;
  }

  void _applyStatus(String? value) {
    setState(() => _selectedStatus = value);
    widget.viewModel.setStatusFilter(value);
  }

  void _clearAll() {
    setState(() => _selectedStatus = null);
    widget.viewModel.setStatusFilter(null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = _selectedStatus != null;
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(SizeTokens.radiusXxl),
        bottomLeft: Radius.circular(SizeTokens.radiusXxl),
      ),
      elevation: 16,
      shadowColor: Colors.black26,
      child: SafeArea(
        left: false,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.78,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Başlık
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SizeTokens.spacingXl,
                  SizeTokens.spacingXl,
                  SizeTokens.spacingMd,
                  SizeTokens.spacingMd,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(SizeTokens.spacingXs),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(SizeTokens.radiusMd),
                      ),
                      child: Icon(Icons.tune,
                          color: AppTheme.primary, size: SizeTokens.iconSm),
                    ),
                    SizedBox(width: SizeTokens.spacingSm),
                    Expanded(
                      child: Text(
                        'Filtreler',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (hasFilter)
                      TextButton(
                        onPressed: _clearAll,
                        style: TextButton.styleFrom(
                            foregroundColor: AppTheme.error),
                        child: Text(
                          'Temizle',
                          style: TextStyle(fontSize: SizeTokens.fontXs),
                        ),
                      ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close,
                          size: SizeTokens.iconSm, color: AppTheme.secondary),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppTheme.border),
              // ─── Seçenekler
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(SizeTokens.spacingXl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Araç Durumu',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                      ),
                      SizedBox(height: SizeTokens.spacingMd),
                      _StatusOption(
                        icon: Icons.all_inclusive_rounded,
                        label: 'Tümü',
                        isSelected: _selectedStatus == null,
                        onTap: () => _applyStatus(null),
                      ),
                      SizedBox(height: SizeTokens.spacingSm),
                      _StatusOption(
                        icon: Icons.inventory_2_outlined,
                        label: 'Stokta',
                        color: AppTheme.statusStokta,
                        isSelected: _selectedStatus == 'STOKTA',
                        onTap: () => _applyStatus('STOKTA'),
                      ),
                      SizedBox(height: SizeTokens.spacingSm),
                      _StatusOption(
                        icon: Icons.sell_outlined,
                        label: 'Satıldı',
                        color: AppTheme.statusSatildi,
                        isSelected: _selectedStatus == 'SATILDI',
                        onTap: () => _applyStatus('SATILDI'),
                      ),
                    ],
                  ),
                ),
              ),
              // ─── Uygula
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SizeTokens.spacingXl,
                  0,
                  SizeTokens.spacingXl,
                  SizeTokens.spacingXl,
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Uygula'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.spacingMd,
          vertical: SizeTokens.spacingMd,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor.withValues(alpha: 0.08)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          border: Border.all(
            color: isSelected ? effectiveColor : AppTheme.border,
            width: isSelected ? 1.5 : SizeTokens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: SizeTokens.iconSm,
              color: isSelected ? effectiveColor : AppTheme.textSecondary,
            ),
            SizedBox(width: SizeTokens.spacingMd),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? effectiveColor : AppTheme.textPrimary,
                  ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: SizeTokens.iconSm,
                color: effectiveColor,
              ),
          ],
        ),
      ),
    );
  }
}

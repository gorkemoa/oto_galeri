import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/core/utils/vehicle_image_helper.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/viewmodels/vehicle_detail_view_model.dart';
import 'package:oto_galeri/views/vehicles/vehicle_detail_view.dart';
import 'package:provider/provider.dart';

/// Araç hızlı önizleme BottomSheet - tıklanınca detay gösterir.
/// Tüm detaylar için VehicleDetailView'e yönlendirir.
void showVehicleBottomSheet(BuildContext context, VehicleModel vehicle) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    enableDrag: true,
    builder: (_) => _VehicleBottomSheetContent(vehicle: vehicle),
  );
}

class _VehicleBottomSheetContent extends StatelessWidget {
  final VehicleModel vehicle;

  const _VehicleBottomSheetContent({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        final currencyFormat =
            NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
        final dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');
        final imageUrl =
            VehicleImageHelper.getLargeImageUrl(vehicle.brand, vehicle.model);

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SizeTokens.radiusXxl),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ─── SCROLLABLE BODY ──────────────────────
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(imageUrl),
                          // Content
                          Padding(
                            padding: EdgeInsets.all(SizeTokens.spacingLg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNameRow(context),
                                SizedBox(height: SizeTokens.spacingMd),
                                _buildSpecsRow(context),
                                SizedBox(height: SizeTokens.spacingLg),
                                _buildPricingSection(context, currencyFormat),
                                if (vehicle.isInStock) ...[
                                  SizedBox(height: SizeTokens.spacingLg),
                                  _buildDatesSection(context, dateFormat),
                                ],
                                if (vehicle.isSold) ...[
                                  SizedBox(height: SizeTokens.spacingLg),
                                  _buildSaleSection(context, currencyFormat, dateFormat),
                                ],
                                SizedBox(height: SizeTokens.spacingXxl),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ─── DRAG HANDLE (Görsel İçinde) ──────────────────────────
                    Positioned(
                      top: SizeTokens.spacingMd,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: SizeTokens.spacing5xl,
                          height: SizeTokens.borderThick + SizeTokens.borderThin,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(SizeTokens.radiusFull),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ─── ACTION BUTTON ────────────────────────
              _buildActionButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return Stack(
      children: [
        SizedBox(
          height: SizeTokens.spacing5xl * 3.5,
          width: double.infinity,
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
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        // Status badge
        Positioned(
          bottom: SizeTokens.spacingMd,
          left: SizeTokens.spacingMd,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.spacingMd,
              vertical: SizeTokens.spacingXs,
            ),
            decoration: BoxDecoration(
              color: vehicle.isInStock
                  ? AppTheme.statusStokta
                  : AppTheme.statusSatildi,
              borderRadius: BorderRadius.circular(SizeTokens.radiusFull),
            ),
            child: Text(
              vehicle.isInStock ? 'STOKTA' : 'SATILDI',
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeTokens.fontXxs,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        // Plate badge
        if (vehicle.plate != null)
          Positioned(
            bottom: SizeTokens.spacingMd,
            right: SizeTokens.spacingMd,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.spacingMd,
                vertical: SizeTokens.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
              ),
              child: Text(
                vehicle.plate!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeTokens.fontXxs,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vehicle.fullName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
        ),
        if (vehicle.year != null || vehicle.color != null) ...[
          SizedBox(height: SizeTokens.spacingXxs),
          Text(
            [
              if (vehicle.year != null) '${vehicle.year}',
              if (vehicle.color != null) vehicle.color!,
              if (vehicle.fuelType != null) vehicle.fuelType!,
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecsRow(BuildContext context) {
    final kmFormat = NumberFormat('#,###', 'tr_TR');
    final specs = <_SpecItem>[
      if (vehicle.kilometer != null)
        _SpecItem(
          icon: Icons.speed_outlined,
          label: '${kmFormat.format(vehicle.kilometer!)} KM',
        ),
      if (vehicle.fuelType != null)
        _SpecItem(
          icon: Icons.local_gas_station_outlined,
          label: vehicle.fuelType!,
        ),
      if (vehicle.paymentMethod != null)
        _SpecItem(
          icon: Icons.payment_outlined,
          label: vehicle.paymentMethod!,
        ),
    ];

    if (specs.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: SizeTokens.spacingSm,
      runSpacing: SizeTokens.spacingSm,
      children: specs
          .map(
            (spec) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.spacingMd,
                vertical: SizeTokens.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
                border: Border.all(
                    color: AppTheme.border, width: SizeTokens.borderThin),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(spec.icon,
                      size: SizeTokens.iconXs,
                      color: AppTheme.textSecondary),
                  SizedBox(width: SizeTokens.spacingXs),
                  Text(
                    spec.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPricingSection(
      BuildContext context, NumberFormat currencyFormat) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
        border: Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: 'Alış Fiyatı',
            value: currencyFormat.format(vehicle.purchasePrice ?? 0),
            valueColor: AppTheme.textPrimary,
          ),
          if ((vehicle.totalExpense ?? 0) > 0) ...[
            Divider(height: SizeTokens.spacingLg, color: AppTheme.divider),
            _PriceRow(
              label: 'Toplam Masraf',
              value: currencyFormat.format(vehicle.totalExpense ?? 0),
              valueColor: AppTheme.error,
            ),
          ],
          if (vehicle.isSold && vehicle.profitLoss != null) ...[
            Divider(height: SizeTokens.spacingLg, color: AppTheme.divider),
            _PriceRow(
              label: 'Net Kar / Zarar',
              value: currencyFormat.format(vehicle.profitLoss!),
              valueColor: (vehicle.profitLoss ?? 0) >= 0
                  ? AppTheme.success
                  : AppTheme.error,
              bold: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDatesSection(BuildContext context, DateFormat dateFormat) {
    final hasAnyDate = vehicle.insuranceDate != null ||
        vehicle.kaskoDate != null ||
        vehicle.inspectionDate != null;
    if (!hasAnyDate) return const SizedBox.shrink();

    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sigorta & Muayene',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: SizeTokens.spacingSm),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
            border:
                Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
          ),
          child: Column(
            children: [
              if (vehicle.insuranceDate != null)
                _DateRow(
                  icon: Icons.shield_outlined,
                  label: 'Trafik Sigortası',
                  date: vehicle.insuranceDate!,
                  dateFormat: dateFormat,
                  now: now,
                ),
              if (vehicle.kaskoDate != null) ...[
                if (vehicle.insuranceDate != null)
                  Divider(
                    height: SizeTokens.borderThin,
                    color: AppTheme.divider,
                    indent: SizeTokens.spacingLg,
                  ),
                _DateRow(
                  icon: Icons.security_outlined,
                  label: 'Kasko',
                  date: vehicle.kaskoDate!,
                  dateFormat: dateFormat,
                  now: now,
                ),
              ],
              if (vehicle.inspectionDate != null) ...[
                if (vehicle.insuranceDate != null || vehicle.kaskoDate != null)
                  Divider(
                    height: SizeTokens.borderThin,
                    color: AppTheme.divider,
                    indent: SizeTokens.spacingLg,
                  ),
                _DateRow(
                  icon: Icons.fact_check_outlined,
                  label: 'Muayene',
                  date: vehicle.inspectionDate!,
                  dateFormat: dateFormat,
                  now: now,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaleSection(
    BuildContext context,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Satış Bilgileri',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: SizeTokens.spacingSm),
        Container(
          padding: EdgeInsets.all(SizeTokens.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.statusSatildi.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
            border: Border.all(
              color: AppTheme.statusSatildi.withValues(alpha: 0.25),
              width: SizeTokens.borderThin,
            ),
          ),
          child: Column(
            children: [
              if (vehicle.salePrice != null)
                _PriceRow(
                  label: 'Satış Fiyatı',
                  value: currencyFormat.format(vehicle.salePrice!),
                  valueColor: AppTheme.statusSatildi,
                  bold: true,
                ),
              if (vehicle.customerName != null) ...[
                SizedBox(height: SizeTokens.spacingMd),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: SizeTokens.iconXs,
                        color: AppTheme.textSecondary),
                    SizedBox(width: SizeTokens.spacingXs),
                    Expanded(
                      child: Text(
                        vehicle.customerName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                    if (vehicle.customerPhone != null) ...[
                      Icon(Icons.phone_outlined,
                          size: SizeTokens.iconXs,
                          color: AppTheme.textSecondary),
                      SizedBox(width: SizeTokens.spacingXs),
                      Text(
                        vehicle.customerPhone!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ],
              if (vehicle.saleDate != null) ...[
                SizedBox(height: SizeTokens.spacingXs),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: SizeTokens.iconXs,
                        color: AppTheme.textSecondary),
                    SizedBox(width: SizeTokens.spacingXs),
                    Text(
                      dateFormat.format(vehicle.saleDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        SizeTokens.spacingLg,
        SizeTokens.spacingMd,
        SizeTokens.spacingLg,
        SizeTokens.spacingXxl,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: SizeTokens.borderThin),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: SizeTokens.buttonHeight,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.open_in_full),
          label: const Text('Tüm Detayları Görüntüle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.textOnPrimary,
          ),
          onPressed: () {
            if (vehicle.id == null) return;
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) =>
                      VehicleDetailViewModel(vehicleId: vehicle.id!),
                  child: VehicleDetailView(initialVehicle: vehicle),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// YARDIMCI WIDGET'LAR
// ─────────────────────────────────────────────────────

class _SpecItem {
  final IconData icon;
  final String label;

  const _SpecItem({required this.icon, required this.label});
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: valueColor,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime date;
  final DateFormat dateFormat;
  final DateTime now;

  const _DateRow({
    required this.icon,
    required this.label,
    required this.date,
    required this.dateFormat,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = date.difference(now).inDays;
    final isExpired = daysLeft < 0;
    final isWarning = !isExpired && daysLeft <= 30;

    final stateColor = isExpired
        ? AppTheme.error
        : isWarning
            ? AppTheme.warning
            : AppTheme.textSecondary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingLg,
        vertical: SizeTokens.spacingMd,
      ),
      child: Row(
        children: [
          Icon(icon, size: SizeTokens.iconXs, color: stateColor),
          SizedBox(width: SizeTokens.spacingMd),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            dateFormat.format(date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          SizedBox(width: SizeTokens.spacingSm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.spacingXs,
              vertical: SizeTokens.spacingXxs,
            ),
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
            ),
            child: Text(
              isExpired ? 'Geçti' : '$daysLeft gün',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: stateColor,
                    fontWeight: FontWeight.w700,
                    fontSize: SizeTokens.fontXxs,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

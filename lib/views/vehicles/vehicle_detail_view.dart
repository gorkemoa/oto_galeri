import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/core/utils/vehicle_image_helper.dart';
import 'package:oto_galeri/models/expense_model.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/viewmodels/vehicle_detail_view_model.dart';
import 'package:oto_galeri/views/vehicles/widgets/add_expense_bottom_sheet.dart';
import 'package:provider/provider.dart';

/// VehicleDetailView - Araç Detay Ekranı
class VehicleDetailView extends StatefulWidget {
  final VehicleModel initialVehicle;

  const VehicleDetailView({super.key, required this.initialVehicle});

  @override
  State<VehicleDetailView> createState() => _VehicleDetailViewState();
}

class _VehicleDetailViewState extends State<VehicleDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleDetailViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VehicleDetailViewModel>();
    final vehicle = viewModel.vehicle ?? widget.initialVehicle;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          vehicle.fullName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.background,
                fontWeight: FontWeight.w600,
              ),
          ),
        backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.textOnPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => showAddExpenseBottomSheet(context),
            icon: const Icon(Icons.add_rounded, color: AppTheme.textOnPrimary, size: 18),
            label: Text(
              'Gider Ekle',
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontWeight: FontWeight.w600,
                fontSize: SizeTokens.fontSm,
              ),
            ),
          ),
        ],
      ),
      body: viewModel.isLoading && viewModel.vehicle == null
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : viewModel.errorMessage != null && viewModel.vehicle == null
              ? _buildError(context, viewModel)
              : _buildBody(context, vehicle, viewModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    VehicleModel vehicle,
    VehicleDetailViewModel viewModel,
  ) {
    final currencyFormat =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    final dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');
    final imageUrl = vehicle.imageUrl?.isNotEmpty == true
        ? vehicle.imageUrl!
        : VehicleImageHelper.getLargeImageUrl(vehicle.brand, vehicle.model);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── ARAÇ GÖRSELİ ───────────────────────────
          _buildImage(imageUrl),

          // ─── BAŞLIK / FİYAT BÖLÜMÜ ──────────────────
          _buildHeader(context, vehicle, currencyFormat),
          SizedBox(height: SizeTokens.spacingSm),

          // ─── ARAÇ ÖZELLİKLERİ ───────────────────────
          _buildSpecsGrid(context, vehicle),
          SizedBox(height: SizeTokens.spacingSm),

          // ─── ALIŞ BİLGİLERİ ─────────────────────────
          _DetailTable(
            title: 'Alış Bilgileri',
            rows: [
              if (vehicle.purchasePrice != null)
                _FieldRow(
                  label: 'Alış Fiyatı',
                  value: currencyFormat.format(vehicle.purchasePrice),
                  bold: true,
                ),
              if (vehicle.purchaseDate != null)
                _FieldRow(
                  label: 'Alış Tarihi',
                  value: dateFormat.format(vehicle.purchaseDate!),
                ),
              if (vehicle.paymentMethod != null)
                _FieldRow(
                  label: 'Ödeme Yöntemi',
                  value: vehicle.paymentMethod!,
                ),
              if (vehicle.totalExpense != null)
                _FieldRow(
                  label: 'Toplam Masraf',
                  value: currencyFormat.format(vehicle.totalExpense),
                  valueColor: AppTheme.error,
                  bold: true,
                ),
              if (vehicle.purchasePrice != null && vehicle.totalExpense != null)
                _FieldRow(
                  label: 'Toplam Maliyet',
                  value: currencyFormat.format(
                      (vehicle.purchasePrice ?? 0) + (vehicle.totalExpense ?? 0)),
                  bold: true,
                ),
            ],
          ),
          SizedBox(height: SizeTokens.spacingSm),

          // ─── BELGELER & TARİHLER ─────────────────────
          if (vehicle.insuranceDate != null ||
              vehicle.kaskoDate != null ||
              vehicle.inspectionDate != null) ...[
            _DetailTable(
              title: 'Belgeler & Tarihler',
              rows: [
                if (vehicle.inspectionDate != null)
                  _FieldRow(
                    label: 'Muayene',
                    value: _formatDateWithCountdown(
                        vehicle.inspectionDate!, dateFormat),
                    valueColor: _dateStatus(vehicle.inspectionDate!),
                  ),
                if (vehicle.insuranceDate != null)
                  _FieldRow(
                    label: 'Sigorta',
                    value: _formatDateWithCountdown(
                        vehicle.insuranceDate!, dateFormat),
                    valueColor: _dateStatus(vehicle.insuranceDate!),
                  ),
                if (vehicle.kaskoDate != null)
                  _FieldRow(
                    label: 'Kasko',
                    value: _formatDateWithCountdown(
                        vehicle.kaskoDate!, dateFormat),
                    valueColor: _dateStatus(vehicle.kaskoDate!),
                  ),
              ],
            ),
            SizedBox(height: SizeTokens.spacingSm),
          ],

          // ─── SATIŞ BİLGİLERİ ─────────────────────────
          if (vehicle.isSold) ...[
            _DetailTable(
              title: 'Satış Bilgileri',
              rows: [
                if (vehicle.salePrice != null)
                  _FieldRow(
                    label: 'Satış Fiyatı',
                    value: currencyFormat.format(vehicle.salePrice),
                    valueColor: AppTheme.statusStokta,
                    bold: true,
                  ),
                if (vehicle.saleDate != null)
                  _FieldRow(
                    label: 'Satış Tarihi',
                    value: dateFormat.format(vehicle.saleDate!),
                  ),
                if (vehicle.salePaymentMethod != null)
                  _FieldRow(
                    label: 'Ödeme Yöntemi',
                    value: vehicle.salePaymentMethod!,
                  ),
                if (vehicle.customerName != null)
                  _FieldRow(label: 'Müşteri', value: vehicle.customerName!),
                if (vehicle.customerPhone != null)
                  _FieldRow(label: 'Telefon', value: vehicle.customerPhone!),
                if (vehicle.profitLoss != null)
                  _FieldRow(
                    label: 'Net Kar / Zarar',
                    value: currencyFormat.format(vehicle.profitLoss),
                    valueColor: (vehicle.profitLoss ?? 0) >= 0
                        ? AppTheme.statusStokta
                        : AppTheme.error,
                    bold: true,
                  ),
              ],
            ),
            SizedBox(height: SizeTokens.spacingSm),
          ],

          // ─── GİDERLER ────────────────────────────────
          _buildExpensesSection(context, viewModel, currencyFormat, dateFormat),
          SizedBox(height: SizeTokens.spacing5xl),
        ],
      ),
    );
  }

  // ─── GÖRSEL ──────────────────────────────────────────
  Widget _buildImage(String imageUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppTheme.border,
          child: Center(
            child: Icon(
              Icons.directions_car_outlined,
              size: SizeTokens.spacing5xl * 1.5,
              color: AppTheme.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── BAŞLIK / FİYAT ──────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    VehicleModel vehicle,
    NumberFormat currencyFormat,
  ) {
    final isStokta = (vehicle.status ?? 'STOKTA') == 'STOKTA';
    final statusColor = isStokta ? AppTheme.statusStokta : AppTheme.statusSatildi;
    final statusLabel = isStokta ? 'STOKTA' : 'SATILDI';

    return Container(
      color: AppTheme.surface,
      padding: EdgeInsets.all(SizeTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Durum etiketi (sadece SATILDI)
          if (!isStokta) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.spacingMd,
                vertical: SizeTokens.spacingXs,
              ),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
              ),
              child: Text(
                statusLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
            SizedBox(height: SizeTokens.spacingMd),
          ],

          // Araç adı + plaka yan yana
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    if (vehicle.year != null || vehicle.kilometer != null) ...[
                      SizedBox(height: SizeTokens.spacingXxs),
                      Text(
                        [
                          if (vehicle.year != null) '${vehicle.year}',
                          if (vehicle.kilometer != null)
                            '${NumberFormat('#,###', 'tr_TR').format(vehicle.kilometer)} KM',
                        ].join(' • '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (vehicle.plate != null) ...[
                SizedBox(width: SizeTokens.spacingMd),
                _TurkishPlate(plate: vehicle.plate!),
              ],
            ],
          ),
          SizedBox(height: SizeTokens.spacingLg),

          // Fiyat ve toplam maliyet yan yana
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alış Fiyatı',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    SizedBox(height: SizeTokens.spacingXxs),
                    Text(
                      currencyFormat.format(vehicle.purchasePrice ?? 0),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              if (vehicle.isSold && vehicle.salePrice != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Satış Fiyatı',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      SizedBox(height: SizeTokens.spacingXxs),
                      Text(
                        currencyFormat.format(vehicle.salePrice),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.statusStokta,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Net kar/zarar bandı (sadece satıldıysa)
          if (vehicle.isSold && vehicle.profitLoss != null) ...[
            SizedBox(height: SizeTokens.spacingMd),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.spacingMd,
                vertical: SizeTokens.spacingSm,
              ),
              decoration: BoxDecoration(
                color: (vehicle.profitLoss ?? 0) >= 0
                    ? AppTheme.statusStokta.withValues(alpha: 0.04)
                    : AppTheme.error.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
                border: Border.all(
                  color: (vehicle.profitLoss ?? 0) >= 0
                      ? AppTheme.statusStokta.withValues(alpha: 0.3)
                      : AppTheme.error.withValues(alpha: 0.3),
                  width: SizeTokens.borderThin,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (vehicle.profitLoss ?? 0) >= 0 ? 'Net Kâr' : 'Net Zarar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: (vehicle.profitLoss ?? 0) >= 0
                              ? AppTheme.statusStokta
                              : AppTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    currencyFormat.format(vehicle.profitLoss),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: (vehicle.profitLoss ?? 0) >= 0
                              ? AppTheme.statusStokta
                              : AppTheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── ARAÇ ÖZELLİKLERİ LİSTE ───────────────────────────
  Widget _buildSpecsGrid(BuildContext context, VehicleModel vehicle) {
    final rows = <_FieldRow>[
      if (vehicle.year != null)
        _FieldRow(label: 'Yıl', value: '${vehicle.year}'),
      if (vehicle.kilometer != null)
        _FieldRow(
          label: 'Kilometre',
          value: '${NumberFormat('#,###', 'tr_TR').format(vehicle.kilometer)} KM',
        ),
      if (vehicle.fuelType != null)
        _FieldRow(label: 'Yakıt Tipi', value: vehicle.fuelType!),
      if (vehicle.color != null)
        _FieldRow(label: 'Renk', value: vehicle.color!),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return _DetailTable(title: 'Araç Özellikleri', rows: rows);
  }

  // ─── GİDERLER (tarihe göre gruplanmış) ─────────────────
  Widget _buildExpensesSection(
    BuildContext context,
    VehicleDetailViewModel viewModel,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    if (viewModel.isLoading && viewModel.expenses == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final expenses = List<ExpenseModel>.from(viewModel.expenses ?? [])
      ..sort((a, b) =>
          (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));

    final total = expenses.fold<double>(0, (s, e) => s + (e.amount ?? 0));

    // Tarihe göre gruplama: { '2026-03-08': [expense, ...] }
    final Map<String, List<ExpenseModel>> grouped = {};
    for (final e in expenses) {
      final key = e.date != null
          ? DateFormat('yyyy-MM-dd').format(e.date!)
          : 'Tarihsiz';
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final dateKeys = grouped.keys.toList();

    return Container(
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık + toplam
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.spacingLg,
              vertical: SizeTokens.spacingMd,
            ),
            child: Row(
              children: [
                Text('Giderler',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                if (expenses.isNotEmpty)
                  Text(
                    currencyFormat.format(total),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          if (expenses.isEmpty)
            Padding(
              padding: EdgeInsets.all(SizeTokens.spacingXxl),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: SizeTokens.spacing5xl,
                        color: AppTheme.textTertiary),
                    SizedBox(height: SizeTokens.spacingMd),
                    Text(
                      'Henüz gider eklenmemiş',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dateKeys.length,
              itemBuilder: (_, gi) {
                final key = dateKeys[gi];
                final group = grouped[key]!;
                final groupDate = group.first.date;
                final groupTotal =
                    group.fold<double>(0, (s, e) => s + (e.amount ?? 0));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Tarih başlığı ──────────────────────────────
                    Container(
                      color: AppTheme.background,
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.spacingLg,
                        vertical: SizeTokens.spacingXs,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: SizeTokens.iconXs,
                            color: AppTheme.textTertiary,
                          ),
                          SizedBox(width: SizeTokens.spacingXs),
                          Text(
                            groupDate != null
                                ? DateFormat('dd MMMM yyyy', 'tr_TR')
                                    .format(groupDate)
                                : 'Tarihsiz',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            currencyFormat.format(groupTotal),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // ── O tarihin giderleri ───────────────────────
                    ...group.asMap().entries.map((entry) {
                      final isLast = entry.key == group.length - 1;
                      return Column(
                        children: [
                          _ExpenseRow(
                            expense: entry.value,
                            currencyFormat: currencyFormat,
                            dateFormat: dateFormat,
                          ),
                          if (!isLast)
                            const Divider(
                                height: 1, color: AppTheme.divider),
                        ],
                      );
                    }),
                    const Divider(height: 1, color: AppTheme.border),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, VehicleDetailViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.all(SizeTokens.spacing5xl),
      child: Column(
        children: [
          Icon(Icons.error_outline,
              size: SizeTokens.spacing5xl, color: AppTheme.error),
          SizedBox(height: SizeTokens.spacingLg),
          Text(viewModel.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: SizeTokens.spacingLg),
          ElevatedButton(
              onPressed: viewModel.onRetry,
              child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }

  String _formatDateWithCountdown(DateTime date, DateFormat fmt) {
    final diff = date.difference(DateTime.now()).inDays;
    final dateStr = fmt.format(date);
    if (diff < 0) return '$dateStr (Süresi geçmiş)';
    if (diff == 0) return '$dateStr (Bugün)';
    return '$dateStr ($diff gün kaldı)';
  }

  Color? _dateStatus(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    if (diff < 0) return AppTheme.error;
    if (diff < 30) return AppTheme.warning;
    return AppTheme.statusStokta;
  }
}

// ─────────────────────────────────────────────────────
// YARDIMCI WİDGETLER
// ─────────────────────────────────────────────────────

// ─── Tablo bölümü ─────────────────────────────────────

class _FieldRow {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _FieldRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });
}

class _DetailTable extends StatelessWidget {
  final String title;
  final List<_FieldRow> rows;

  const _DetailTable({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.spacingLg,
              vertical: SizeTokens.spacingMd,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppTheme.divider),
            itemBuilder: (_, i) {
              final row = rows[i];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.spacingLg,
                  vertical: SizeTokens.spacingMd,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: SizeTokens.spacing5xl * 2.4,
                      child: Text(
                        row.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.value,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight:
                                  row.bold ? FontWeight.w700 : FontWeight.w500,
                              color: row.valueColor ?? AppTheme.textPrimary,
                            ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Türk plakası ─────────────────────────────────────

class _TurkishPlate extends StatelessWidget {
  final String plate;

  const _TurkishPlate({required this.plate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeTokens.spacing5xl * 0.75,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
        border: Border.all(color: AppTheme.textPrimary, width: SizeTokens.borderMedium),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mavi TR şeridi
          Container(
            width: SizeTokens.spacingXxl,
            color: const Color(0xFF003DA5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TR',
                  style: TextStyle(
                    color: AppTheme.surface,
                    fontSize: SizeTokens.fontXxs,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          // Plaka numarası
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingMd),
            child: Text(
              plate,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: SizeTokens.fontMd,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gider satırı ─────────────────────────────────────

class _ExpenseRow extends StatelessWidget {
  final ExpenseModel expense;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;

  static const Map<String, IconData> _typeIcons = {
    'Noter': Icons.description_outlined,
    'Servis': Icons.build_outlined,
    'Lastik': Icons.circle_outlined,
    'Yakıt': Icons.local_gas_station_outlined,
    'Tamir': Icons.handyman_outlined,
    'Temizlik': Icons.cleaning_services_outlined,
    'Ekspertiz': Icons.search_outlined,
  };

  const _ExpenseRow({
    required this.expense,
    required this.currencyFormat,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _typeIcons[expense.type] ?? Icons.receipt_outlined;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingLg,
        vertical: SizeTokens.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeTokens.spacingXs),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
            ),
            child: Icon(icon,
                size: SizeTokens.iconSm, color: AppTheme.textSecondary),
          ),
          SizedBox(width: SizeTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.type ?? 'Gider',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                ),
                if (expense.description != null &&
                    expense.description!.isNotEmpty)
                  Text(
                    expense.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: SizeTokens.fontXxs,
                          color: AppTheme.textTertiary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(expense.amount ?? 0),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.error,
                    ),
              ),
              if (expense.date != null)
                Text(
                  dateFormat.format(expense.date!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: SizeTokens.fontXxs,
                        color: AppTheme.textTertiary,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

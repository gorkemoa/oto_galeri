import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/core/utils/vehicle_image_helper.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/viewmodels/vehicle_sale_view_model.dart';
import 'package:oto_galeri/views/vehicle_sale/widgets/sale_vehicle_selector_sheet.dart';
import 'package:provider/provider.dart';

/// VehicleSaleView - Araç Sat sayfası
class VehicleSaleView extends StatefulWidget {
  final VehicleModel? initialVehicle;

  const VehicleSaleView({super.key, this.initialVehicle});

  @override
  State<VehicleSaleView> createState() => _VehicleSaleViewState();
}

class _VehicleSaleViewState extends State<VehicleSaleView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<VehicleSaleViewModel>();
      viewModel.init().then((_) {
        if (widget.initialVehicle != null) {
          viewModel.setVehicle(widget.initialVehicle);
        }
      });
    });
  }

  Future<void> _pickDate(VehicleSaleViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: AppTheme.textOnPrimary,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) viewModel.setDate(picked);
  }

  Future<void> _onSave() async {
    final viewModel = context.read<VehicleSaleViewModel>();

    if (viewModel.selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen satılacak aracı seçin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final success = await viewModel.sellVehicle();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Araç başarıyla satıldı.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              viewModel.errorMessage ?? 'Araç satışı gerçekleştirilemedi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VehicleSaleViewModel>();
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final currencyFormat =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Araç Sat',
            style: TextStyle(
              color: AppTheme.background,
              fontSize: SizeTokens.fontMd,
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: AppTheme.primary,
        surfaceTintColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              size: SizeTokens.iconSm, color: AppTheme.background),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── İÇERİK ──────────────────────────────
            Expanded(
              child: viewModel.isLoadingVehicles
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary))
                  : viewModel.errorMessage != null &&
                          viewModel.vehicles.isEmpty
                      ? _buildError(viewModel)
                      : Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              SizeTokens.spacingLg,
                              SizeTokens.spacingMd,
                              SizeTokens.spacingLg,
                              SizeTokens.spacingMd,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Araç seçici
                                _buildVehicleSelector(viewModel),
                                SizedBox(height: SizeTokens.spacingMd),

                                // Maliyet özeti (araç seçiliyse)
                                if (viewModel.selectedVehicle != null) ...[
                                  _buildCostSummary(
                                      viewModel, currencyFormat),
                                  SizedBox(height: SizeTokens.spacingMd),
                                ],

                                // Satış fiyatı + kar/zarar
                                _buildSalePriceSection(
                                    viewModel, currencyFormat),
                                SizedBox(height: SizeTokens.spacingMd),

                                // Satış tarihi + ödeme yöntemi
                                _buildSaleDateAndPayment(
                                    viewModel, dateFormat),
                                SizedBox(height: SizeTokens.spacingMd),

                                // Vadeli detayları
                                if (viewModel.isVadeli) ...[
                                  _buildVadeliSection(
                                      viewModel, currencyFormat),
                                  SizedBox(height: SizeTokens.spacingMd),
                                ],

                                // Müşteri bilgileri
                                _buildCustomerSection(viewModel),
                                SizedBox(height: SizeTokens.spacing3xl),
                              ],
                            ),
                          ),
                        ),
            ),

            // ─── ALT KAYDET BUTONU ────────────────────
            _buildBottomBar(viewModel),
          ],
        ),
      ),
    );
  }

  // ─── ARAÇ SEÇİCİ ─────────────────────────────────────
  Widget _buildVehicleSelector(VehicleSaleViewModel viewModel) {
    final vehicle = viewModel.selectedVehicle;
    final imageUrl = vehicle != null
        ? (vehicle.imageUrl?.isNotEmpty == true
            ? vehicle.imageUrl!
            : VehicleImageHelper.getAssetPath(vehicle.brand, vehicle.model))
        : null;

    return _FormCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionLabel(label: 'Araç'),
            TextButton(
              onPressed: () => _showVehicleSelector(viewModel),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                vehicle == null ? 'Seç' : 'Değiştir',
                style: TextStyle(
                  fontSize: SizeTokens.fontXs,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accent,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeTokens.spacingSm),
        if (vehicle == null)
          GestureDetector(
            onTap: () => _showVehicleSelector(viewModel),
            child: Container(
              padding:
                  EdgeInsets.symmetric(vertical: SizeTokens.spacingXxl),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius:
                    BorderRadius.circular(SizeTokens.radiusMd),
                border: Border.all(
                    color: AppTheme.border, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.sell_outlined,
                      color: AppTheme.textTertiary,
                      size: SizeTokens.iconMd),
                  SizedBox(height: SizeTokens.spacingSm),
                  Text(
                    'Satılacak aracı seçin',
                    style: TextStyle(
                      fontSize: SizeTokens.fontSm,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Row(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(SizeTokens.radiusSm),
                child: Image.asset(
                  imageUrl!,
                  width: SizeTokens.avatarLg,
                  height: SizeTokens.avatarLg,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: SizeTokens.avatarLg,
                    height: SizeTokens.avatarLg,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius:
                          BorderRadius.circular(SizeTokens.radiusSm),
                    ),
                    child: Icon(Icons.directions_car,
                        color: AppTheme.textTertiary),
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.fullName,
                      style: TextStyle(
                        fontSize: SizeTokens.fontSm,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeTokens.spacingXxs),
                    Row(
                      children: [
                        if (vehicle.plate != null) ...[
                          _StatusTag(
                              label: vehicle.plate!,
                              color: AppTheme.textSecondary),
                          SizedBox(width: SizeTokens.spacingXs),
                        ],
                        if (vehicle.year != null)
                          _StatusTag(
                              label: '${vehicle.year}',
                              color: AppTheme.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showVehicleSelector(VehicleSaleViewModel viewModel) async {
    final selected = await showModalBottomSheet<VehicleModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaleVehicleSelectorSheet(
        vehicles: viewModel.vehicles,
        selectedVehicle: viewModel.selectedVehicle,
      ),
    );
    if (selected != null) {
      viewModel.setVehicle(selected);
    }
  }

  // ─── MALİYET ÖZETİ ───────────────────────────────────
  Widget _buildCostSummary(
      VehicleSaleViewModel viewModel, NumberFormat fmt) {
    final vehicle = viewModel.selectedVehicle!;
    final purchase = vehicle.purchasePrice ?? 0;
    final expenses = vehicle.totalExpense ?? 0;
    final total = purchase + expenses;

    return Container(
      padding: EdgeInsets.all(SizeTokens.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MALİYET ÖZETİ',
            style: TextStyle(
              fontSize: SizeTokens.fontXxs,
              fontWeight: FontWeight.w700,
              color: AppTheme.textOnPrimary.withValues(alpha: 0.6),
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: SizeTokens.spacingMd),
          Row(
            children: [
              Expanded(
                child: _CostRow(
                  label: 'Alış Fiyatı',
                  value: fmt.format(purchase),
                  icon: Icons.shopping_cart_outlined,
                ),
              ),
              Container(
                height: SizeTokens.spacing3xl,
                width: SizeTokens.borderThin,
                color: AppTheme.textOnPrimary.withValues(alpha: 0.12),
              ),
              Expanded(
                child: _CostRow(
                  label: 'Toplam Masraf',
                  value: fmt.format(expenses),
                  icon: Icons.receipt_long_outlined,
                  align: CrossAxisAlignment.center,
                ),
              ),
              Container(
                height: SizeTokens.spacing3xl,
                width: SizeTokens.borderThin,
                color: AppTheme.textOnPrimary.withValues(alpha: 0.12),
              ),
              Expanded(
                child: _CostRow(
                  label: 'Başa Baş',
                  value: fmt.format(total),
                  icon: Icons.balance_outlined,
                  align: CrossAxisAlignment.end,
                  highlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SATIŞ FİYATI ────────────────────────────────────
  Widget _buildSalePriceSection(
      VehicleSaleViewModel viewModel, NumberFormat fmt) {
    final profit = viewModel.profitLoss;
    final isProfit = (profit ?? 0) >= 0;

    return _FormCard(
      children: [
        _SectionLabel(label: 'Satış Fiyatı'),
        SizedBox(height: SizeTokens.spacingSm),
        _AppTextField(
          controller: viewModel.salePriceController,
          label: 'Satış Tutarı',
          hint: '0',
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
          ],
          prefix: Text(
            '₺',
            style: TextStyle(
              fontSize: SizeTokens.fontMd,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          onChanged: (_) => viewModel.notifyFieldChanged(),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Satış tutarı zorunludur';
            final raw = v.replaceAll('.', '').replaceAll(',', '.');
            final n = double.tryParse(raw);
            if (n == null || n <= 0) return 'Geçerli bir tutar girin';
            return null;
          },
        ),
        // Canlı kar/zarar gösterimi
        if (profit != null) ...[
          SizedBox(height: SizeTokens.spacingMd),
          _ProfitIndicator(
            profit: profit,
            isProfit: isProfit,
            formatted: fmt.format(profit.abs()),
          ),
        ],
      ],
    );
  }

  // ─── SATIŞ TARİHİ + ÖDEME YÖNTEMİ ───────────────────
  Widget _buildSaleDateAndPayment(
      VehicleSaleViewModel viewModel, DateFormat dateFormat) {
    return _FormCard(
      children: [
        _DateField(
          label: 'Satış Tarihi',
          value: viewModel.selectedDate,
          formatted: dateFormat.format(viewModel.selectedDate),
          onTap: () => _pickDate(viewModel),
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _SectionLabel(label: 'Ödeme Yöntemi'),
        SizedBox(height: SizeTokens.spacingSm),
        Wrap(
          spacing: SizeTokens.spacingSm,
          runSpacing: SizeTokens.spacingSm,
          children: VehicleSaleViewModel.paymentMethods.map((method) {
            final isSelected =
                viewModel.selectedPaymentMethod == method;
            return _PaymentChip(
              label: method,
              icon: _paymentMethodIcons[method] ?? Icons.payment_outlined,
              isSelected: isSelected,
              onTap: () => viewModel.setPaymentMethod(method),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── VADELİ DETAYLARI ────────────────────────────────
  Widget _buildVadeliSection(
      VehicleSaleViewModel viewModel, NumberFormat fmt) {
    final charge = viewModel.calculatedFinanceCharge;

    return _FormCard(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.spacingXs),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(SizeTokens.radiusSm),
              ),
              child: Icon(Icons.schedule_outlined,
                  size: SizeTokens.iconSm, color: AppTheme.warning),
            ),
            SizedBox(width: SizeTokens.spacingSm),
            Text(
              'Vade Detayları',
              style: TextStyle(
                fontSize: SizeTokens.fontSm,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeTokens.spacingMd),
        Row(
          children: [
            Expanded(
              child: _AppTextField(
                controller: viewModel.interestRateController,
                label: 'Faiz Oranı (%)',
                hint: '0,00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ],
                onChanged: (_) => viewModel.notifyFieldChanged(),
              ),
            ),
            SizedBox(width: SizeTokens.spacingMd),
            Expanded(
              child: _AppTextField(
                controller: viewModel.installmentCountController,
                label: 'Vade (Ay)',
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) => viewModel.notifyFieldChanged(),
              ),
            ),
          ],
        ),
        if (charge != null && charge > 0) ...[
          SizedBox(height: SizeTokens.spacingMd),
          Container(
            padding: EdgeInsets.all(SizeTokens.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
              border: Border.all(
                color: AppTheme.warning.withValues(alpha: 0.3),
                width: SizeTokens.borderThin,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: SizeTokens.iconSm, color: AppTheme.warning),
                SizedBox(width: SizeTokens.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vadeden Doğan Maliyet',
                        style: TextStyle(
                          fontSize: SizeTokens.fontXs,
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        fmt.format(charge),
                        style: TextStyle(
                          fontSize: SizeTokens.fontMd,
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── MÜŞTERİ BİLGİLERİ ───────────────────────────────
  Widget _buildCustomerSection(VehicleSaleViewModel viewModel) {
    return _FormCard(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.spacingXs),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(SizeTokens.radiusSm),
              ),
              child: Icon(Icons.person_outline,
                  size: SizeTokens.iconSm, color: AppTheme.primary),
            ),
            SizedBox(width: SizeTokens.spacingSm),
            Text(
              'Müşteri Bilgileri',
              style: TextStyle(
                fontSize: SizeTokens.fontSm,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(width: SizeTokens.spacingXs),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.spacingXs,
                vertical: SizeTokens.spacingXxs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius:
                    BorderRadius.circular(SizeTokens.radiusSm),
                border: Border.all(
                    color: AppTheme.border,
                    width: SizeTokens.borderThin),
              ),
              child: Text(
                'İsteğe Bağlı',
                style: TextStyle(
                  fontSize: SizeTokens.fontXxs,
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppTextField(
          controller: viewModel.customerNameController,
          label: 'Müşteri Adı Soyadı',
          hint: 'Ad Soyad',
          keyboardType: TextInputType.name,
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppTextField(
          controller: viewModel.customerPhoneController,
          label: 'Telefon Numarası',
          hint: '05XX XXX XX XX',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\s+\-()]')),
          ],
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppTextField(
          controller: viewModel.customerBalanceController,
          label: 'Kalan Bakiye',
          hint: '0',
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
          ],
          prefix: Text(
            '₺',
            style: TextStyle(
              fontSize: SizeTokens.fontMd,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── ALT BAR ─────────────────────────────────────────
  Widget _buildBottomBar(VehicleSaleViewModel viewModel) {
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
          top: BorderSide(
              color: AppTheme.border, width: SizeTokens.borderThin),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: SizeTokens.buttonHeight,
        child: ElevatedButton(
          onPressed: viewModel.isLoading ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.textOnPrimary,
            elevation: 0,
            disabledBackgroundColor:
                AppTheme.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(SizeTokens.radiusLg),
            ),
          ),
          child: viewModel.isLoading
              ? SizedBox(
                  width: SizeTokens.iconSm,
                  height: SizeTokens.iconSm,
                  child: const CircularProgressIndicator(
                    color: AppTheme.textOnPrimary,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sell_outlined,
                        size: SizeTokens.iconSm,
                        color: AppTheme.textOnPrimary),
                    SizedBox(width: SizeTokens.spacingSm),
                    Text(
                      'Satışı Tamamla',
                      style: TextStyle(
                        fontSize: SizeTokens.fontMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── HATA ─────────────────────────────────────────────
  Widget _buildError(VehicleSaleViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.all(SizeTokens.spacing5xl),
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
    );
  }
}

// ─────────────────────────────────────────────────────
// STATİK VERİLER
// ─────────────────────────────────────────────────────

const Map<String, IconData> _paymentMethodIcons = {
  'Nakit': Icons.payments_outlined,
  'Çek': Icons.receipt_outlined,
  'Vadeli': Icons.schedule_outlined,
  'Vadesiz': Icons.credit_card_outlined,
};

// ─────────────────────────────────────────────────────
// YARDIMCI WİDGETLER
// ─────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeTokens.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(
            color: AppTheme.border, width: SizeTokens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.textSecondary,
            letterSpacing: 0.6,
          ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingXs,
        vertical: SizeTokens.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
        border:
            Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: SizeTokens.fontXxs,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final CrossAxisAlignment align;
  final bool highlight;

  const _CostRow({
    required this.label,
    required this.value,
    required this.icon,
    this.align = CrossAxisAlignment.start,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingMd),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Icon(icon,
              size: SizeTokens.iconXs,
              color: AppTheme.textOnPrimary.withValues(alpha: 0.5)),
          SizedBox(height: SizeTokens.spacingXs),
          Text(
            label,
            style: TextStyle(
              fontSize: SizeTokens.fontXxs,
              color: AppTheme.textOnPrimary.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: SizeTokens.spacingXxs),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeTokens.fontXs,
              fontWeight: FontWeight.w700,
              color: highlight
                  ? AppTheme.accent
                  : AppTheme.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitIndicator extends StatelessWidget {
  final double profit;
  final bool isProfit;
  final String formatted;

  const _ProfitIndicator({
    required this.profit,
    required this.isProfit,
    required this.formatted,
  });

  @override
  Widget build(BuildContext context) {
    final color = isProfit ? AppTheme.success : AppTheme.error;
    final bgColor = isProfit
        ? AppTheme.success.withValues(alpha: 0.08)
        : AppTheme.error.withValues(alpha: 0.08);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingMd,
        vertical: SizeTokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: SizeTokens.borderThin),
      ),
      child: Row(
        children: [
          Icon(
            isProfit ? Icons.trending_up : Icons.trending_down,
            size: SizeTokens.iconSm,
            color: color,
          ),
          SizedBox(width: SizeTokens.spacingSm),
          Expanded(
            child: Text(
              isProfit ? 'Tahmini Kar' : 'Tahmini Zarar',
              style: TextStyle(
                fontSize: SizeTokens.fontXs,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${isProfit ? '+' : '-'}$formatted',
            style: TextStyle(
              fontSize: SizeTokens.fontMd,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;

  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.prefix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: SizeTokens.spacingXs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: SizeTokens.fontSm,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix != null
                ? Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.spacingMd),
                    child: prefix,
                  )
                : null,
            prefixIconConstraints: prefix != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final String formatted;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.formatted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: SizeTokens.spacingXs),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: SizeTokens.inputHeight,
            padding:
                EdgeInsets.symmetric(horizontal: SizeTokens.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
              border: Border.all(
                  color: AppTheme.border, width: SizeTokens.borderThin),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: SizeTokens.iconXs,
                    color: AppTheme.textSecondary),
                SizedBox(width: SizeTokens.spacingSm),
                Text(
                  formatted,
                  style: TextStyle(
                    fontSize: SizeTokens.fontSm,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right,
                    size: SizeTokens.iconSm,
                    color: AppTheme.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentChip({
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
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.spacingMd,
          vertical: SizeTokens.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: SizeTokens.borderMedium,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: SizeTokens.iconXs,
              color: isSelected
                  ? AppTheme.textOnPrimary
                  : AppTheme.textSecondary,
            ),
            SizedBox(width: SizeTokens.spacingXs),
            Text(
              label,
              style: TextStyle(
                fontSize: SizeTokens.fontXs,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.textOnPrimary
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/viewmodels/vehicle_add_view_model.dart';
import 'package:provider/provider.dart';

// Adım tanımları
const _kSteps = [
  _StepMeta(number: 1, label: 'Araç\nBilgileri'),
  _StepMeta(number: 2, label: 'Alış\nBilgileri'),
  _StepMeta(number: 3, label: 'Sigorta /\nMuayene'),
];

class _StepMeta {
  final int number;
  final String label;
  const _StepMeta({required this.number, required this.label});
}

/// VehicleAddView - Araç Ekle sayfası (adım adım)
class VehicleAddView extends StatefulWidget {
  const VehicleAddView({super.key});

  @override
  State<VehicleAddView> createState() => _VehicleAddViewState();
}

class _VehicleAddViewState extends State<VehicleAddView> {
  int _currentStep = 0;

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleAddViewModel>().reset();
    });
  }

  void _onNext() {
    if (!_formKeys[_currentStep].currentState!.validate()) return;
    setState(() => _currentStep++);
  }

  void _onBack() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _onSave() async {
    if (!_formKeys[_currentStep].currentState!.validate()) return;
    final viewModel = context.read<VehicleAddViewModel>();
    final success = await viewModel.addVehicle();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Araç başarıyla eklendi.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VehicleAddViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Araç Ekle', style: TextStyle(color: AppTheme.background)),
        backgroundColor: AppTheme.primary,
        surfaceTintColor: AppTheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: SizeTokens.iconSm, color: AppTheme.background),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── ADIM GÖSTERGESİ ──────────────────────
            _StepIndicator(currentStep: _currentStep, steps: _kSteps),

            // ─── İÇERİK ──────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: Form(
                  key: _formKeys[_currentStep],
                  child: SingleChildScrollView(
                    key: ValueKey(_currentStep),
                    padding: EdgeInsets.fromLTRB(
                      SizeTokens.spacingLg,
                      SizeTokens.spacingMd,
                      SizeTokens.spacingLg,
                      SizeTokens.spacingMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (viewModel.errorMessage != null)
                          _ErrorBanner(message: viewModel.errorMessage!),
                        if (_currentStep == 0) _buildVehicleInfoSection(viewModel),
                        if (_currentStep == 1) _buildPurchaseSection(viewModel),
                        if (_currentStep == 2) _buildInsuranceSection(viewModel),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── ALT BUTONLAR ─────────────────────────
            _buildBottomBar(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(VehicleAddViewModel viewModel) {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == _kSteps.length - 1;

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
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              flex: 2,
              child: SizedBox(
                height: SizeTokens.buttonHeight,
                child: OutlinedButton(
                  onPressed: viewModel.isLoading ? null : _onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(
                      color: AppTheme.border,
                      width: SizeTokens.borderThin,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
                    ),
                  ),
                  child: Text(
                    'Geri',
                    style: TextStyle(
                      fontSize: SizeTokens.fontSm,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          if (!isFirst) SizedBox(width: SizeTokens.spacingMd),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: SizeTokens.buttonHeight,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : (isLast ? _onSave : _onNext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
                  ),
                  elevation: 0,
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
                    : Text(
                        isLast ? 'Araç Kaydet' : 'İleri',
                        style: TextStyle(
                          fontSize: SizeTokens.fontMd,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ARAÇ BİLGİLERİ BÖLÜMÜ ───────────────────────────────
  Widget _buildVehicleInfoSection(VehicleAddViewModel viewModel) {
    return _FormCard(
      children: [
        // ── GÖRSEL SEÇİCİ ──────────────────────────────────
        _ImagePicker(
          imagePath: viewModel.selectedImagePath,
          onTap: viewModel.pickImage,
          onRemove: viewModel.removeImage,
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppTextField(
          controller: viewModel.brandController,
          label: 'Marka',
          hint: 'BMW, Mercedes...',
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Marka zorunludur' : null,
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppTextField(
          controller: viewModel.modelController,
          label: 'Model',
          hint: '320i, C180...',
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Model zorunludur' : null,
        ),
        SizedBox(height: SizeTokens.spacingMd),
        Row(
          children: [
            Expanded(
              child: _AppTextField(
                controller: viewModel.yearController,
                label: 'Yıl',
                hint: '2020',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Yıl zorunludur';
                  final y = int.tryParse(v.trim());
                  if (y == null || y < 1900 || y > 2100) return 'Geçerli yıl girin';
                  return null;
                },
              ),
            ),
            SizedBox(width: SizeTokens.spacingMd),
            Expanded(
              child: _AppTextField(
                controller: viewModel.kilometerController,
                label: 'KM',
                hint: '120000',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'KM zorunludur';
                  if (int.tryParse(v.trim()) == null) return 'Geçerli değer girin';
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppDropdown<String>(
          label: 'Yakıt Tipi',
          value: viewModel.fuelType,
          items: VehicleAddViewModel.fuelTypes,
          itemLabel: (e) => e,
          onChanged: viewModel.setFuelType,
          validator: (v) => v == null ? 'Yakıt tipi seçiniz' : null,
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppTextField(
          controller: viewModel.colorController,
          label: 'Renk',
          hint: 'Beyaz, Siyah...',
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppTextField(
          controller: viewModel.plateController,
          label: 'Plaka',
          hint: '34 ABC 123',
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }

  // ─── ALIŞ BİLGİLERİ BÖLÜMÜ ───────────────────────────
  Widget _buildPurchaseSection(VehicleAddViewModel viewModel) {
    final bool showFinanceFields =
        viewModel.paymentMethod == 'Çek' || viewModel.paymentMethod == 'Vadeli';
    final bool showInstallmentCount = viewModel.paymentMethod == 'Vadeli';

    return _FormCard(
      children: [
        _AppTextField(
          controller: viewModel.purchasePriceController,
          label: 'Alış Fiyatı (₺)',
          hint: '1200000',
          keyboardType: TextInputType.number,
          onChanged: (_) => viewModel.calculateFinanceCharge(),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Alış fiyatı zorunludur';
            final cleaned = v.trim().replaceAll('.', '').replaceAll(',', '.');
            if (double.tryParse(cleaned) == null) return 'Geçerli fiyat girin';
            return null;
          },
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppDateField(
          label: 'Alış Tarihi',
          value: viewModel.purchaseDate,
          onTap: () => _pickDate(context, viewModel.purchaseDate, viewModel.setPurchaseDate),
          validator: (_) => viewModel.purchaseDate == null ? 'Alış tarihi zorunludur' : null,
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppDropdown<String>(
          label: 'Ödeme Yöntemi',
          value: viewModel.paymentMethod,
          items: VehicleAddViewModel.paymentMethods,
          itemLabel: (e) => e,
          onChanged: viewModel.setPaymentMethod,
          validator: (v) => v == null ? 'Ödeme yöntemi seçiniz' : null,
        ),
        // DEMO: Çek veya Vadeli seçildiğinde görünür – Nakit'te gizli
        if (showFinanceFields) ...[
          SizedBox(height: SizeTokens.spacingMd),
          _AppTextField(
            controller: viewModel.interestRateController,
            label: 'Faiz / Vade Farkı Oranı (%)',
            hint: '2.5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => viewModel.calculateFinanceCharge(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Faiz oranı zorunludur';
              if (double.tryParse(v.trim().replaceAll(',', '.')) == null) {
                return 'Geçerli oran girin';
              }
              return null;
            },
          ),
          if (showInstallmentCount) ...[
            SizedBox(height: SizeTokens.spacingMd),
            _AppTextField(
              controller: viewModel.installmentCountController,
              label: 'Vade Süresi (Ay)',
              hint: '12',
              keyboardType: TextInputType.number,
              onChanged: (_) => viewModel.calculateFinanceCharge(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vade süresi zorunludur';
                final m = int.tryParse(v.trim());
                if (m == null || m <= 0) return 'Geçerli vade süresi girin';
                return null;
              },
            ),
          ],
          if (viewModel.financeChargeAmount != null) ...[
            SizedBox(height: SizeTokens.spacingMd),
            _FinanceChargeSummary(amount: viewModel.financeChargeAmount!),
          ],
        ],
      ],
    );
  }

  // ─── SİGORTA BÖLÜMÜ ──────────────────────────────────
  Widget _buildInsuranceSection(VehicleAddViewModel viewModel) {
    return _FormCard(
      children: [
        _AppDateField(
          label: 'Sigorta Bitiş Tarihi',
          value: viewModel.insuranceDate,
          onTap: () => _pickDate(context, viewModel.insuranceDate, viewModel.setInsuranceDate),
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppDateField(
          label: 'Kasko Bitiş Tarihi',
          value: viewModel.kaskoDate,
          onTap: () => _pickDate(context, viewModel.kaskoDate, viewModel.setKaskoDate),
        ),
        SizedBox(height: SizeTokens.spacingMd),
        _AppDateField(
          label: 'Muayene Bitiş Tarihi',
          value: viewModel.inspectionDate,
          onTap: () => _pickDate(context, viewModel.inspectionDate, viewModel.setInspectionDate),
        ),
      ],
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    DateTime? initialDate,
    void Function(DateTime?) onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }
}

// ─── ADIM GÖSTERGESİ ─────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<_StepMeta> steps;

  const _StepIndicator({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: EdgeInsets.symmetric(
        vertical: SizeTokens.spacingMd,
        horizontal: SizeTokens.spacingLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final isDone = currentStep > stepIndex;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: SizeTokens.spacing3xl / 2),
                child: Container(
                  height: SizeTokens.borderMedium,
                  color: isDone ? AppTheme.primary : AppTheme.border,
                ),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final meta = steps[stepIndex];
          return _StepDot(
            number: meta.number,
            label: meta.label,
            isDone: currentStep > stepIndex,
            isCurrent: currentStep == stepIndex,
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int number;
  final String label;
  final bool isDone;
  final bool isCurrent;

  const _StepDot({
    required this.number,
    required this.label,
    required this.isDone,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor;
    final Color circleText;
    final Color borderColor;

    if (isDone || isCurrent) {
      circleColor = AppTheme.primary;
      circleText = AppTheme.textOnPrimary;
      borderColor = AppTheme.primary;
    } else {
      circleColor = AppTheme.surface;
      circleText = AppTheme.textTertiary;
      borderColor = AppTheme.border;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: SizeTokens.spacing3xl,
          height: SizeTokens.spacing3xl,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: SizeTokens.borderMedium),
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check, size: SizeTokens.iconXs, color: circleText)
                : Text(
                    '$number',
                    style: TextStyle(
                      fontSize: SizeTokens.fontXs,
                      fontWeight: FontWeight.w700,
                      color: circleText,
                    ),
                  ),
          ),
        ),
        SizedBox(height: SizeTokens.spacingXxs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SizeTokens.fontXxs,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            color: isCurrent ? AppTheme.primary : AppTheme.textTertiary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// ─── FORM KARTI ────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

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
        children: children,
      ),
    );
  }
}

// ─── METİN ALANI ───────────────────────────────────────
class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;

  const _AppTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.validator,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: SizeTokens.spacingXs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ),
      ],
    );
  }
}

// ─── DROPDOWN ALANI ────────────────────────────────────
class _AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const _AppDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: SizeTokens.spacingXs),
        DropdownButtonFormField<T>(
          value: value,
          validator: validator,
          decoration: const InputDecoration(),
          icon: Icon(Icons.keyboard_arrow_down, size: 20, color: AppTheme.textSecondary),
          dropdownColor: AppTheme.surface,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    itemLabel(e),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          hint: Text(
            'Seçiniz',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ),
      ],
    );
  }
}

// ─── TARİH SEÇİCİ ALANI ────────────────────────────────
class _AppDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  const _AppDateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final formatted =
        value != null ? DateFormat('dd.MM.yyyy').format(value!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: SizeTokens.spacingXs),
        TextFormField(
          readOnly: true,
          onTap: onTap,
          validator: validator,
          controller: TextEditingController(text: formatted ?? ''),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
          decoration: InputDecoration(
            hintText: 'Tarih seçiniz',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              size: SizeTokens.iconSm,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── GÖRSEL SEÇİCİ ─────────────────────────────────────
class _ImagePicker extends StatelessWidget {
  final String? imagePath;
  final Future<void> Function() onTap;
  final VoidCallback onRemove;

  const _ImagePicker({
    required this.imagePath,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Araç Görseli',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: SizeTokens.spacingXs),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: SizeTokens.cardImageWidth * 1.4,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
              border: Border.all(
                color: AppTheme.border,
                width: SizeTokens.borderThin,
              ),
            ),
            child: imagePath != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
                        child: Image.file(
                          File(imagePath!),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // ── Kaldır butonu ──
                      Positioned(
                        top: SizeTokens.spacingXs,
                        right: SizeTokens.spacingXs,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: EdgeInsets.all(SizeTokens.spacingXs),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.75),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: SizeTokens.iconXs,
                              color: AppTheme.textOnPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: SizeTokens.iconXl,
                        color: AppTheme.textTertiary,
                      ),
                      SizedBox(height: SizeTokens.spacingXs),
                      Text(
                        'Fotoğraf Ekle',
                        style: TextStyle(
                          fontSize: SizeTokens.fontSm,
                          color: AppTheme.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: SizeTokens.spacingXxs),
                      Text(
                        'Galeriden seç',
                        style: TextStyle(
                          fontSize: SizeTokens.fontXxs,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ─── HATA MESAJI BANNER ────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.spacingMd),
      padding: EdgeInsets.all(SizeTokens.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(
          color: AppTheme.error.withValues(alpha: 0.3),
          width: SizeTokens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.error, size: SizeTokens.iconSm),
          SizedBox(width: SizeTokens.spacingSm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DEMO: VADE FARKI ÖZET KARTI ─────────────────────────
// Geçici demo bileşeni – backend hazır olduğunda bu hesap API'den dönecek
class _FinanceChargeSummary extends StatelessWidget {
  final double amount;
  const _FinanceChargeSummary({required this.amount});

  @override
  Widget build(BuildContext context) {
    final isCost = amount >= 0;
    final color = isCost ? AppTheme.error : AppTheme.statusStokta;
    final label = isCost ? 'Vadeden Doğan Masraf' : 'Vadeden Doğan Kazanç';
    final icon = isCost ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final formatted = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    ).format(amount.abs());

    return Container(
      padding: EdgeInsets.all(SizeTokens.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: SizeTokens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: SizeTokens.iconSm),
          SizedBox(width: SizeTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: SizeTokens.spacingXxs),
                Text(
                  'Hesaplanan tutar',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
          Text(
            formatted,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

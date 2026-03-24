import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/core/utils/vehicle_image_helper.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/viewmodels/expense_add_view_model.dart';
import 'package:oto_galeri/viewmodels/vehicle_detail_view_model.dart';
import 'package:oto_galeri/views/expenses/widgets/vehicle_selector_sheet.dart';
import 'package:oto_galeri/views/vehicles/vehicle_detail_view.dart';
import 'package:provider/provider.dart';

/// ExpenseAddView - Masraf Ekle sayfası
class ExpenseAddView extends StatefulWidget {
  final VehicleModel? initialVehicle;

  const ExpenseAddView({super.key, this.initialVehicle});

  @override
  State<ExpenseAddView> createState() => _ExpenseAddViewState();
}

class _ExpenseAddViewState extends State<ExpenseAddView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ExpenseAddViewModel>();
      viewModel.init().then((_) {
        if (widget.initialVehicle != null) {
          viewModel.setVehicle(widget.initialVehicle);
        }
      });
    });
  }

  Future<void> _pickDate(ExpenseAddViewModel viewModel) async {
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
    final viewModel = context.read<ExpenseAddViewModel>();

    if (viewModel.selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir araç seçin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final success = await viewModel.addExpense();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Masraf başarıyla eklendi.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Masraf eklenemedi, tekrar deneyin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseAddViewModel>();
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Masraf Ekle', style: TextStyle(color: AppTheme.background)),
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
                      child: CircularProgressIndicator(color: AppTheme.primary))
                  : viewModel.errorMessage != null && viewModel.vehicles.isEmpty
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
                                // Masraf tipi
                                _buildTypeSelector(viewModel),
                                SizedBox(height: SizeTokens.spacingMd),
                                // Tutar + Tarih
                                _FormCard(
                                  children: [
                                    _AppTextField(
                                      controller: viewModel.amountController,
                                      label: 'Tutar',
                                      hint: '0',
                                      keyboardType: const TextInputType.numberWithOptions(
                                          decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[\d,.]')),
                                      ],
                                      prefix: Text(
                                        '₺',
                                        style: TextStyle(
                                          fontSize: SizeTokens.fontMd,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Tutar zorunludur';
                                        }
                                        final raw = v
                                            .replaceAll('.', '')
                                            .replaceAll(',', '.');
                                        final n = double.tryParse(raw);
                                        if (n == null || n <= 0) {
                                          return 'Geçerli bir tutar girin';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: SizeTokens.spacingMd),
                                    _DateField(
                                      label: 'Tarih',
                                      value: viewModel.selectedDate,
                                      formatted: dateFormat
                                          .format(viewModel.selectedDate),
                                      onTap: () => _pickDate(viewModel),
                                    ),
                                  ],
                                ),
                                SizedBox(height: SizeTokens.spacingMd),
                                // Açıklama
                                _FormCard(
                                  children: [
                                    _AppTextField(
                                      controller: viewModel.descriptionController,
                                      label: 'Açıklama',
                                      hint: 'İsteğe bağlı not ekleyin...',
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
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
  Widget _buildVehicleSelector(ExpenseAddViewModel viewModel) {
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
              padding: EdgeInsets.symmetric(vertical: SizeTokens.spacingXxl),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
                border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_circle_outline, color: AppTheme.textTertiary, size: SizeTokens.iconMd),
                  SizedBox(height: SizeTokens.spacingSm),
                  Text(
                    'Lütfen bir araç seçin',
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
                borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
                child: Image.asset(
                  imageUrl!,
                  width: SizeTokens.avatarMd,
                  height: SizeTokens.avatarMd,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: SizeTokens.avatarMd,
                    height: SizeTokens.avatarMd,
                    color: AppTheme.background,
                    child: Icon(Icons.directions_car, color: AppTheme.textTertiary),
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
                    if (vehicle.plate != null)
                      Text(
                        vehicle.plate!,
                        style: TextStyle(
                          fontSize: SizeTokens.fontXs,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) =>
                            VehicleDetailViewModel(vehicleId: vehicle.id ?? 0),
                        child: VehicleDetailView(initialVehicle: vehicle),
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingSm, vertical: SizeTokens.spacingXs),
                ),
                child: Text(
                  'Detayına Git',
                  style: TextStyle(
                    fontSize: SizeTokens.fontXs,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showVehicleSelector(ExpenseAddViewModel viewModel) async {
    final selected = await showModalBottomSheet<VehicleModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VehicleSelectorSheet(
        vehicles: viewModel.vehicles,
        selectedVehicle: viewModel.selectedVehicle,
      ),
    );
    if (selected != null) {
      viewModel.setVehicle(selected);
    }
  }

  // ─── MASRAF TİPİ SEÇİCİ ──────────────────────────────
  Widget _buildTypeSelector(ExpenseAddViewModel viewModel) {
    return _FormCard(
      children: [
        _SectionLabel(label: 'Masraf Türü'),
        SizedBox(height: SizeTokens.spacingSm),
        Wrap(
          spacing: SizeTokens.spacingSm,
          runSpacing: SizeTokens.spacingSm,
          children: ExpenseAddViewModel.expenseTypes.map((type) {
            final isSelected = viewModel.selectedType == type;
            return _TypeChip(
              label: type,
              icon: _expenseTypeIcons[type] ?? Icons.receipt_outlined,
              color: _expenseTypeColors[type] ?? AppTheme.textSecondary,
              isSelected: isSelected,
              onTap: () => viewModel.setType(type),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── ALT BAR ─────────────────────────────────────────
  Widget _buildBottomBar(ExpenseAddViewModel viewModel) {
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
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
              : Text(
                  'Masraf Kaydet',
                  style: TextStyle(
                    fontSize: SizeTokens.fontMd,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // ─── HATA ─────────────────────────────────────────────
  Widget _buildError(ExpenseAddViewModel viewModel) {
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

const Map<String, IconData> _expenseTypeIcons = {
  'Servis': Icons.build_outlined,
  'Tamir': Icons.handyman_outlined,
  'Lastik': Icons.tire_repair_outlined,
  'Yakıt': Icons.local_gas_station_outlined,
  'Noter': Icons.description_outlined,
  'Temizlik': Icons.cleaning_services_outlined,
  'Ekspertiz': Icons.search_outlined,
  'Diğer': Icons.receipt_outlined,
};

const Map<String, Color> _expenseTypeColors = {
  'Servis': AppTheme.accent,
  'Tamir': AppTheme.error,
  'Lastik': AppTheme.warning,
  'Yakıt': Color(0xFF10B981),
  'Noter': AppTheme.textSecondary,
  'Temizlik': Color(0xFF8B5CF6),
  'Ekspertiz': AppTheme.secondary,
  'Diğer': AppTheme.textSecondary,
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
        border: Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
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

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLines;
  final Widget? prefix;

  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.prefix,
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
          maxLines: maxLines,
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
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
              border: Border.all(
                  color: AppTheme.border, width: SizeTokens.borderThin),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: SizeTokens.iconXs, color: AppTheme.textSecondary),
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
                    size: SizeTokens.iconSm, color: AppTheme.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.spacingMd,
          vertical: SizeTokens.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppTheme.background,
          borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
          border: Border.all(
            color: isSelected ? color : AppTheme.border,
            width: isSelected ? SizeTokens.borderMedium : SizeTokens.borderThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: SizeTokens.iconXs,
                color: isSelected ? color : AppTheme.textSecondary),
            SizedBox(width: SizeTokens.spacingXs),
            Text(
              label,
              style: TextStyle(
                fontSize: SizeTokens.fontXs,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


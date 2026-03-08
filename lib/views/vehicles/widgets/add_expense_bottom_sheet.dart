import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/viewmodels/vehicle_detail_view_model.dart';
import 'package:provider/provider.dart';

/// Araç detay ekranından gider eklemek için bottom sheet.
void showAddExpenseBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    enableDrag: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<VehicleDetailViewModel>(),
      child: const _AddExpenseSheet(),
    ),
  );
}

// ────────────────────────────────────────────────────────────────────────────

class _AddExpenseSheet extends StatefulWidget {
  const _AddExpenseSheet();

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  static const _types = [
    'Servis',
    'Tamir',
    'Lastik',
    'Yakıt',
    'Noter',
    'Temizlik',
    'Ekspertiz',
    'Diğer',
  ];

  static const Map<String, IconData> _typeIcons = {
    'Servis': Icons.build_outlined,
    'Tamir': Icons.handyman_outlined,
    'Lastik': Icons.tire_repair_outlined,
    'Yakıt': Icons.local_gas_station_outlined,
    'Noter': Icons.description_outlined,
    'Temizlik': Icons.cleaning_services_outlined,
    'Ekspertiz': Icons.search_outlined,
    'Diğer': Icons.receipt_outlined,
  };

  static const Map<String, Color> _typeColors = {
    'Servis': AppTheme.accent,
    'Tamir': AppTheme.error,
    'Lastik': AppTheme.warning,
    'Yakıt': Color(0xFF10B981),
    'Noter': AppTheme.textSecondary,
    'Temizlik': Color(0xFF8B5CF6),
    'Ekspertiz': AppTheme.secondary,
    'Diğer': AppTheme.textSecondary,
  };

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedType = 'Servis';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.accent,
            onPrimary: Colors.white,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final raw = _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir tutar girin.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final vm = context.read<VehicleDetailViewModel>();
    final success = await vm.addExpense(
      type: _selectedType,
      amount: amount,
      date: _selectedDate,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gider eklendi.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gider eklenemedi, tekrar deneyin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeTokens.radiusXxl),
              ),
            ),
            child: Column(
              children: [
                // ─── DRAG HANDLE ────────────────────────
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: SizeTokens.spacingMd),
                    width: SizeTokens.spacing5xl,
                    height: SizeTokens.borderThick + SizeTokens.borderThin,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius:
                          BorderRadius.circular(SizeTokens.radiusFull),
                    ),
                  ),
                ),
                SizedBox(height: SizeTokens.spacingMd),

                // ─── BAŞLIK ─────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingLg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Gider Ekle',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.border),

                // ─── FORM ───────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(SizeTokens.spacingLg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gider Türü
                          _SectionLabel(label: 'Gider Türü'),
                          SizedBox(height: SizeTokens.spacingSm),
                          _TypeSelector(
                            types: _types,
                            icons: _typeIcons,
                            colors: _typeColors,
                            selected: _selectedType,
                            onChanged: (t) => setState(() => _selectedType = t),
                          ),

                          SizedBox(height: SizeTokens.spacingXxl),

                          // Tutar
                          _SectionLabel(label: 'Tutar (₺)'),
                          SizedBox(height: SizeTokens.spacingSm),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9,.]')),
                            ],
                            decoration: _inputDecoration(
                              hint: '0',
                              prefix: const Text('₺ '),
                            ),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.error,
                                ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Tutar zorunlu';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: SizeTokens.spacingXxl),

                          // Tarih
                          _SectionLabel(label: 'Tarih'),
                          SizedBox(height: SizeTokens.spacingSm),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius:
                                BorderRadius.circular(SizeTokens.radiusMd),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeTokens.spacingMd,
                                vertical: SizeTokens.spacingMd,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppTheme.border,
                                    width: SizeTokens.borderThin),
                                borderRadius:
                                    BorderRadius.circular(SizeTokens.radiusMd),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: SizeTokens.iconSm,
                                      color: AppTheme.accent),
                                  SizedBox(width: SizeTokens.spacingMd),
                                  Text(
                                    dateFormat.format(_selectedDate),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
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

                          SizedBox(height: SizeTokens.spacingXxl),

                          // Açıklama (opsiyonel)
                          _SectionLabel(label: 'Açıklama (opsiyonel)'),
                          SizedBox(height: SizeTokens.spacingSm),
                          TextFormField(
                            controller: _descController,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            decoration: _inputDecoration(
                              hint: 'Örn: Ön fren balataları değiştirildi...',
                            ),
                          ),

                          SizedBox(height: SizeTokens.spacing5xl),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── KAYDET BUTONU ───────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    SizeTokens.spacingLg,
                    SizeTokens.spacingSm,
                    SizeTokens.spacingLg,
                    SizeTokens.spacingXxl,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? SizedBox(
                              width: SizeTokens.spacingLg,
                              height: SizeTokens.spacingLg,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(_isSaving ? 'Kaydediliyor...' : 'Gideri Kaydet'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefix != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingMd),
              child: prefix,
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: AppTheme.background,
      contentPadding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingMd,
        vertical: SizeTokens.spacingMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        borderSide: BorderSide(
            color: AppTheme.border, width: SizeTokens.borderThin),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        borderSide: BorderSide(
            color: AppTheme.border, width: SizeTokens.borderThin),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        borderSide: BorderSide(
            color: AppTheme.error, width: SizeTokens.borderThin),
      ),
    );
  }
}

// ─── Bölüm etiketi ────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
    );
  }
}

// ─── Tür seçici ───────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final List<String> types;
  final Map<String, IconData> icons;
  final Map<String, Color> colors;
  final String selected;
  final ValueChanged<String> onChanged;

  const _TypeSelector({
    required this.types,
    required this.icons,
    required this.colors,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SizeTokens.spacingSm,
      runSpacing: SizeTokens.spacingSm,
      children: types.map((type) {
        final isSelected = type == selected;
        final color = colors[type] ?? AppTheme.textSecondary;
        final icon = icons[type] ?? Icons.receipt_outlined;

        return GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.spacingMd,
              vertical: SizeTokens.spacingSm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.12)
                  : AppTheme.background,
              borderRadius: BorderRadius.circular(SizeTokens.radiusFull),
              border: Border.all(
                color: isSelected ? color : AppTheme.border,
                width: isSelected
                    ? SizeTokens.borderMedium
                    : SizeTokens.borderThin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: SizeTokens.iconXs,
                    color: isSelected ? color : AppTheme.textTertiary),
                SizedBox(width: SizeTokens.spacingXxs),
                Text(
                  type,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected ? color : AppTheme.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/services/vehicle_usage_service.dart';
import 'package:oto_galeri/viewmodels/vehicle_detail_view_model.dart';
import 'package:provider/provider.dart';

/// Araç kullanım kaydı eklemek için bottom sheet.
void showAddUsageBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    enableDrag: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<VehicleDetailViewModel>(),
      child: const _AddUsageSheet(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _AddUsageSheet extends StatefulWidget {
  const _AddUsageSheet();

  @override
  State<_AddUsageSheet> createState() => _AddUsageSheetState();
}

class _AddUsageSheetState extends State<_AddUsageSheet> {
  static const _otherStaff = 'Diğer (Manuel Giriş)';

  final _formKey = GlobalKey<FormState>();
  final _manualStaffController = TextEditingController();
  final _startKmController = TextEditingController();
  final _endKmController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedStaff = VehicleUsageService.mockStaffList.first;
  bool _isManualStaff = false;
  DateTime _selectedDate = DateTime.now();
  bool _hasExpense = false;
  String _expenseType = VehicleUsageService.usageExpenseTypes.first;
  bool _isSaving = false;

  @override
  void dispose() {
    _manualStaffController.dispose();
    _startKmController.dispose();
    _endKmController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final staff = _isManualStaff
        ? _manualStaffController.text.trim()
        : (_selectedStaff ?? '');

    final startKm = _startKmController.text.trim().isEmpty
        ? null
        : int.tryParse(_startKmController.text.trim());
    final endKm = _endKmController.text.trim().isEmpty
        ? null
        : int.tryParse(_endKmController.text.trim());

    double? expenseAmount;
    if (_hasExpense) {
      final raw =
          _amountController.text.replaceAll('.', '').replaceAll(',', '.');
      expenseAmount = double.tryParse(raw);
    }

    setState(() => _isSaving = true);

    final vm = context.read<VehicleDetailViewModel>();
    final success = await vm.addUsage(
      date: _selectedDate,
      staffName: staff,
      startKm: startKm,
      endKm: endKm,
      expenseType: _hasExpense ? _expenseType : null,
      expenseAmount: expenseAmount,
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
          content: const Text('Kullanım kaydı eklendi.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt eklenemedi, tekrar deneyin.'),
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
        initialChildSize: 0.82,
        minChildSize: 0.55,
        maxChildSize: 0.97,
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
                // ─── DRAG HANDLE ─────────────────────────────────────
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

                // ─── BAŞLIK ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.spacingLg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Kullanım Kaydı Ekle',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: AppTheme.textSecondary,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.border),

                // ─── FORM ────────────────────────────────────────────
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(SizeTokens.spacingLg),
                      children: [
                        // ── Personel seçimi ──────────────────────────
                        _SectionLabel(
                          icon: Icons.person_outline,
                          label: 'Kullanan Personel',
                        ),
                        SizedBox(height: SizeTokens.spacingXs),
                        DropdownButtonFormField<String>(
                          value: _isManualStaff ? _otherStaff : _selectedStaff,
                          decoration: const InputDecoration(),
                          icon: Icon(Icons.keyboard_arrow_down,
                              size: 20, color: AppTheme.textSecondary),
                          dropdownColor: AppTheme.surface,
                          items: [
                            ...VehicleUsageService.mockStaffList.map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: AppTheme.textPrimary)),
                              ),
                            ),
                            DropdownMenuItem(
                              value: _otherStaff,
                              child: Text(_otherStaff,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontStyle: FontStyle.italic)),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _isManualStaff = v == _otherStaff;
                              if (!_isManualStaff) _selectedStaff = v;
                            });
                          },
                          validator: (v) =>
                              v == null ? 'Personel seçiniz' : null,
                        ),
                        if (_isManualStaff) ...[
                          SizedBox(height: SizeTokens.spacingMd),
                          TextFormField(
                            controller: _manualStaffController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'Personel adı girin',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppTheme.textTertiary),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Personel adı zorunludur'
                                    : null,
                          ),
                        ],
                        SizedBox(height: SizeTokens.spacingLg),

                        // ── Tarih ────────────────────────────────────
                        _SectionLabel(
                          icon: Icons.calendar_today_outlined,
                          label: 'Kullanım Tarihi',
                        ),
                        SizedBox(height: SizeTokens.spacingXs),
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                  text: dateFormat.format(_selectedDate)),
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  size: SizeTokens.iconSm,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: SizeTokens.spacingLg),

                        // ── KM Bilgisi ───────────────────────────────
                        _SectionLabel(
                          icon: Icons.speed_outlined,
                          label: 'KM Bilgisi',
                          sublabel: '(İsteğe bağlı)',
                        ),
                        SizedBox(height: SizeTokens.spacingXs),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _startKmController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Başlangıç KM',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppTheme.textTertiary),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return null;
                                  if (int.tryParse(v) == null) {
                                    return 'Geçersiz';
                                  }
                                  return null;
                                },
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: SizeTokens.spacingMd),
                              child: Icon(
                                Icons.arrow_forward,
                                size: SizeTokens.iconSm,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _endKmController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Bitiş KM',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppTheme.textTertiary),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return null;
                                  final end = int.tryParse(v);
                                  if (end == null) return 'Geçersiz';
                                  final start = int.tryParse(
                                      _startKmController.text);
                                  if (start != null && end <= start) {
                                    return 'Başlangıçtan büyük olmalı';
                                  }
                                  return null;
                                },
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        // Kullanılan km özet bandı
                        _buildKmSummary(),
                        SizedBox(height: SizeTokens.spacingLg),

                        // ── Gider ────────────────────────────────────
                        _SectionLabel(
                          icon: Icons.receipt_long_outlined,
                          label: 'Gider',
                          trailing: Switch(
                            value: _hasExpense,
                            onChanged: (v) =>
                                setState(() => _hasExpense = v),
                            activeColor: AppTheme.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        if (_hasExpense) ...[
                          SizedBox(height: SizeTokens.spacingXs),
                          // Gider türü
                          DropdownButtonFormField<String>(
                            value: _expenseType,
                            decoration: const InputDecoration(),
                            icon: Icon(Icons.keyboard_arrow_down,
                                size: 20, color: AppTheme.textSecondary),
                            dropdownColor: AppTheme.surface,
                            items: VehicleUsageService.usageExpenseTypes
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color:
                                                      AppTheme.textPrimary)),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _expenseType = v!),
                            validator: (v) =>
                                _hasExpense && v == null
                                    ? 'Gider türü seçiniz'
                                    : null,
                          ),
                          SizedBox(height: SizeTokens.spacingMd),
                          // Tutar
                          TextFormField(
                            controller: _amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Tutar (₺)',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppTheme.textTertiary),
                            ),
                            validator: (v) {
                              if (!_hasExpense) return null;
                              if (v == null || v.trim().isEmpty) {
                                return 'Tutar zorunludur';
                              }
                              final cleaned = v
                                  .replaceAll('.', '')
                                  .replaceAll(',', '.');
                              if (double.tryParse(cleaned) == null) {
                                return 'Geçerli tutar girin';
                              }
                              return null;
                            },
                          ),
                        ],
                        SizedBox(height: SizeTokens.spacingLg),

                        // ── Açıklama ─────────────────────────────────
                        _SectionLabel(
                          icon: Icons.notes_outlined,
                          label: 'Açıklama',
                          sublabel: '(İsteğe bağlı)',
                        ),
                        SizedBox(height: SizeTokens.spacingXs),
                        TextFormField(
                          controller: _descController,
                          minLines: 2,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Kullanım notu veya ek bilgi...',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppTheme.textTertiary),
                          ),
                        ),
                        SizedBox(height: SizeTokens.spacingXxl),

                        // ── Kaydet butonu ─────────────────────────────
                        SizedBox(
                          height: SizeTokens.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: AppTheme.textOnPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    SizeTokens.radiusLg),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    width: SizeTokens.iconSm,
                                    height: SizeTokens.iconSm,
                                    child: const CircularProgressIndicator(
                                      color: AppTheme.textOnPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Kullanım Kaydını Kaydet',
                                    style: TextStyle(
                                      fontSize: SizeTokens.fontMd,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: SizeTokens.spacingMd),
                      ],
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

  Widget _buildKmSummary() {
    final start = int.tryParse(_startKmController.text);
    final end = int.tryParse(_endKmController.text);
    if (start == null || end == null || end <= start) {
      return const SizedBox.shrink();
    }
    final used = end - start;
    return Padding(
      padding: EdgeInsets.only(top: SizeTokens.spacingMd),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.spacingMd,
          vertical: SizeTokens.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.2),
            width: SizeTokens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.speed_outlined,
                size: SizeTokens.iconSm, color: AppTheme.primary),
            SizedBox(width: SizeTokens.spacingXs),
            Text(
              'Kullanılan KM:',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const Spacer(),
            Text(
              '${NumberFormat('#,###', 'tr_TR').format(used)} KM',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bölüm etiketi ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Widget? trailing;

  const _SectionLabel({
    required this.icon,
    required this.label,
    this.sublabel,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: SizeTokens.iconSm, color: AppTheme.textSecondary),
        SizedBox(width: SizeTokens.spacingXs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        if (sublabel != null) ...[
          SizedBox(width: SizeTokens.spacingXxs),
          Text(
            sublabel!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ],
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

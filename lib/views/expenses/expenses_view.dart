import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/core/utils/vehicle_image_helper.dart';
import 'package:oto_galeri/viewmodels/expenses_view_model.dart';
import 'package:oto_galeri/models/expense_model.dart';
import 'package:oto_galeri/views/expenses/widgets/expense_bottom_sheet.dart';
import 'package:oto_galeri/views/expenses/expense_add_view.dart';
import 'package:oto_galeri/viewmodels/expense_add_view_model.dart';
import 'package:provider/provider.dart';

/// ExpensesView - Giderler listesi (araç bazında gruplu)
class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus && !_searchExpanded) {
        setState(() => _searchExpanded = true);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpensesViewModel>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpensesViewModel>();
    final currencyFormat =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Giderler',
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: SizeTokens.fontMd,
              ),
            ),
          
          ],
        ),
        actions: [
          _buildFilterIcon(context, viewModel),
          SizedBox(width: SizeTokens.spacingXs),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_expense_fab',
        onPressed: () => _openAddExpense(context, viewModel),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 3,
        child: Icon(Icons.add, size: SizeTokens.iconMd),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── ARAMA ÇUBUĞU & TOPLAM ──────────────────
            _buildHeader(context, viewModel, currencyFormat),

            // ─── CONTENT ────────────────────────────────
            Expanded(
              child: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent))
                  : viewModel.errorMessage != null
                      ? _buildError(viewModel)
                      : (viewModel.expenses == null ||
                              viewModel.expenses!.isEmpty)
                          ? _buildEmpty()
                          : viewModel.groupedByVehicle.isEmpty
                              ? _buildNoResults()
                              : RefreshIndicator(
                                  color: AppTheme.accent,
                                  onRefresh: viewModel.refresh,
                                  child: _buildVehicleGroupedList(
                                      context, viewModel, currencyFormat),
                                ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── MASRAF EKLE NAVİGASYON ──────────────────────────────
  Future<void> _openAddExpense(
      BuildContext context, ExpensesViewModel expensesViewModel) async {
    final vm = context.read<ExpenseAddViewModel>();
    vm.reset();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const ExpenseAddView(),
        ),
      ),
    );
    if (result == true) {
      expensesViewModel.refresh();
    }
  }

  // ─── HEADER ─────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    ExpensesViewModel viewModel,
    NumberFormat currencyFormat,
  ) {
    final showTotal =
        viewModel.expenses != null && viewModel.expenses!.isNotEmpty;

    // _searchExpanded: true → arama geniş, toplam dar
    //                  false → toplam geniş, arama dar

    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.fromLTRB(
        SizeTokens.spacingLg,
        SizeTokens.spacingXs,
        SizeTokens.spacingLg,
        SizeTokens.spacingMd,
      ),
      child: SizedBox(
        height: SizeTokens.inputHeight,
        child: !showTotal
            // Toplam yoksa arama tüm satırı kaplar
            ? _buildSearchField(viewModel, fullWidth: true)
            : Row(
                children: [
                  // ─── ARAMA ──────────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: SizedBox(
                      width: _searchExpanded
                          ? MediaQuery.of(context).size.width *
                              0.68
                          : MediaQuery.of(context).size.width *
                              0.47,
                      child: _buildSearchField(viewModel,
                          fullWidth: false),
                    ),
                  ),
                  SizedBox(width: SizeTokens.spacingSm),
                  // ─── TOPLAM ──────────────────────────
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _searchFocus.unfocus();
                        setState(() => _searchExpanded = false);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeTokens.spacingSm,
                          vertical: SizeTokens.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: _searchExpanded
                              ? AppTheme.textOnPrimary
                                  .withValues(alpha: 0.07)
                              : AppTheme.textOnPrimary
                                  .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                              SizeTokens.radiusMd),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                currencyFormat
                                    .format(viewModel.totalExpense),
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: SizeTokens.fontSm,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!_searchExpanded)
                              Text(
                                'Toplam Gider',
                                style: TextStyle(
                                  color: AppTheme.textOnPrimary
                                      .withValues(alpha: 0.5),
                                  fontSize: SizeTokens.fontXxs,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchField(ExpensesViewModel viewModel,
      {required bool fullWidth}) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      onChanged: (q) {
        viewModel.setSearchQuery(q);
        setState(() => _searchExpanded = true);
      },
      onTap: () => setState(() => _searchExpanded = true),
      style: TextStyle(
          color: AppTheme.textOnPrimary, fontSize: SizeTokens.fontXs),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.textOnPrimary.withValues(alpha: 0.12),
        hintText: _searchExpanded ? 'Gider ara...' : 'Ara...',
        hintStyle: TextStyle(
            color: AppTheme.textOnPrimary.withValues(alpha: 0.45),
            fontSize: SizeTokens.fontXs),
        prefixIcon: Icon(Icons.search,
            size: SizeTokens.iconXs,
            color: AppTheme.textOnPrimary.withValues(alpha: 0.7)),
        suffixIcon: _searchController.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  viewModel.setSearchQuery('');
                  _searchFocus.unfocus();
                  setState(() => _searchExpanded = false);
                },
                child: Icon(Icons.close,
                    size: SizeTokens.iconXs,
                    color:
                        AppTheme.textOnPrimary.withValues(alpha: 0.6)),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
          borderSide: BorderSide(
              color: AppTheme.textOnPrimary.withValues(alpha: 0.3)),
        ),
        contentPadding:
            EdgeInsets.symmetric(vertical: SizeTokens.spacingXs),
        isDense: true,
      ),
    );
  }

  // ─── ARAç GRUPLU LİSTE ───────────────────────────────────
  Widget _buildVehicleGroupedList(
    BuildContext context,
    ExpensesViewModel viewModel,
    NumberFormat currencyFormat,
  ) {
    final grouped = viewModel.groupedByVehicle;
    final vehicleIds = grouped.keys.toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingLg,
        vertical: SizeTokens.spacingMd,
      ),
      itemCount: vehicleIds.length,
      itemBuilder: (context, index) {
        final vehicleId = vehicleIds[index];
        final vehicleExpenses = grouped[vehicleId]!;
        final total = viewModel.vehicleTotal(vehicleId);
        final sample = vehicleExpenses.first;

        return _VehicleExpenseGroup(
          vehicleName: sample.vehicleName ?? 'Araç #$vehicleId',
          vehicleBrand: sample.vehicleBrand,
          vehicleModel: sample.vehicleModel,
          expenses: vehicleExpenses,
          total: total,
          currencyFormat: currencyFormat,
        );
      },
    );
  }

  // ─── FİLTRE İKONU ───────────────────────────────────────
  Widget _buildFilterIcon(BuildContext context, ExpensesViewModel viewModel) {
    final hasFilter =
        viewModel.selectedType != null || viewModel.selectedBrand != null;
    return IconButton(
      icon: Badge(
        isLabelVisible: hasFilter,
        smallSize: 7,
        backgroundColor: AppTheme.accent,
        child: Icon(
          Icons.tune,
          size: SizeTokens.iconSm,
          color: hasFilter ? AppTheme.accent : AppTheme.secondary,
        ),
      ),
      onPressed: () => _showFilterPanel(context, viewModel),
    );
  }

  void _showFilterPanel(BuildContext context, ExpensesViewModel viewModel) {
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

  // ─── FİLTRE CHİP'LERİ ───────────────────────────────────
  Widget _buildError(ExpensesViewModel viewModel) {
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
              onPressed: viewModel.onRetry,
              child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: SizeTokens.spacing5xl, color: AppTheme.textTertiary),
          SizedBox(height: SizeTokens.spacingLg),
          Text('Gider bulunamadı',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined,
              size: SizeTokens.spacing5xl, color: AppTheme.textTertiary),
          SizedBox(height: SizeTokens.spacingLg),
          Text('Sonuç bulunamadı',
              style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: SizeTokens.spacingXs),
          Text(
            'Arama veya filtreyi değiştirerek tekrar deneyin',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ARAÇ GRUBU KARTI
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleExpenseGroup extends StatefulWidget {
  final String vehicleName;
  final String? vehicleBrand;
  final String? vehicleModel;
  final List<ExpenseModel> expenses;
  final double total;
  final NumberFormat currencyFormat;

  const _VehicleExpenseGroup({
    required this.vehicleName,
    this.vehicleBrand,
    this.vehicleModel,
    required this.expenses,
    required this.total,
    required this.currencyFormat,
  });

  @override
  State<_VehicleExpenseGroup> createState() => _VehicleExpenseGroupState();
}

class _VehicleExpenseGroupState extends State<_VehicleExpenseGroup>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late AnimationController _controller;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
      value: 1.0,
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = VehicleImageHelper.getImageUrl(
        widget.vehicleBrand, widget.vehicleModel);
    final dateFormat = DateFormat('dd MMM', 'tr_TR');

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
        border: Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Araç başlık bandı ──────────────────────────────
          InkWell(
            onTap: _toggle,
            child: Container(
              height: SizeTokens.spacing5xl * 1.5,
              decoration: BoxDecoration(
                color: AppTheme.primary,
              ),
              child: Row(
                children: [
                  // Araç görseli (sol)
                  SizedBox(
                    width: SizeTokens.spacing5xl * 2.2,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.primaryContainer,
                            child: Center(
                              child: Icon(
                                Icons.directions_car_outlined,
                                color: AppTheme.textOnPrimary.withValues(alpha: 0.4),
                                size: SizeTokens.iconLg,
                              ),
                            ),
                          ),
                        ),
                        // Koyu gradient overlay
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                AppTheme.primary.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Araç adı + gider sayısı + toplam
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.spacingMd,
                        vertical: SizeTokens.spacingSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.vehicleName,
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppTheme.textOnPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: SizeTokens.spacingXxs),
                          Text(
                            '${widget.expenses.length} gider',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textOnPrimary
                                          .withValues(alpha: 0.65),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Toplam + chevron
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: SizeTokens.spacingMd),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.currencyFormat.format(widget.total),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFFFF8080),
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        SizedBox(height: SizeTokens.spacingXxs),
                        AnimatedRotation(
                          turns: _expanded ? 0 : -0.5,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: AppTheme.textOnPrimary.withValues(alpha: 0.6),
                            size: SizeTokens.iconSm,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Giderler listesi (açılır/kapanır) ─────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: -1,
            child: Column(
              children: widget.expenses.asMap().entries.map((entry) {
                final isLast = entry.key == widget.expenses.length - 1;
                return Column(
                  children: [
                    _ExpenseRow(
                      expense: entry.value,
                      currencyFormat: widget.currencyFormat,
                      dateFormat: dateFormat,
                    ),
                    if (!isLast)
                      const Divider(height: 1, color: AppTheme.divider),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GİDER SATIRI
// ─────────────────────────────────────────────────────────────────────────────

class _ExpenseRow extends StatelessWidget {
  final ExpenseModel expense;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;

  const _ExpenseRow({
    required this.expense,
    required this.currencyFormat,
    required this.dateFormat,
  });

  static IconData _typeIcon(String? type) => switch (type) {
        'Noter' => Icons.description_outlined,
        'Servis' => Icons.build_outlined,
        'Lastik' => Icons.tire_repair_outlined,
        'Yakıt' => Icons.local_gas_station_outlined,
        'Tamir' => Icons.handyman_outlined,
        'Temizlik' => Icons.cleaning_services_outlined,
        'Ekspertiz' => Icons.search_outlined,
        _ => Icons.receipt_outlined,
      };

  static Color _typeColor(String? type) => switch (type) {
        'Servis' => AppTheme.accent,
        'Tamir' => AppTheme.error,
        'Lastik' => AppTheme.warning,
        'Yakıt' => const Color(0xFF10B981),
        'Noter' => AppTheme.textSecondary,
        'Temizlik' => const Color(0xFF8B5CF6),
        'Ekspertiz' => AppTheme.secondary,
        _ => AppTheme.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(expense.type);
    final typeIcon = _typeIcon(expense.type);

    return InkWell(
      onTap: () => showExpenseBottomSheet(context, expense),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.spacingMd,
          vertical: SizeTokens.spacingMd,
        ),
        child: Row(
          children: [
            // Tür ikonu
            Container(
              padding: EdgeInsets.all(SizeTokens.spacingXs),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
              ),
              child: Icon(typeIcon, size: SizeTokens.iconSm, color: typeColor),
            ),
            SizedBox(width: SizeTokens.spacingMd),
            // Tür + açıklama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.type ?? 'Gider',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
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
            // Tarih + tutar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(expense.amount ?? 0),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FİLTRE PANELİ (sağdan kayarak açılır)
// ─────────────────────────────────────────────────────────────────────────────

class _FilterPanel extends StatefulWidget {
  final ExpensesViewModel viewModel;
  const _FilterPanel({required this.viewModel});

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late String? _selectedType;
  late String? _selectedBrand;

  static const _types = [
    (label: 'Tümü', icon: Icons.all_inclusive_rounded, value: null, color: null),
    (label: 'Noter', icon: Icons.description_outlined, value: 'Noter', color: AppTheme.textSecondary),
    (label: 'Servis', icon: Icons.build_outlined, value: 'Servis', color: AppTheme.accent),
    (label: 'Lastik', icon: Icons.tire_repair_outlined, value: 'Lastik', color: AppTheme.warning),
    (label: 'Yakıt', icon: Icons.local_gas_station_outlined, value: 'Yakıt', color: Color(0xFF10B981)),
    (label: 'Tamir', icon: Icons.handyman_outlined, value: 'Tamir', color: AppTheme.error),
    (label: 'Temizlik', icon: Icons.cleaning_services_outlined, value: 'Temizlik', color: Color(0xFF8B5CF6)),
    (label: 'Ekspertiz', icon: Icons.search_outlined, value: 'Ekspertiz', color: AppTheme.secondary),
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.viewModel.selectedType;
    _selectedBrand = widget.viewModel.selectedBrand;
  }

  void _applyType(String? value) {
    setState(() => _selectedType = value);
    widget.viewModel.setTypeFilter(value);
  }

  void _applyBrand(String? value) {
    setState(() => _selectedBrand = (value == 'Tümü' ? null : value));
    widget.viewModel.setBrandFilter(value == 'Tümü' ? null : value);
  }

  void _clearAll() {
    setState(() {
      _selectedType = null;
      _selectedBrand = null;
    });
    widget.viewModel.clearFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = _selectedType != null || _selectedBrand != null;
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
                        color: AppTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
                      ),
                      child: Icon(Icons.tune,
                          color: AppTheme.accent, size: SizeTokens.iconSm),
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
                        'Marka',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                      ),
                      SizedBox(height: SizeTokens.spacingMd),
                      Wrap(
                        spacing: SizeTokens.spacingSm,
                        runSpacing: SizeTokens.spacingSm,
                        children: widget.viewModel.availableBrands.map((brand) {
                          final isSelected = (brand == 'Tümü' &&
                                  _selectedBrand == null) ||
                              (_selectedBrand == brand);
                          return InkWell(
                            onTap: () => _applyBrand(brand),
                            borderRadius:
                                BorderRadius.circular(SizeTokens.radiusFull),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeTokens.spacingMd,
                                vertical: SizeTokens.spacingXs,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accent
                                    : AppTheme.background,
                                borderRadius: BorderRadius.circular(
                                    SizeTokens.radiusFull),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.accent
                                      : AppTheme.border,
                                  width: SizeTokens.borderThin,
                                ),
                              ),
                              child: Text(
                                brand,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isSelected
                                          ? AppTheme.textOnAccent
                                          : AppTheme.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: SizeTokens.spacingXl),
                      Text(
                        'Gider Türü',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                      ),
                      SizedBox(height: SizeTokens.spacingMd),
                      ..._types.map(
                        (t) => Padding(
                          padding:
                              EdgeInsets.only(bottom: SizeTokens.spacingSm),
                          child: _TypeOption(
                            icon: t.icon,
                            label: t.label,
                            color: t.color,
                            isSelected: t.value == null
                                ? _selectedType == null
                                : _selectedType == t.value,
                            onTap: () => _applyType(t.value),
                          ),
                        ),
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

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
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

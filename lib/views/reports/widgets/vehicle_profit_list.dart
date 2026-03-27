import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/core/utils/vehicle_image_helper.dart';
import 'package:oto_galeri/models/vehicle_profit_report_model.dart';

/// VehicleProfitList - Araç bazlı kârlılık genişletilebilir listesi
class VehicleProfitList extends StatelessWidget {
  final List<VehicleProfitReportModel> vehicles;

  const VehicleProfitList({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: SizeTokens.spacing3xl),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.directions_car_outlined,
                  size: SizeTokens.spacing4xl,
                  color: AppTheme.textTertiary),
              SizedBox(height: SizeTokens.spacingMd),
              Text(
                'Bu dönemde araç verisi yok',
                style: TextStyle(
                  fontSize: SizeTokens.fontSm,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: vehicles.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: SizeTokens.spacingMd),
          child: _VehicleProfitRow(
            vehicle: entry.value,
            rank: entry.key + 1,
          ),
        );
      }).toList(),
    );
  }
}

class _VehicleProfitRow extends StatefulWidget {
  final VehicleProfitReportModel vehicle;
  final int rank;

  const _VehicleProfitRow({required this.vehicle, required this.rank});

  @override
  State<_VehicleProfitRow> createState() => _VehicleProfitRowState();
}

class _VehicleProfitRowState extends State<_VehicleProfitRow>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final fmt = NumberFormat.currency(
        locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    final profitColor =
        v.isSold ? (v.isProfitable ? AppTheme.success : AppTheme.error) : AppTheme.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(
          color: v.isSold && v.isProfitable
              ? AppTheme.success.withValues(alpha: 0.25)
              : v.isSold && !v.isProfitable
                  ? AppTheme.error.withValues(alpha: 0.25)
                  : AppTheme.border,
          width: SizeTokens.borderThin,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // ─── BAŞLIK SATIRI ─────────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(SizeTokens.spacingMd),
              child: Row(
                children: [
                  // Araç görseli + durum rozeti
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(SizeTokens.radiusSm),
                        child: Image.asset(
                          VehicleImageHelper.getAssetPath(
                              v.brand, v.model),
                          width: SizeTokens.avatarLg,
                          height: SizeTokens.avatarLg,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: SizeTokens.avatarLg,
                            height: SizeTokens.avatarLg,
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(
                                  SizeTokens.radiusSm),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: AppTheme.textTertiary,
                              size: SizeTokens.iconSm,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(SizeTokens.spacingXxs),
                          decoration: BoxDecoration(
                            color: v.isSold
                                ? profitColor
                                : AppTheme.primary
                                    .withValues(alpha: 0.75),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                  SizeTokens.radiusSm),
                              bottomRight: Radius.circular(
                                  SizeTokens.radiusSm),
                            ),
                          ),
                          child: v.isSold
                              ? Icon(
                                  v.isProfitable
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: SizeTokens.iconXs,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${widget.rank}',
                                  style: TextStyle(
                                    fontSize: SizeTokens.fontXxs,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: SizeTokens.spacingMd),
                  // Araç bilgisi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                v.vehicleName ?? '—',
                                style: TextStyle(
                                  fontSize: SizeTokens.fontSm,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _StatusBadge(status: v.status ?? 'STOKTA'),
                          ],
                        ),
                        SizedBox(height: SizeTokens.spacingXxs),
                        Row(
                          children: [
                            if (v.plate != null) ...[
                              Text(
                                v.plate!,
                                style: TextStyle(
                                  fontSize: SizeTokens.fontXxs,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              SizedBox(width: SizeTokens.spacingXs),
                            ],
                            if (v.year != null)
                              Text(
                                '${v.year}',
                                style: TextStyle(
                                  fontSize: SizeTokens.fontXxs,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: SizeTokens.spacingSm),
                  // Kâr/zarar veya maliyet
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        v.isSold
                            ? '${v.isProfitable ? '+' : ''}${fmt.format(v.profitLoss)}'
                            : fmt.format(v.totalCost),
                        style: TextStyle(
                          fontSize: SizeTokens.fontSm,
                          fontWeight: FontWeight.w700,
                          color: profitColor,
                        ),
                      ),
                      Text(
                        v.isSold ? 'Net Kâr/Zarar' : 'Toplam Maliyet',
                        style: TextStyle(
                          fontSize: SizeTokens.fontXxs,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: SizeTokens.spacingXs),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5)
                        .animate(_expandAnimation),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: SizeTokens.iconSm,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── GENİŞLETİLMİŞ DETAY ──────────────────────
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                Divider(
                    height: SizeTokens.borderThin,
                    color: AppTheme.divider),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    SizeTokens.spacingMd,
                    SizeTokens.spacingMd,
                    SizeTokens.spacingMd,
                    SizeTokens.spacingLg,
                  ),
                  child: Column(
                    children: [
                      // Maliyet kırılımı
                      _DetailRow(
                        label: 'Alış Fiyatı',
                        value: fmt.format(v.purchaseCost ?? 0),
                        icon: Icons.shopping_cart_outlined,
                        iconColor: AppTheme.textSecondary,
                        isCost: true,
                      ),
                      _DetailRow(
                        label: 'Operasyon Giderleri',
                        value: fmt.format(v.operationExpenses ?? 0),
                        icon: Icons.receipt_long_outlined,
                        iconColor: AppTheme.warning,
                        isCost: true,
                      ),
                      if ((v.financingCost ?? 0) > 0)
                        _DetailRow(
                          label: 'Finansman Gideri',
                          value: fmt.format(v.financingCost ?? 0),
                          icon: Icons.schedule_outlined,
                          iconColor: AppTheme.warning,
                          isCost: true,
                        ),
                      _DetailRow(
                        label: 'Toplam Maliyet',
                        value: fmt.format(v.totalCost),
                        icon: Icons.calculate_outlined,
                        iconColor: AppTheme.textSecondary,
                        isCost: true,
                        isBold: true,
                      ),

                      // Satış geliri (sadece satılmışsa)
                      if (v.isSold && v.saleRevenue != null) ...[
                        SizedBox(height: SizeTokens.spacingXs),
                        Divider(
                            height: SizeTokens.borderThin,
                            color: AppTheme.divider),
                        SizedBox(height: SizeTokens.spacingXs),
                        _DetailRow(
                          label: 'Satış Geliri',
                          value: fmt.format(v.saleRevenue ?? 0),
                          icon: Icons.sell_outlined,
                          iconColor: AppTheme.success,
                          isCost: false,
                        ),
                        _DetailRow(
                          label: 'Net Kâr / Zarar',
                          value:
                              '${v.isProfitable ? '+' : ''}${fmt.format(v.profitLoss)}',
                          icon: v.isProfitable
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          iconColor: profitColor,
                          isCost: false,
                          isBold: true,
                          valueColor: profitColor,
                        ),
                      ],

                      // Gider kategori dağılımı
                      if (v.expenseByCategory != null &&
                          v.expenseByCategory!.isNotEmpty) ...[
                        SizedBox(height: SizeTokens.spacingMd),
                        Container(
                          padding: EdgeInsets.all(SizeTokens.spacingMd),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(
                                SizeTokens.radiusMd),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GİDER KATEGORİLERİ',
                                style: TextStyle(
                                  fontSize: SizeTokens.fontXxs,
                                  color: AppTheme.textTertiary,
                                  letterSpacing: 0.6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: SizeTokens.spacingSm),
                              ...v.expenseByCategory!.entries
                                  .map((e) => Padding(
                                        padding: EdgeInsets.only(
                                            bottom:
                                                SizeTokens.spacingXs),
                                        child: Row(
                                          children: [
                                            Text(
                                              e.key,
                                              style: TextStyle(
                                                fontSize:
                                                    SizeTokens.fontXs,
                                                color: AppTheme
                                                    .textSecondary,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              fmt.format(e.value),
                                              style: TextStyle(
                                                fontSize:
                                                    SizeTokens.fontXs,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: AppTheme
                                                    .textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isCost;
  final bool isBold;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isCost,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeTokens.spacingXs),
      child: Row(
        children: [
          Icon(icon, size: SizeTokens.iconXs, color: iconColor),
          SizedBox(width: SizeTokens.spacingXs),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: SizeTokens.fontXs,
                color: AppTheme.textSecondary,
                fontWeight:
                    isBold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeTokens.fontXs,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSold = status == 'SATILDI';
    return Container(
      margin: EdgeInsets.only(left: SizeTokens.spacingXs),
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingXs,
        vertical: SizeTokens.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: isSold
            ? AppTheme.statusSatildi.withValues(alpha: 0.1)
            : AppTheme.statusStokta.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: SizeTokens.fontXxs,
          fontWeight: FontWeight.w600,
          color: isSold ? AppTheme.statusSatildi : AppTheme.statusStokta,
        ),
      ),
    );
  }
}

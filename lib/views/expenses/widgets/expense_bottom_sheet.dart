import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/core/utils/vehicle_image_helper.dart';
import 'package:oto_galeri/models/expense_model.dart';
import 'package:oto_galeri/views/expenses/widgets/receipt_attachment_section.dart';

/// Gider hızlı önizleme BottomSheet - tıklanınca detay gösterir.
void showExpenseBottomSheet(BuildContext context, ExpenseModel expense) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    enableDrag: true,
    builder: (_) => _ExpenseBottomSheetContent(expense: expense),
  );
}

class _ExpenseBottomSheetContent extends StatelessWidget {
  final ExpenseModel expense;

  const _ExpenseBottomSheetContent({required this.expense});

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
    final currencyFormat =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final typeIcon = _typeIcon(expense.type);
    final typeColor = _typeColor(expense.type);
    final imageUrl =
        VehicleImageHelper.getLargeImageUrl(expense.vehicleBrand, expense.vehicleModel);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SizeTokens.radiusXxl),
            ),
          ),
          clipBehavior: Clip.antiAlias,
            child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── ARAÇ GÖRSELI + OVERLAY ───────────────
                    Stack(
                      children: [
                        SizedBox(
                          height: SizeTokens.spacing5xl * 3.2,
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
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Araç adı overlay (Alt Sol)
                        Positioned(
                          bottom: SizeTokens.spacingMd,
                          left: SizeTokens.spacingMd,
                          child: Text(
                            expense.vehicleName ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeTokens.fontMd,
                              fontWeight: FontWeight.w700,
                              shadows: const [
                                Shadow(color: Colors.black38, blurRadius: 8),
                              ],
                            ),
                          ),
                        ),
                        // Gider türü badge overlay (Alt Sağ)
                        Positioned(
                          bottom: SizeTokens.spacingMd,
                          right: SizeTokens.spacingMd,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeTokens.spacingMd,
                              vertical: SizeTokens.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.9),
                              borderRadius:
                                  BorderRadius.circular(SizeTokens.radiusFull),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(typeIcon,
                                    color: Colors.white, size: SizeTokens.iconXs),
                                SizedBox(width: SizeTokens.spacingXs),
                                Text(
                                  expense.type ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeTokens.fontXxs,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ─── CONTENT ──────────────────────────────
                    Padding(
                      padding: EdgeInsets.all(SizeTokens.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tutar + tarih satırı
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tür ikonu
                              Container(
                                padding: EdgeInsets.all(SizeTokens.spacingMd),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(SizeTokens.radiusMd),
                                ),
                                child: Icon(typeIcon,
                                    color: typeColor, size: SizeTokens.iconMd),
                              ),
                              SizedBox(width: SizeTokens.spacingMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.type ?? 'Gider',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                    ),
                                    if (expense.date != null) ...[
                                      SizedBox(height: SizeTokens.spacingXxs),
                                      Text(
                                        dateFormat.format(expense.date!),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Tutar
                              Text(
                                currencyFormat.format(expense.amount ?? 0),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.error,
                                    ),
                              ),
                            ],
                          ),

                          // Açıklama kutusu
                          if (expense.description != null &&
                              expense.description!.isNotEmpty) ...[
                            SizedBox(height: SizeTokens.spacingLg),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(SizeTokens.spacingLg),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius:
                                    BorderRadius.circular(SizeTokens.radiusLg),
                                border: Border.all(
                                    color: AppTheme.border,
                                    width: SizeTokens.borderThin),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Açıklama',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppTheme.textTertiary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  SizedBox(height: SizeTokens.spacingXs),
                                  Text(
                                    expense.description!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textPrimary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // ─── DEKONTLAR & BELGELER ──────────────────────────
                          SizedBox(height: SizeTokens.spacingLg),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(SizeTokens.spacingLg),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius:
                                  BorderRadius.circular(SizeTokens.radiusLg),
                              border: Border.all(
                                  color: AppTheme.border,
                                  width: SizeTokens.borderThin),
                            ),
                            child: ReceiptAttachmentSection(
                              initialAttachments: _mockAttachments(expense),
                            ),
                          ),

                          SizedBox(height: SizeTokens.spacing5xl),
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
                        boxShadow: [
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
        );
      },
    );
  }
}

/// Örnek (mock) ekler — gerçek uygulamada API'dan gelir.
List<ReceiptAttachment> _mockAttachments(ExpenseModel expense) {
  // Sadece belirli tür giderler için örnek belge göster.
  if (expense.type == 'Servis' || expense.type == 'Tamir') {
    return [
      ReceiptAttachment(
        fileName: 'servis_dekont_${expense.id ?? 1}.pdf',
        fileType: 'pdf',
        fileSizeBytes: 214 * 1024,
        uploadedAt: expense.date ?? DateTime.now(),
      ),
      ReceiptAttachment(
        fileName: 'atis_fotografi.jpg',
        fileType: 'image',
        fileSizeBytes: 1024 * 876,
        uploadedAt: expense.date ?? DateTime.now(),
      ),
    ];
  }
  if (expense.type == 'Noter') {
    return [
      ReceiptAttachment(
        fileName: 'noter_belgesi.pdf',
        fileType: 'pdf',
        fileSizeBytes: 512 * 1024,
        uploadedAt: expense.date ?? DateTime.now(),
      ),
    ];
  }
  // Diğer türler için boş liste — "Henüz belge eklenmemiş" gösterilir.
  return [];
}

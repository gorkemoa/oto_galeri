import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';

/// Ekli belge modeli – sadece UI katmanı için (gerçek dosya yolu veya URL)
class ReceiptAttachment {
  final String fileName;
  final String fileType; // 'pdf' | 'image' | 'other'
  final int fileSizeBytes;
  final DateTime uploadedAt;
  final String? localPath; // Cihazdan seçilen dosya yolu
  final String? remoteUrl; // Sunucudan gelen URL

  const ReceiptAttachment({
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
    required this.uploadedAt,
    this.localPath,
    this.remoteUrl,
  });
}

/// Gider detayında dekont / belge ekleme ve listeleme bölümü.
///
/// Kullanım:
/// ```dart
/// ReceiptAttachmentSection(attachments: mockAttachments)
/// ```
class ReceiptAttachmentSection extends StatefulWidget {
  /// Başlangıçta gösterilecek örnek/mock belgeler.
  final List<ReceiptAttachment> initialAttachments;

  const ReceiptAttachmentSection({
    super.key,
    this.initialAttachments = const [],
  });

  @override
  State<ReceiptAttachmentSection> createState() =>
      _ReceiptAttachmentSectionState();
}

class _ReceiptAttachmentSectionState extends State<ReceiptAttachmentSection> {
  late List<ReceiptAttachment> _attachments;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _attachments = List.from(widget.initialAttachments);
  }

  Future<void> _pickFiles() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp'],
      );

      if (result != null && result.files.isNotEmpty) {
        final newAttachments = result.files.map((f) {
          final ext = (f.extension ?? '').toLowerCase();
          final fileType = (ext == 'pdf') ? 'pdf' : 'image';
          return ReceiptAttachment(
            fileName: f.name,
            fileType: fileType,
            fileSizeBytes: f.size,
            uploadedAt: DateTime.now(),
            localPath: f.path,
          );
        }).toList();

        setState(() => _attachments.addAll(newAttachments));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosya seçilemedi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── BAŞLIK + EKLE BUTONU ──────────────────────────────
        Row(
          children: [
            Icon(
              Icons.attach_file_rounded,
              size: SizeTokens.iconSm,
              color: AppTheme.textSecondary,
            ),
            SizedBox(width: SizeTokens.spacingXs),
            Text(
              'Dekontlar & Belgeler',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
            ),
            const Spacer(),
            _isPicking
                ? SizedBox(
                    width: SizeTokens.spacingLg,
                    height: SizeTokens.spacingLg,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accent,
                    ),
                  )
                : GestureDetector(
                    onTap: _pickFiles,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.spacingMd,
                        vertical: SizeTokens.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(SizeTokens.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              size: SizeTokens.iconXs, color: AppTheme.accent),
                          SizedBox(width: SizeTokens.spacingXxs),
                          Text(
                            'Belge Ekle',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),

        SizedBox(height: SizeTokens.spacingMd),

        // ─── BELGE LİSTESİ ─────────────────────────────────────
        if (_attachments.isEmpty)
          _EmptyAttachmentHint()
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _attachments.length,
            separatorBuilder: (_, __) => SizedBox(height: SizeTokens.spacingSm),
            itemBuilder: (context, index) {
              return _AttachmentTile(
                attachment: _attachments[index],
                onRemove: () => _removeAttachment(index),
              );
            },
          ),
      ],
    );
  }
}

// ─── BOŞ DURUM ──────────────────────────────────────────────────────────────

class _EmptyAttachmentHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeTokens.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(
          color: AppTheme.border,
          width: SizeTokens.borderThin,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: SizeTokens.spacing4xl,
            color: AppTheme.textTertiary,
          ),
          SizedBox(height: SizeTokens.spacingXs),
          Text(
            'Henüz belge eklenmemiş',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
          SizedBox(height: SizeTokens.spacingXxs),
          Text(
            'PDF, JPG veya PNG ekleyebilirsiniz',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                  fontSize: SizeTokens.fontXxs,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── BELGE KARTI ───────────────────────────────────────────────────────────

class _AttachmentTile extends StatelessWidget {
  final ReceiptAttachment attachment;
  final VoidCallback onRemove;

  const _AttachmentTile({required this.attachment, required this.onRemove});

  String get _sizeLabel {
    final kb = attachment.fileSizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  IconData get _fileIcon => switch (attachment.fileType) {
        'pdf' => Icons.picture_as_pdf_rounded,
        'image' => Icons.image_rounded,
        _ => Icons.insert_drive_file_rounded,
      };

  Color get _fileColor => switch (attachment.fileType) {
        'pdf' => const Color(0xFFDC2626),
        'image' => AppTheme.accent,
        _ => AppTheme.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border:
            Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        child: InkWell(
          onTap: () => _onTapView(context),
          borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.spacingMd,
              vertical: SizeTokens.spacingMd,
            ),
            child: Row(
              children: [
                // Dosya ikonu
                Container(
                  padding: EdgeInsets.all(SizeTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: _fileColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
                  ),
                  child: Icon(_fileIcon,
                      color: _fileColor, size: SizeTokens.iconMd),
                ),
                SizedBox(width: SizeTokens.spacingMd),

                // Dosya adı + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.fileName,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: SizeTokens.spacingXxs),
                      Text(
                        '$_sizeLabel · ${dateFormat.format(attachment.uploadedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiary,
                              fontSize: SizeTokens.fontXxs,
                            ),
                      ),
                    ],
                  ),
                ),

                // Sil butonu
                IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: Icon(Icons.delete_outline_rounded,
                      color: AppTheme.error, size: SizeTokens.iconSm),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: SizeTokens.spacing3xl,
                    minHeight: SizeTokens.spacing3xl,
                  ),
                  tooltip: 'Kaldır',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTapView(BuildContext context) {
    // TODO: Gerçek uygulamada: open_file veya flutter_pdfview ile aç
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Açılıyor: ${attachment.fileName}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Belgeyi Kaldır'),
        content: Text(
          '"${attachment.fileName}" adlı belge kaldırılsın mı?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, true);
              onRemove();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Kaldır'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/viewmodels/profile_view_model.dart';
import 'package:provider/provider.dart';

/// ProfileView - Profil / Ayarlar ekranı
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: SizeTokens.spacingLg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil',
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: SizeTokens.fontMd,
              ),
            ),
           
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                SizeTokens.spacingLg,
                SizeTokens.spacingLg,
                SizeTokens.spacingLg,
                SizeTokens.spacing5xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── KİMLİK KARTI ────────────────────────
                  _IdentityCard(viewModel: viewModel),
                  SizedBox(height: SizeTokens.spacingXl),

                  // ─── GALERİ BİLGİLERİ ────────────────────
                  _SectionLabel(label: 'GALERİ BİLGİLERİ'),
                  SizedBox(height: SizeTokens.spacingXs),
                  _InfoCard(items: [
                    _InfoRow(
                      icon: Icons.store_outlined,
                      label: 'Galeri Adı',
                      value: viewModel.galleryName ?? '—',
                    ),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Telefon',
                      value: viewModel.phone ?? '—',
                    ),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Adres',
                      value: viewModel.address ?? '—',
                      isLast: true,
                    ),
                  ]),

                  SizedBox(height: SizeTokens.spacingXl),

                  // ─── YÖNETİM ─────────────────────────────
                  _SectionLabel(label: 'YÖNETİM'),
                  SizedBox(height: SizeTokens.spacingXs),
                  _InfoCard(items: [
                    _InfoRow(
                      icon: Icons.people_outline,
                      label: 'Kullanıcı Yönetimi',
                      trailing: Icon(Icons.chevron_right,
                          size: SizeTokens.iconSm,
                          color: AppTheme.textTertiary),
                      onTap: () {},
                      isLast: true,
                    ),
                  ]),

                  SizedBox(height: SizeTokens.spacingXl),

                  // ─── UYGULAMA ────────────────────────────
                  _SectionLabel(label: 'UYGULAMA'),
                  SizedBox(height: SizeTokens.spacingXs),
                  _InfoCard(items: [
                    _InfoRow(
                      icon: Icons.notifications_none_outlined,
                      label: 'Bildirimler',
                      trailing: Icon(Icons.chevron_right,
                          size: SizeTokens.iconSm,
                          color: AppTheme.textTertiary),
                      onTap: () {},
                    ),
                    _InfoRow(
                      icon: Icons.info_outline,
                      label: 'Sürüm',
                      value: '1.0.0',
                      isLast: true,
                    ),
                  ]),

                  SizedBox(height: SizeTokens.spacingXl),

                  // ─── ÇIKIŞ ───────────────────────────────
                  _LogoutButton(onTap: () => viewModel.logout()),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────
// YARDIMCI WİDGETLER
// ─────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  final ProfileViewModel viewModel;
  const _IdentityCard({required this.viewModel});

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
        border: Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: EdgeInsets.all(SizeTokens.spacingLg),
      child: Row(
        children: [
          Container(
            width: SizeTokens.spacing5xl,
            height: SizeTokens.spacing5xl,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
            ),
            child: Center(
              child: Text(
                _initials(viewModel.galleryName),
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: SizeTokens.fontMd,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SizedBox(width: SizeTokens.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.galleryName ?? '—',
                  style: TextStyle(
                    fontSize: SizeTokens.fontSm,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: SizeTokens.spacingXxs),
                Text(
                  viewModel.userName ?? '—',
                  style: TextStyle(
                    fontSize: SizeTokens.fontXs,
                    color: AppTheme.textSecondary,
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: SizeTokens.spacingXxs),
      child: Text(
        label,
        style: TextStyle(
          fontSize: SizeTokens.fontXxs,
          fontWeight: FontWeight.w600,
          color: AppTheme.textTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
        border:
            Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(children: items),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: isLast
              ? BorderRadius.only(
                  bottomLeft: Radius.circular(SizeTokens.radiusLg),
                  bottomRight: Radius.circular(SizeTokens.radiusLg),
                )
              : BorderRadius.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.spacingLg,
              vertical: SizeTokens.spacingMd,
            ),
            child: Row(
              children: [
                Container(
                  width: SizeTokens.spacingXxl,
                  height: SizeTokens.spacingXxl,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
                  ),
                  child: Icon(icon,
                      size: SizeTokens.iconXs, color: AppTheme.textSecondary),
                ),
                SizedBox(width: SizeTokens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: SizeTokens.fontXs,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      if (value != null) ...[
                        SizedBox(height: SizeTokens.spacingXxs),
                        Text(
                          value!,
                          style: TextStyle(
                            fontSize: SizeTokens.fontSm,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: SizeTokens.borderThin,
            indent: SizeTokens.spacingLg +
                SizeTokens.spacingXxl +
                SizeTokens.spacingMd,
            endIndent: 0,
            color: AppTheme.divider,
          ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: SizeTokens.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
          border: Border.all(
              color: AppTheme.error.withValues(alpha: 0.2),
              width: SizeTokens.borderThin),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_outlined,
                size: SizeTokens.iconSm, color: AppTheme.error),
            SizedBox(width: SizeTokens.spacingSm),
            Text(
              'Çıkış Yap',
              style: TextStyle(
                fontSize: SizeTokens.fontSm,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



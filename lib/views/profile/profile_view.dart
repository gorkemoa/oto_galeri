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
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
            : SingleChildScrollView(
                padding: EdgeInsets.all(SizeTokens.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: SizeTokens.spacingXxl),

                    // ─── KULLANICI KARTI ──────────────────
                    _buildUserCard(viewModel),
                    SizedBox(height: SizeTokens.spacingXxl),

                    // ─── AYARLAR LİSTESİ ─────────────────
                    _buildSection('Galeri Bilgileri', [
                      _SettingsItem(
                        icon: Icons.store_outlined,
                        title: 'Galeri Adı',
                        subtitle: viewModel.galleryName ?? '-',
                      ),
                      _SettingsItem(
                        icon: Icons.phone_outlined,
                        title: 'Telefon',
                        subtitle: viewModel.phone ?? '-',
                      ),
                      _SettingsItem(
                        icon: Icons.location_on_outlined,
                        title: 'Adres',
                        subtitle: viewModel.address ?? '-',
                      ),
                    ]),
                    SizedBox(height: SizeTokens.spacingLg),

                    _buildSection('Yönetim', [
                      _SettingsItem(
                        icon: Icons.people_outline,
                        title: 'Kullanıcı Yönetimi',
                        trailing: Icon(
                          Icons.chevron_right,
                          size: SizeTokens.iconSm,
                          color: AppTheme.textTertiary,
                        ),
                        onTap: () {
                          // TODO: Kullanıcı yönetimi sayfasına navigate
                        },
                      ),
                    ]),
                    SizedBox(height: SizeTokens.spacingXxl),

                    // ─── ÇIKIŞ BUTONU ────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Çıkış yap flow
                          viewModel.logout();
                        },
                        icon: Icon(Icons.logout, size: SizeTokens.iconSm, color: AppTheme.error),
                        label: Text(
                          'Çıkış Yap',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeTokens.spacing3xl),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUserCard(ProfileViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.spacingXxl),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
        border: Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: SizeTokens.spacing5xl,
            height: SizeTokens.spacing5xl,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SizeTokens.radiusFull),
            ),
            child: Icon(
              Icons.person,
              color: AppTheme.accent,
              size: SizeTokens.iconLg,
            ),
          ),
          SizedBox(width: SizeTokens.spacingLg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.userName ?? '-',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: SizeTokens.spacingXxs),
              Text(
                viewModel.galleryName ?? '-',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.accent,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textTertiary,
              ),
        ),
        SizedBox(height: SizeTokens.spacingMd),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
            border: Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeTokens.radiusLg),
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.spacingLg),
        child: Row(
          children: [
            Icon(icon, size: SizeTokens.iconSm, color: AppTheme.textSecondary),
            SizedBox(width: SizeTokens.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  if (subtitle != null) ...[
                    SizedBox(height: SizeTokens.spacingXxs),
                    Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

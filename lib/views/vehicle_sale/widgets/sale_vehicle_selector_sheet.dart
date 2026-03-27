import 'package:flutter/material.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/core/utils/vehicle_image_helper.dart';
import 'package:oto_galeri/models/vehicle_model.dart';

/// SaleVehicleSelectorSheet - Araç Sat ekranında stokta olan araçları listeler
class SaleVehicleSelectorSheet extends StatefulWidget {
  final List<VehicleModel> vehicles;
  final VehicleModel? selectedVehicle;

  const SaleVehicleSelectorSheet({
    super.key,
    required this.vehicles,
    this.selectedVehicle,
  });

  @override
  State<SaleVehicleSelectorSheet> createState() => _SaleVehicleSelectorSheetState();
}

class _SaleVehicleSelectorSheetState extends State<SaleVehicleSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<VehicleModel> _filteredVehicles = [];

  @override
  void initState() {
    super.initState();
    _filteredVehicles = widget.vehicles;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVehicles = widget.vehicles;
      } else {
        final q = query.toLowerCase().trim();
        _filteredVehicles = widget.vehicles.where((v) {
          final name = v.fullName.toLowerCase();
          final plate = (v.plate ?? '').toLowerCase();
          return name.contains(q) || plate.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SizeTokens.radiusXl)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: SizeTokens.spacingMd),
              width: SizeTokens.spacing5xl,
              height: SizeTokens.borderThick,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(SizeTokens.radiusFull),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingLg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Araç Seçin',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      Text(
                        'Satışa hazır stok araçları',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      size: SizeTokens.iconMd, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          SizedBox(height: SizeTokens.spacingSm),

          // Search
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingLg),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Marka, model veya plaka ara...',
                prefixIcon: Icon(Icons.search,
                    color: AppTheme.textSecondary, size: SizeTokens.iconSm),
                hintStyle: TextStyle(fontSize: SizeTokens.fontSm),
              ),
            ),
          ),

          SizedBox(height: SizeTokens.spacingSm),

          // List
          Expanded(
            child: _filteredVehicles.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      SizeTokens.spacingLg,
                      SizeTokens.spacingXs,
                      SizeTokens.spacingLg,
                      SizeTokens.spacingXxl,
                    ),
                    itemCount: _filteredVehicles.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: SizeTokens.spacingXs),
                    itemBuilder: (context, index) {
                      final vehicle = _filteredVehicles[index];
                      final isSelected =
                          widget.selectedVehicle?.id == vehicle.id;
                      return _VehicleRow(
                        vehicle: vehicle,
                        isSelected: isSelected,
                        onTap: () => Navigator.pop(context, vehicle),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined,
              size: SizeTokens.spacing5xl, color: AppTheme.textTertiary),
          SizedBox(height: SizeTokens.spacingMd),
          Text(
            'Stokta araç bulunamadı',
            style: TextStyle(
              fontSize: SizeTokens.fontSm,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: SizeTokens.spacingXs),
          Text(
            'Önce araç stoğuna ekleme yapın',
            style: TextStyle(
              fontSize: SizeTokens.fontXs,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleRow({
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = vehicle.imageUrl?.isNotEmpty == true
        ? vehicle.imageUrl!
        : VehicleImageHelper.getAssetPath(vehicle.brand, vehicle.model);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(SizeTokens.spacingMd),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withValues(alpha: 0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.border,
            width: isSelected
                ? SizeTokens.borderMedium
                : SizeTokens.borderThin,
          ),
        ),
        child: Row(
          children: [
            // Araç görseli
            ClipRRect(
              borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
              child: Image.asset(
                imageUrl,
                width: SizeTokens.avatarLg,
                height: SizeTokens.avatarLg,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: SizeTokens.avatarLg,
                  height: SizeTokens.avatarLg,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
                  ),
                  child: Icon(Icons.directions_car,
                      color: AppTheme.textTertiary,
                      size: SizeTokens.iconMd),
                ),
              ),
            ),
            SizedBox(width: SizeTokens.spacingMd),

            // Bilgiler
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
                  SizedBox(height: SizeTokens.spacingXxs),
                  Row(
                    children: [
                      if (vehicle.plate != null) ...[
                        _InfoPill(label: vehicle.plate!),
                        SizedBox(width: SizeTokens.spacingXs),
                      ],
                      if (vehicle.year != null)
                        _InfoPill(label: '${vehicle.year}'),
                    ],
                  ),
                ],
              ),
            ),

            // Seçili işareti
            if (isSelected)
              Container(
                width: SizeTokens.iconSm,
                height: SizeTokens.iconSm,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check,
                    size: SizeTokens.iconXs, color: AppTheme.textOnAccent),
              )
            else
              Icon(Icons.chevron_right,
                  size: SizeTokens.iconSm, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;

  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.spacingXs,
        vertical: SizeTokens.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(SizeTokens.radiusSm),
        border: Border.all(color: AppTheme.border, width: SizeTokens.borderThin),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: SizeTokens.fontXxs,
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:oto_galeri/app/app_theme.dart';
import 'package:oto_galeri/core/responsive/size_tokens.dart';
import 'package:oto_galeri/core/utils/vehicle_image_helper.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/viewmodels/vehicle_detail_view_model.dart';
import 'package:oto_galeri/views/vehicles/vehicle_detail_view.dart';
import 'package:provider/provider.dart';

/// VehicleSelectorSheet - Masraf eklerken araç seçmek için kullanılan modern arayüz
class VehicleSelectorSheet extends StatefulWidget {
  final List<VehicleModel> vehicles;
  final VehicleModel? selectedVehicle;

  const VehicleSelectorSheet({
    super.key,
    required this.vehicles,
    this.selectedVehicle,
  });

  @override
  State<VehicleSelectorSheet> createState() => _VehicleSelectorSheetState();
}

class _VehicleSelectorSheetState extends State<VehicleSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<VehicleModel> _filteredVehicles = [];

  @override
  void initState() {
    super.initState();
    _filteredVehicles = widget.vehicles;
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(SizeTokens.radiusXl)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: SizeTokens.spacingMd),
              width: SizeTokens.spacing5xl,
              height: 4,
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
                Text(
                  'Araç Seçin',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: EdgeInsets.all(SizeTokens.spacingLg),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Araç markası, model veya plaka ara...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: SizeTokens.iconSm),
                hintStyle: TextStyle(fontSize: SizeTokens.fontSm),
              ),
            ),
          ),

          // List
          Expanded(
            child: _filteredVehicles.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingLg),
                    itemCount: _filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = _filteredVehicles[index];
                      final isSelected = widget.selectedVehicle?.id == vehicle.id;
                      
                      return _VehicleSelectionRow(
                        vehicle: vehicle,
                        isSelected: isSelected,
                        onSelect: () => Navigator.pop(context, vehicle),
                        onDetail: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider(
                                create: (_) => VehicleDetailViewModel(
                                    vehicleId: vehicle.id ?? 0),
                                child: VehicleDetailView(initialVehicle: vehicle),
                              ),
                            ),
                          );
                        },
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
          Icon(Icons.directions_car_filled_outlined, size: SizeTokens.spacing5xl, color: AppTheme.border),
          SizedBox(height: SizeTokens.spacingMd),
          Text(
            'Araç bulunamadı',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: SizeTokens.fontMd),
          ),
        ],
      ),
    );
  }
}

class _VehicleSelectionRow extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onDetail;

  const _VehicleSelectionRow({
    required this.vehicle,
    required this.isSelected,
    required this.onSelect,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = vehicle.imageUrl?.isNotEmpty == true
        ? vehicle.imageUrl!
        : VehicleImageHelper.getAssetPath(vehicle.brand, vehicle.model);

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.spacingMd),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accent.withValues(alpha: 0.04) : AppTheme.surface,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        border: Border.all(
          color: isSelected ? AppTheme.accent : AppTheme.border,
          width: isSelected ? SizeTokens.borderMedium : SizeTokens.borderThin,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(SizeTokens.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(SizeTokens.spacingMd),
          child: Row(
            children: [
              // Image
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
                    color: AppTheme.background,
                    child: Icon(Icons.directions_car, color: AppTheme.textTertiary),
                  ),
                ),
              ),
              SizedBox(width: SizeTokens.spacingMd),
              
              // Name & Plate
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: SizeTokens.fontSm,
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

              // Detail Button
              TextButton(
                onPressed: onDetail,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(horizontal: SizeTokens.spacingSm, vertical: SizeTokens.spacingXs),
                ),
                child: Text(
                  'Detay',
                  style: TextStyle(fontSize: SizeTokens.fontXs, color: AppTheme.accent, fontWeight: FontWeight.w600),
                ),
              ),

              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(left: SizeTokens.spacingSm),
                  child: Icon(Icons.check_circle, color: AppTheme.accent, size: SizeTokens.iconSm),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/forge_response.dart';
import '../widgets/forge_app_bar.dart';
import '../widgets/vendor_tile.dart';

class VendorMapScreen extends StatefulWidget {
  final List<VendorInfo> vendors;

  const VendorMapScreen({super.key, required this.vendors});

  @override
  State<VendorMapScreen> createState() => _VendorMapScreenState();
}

class _VendorMapScreenState extends State<VendorMapScreen> {
  VendorInfo? _selectedVendor;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    if (widget.vendors.isNotEmpty) {
      _selectedVendor = widget.vendors.first;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (widget.vendors.isNotEmpty) {
      final latLng = LatLng(widget.vendors.first.lat, widget.vendors.first.lng);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 12));
    }
  }

  void _openDirections(VendorInfo vendor) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${vendor.lat},${vendor.lng}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showVendorDetails(VendorInfo vendor) {
    setState(() => _selectedVendor = vendor);
    _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(vendor.lat, vendor.lng)));
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => VendorDetailSheet(
        vendor: vendor,
        onGetDirections: () {
          Navigator.pop(context);
          _openDirections(vendor);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = widget.vendors.map((v) {
      return Marker(
        markerId: MarkerId(v.name),
        position: LatLng(v.lat, v.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _selectedVendor == v ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueAzure,
        ),
        onTap: () => _showVendorDetails(v),
      );
    }).toSet();

    // Default to Bangalore if no vendors
    final initialPos = widget.vendors.isNotEmpty 
        ? LatLng(widget.vendors.first.lat, widget.vendors.first.lng)
        : const LatLng(12.9716, 77.5946);

    // Show the back button only when this screen is pushed on top of another screen
    final showBack = Navigator.of(context).canPop();

    return Scaffold(
      appBar: ForgeAppBar(title: 'Vendor Map', showBackButton: showBack),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: initialPos, zoom: 11),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Empty state message when no vendors
          if (widget.vendors.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(kSpaceLG),
                margin: const EdgeInsets.all(kSpaceMarginMobile),
                decoration: BoxDecoration(
                  color: kSurfaceContainerLowest.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(kRadiusLG),
                  boxShadow: kSoftShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.store_mall_directory, size: 48, color: kPrimary),
                    const SizedBox(height: kSpaceMD),
                    const Text('No Vendors Yet', style: kHeadlineMd),
                    const SizedBox(height: kSpaceSM),
                    Text(
                      'Search for a material first.\nLocal vendors will appear here.',
                      textAlign: TextAlign.center,
                      style: kBodyMd.copyWith(color: kSecondary),
                    ),
                  ],
                ),
              ),
            ),

          // Filter Chips overlay (only when vendors exist)
          if (widget.vendors.isNotEmpty)
            Positioned(
              top: kSpaceMD,
              left: kSpaceMarginMobile,
              right: kSpaceMarginMobile,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(label: 'Nearest', isSelected: true),
                    const SizedBox(width: kSpaceSM),
                    _FilterChip(label: 'Highest Rated', isSelected: false),
                    const SizedBox(width: kSpaceSM),
                    _FilterChip(label: 'Open Now', isSelected: false),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: widget.vendors.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton(
                onPressed: () {
                  _showVendorDetails(widget.vendors.first);
                },
                backgroundColor: kSurfaceContainerLowest,
                child: const Icon(Icons.list, color: kPrimary),
              ),
            )
          : null,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? kPrimary : kSurfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 4)],
      ),
      child: Text(
        label,
        style: kLabelMd.copyWith(color: isSelected ? Colors.white : kOnSurface),
      ),
    );
  }
}

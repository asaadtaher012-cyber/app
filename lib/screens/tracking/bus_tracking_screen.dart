import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../services/localization_service.dart';
import '../../utils/theme.dart';

class BusTrackingScreen extends StatefulWidget {
  const BusTrackingScreen({super.key});

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _busPosition;
  Set<Marker> _markers = {};
  bool _isTracking = false;
  String _busStatus = 'waiting';
  int _estimatedArrival = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startBusTracking();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _startBusTracking() {
    setState(() {
      _isTracking = true;
      _busStatus = 'on_route';
      _estimatedArrival = 15; // minutes
    });

    // Simulate bus movement
    _simulateBusMovement();
  }

  void _simulateBusMovement() {
    if (_currentPosition != null) {
      // Simulate bus position (in real app, this would come from server)
      _busPosition = LatLng(
        _currentPosition!.latitude + 0.01,
        _currentPosition!.longitude + 0.01,
      );

      setState(() {
        _markers = {
          Marker(
            markerId: MarkerId('current_location'),
            position: _currentPosition!,
            infoWindow: InfoWindow(title: 'موقعك الحالي'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
          Marker(
            markerId: MarkerId('bus_location'),
            position: _busPosition!,
            infoWindow: InfoWindow(title: 'موقع الحافلة'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('تتبع الحافلة'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status Card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _busStatus == 'on_route' 
                        ? AppTheme.successColor 
                        : AppTheme.warningColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _busStatus == 'on_route' 
                        ? Icons.directions_bus 
                        : Icons.schedule,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _busStatus == 'on_route' 
                            ? 'الحافلة في الطريق' 
                            : 'في انتظار الحافلة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'الوصول المتوقع: $_estimatedArrival دقيقة',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isTracking)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'مباشر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Map
          Expanded(
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 15,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
          ),
          
          // Action Buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'تم الإرسال',
                        'تم إرسال إشعار للسائق',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppTheme.successColor,
                        colorText: Colors.white,
                      );
                    },
                    icon: Icon(Icons.notifications),
                    label: Text('تنبيه السائق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'تم الإرسال',
                        'تم إرسال رسالة طوارئ',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppTheme.errorColor,
                        colorText: Colors.white,
                      );
                    },
                    icon: Icon(Icons.emergency),
                    label: Text('طوارئ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(color: AppTheme.errorColor),
                    ),
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

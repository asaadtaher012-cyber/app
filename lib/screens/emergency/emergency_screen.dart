import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/localization_service.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  LatLng? _currentPosition;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      'name': 'الطوارئ العامة',
      'number': '911',
      'icon': Icons.emergency,
      'color': AppTheme.errorColor,
    },
    {
      'name': 'شرطة النقل',
      'number': '123',
      'icon': Icons.local_police,
      'color': AppTheme.primaryColor,
    },
    {
      'name': 'الإسعاف',
      'number': '997',
      'icon': Icons.medical_services,
      'color': AppTheme.successColor,
    },
    {
      'name': 'المطافئ',
      'number': '998',
      'icon': Icons.fire_truck,
      'color': AppTheme.warningColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

  Future<void> _sendEmergencyAlert() async {
    if (_currentPosition == null) {
      Get.snackbar(
        'خطأ',
        'لا يمكن تحديد موقعك الحالي',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId != null) {
        // Send emergency alert to database
        await _firestore.collection('emergencyAlerts').add({
          'userId': userId,
          'location': GeoPoint(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          'timestamp': Timestamp.now(),
          'status': 'active',
          'type': 'emergency',
        });

        // Send notification to admin
        await _firestore.collection('notifications').add({
          'userId': 'admin',
          'title': 'تنبيه طوارئ',
          'body': 'تم إرسال تنبيه طوارئ من أحد المستخدمين',
          'timestamp': Timestamp.now(),
          'type': 'emergency',
          'data': {
            'userId': userId,
            'location': {
              'latitude': _currentPosition!.latitude,
              'longitude': _currentPosition!.longitude,
            },
          },
        });

        Get.snackbar(
          'تم الإرسال',
          'تم إرسال تنبيه الطوارئ بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إرسال التنبيه',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _callEmergencyContact(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'خطأ',
          'لا يمكن فتح تطبيق الهاتف',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الاتصال',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطوارئ'),
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Alert Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.errorColor,
                    AppTheme.errorColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emergency,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تنبيه طوارئ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اضغط هنا لإرسال تنبيه طوارئ فوري',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendEmergencyAlert,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.errorColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.errorColor,
                              ),
                            ),
                          )
                        : const Text(
                            'إرسال تنبيه طوارئ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Emergency Contacts
            const Text(
              'أرقام الطوارئ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._emergencyContacts.map((contact) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: contact['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        contact['icon'],
                        color: contact['color'],
                        size: 24,
                      ),
                    ),
                    title: Text(
                      contact['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      contact['number'],
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _callEmergencyContact(contact['number']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: contact['color'],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.phone),
                    ),
                  ),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 24),
            
            // Safety Tips
            const Text(
              'نصائح السلامة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSafetyTip(
              'في حالة الطوارئ',
              'ابق هادئاً واتصل برقم الطوارئ المناسب',
              Icons.warning,
              AppTheme.warningColor,
            ),
            _buildSafetyTip(
              'أثناء الرحلة',
              'التزم بقواعد السلامة واربط حزام الأمان',
              Icons.security,
              AppTheme.primaryColor,
            ),
            _buildSafetyTip(
              'مع الأطفال',
              'تأكد من وجود الأطفال في مكان آمن',
              Icons.child_care,
              AppTheme.successColor,
            ),
            _buildSafetyTip(
              'الموقع',
              'تأكد من تحديد موقعك بدقة عند الطوارئ',
              Icons.location_on,
              AppTheme.accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTip(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
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
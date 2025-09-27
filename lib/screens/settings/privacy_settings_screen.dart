import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/localization_service.dart';
import '../../utils/theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _locationTracking = true;
  bool _notifications = true;
  bool _dataCollection = false;
  bool _analytics = false;
  bool _crashReporting = false;
  bool _personalizedAds = false;
  bool _shareDataWithPartners = false;
  bool _emergencyContacts = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _locationTracking = prefs.getBool('location_tracking') ?? true;
      _notifications = prefs.getBool('notifications') ?? true;
      _dataCollection = prefs.getBool('data_collection') ?? false;
      _analytics = prefs.getBool('analytics') ?? false;
      _crashReporting = prefs.getBool('crash_reporting') ?? false;
      _personalizedAds = prefs.getBool('personalized_ads') ?? false;
      _shareDataWithPartners = prefs.getBool('share_data_with_partners') ?? false;
      _emergencyContacts = prefs.getBool('emergency_contacts') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات الخصوصية'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Overview
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حماية خصوصيتك',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'نحن نلتزم بحماية خصوصيتك وبياناتك الشخصية',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Location Settings
            _buildSectionTitle('إعدادات الموقع'),
            _buildSwitchTile(
              'تتبع الموقع',
              'السماح للتطبيق بتتبع موقعك لتوفير خدمات أفضل',
              _locationTracking,
              (value) {
                setState(() => _locationTracking = value);
                _saveSetting('location_tracking', value);
              },
              Icons.location_on,
            ),
            
            SizedBox(height: 16),
            
            // Notification Settings
            _buildSectionTitle('إعدادات الإشعارات'),
            _buildSwitchTile(
              'الإشعارات',
              'تلقي إشعارات حول الرحلات والتحديثات',
              _notifications,
              (value) {
                setState(() => _notifications = value);
                _saveSetting('notifications', value);
              },
              Icons.notifications,
            ),
            
            SizedBox(height: 16),
            
            // Data Collection Settings
            _buildSectionTitle('جمع البيانات'),
            _buildSwitchTile(
              'جمع البيانات',
              'السماح بجمع البيانات لتحسين الخدمة',
              _dataCollection,
              (value) {
                setState(() => _dataCollection = value);
                _saveSetting('data_collection', value);
              },
              Icons.data_usage,
            ),
            
            _buildSwitchTile(
              'التحليلات',
              'جمع بيانات الاستخدام للتحليل',
              _analytics,
              (value) {
                setState(() => _analytics = value);
                _saveSetting('analytics', value);
              },
              Icons.analytics,
            ),
            
            _buildSwitchTile(
              'تقرير الأخطاء',
              'إرسال تقارير الأخطاء لتحسين التطبيق',
              _crashReporting,
              (value) {
                setState(() => _crashReporting = value);
                _saveSetting('crash_reporting', value);
              },
              Icons.bug_report,
            ),
            
            SizedBox(height: 16),
            
            // Advertising Settings
            _buildSectionTitle('الإعلانات'),
            _buildSwitchTile(
              'الإعلانات المخصصة',
              'عرض إعلانات مخصصة حسب اهتماماتك',
              _personalizedAds,
              (value) {
                setState(() => _personalizedAds = value);
                _saveSetting('personalized_ads', value);
              },
              Icons.ad_units,
            ),
            
            _buildSwitchTile(
              'مشاركة البيانات مع الشركاء',
              'السماح بمشاركة البيانات مع شركاء الإعلان',
              _shareDataWithPartners,
              (value) {
                setState(() => _shareDataWithPartners = value);
                _saveSetting('share_data_with_partners', value);
              },
              Icons.share,
            ),
            
            SizedBox(height: 16),
            
            // Emergency Settings
            _buildSectionTitle('إعدادات الطوارئ'),
            _buildSwitchTile(
              'جهات الاتصال الطارئة',
              'السماح بالوصول لجهات الاتصال في حالات الطوارئ',
              _emergencyContacts,
              (value) {
                setState(() => _emergencyContacts = value);
                _saveSetting('emergency_contacts', value);
              },
              Icons.emergency,
            ),
            
            SizedBox(height: 24),
            
            // Privacy Policy and Terms
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات إضافية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildInfoTile(
                    'سياسة الخصوصية',
                    'اقرأ سياسة الخصوصية الكاملة',
                    Icons.privacy_tip,
                    () {
                      Get.snackbar(
                        'قريباً',
                        'سياسة الخصوصية قريباً',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  _buildInfoTile(
                    'شروط الاستخدام',
                    'اقرأ شروط الاستخدام',
                    Icons.description,
                    () {
                      Get.snackbar(
                        'قريباً',
                        'شروط الاستخدام قريباً',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  _buildInfoTile(
                    'حذف البيانات',
                    'حذف جميع البيانات الشخصية',
                    Icons.delete_forever,
                    () {
                      _showDeleteDataDialog();
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'تم الحفظ',
                    'تم حفظ إعدادات الخصوصية بنجاح',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.successColor,
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'حفظ الإعدادات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: SwitchListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          value: value,
          onChanged: onChanged,
          secondary: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          activeColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showDeleteDataDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('حذف البيانات'),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف جميع البيانات الشخصية؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم الحذف',
                'تم حذف البيانات الشخصية',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.successColor,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}

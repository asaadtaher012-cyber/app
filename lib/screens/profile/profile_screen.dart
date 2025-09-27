import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../services/localization_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../settings/privacy_settings_screen.dart';
import '../../utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.getText('Profile')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Get.offAll(() => LoginScreen());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    authService.currentUser?.displayName ?? 'المستخدم',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    authService.currentUser?.email ?? 'user@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            
            // Profile Options
            _buildProfileOption(
              context,
              Icons.person,
              localizationService.getText('your_info'),
              'إدارة معلوماتك الشخصية',
              () => Get.snackbar('قريباً', 'ميزة تعديل الملف الشخصي قريباً'),
            ),
            _buildProfileOption(
              context,
              Icons.language,
              localizationService.getText('language'),
              'تغيير اللغة',
              () => _showLanguageDialog(context),
            ),
            _buildProfileOption(
              context,
              Icons.notifications,
              localizationService.getText('notifications'),
              'إدارة الإشعارات',
              () => Get.snackbar('قريباً', 'ميزة الإشعارات قريباً'),
            ),
            _buildProfileOption(
              context,
              Icons.payment,
              localizationService.getText('payment_methods'),
              'طرق الدفع',
              () => Get.snackbar('قريباً', 'ميزة الدفع قريباً'),
            ),
            _buildProfileOption(
              context,
              Icons.privacy_tip,
              'إعدادات الخصوصية',
              'إدارة إعدادات الخصوصية والأمان',
              () => Get.to(() => PrivacySettingsScreen()),
            ),
            _buildProfileOption(
              context,
              Icons.help,
              localizationService.getText('help'),
              'المساعدة والدعم',
              () => Get.snackbar('قريباً', 'ميزة المساعدة قريباً'),
            ),
            _buildProfileOption(
              context,
              Icons.info,
              localizationService.getText('about_app'),
              'حول التطبيق',
              () => _showAboutDialog(context),
            ),
            _buildProfileOption(
              context,
              Icons.logout,
              localizationService.getText('logout'),
              'تسجيل الخروج',
              () => _showLogoutDialog(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDestructive 
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.blue,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDestructive ? Colors.red : null,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationService.getText('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.language, color: Colors.blue),
              title: Text(localizationService.getText('language_arabic')),
              onTap: () {
                localizationService.changeLanguage('ar');
                Navigator.pop(context);
                Get.snackbar(
                  'نجح',
                  'تم تغيير اللغة إلى العربية',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.green),
              title: Text(localizationService.getText('language_english')),
              onTap: () {
                localizationService.changeLanguage('en');
                Navigator.pop(context);
                Get.snackbar(
                  'Success',
                  'Language changed to English',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حول التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 60, color: Colors.blue),
            SizedBox(height: 15),
            Text(
              'Schoolz - Gold Bus',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('الإصدار: 1.0.0'),
            SizedBox(height: 10),
            Text(
              'تطبيق إدارة النقل المدرسي الذكي',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تسجيل الخروج'),
        content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              Get.offAll(() => LoginScreen());
            },
            child: Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
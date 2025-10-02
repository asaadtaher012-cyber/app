import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../services/localization_service.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';
import '../auth/login_screen.dart';
import '../kids/kids_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../tracking/bus_tracking_screen.dart';
import '../rating/driver_rating_screen.dart';
import '../reports/reports_screen.dart';
import '../loyalty/loyalty_screen.dart';
import '../emergency/emergency_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeTab(),
    const KidsScreen(),
    const MapScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: localizationService.getText('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.child_care),
            label: localizationService.getText('Kids'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: localizationService.getText('Map'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: localizationService.getText('Profile'),
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.getText('schoolz')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Get.snackbar(
                'إشعارات',
                'لا توجد إشعارات جديدة',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Get.offAll(() => const LoginScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizationService.getText('welcome'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Consumer<AuthService>(
                    builder: (context, authService, child) => Text(
                      authService.currentUser?.email ?? 'user@example.com',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildServiceCard(
                    context,
                    Icons.child_care,
                    localizationService.getText('Kids'),
                    AppTheme.primaryColor,
                    () => Get.to(() => const KidsScreen()),
                  ),
                  _buildServiceCard(
                    context,
                    Icons.map,
                    localizationService.getText('Map'),
                    AppTheme.successColor,
                    () => Get.to(() => const MapScreen()),
                  ),
                  _buildServiceCard(
                    context,
                    Icons.track_changes,
                    'تتبع الحافلة',
                    AppTheme.primaryColor,
                    () => Get.to(() => const BusTrackingScreen()),
                  ),
                  _buildServiceCard(
                    context,
                    Icons.star_rate,
                    'تقييم السائق',
                    AppTheme.accentColor,
                    () => Get.to(() => DriverRatingScreen(
                      tripId: 'trip_123',
                      driverName: 'أحمد محمد',
                      driverImage: 'https://example.com/driver.jpg',
                    )),
                  ),
                  _buildServiceCard(
                    context,
                    Icons.assessment,
                    'التقارير',
                    AppTheme.successColor,
                    () => Get.to(() => const ReportsScreen()),
                  ),
                  _buildServiceCard(
                    context,
                    Icons.card_giftcard,
                    'نقاط الولاء',
                    AppTheme.warningColor,
                    () => Get.to(() => const LoyaltyScreen()),
                  ),
                  _buildServiceCard(
                    context,
                    Icons.emergency,
                    'الطوارئ',
                    AppTheme.errorColor,
                    () => Get.to(() => const EmergencyScreen()),
                  ),
                  _buildServiceCard(
                    context,
                    Icons.report_problem,
                    localizationService.getText('Complaints'),
                    AppTheme.accentColor,
                    () => Get.snackbar('قريباً', 'ميزة الشكاوى قريباً'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
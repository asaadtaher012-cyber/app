import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/localization_service.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentPoints = 0;
  int _totalPoints = 0;
  String _currentLevel = 'مبتدئ';
  List<Map<String, dynamic>> _rewards = [];
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyData();
  }

  Future<void> _loadLoyaltyData() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId != null) {
        // Load user loyalty data
        final userDoc = await _firestore
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            _currentPoints = userData['loyaltyPoints'] ?? 0;
            _totalPoints = userData['totalPoints'] ?? 0;
            _currentLevel = _getLevelFromPoints(_currentPoints);
          });
        }

        // Load rewards
        final rewardsSnapshot = await _firestore
            .collection('rewards')
            .orderBy('pointsRequired')
            .get();

        setState(() {
          _rewards = rewardsSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': data['title'] ?? '',
              'description': data['description'] ?? '',
              'pointsRequired': data['pointsRequired'] ?? 0,
              'isAvailable': _currentPoints >= (data['pointsRequired'] ?? 0),
              'icon': data['icon'] ?? 'gift',
            };
          }).toList();
        });

        // Load history
        final historySnapshot = await _firestore
            .collection('loyaltyHistory')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();

        setState(() {
          _history = historySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'type': data['type'] ?? '',
              'points': data['points'] ?? 0,
              'description': data['description'] ?? '',
              'createdAt': data['createdAt'] ?? Timestamp.now(),
            };
          }).toList();
        });
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل بيانات الولاء',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getLevelFromPoints(int points) {
    if (points >= 1000) return 'مميز';
    if (points >= 500) return 'متقدم';
    if (points >= 200) return 'متوسط';
    return 'مبتدئ';
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'مميز':
        return AppTheme.accentColor;
      case 'متقدم':
        return AppTheme.primaryColor;
      case 'متوسط':
        return AppTheme.successColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  Future<void> _claimReward(Map<String, dynamic> reward) async {
    if (!reward['isAvailable']) {
      Get.snackbar(
        'غير متاح',
        'نقاطك غير كافية لهذه المكافأة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.warningColor,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId != null) {
        // Update user points
        await _firestore.collection('users').doc(userId).update({
          'loyaltyPoints': FieldValue.increment(-reward['pointsRequired']),
        });

        // Add to history
        await _firestore.collection('loyaltyHistory').add({
          'userId': userId,
          'type': 'reward_claimed',
          'points': -reward['pointsRequired'],
          'description': 'استبدال مكافأة: ${reward['title']}',
          'createdAt': Timestamp.now(),
        });

        Get.snackbar(
          'تم الاستبدال',
          'تم استبدال المكافأة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );

        _loadLoyaltyData();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء استبدال المكافأة',
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
        title: Text('نقاط الولاء'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLoyaltyData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Points Summary Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'نقاطك الحالية',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  '$_currentPoints',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'مستواك',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _currentLevel,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: _currentPoints / 1000,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${_currentPoints} / 1000 نقطة للوصول للمستوى التالي',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Rewards Section
                  Text(
                    'المكافآت المتاحة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  ..._rewards.map((reward) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: reward['isAvailable'] 
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getRewardIcon(reward['icon']),
                              color: reward['isAvailable'] 
                                  ? AppTheme.primaryColor
                                  : Colors.grey,
                            ),
                          ),
                          title: Text(
                            reward['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            reward['description'],
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${reward['pointsRequired']} نقطة',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              if (reward['isAvailable'])
                                ElevatedButton(
                                  onPressed: () => _claimReward(reward),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                  ),
                                  child: Text(
                                    'استبدال',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  SizedBox(height: 24),
                  
                  // History Section
                  Text(
                    'سجل النقاط',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  ..._history.map((item) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: (item['points'] > 0 
                                  ? AppTheme.successColor 
                                  : AppTheme.errorColor).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              item['points'] > 0 
                                  ? Icons.add 
                                  : Icons.remove,
                              color: item['points'] > 0 
                                  ? AppTheme.successColor 
                                  : AppTheme.errorColor,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  _formatDate(item['createdAt']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item['points'] > 0 ? '+' : ''}${item['points']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: item['points'] > 0 
                                  ? AppTheme.successColor 
                                  : AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  IconData _getRewardIcon(String iconName) {
    switch (iconName) {
      case 'gift':
        return Icons.card_giftcard;
      case 'discount':
        return Icons.local_offer;
      case 'free_ride':
        return Icons.directions_bus;
      case 'upgrade':
        return Icons.star;
      default:
        return Icons.card_giftcard;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}

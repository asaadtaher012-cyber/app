import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../services/localization_service.dart';
import '../../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupNotificationHandlers();
  }

  Future<void> _loadNotifications() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;
      
      if (userId != null) {
        final snapshot = await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
        
        setState(() {
          _notifications = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': data['title'] ?? '',
              'body': data['body'] ?? '',
              'isRead': data['isRead'] ?? false,
              'createdAt': data['createdAt'],
              'type': data['type'] ?? 'general',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('خطأ', 'فشل في تحميل الإشعارات: $e');
    }
  }

  void _setupNotificationHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Get.snackbar(
        message.notification?.title ?? 'إشعار جديد',
        message.notification?.body ?? '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      _loadNotifications(); // Reload notifications
    });

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _loadNotifications(); // Reload notifications
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['isRead'] = true;
        }
      });
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحديث الإشعار');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;
      
      if (userId != null) {
        final batch = _firestore.batch();
        final unreadNotifications = _notifications.where((n) => !n['isRead']);
        
        for (final notification in unreadNotifications) {
          final docRef = _firestore.collection('notifications').doc(notification['id']);
          batch.update(docRef, {'isRead': true});
        }
        
        await batch.commit();
        _loadNotifications();
        Get.snackbar('نجح', 'تم تحديد جميع الإشعارات كمقروءة');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحديث الإشعارات');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      setState(() {
        _notifications.removeWhere((n) => n['id'] == notificationId);
      });
      Get.snackbar('نجح', 'تم حذف الإشعار');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف الإشعار');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.getText('notifications')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.any((n) => !n['isRead']))
            IconButton(
              icon: Icon(Icons.mark_email_read),
              onPressed: _markAllAsRead,
              tooltip: 'تحديد الكل كمقروء',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('جاري تحميل الإشعارات...'),
                ],
              ),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 20),
                      Text(
                        localizationService.getText('no_have_notifications'),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isRead = notification['isRead'] as bool;
                    final createdAt = notification['createdAt'] as Timestamp?;
                    final type = notification['type'] as String;
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: isRead ? 1 : 3,
                      color: isRead ? Colors.grey[50] : Colors.blue[50],
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getNotificationColor(type),
                          child: Icon(
                            _getNotificationIcon(type),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          notification['title'],
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification['body']),
                            SizedBox(height: 4),
                            Text(
                              _formatDate(createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            if (!isRead)
                              PopupMenuItem(
                                value: 'mark_read',
                                child: Row(
                                  children: [
                                    Icon(Icons.mark_email_read),
                                    SizedBox(width: 8),
                                    Text('تحديد كمقروء'),
                                  ],
                                ),
                              ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('حذف', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'mark_read') {
                              _markAsRead(notification['id']);
                            } else if (value == 'delete') {
                              _deleteNotification(notification['id']);
                            }
                          },
                        ),
                        onTap: () {
                          if (!isRead) {
                            _markAsRead(notification['id']);
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'trip':
        return Colors.green;
      case 'payment':
        return Colors.orange;
      case 'emergency':
        return Colors.red;
      case 'system':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'trip':
        return Icons.directions_bus;
      case 'payment':
        return Icons.payment;
      case 'emergency':
        return Icons.warning;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}


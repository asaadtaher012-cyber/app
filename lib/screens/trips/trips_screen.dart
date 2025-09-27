import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../services/localization_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import 'book_trip_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});
  
  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;
      
      if (userId != null) {
        final snapshot = await _firestore
            .collection('trips')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
        
        setState(() {
          _trips = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'from': data['from'] ?? '',
              'to': data['to'] ?? '',
              'date': data['date'] ?? '',
              'time': data['time'] ?? '',
              'status': data['status'] ?? 'pending',
              'price': data['price'] ?? 0.0,
              'createdAt': data['createdAt'],
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
      Get.snackbar('خطأ', 'فشل في تحميل الرحلات: $e');
    }
  }

  void _navigateToBookTrip() {
    Get.to(() => BookTripScreen())?.then((_) {
      _loadTrips(); // Reload trips after booking
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'مؤكد';
      case 'pending':
        return 'في الانتظار';
      case 'cancelled':
        return 'ملغي';
      case 'completed':
        return 'مكتمل';
      default:
        return 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.getText('Trip History')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTrips,
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
                  Text('جاري تحميل الرحلات...'),
                ],
              ),
            )
          : _trips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_bus,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 20),
                      Text(
                        localizationService.getText('You do not have trips'),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 30),
                      CustomButton(
                        text: localizationService.getText('order_ride'),
                        onPressed: _navigateToBookTrip,
                        width: 200,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Book Trip Button
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      child: CustomButton(
                        text: localizationService.getText('order_ride'),
                        onPressed: _navigateToBookTrip,
                      ),
                    ),
                    
                    // Trips List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
                          final status = trip['status'] as String;
                          final createdAt = trip['createdAt'] as Timestamp?;
                          
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(status),
                                child: Icon(
                                  Icons.directions_bus,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                'من ${trip['from']} إلى ${trip['to']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('التاريخ: ${trip['date']}'),
                                  Text('الوقت: ${trip['time']}'),
                                  Text('السعر: ${trip['price']} دج'),
                                  if (createdAt != null)
                                    Text(
                                      'تم الحجز: ${_formatDate(createdAt)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(status),
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              onTap: () {
                                _showTripDetails(trip);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  void _showTripDetails(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الرحلة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('من: ${trip['from']}'),
            Text('إلى: ${trip['to']}'),
            Text('التاريخ: ${trip['date']}'),
            Text('الوقت: ${trip['time']}'),
            Text('السعر: ${trip['price']} دج'),
            Text('الحالة: ${_getStatusText(trip['status'])}'),
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

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}


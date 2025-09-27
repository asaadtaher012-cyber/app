import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/localization_service.dart';
import '../../services/auth_service.dart';
import 'add_kid_screen.dart';

class KidsScreen extends StatefulWidget {
  const KidsScreen({super.key});
  
  @override
  State<KidsScreen> createState() => _KidsScreenState();
}

class _KidsScreenState extends State<KidsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _kids = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKids();
  }

  Future<void> _loadKids() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;
      
      if (userId != null) {
        final snapshot = await _firestore
            .collection('kids')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
        
        setState(() {
          _kids = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? '',
              'age': data['age'] ?? 0,
              'grade': data['grade'] ?? '',
              'school': data['school'] ?? '',
              'gender': data['gender'] ?? '',
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
      Get.snackbar('خطأ', 'فشل في تحميل بيانات الأطفال: $e');
    }
  }

  Future<void> _deleteKid(String kidId) async {
    try {
      await _firestore.collection('kids').doc(kidId).delete();
      setState(() {
        _kids.removeWhere((kid) => kid['id'] == kidId);
      });
      Get.snackbar('نجح', 'تم حذف الطفل');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف الطفل');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.getText('Kids')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Get.to(() => AddKidScreen())?.then((_) {
                _loadKids(); // Reload kids after adding
              });
            },
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
                  Text('جاري تحميل بيانات الأطفال...'),
                ],
              ),
            )
          : Column(
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.child_care,
                        size: 50,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Text(
                        localizationService.getText('Kids'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'إدارة أبنائك في النقل المدرسي',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Kids List
                Expanded(
                  child: _kids.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.child_care,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                localizationService.getText('You do not have kids'),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'أضف أبنائك للبدء في استخدام خدمات النقل المدرسي',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: 30),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(() => AddKidScreen())?.then((_) {
                                    _loadKids();
                                  });
                                },
                                icon: Icon(Icons.add),
                                label: Text(localizationService.getText('Add new')),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _kids.length,
                          itemBuilder: (context, index) {
                            final kid = _kids[index];
                            final gender = kid['gender'] as String;
                            
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: gender == 'Boy' ? Colors.blue : Colors.pink,
                                  child: Icon(
                                    gender == 'Boy' ? Icons.boy : Icons.girl,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  kid['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('العمر: ${kid['age']} سنة'),
                                    Text('الصف: ${kid['grade']}'),
                                    Text('المدرسة: ${kid['school']}'),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text('تعديل'),
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
                                    if (value == 'delete') {
                                      _showDeleteDialog(kid['id'], kid['name']);
                                    } else if (value == 'edit') {
                                      Get.to(() => AddKidScreen(kidData: kid))?.then((_) {
                                        _loadKids();
                                      });
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _showDeleteDialog(String kidId, String kidName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الطفل'),
        content: Text('هل أنت متأكد من حذف $kidName؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteKid(kidId);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
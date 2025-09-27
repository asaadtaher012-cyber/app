import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class BookTripScreen extends StatefulWidget {
  const BookTripScreen({super.key});
  
  @override
  State<BookTripScreen> createState() => _BookTripScreenState();
}

class _BookTripScreenState extends State<BookTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  
  final List<String> _locations = [
    'الجزائر العاصمة',
    'وهران',
    'قسنطينة',
    'عنابة',
    'باتنة',
    'بجاية',
    'سطيف',
    'تيزي وزو',
    'البيض',
    'الوادي',
  ];

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  double _calculatePrice() {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      return 0.0;
    }
    
    // Simple price calculation based on distance
    final fromIndex = _locations.indexOf(_fromController.text);
    final toIndex = _locations.indexOf(_toController.text);
    
    if (fromIndex == -1 || toIndex == -1) return 0.0;
    
    final distance = (fromIndex - toIndex).abs();
    return (distance + 1) * 50.0; // 50 DZD per city
  }

  Future<void> _bookTrip() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;
      
      if (userId == null) {
        Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً');
        return;
      }
      
      final price = _calculatePrice();
      
      await _firestore.collection('trips').add({
        'userId': userId,
        'from': _fromController.text,
        'to': _toController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'price': price,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Send notification
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': 'تم حجز الرحلة بنجاح',
        'body': 'تم حجز رحلة من ${_fromController.text} إلى ${_toController.text}',
        'type': 'trip',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      Get.snackbar('نجح', 'تم حجز الرحلة بنجاح!');
      Get.back();
      
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حجز الرحلة: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = _calculatePrice();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('حجز رحلة جديدة'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
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
                      Icons.directions_bus,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'حجز رحلة جديدة',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'احجز رحلتك المدرسية بسهولة',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              
              // From Location
              Text(
                'نقطة الانطلاق',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _fromController.text.isEmpty ? null : _fromController.text,
                decoration: InputDecoration(
                  hintText: 'اختر نقطة الانطلاق',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.location_on),
                ),
                items: _locations.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _fromController.text = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب اختيار نقطة الانطلاق';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              
              // To Location
              Text(
                'نقطة الوصول',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _toController.text.isEmpty ? null : _toController.text,
                decoration: InputDecoration(
                  hintText: 'اختر نقطة الوصول',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.location_on),
                ),
                items: _locations.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _toController.text = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب اختيار نقطة الوصول';
                  }
                  if (value == _fromController.text) {
                    return 'نقطة الانطلاق والوصول يجب أن تكونا مختلفتين';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              
              // Date and Time Row
              Row(
                children: [
                  // Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التاريخ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'اختر التاريخ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: _selectDate,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يجب اختيار التاريخ';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  
                  // Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الوقت',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _timeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'اختر الوقت',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          onTap: _selectTime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يجب اختيار الوقت';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              
              // Price Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'السعر المقدر',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        Text(
                          'بناءً على المسافة',
                          style: TextStyle(
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${price.toStringAsFixed(0)} دج',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              
              // Book Button
              CustomButton(
                text: _isLoading ? 'جاري الحجز...' : 'حجز الرحلة',
                onPressed: _isLoading ? null : _bookTrip,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../services/localization_service.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddKidScreen extends StatefulWidget {
  final Map<String, dynamic>? kidData;
  
  const AddKidScreen({super.key, this.kidData});
  
  @override
  State<AddKidScreen> createState() => _AddKidScreenState();
}

class _AddKidScreenState extends State<AddKidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _schoolController = TextEditingController();
  final _classController = TextEditingController();
  String _selectedGender = 'ولد';
  String _selectedLevel = 'ابتدائي';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.kidData != null) {
      _loadKidData();
    }
  }

  void _loadKidData() {
    final data = widget.kidData!;
    _nameController.text = data['name'] ?? '';
    _ageController.text = data['age']?.toString() ?? '';
    _schoolController.text = data['school'] ?? '';
    _classController.text = data['grade'] ?? '';
    _selectedGender = data['gender'] ?? 'ولد';
    _selectedLevel = data['level'] ?? 'ابتدائي';
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.getText('Add new')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
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
                          Icons.child_care,
                          size: 50,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          localizationService.getText('child information'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  // Form Fields
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: localizationService.getText('kid_name'),
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizationService.getText('Name Is Require');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'العمر',
                      prefixIcon: Icon(Icons.cake),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'العمر مطلوب';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: localizationService.getText('kid_type'),
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'ولد', child: Text(localizationService.getText('Boy'))),
                      DropdownMenuItem(value: 'بنت', child: Text(localizationService.getText('Girl'))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: InputDecoration(
                      labelText: localizationService.getText('Education period'),
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'ابتدائي', child: Text('ابتدائي')),
                      DropdownMenuItem(value: 'إعدادي', child: Text('إعدادي')),
                      DropdownMenuItem(value: 'ثانوي', child: Text('ثانوي')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _schoolController,
                    decoration: InputDecoration(
                      labelText: 'اسم المدرسة',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'اسم المدرسة مطلوب';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _classController,
                    decoration: InputDecoration(
                      labelText: 'الصف الدراسي',
                      prefixIcon: Icon(Icons.class_),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الصف الدراسي مطلوب';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addKid,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(localizationService.getText('Add Successfully')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addKid() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final userId = authService.currentUser?.uid;
        
        if (userId != null) {
          await FirebaseFirestore.instance.collection('kids').add({
            'userId': userId,
            'name': _nameController.text.trim(),
            'age': int.tryParse(_ageController.text) ?? 0,
            'gender': _selectedGender,
            'level': _selectedLevel,
            'school': _schoolController.text.trim(),
            'class': _classController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });
          
          Get.snackbar(
            'نجح',
            'Add Successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          
          Get.back();
        }
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'فشل في إضافة الطفل: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
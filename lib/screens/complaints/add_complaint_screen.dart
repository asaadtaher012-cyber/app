import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../services/localization_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddComplaintScreen extends StatefulWidget {
  const AddComplaintScreen({super.key});
  
  @override
  State<AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isLoading = false;

  final List<String> _categories = [
    'General',
    'Driver Issue',
    'Payment Issue',
    'Trip Issue',
    'Technical Issue',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement submit complaint logic
      await Future.delayed(Duration(seconds: 2));
      
      Get.snackbar(
        'Success',
        'Complaint submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.getText('new_complaint')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Selection
              Text(
                localizationService.getText('subject'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedCategory = newValue!);
                },
              ),
              const SizedBox(height: 20),
              
              // Subject Field
              CustomTextField(
                controller: _subjectController,
                labelText: localizationService.getText('subject'),
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Subject is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Message Field
              CustomTextField(
                controller: _messageController,
                labelText: localizationService.getText('your_message'),
                prefixIcon: Icons.message,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Message is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              
              // Submit Button
              CustomButton(
                text: localizationService.getText('send_message'),
                onPressed: _isLoading ? null : _submitComplaint,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../services/localization_service.dart';
import '../../widgets/custom_button.dart';
import 'add_complaint_screen.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.getText('Complaints')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Get.to(() => const AddComplaintScreen()),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              localizationService.getText('No complaints yet'),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: localizationService.getText('Add Complaint'),
              onPressed: () => Get.to(() => const AddComplaintScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../services/localization_service.dart';
import '../../widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0;
  final double _amount = 100.0;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 0,
      'name': 'Collect In Our Office',
      'icon': Icons.business,
      'description': 'Pay at our office',
    },
    {
      'id': 1,
      'name': 'Smart wallet',
      'icon': Icons.account_balance_wallet,
      'description': 'Pay using smart wallet',
    },
    {
      'id': 2,
      'name': 'Bank Deposit / Wire Transfer',
      'icon': Icons.account_balance,
      'description': 'Bank transfer',
    },
    {
      'id': 3,
      'name': 'Credit Card',
      'icon': Icons.credit_card,
      'description': 'Pay with credit card',
    },
    {
      'id': 4,
      'name': 'Fawry',
      'icon': Icons.receipt,
      'description': 'Pay via Fawry',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.getText('payment_methods')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizationService.getText('payment_methods_details'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizationService.getText('subtotal')),
                        Text('${_amount.toStringAsFixed(2)} ${localizationService.getText('LE')}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizationService.getText('total')),
                        Text(
                          '${_amount.toStringAsFixed(2)} ${localizationService.getText('LE')}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Payment Methods
            Text(
              localizationService.getText('select_payment_methods'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            ..._paymentMethods.map((method) => _buildPaymentMethodCard(
              context,
              method,
              _selectedPaymentMethod == method['id'],
              () {
                setState(() {
                  _selectedPaymentMethod = method['id'];
                });
              },
            )),
            SizedBox(height: 30),
            
            // Pay Button
            CustomButton(
              text: localizationService.getText('continue'),
              onPressed: _processPayment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    Map<String, dynamic> method,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                method['icon'],
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      method['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<int>(
                value: method['id'],
                groupValue: _selectedPaymentMethod,
                onChanged: (value) => onTap(),
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    Get.snackbar(
      localizationService.getText('success'),
      localizationService.getText('donePay'),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    // TODO: Implement actual payment processing
  }
}


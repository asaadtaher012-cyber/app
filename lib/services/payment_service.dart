import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Payment Methods
  static const String CASH = 'cash';
  static const String CARD = 'card';
  static const String WALLET = 'wallet';
  static const String BANK_TRANSFER = 'bank_transfer';

  // Payment Status
  static const String PENDING = 'pending';
  static const String COMPLETED = 'completed';
  static const String FAILED = 'failed';
  static const String REFUNDED = 'refunded';

  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required String tripId,
    required double amount,
    required String paymentMethod,
    Map<String, dynamic>? paymentData,
  }) async {
    try {
      // Create payment record
      final paymentRef = await _firestore.collection('payments').add({
        'userId': userId,
        'tripId': tripId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'status': PENDING,
        'createdAt': Timestamp.now(),
        'paymentData': paymentData ?? {},
      });

      // Process payment based on method
      bool paymentSuccess = false;
      String transactionId = '';

      switch (paymentMethod) {
        case CASH:
          paymentSuccess = await _processCashPayment(amount);
          break;
        case CARD:
          final result = await _processCardPayment(amount, paymentData);
          paymentSuccess = result['success'];
          transactionId = result['transactionId'];
          break;
        case WALLET:
          paymentSuccess = await _processWalletPayment(userId, amount);
          break;
        case BANK_TRANSFER:
          paymentSuccess = await _processBankTransfer(amount, paymentData);
          break;
      }

      // Update payment status
      await paymentRef.update({
        'status': paymentSuccess ? COMPLETED : FAILED,
        'transactionId': transactionId,
        'processedAt': Timestamp.now(),
      });

      if (paymentSuccess) {
        // Update trip payment status
        await _firestore.collection('trips').doc(tripId).update({
          'paymentStatus': 'paid',
          'paymentId': paymentRef.id,
        });

        // Add loyalty points
        await _addLoyaltyPoints(userId, amount);

        return {
          'success': true,
          'paymentId': paymentRef.id,
          'transactionId': transactionId,
          'message': 'تم الدفع بنجاح',
        };
      } else {
        return {
          'success': false,
          'error': 'فشل في معالجة الدفع',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<bool> _processCashPayment(double amount) async {
    // Simulate cash payment processing
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  Future<Map<String, dynamic>> _processCardPayment(
    double amount,
    Map<String, dynamic>? paymentData,
  ) async {
    try {
      // Simulate card payment processing
      await Future.delayed(Duration(seconds: 2));
      
      // In real implementation, integrate with payment gateway
      // For now, simulate success
      return {
        'success': true,
        'transactionId': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<bool> _processWalletPayment(String userId, double amount) async {
    try {
      // Check wallet balance
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final walletBalance = userData?['walletBalance'] ?? 0.0;

      if (walletBalance >= amount) {
        // Deduct from wallet
        await _firestore.collection('users').doc(userId).update({
          'walletBalance': FieldValue.increment(-amount),
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> _processBankTransfer(
    double amount,
    Map<String, dynamic>? paymentData,
  ) async {
    try {
      // Simulate bank transfer processing
      await Future.delayed(Duration(seconds: 3));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _addLoyaltyPoints(String userId, double amount) async {
    try {
      // Add 1 point for every 10 units spent
      final points = (amount / 10).floor();
      
      await _firestore.collection('users').doc(userId).update({
        'loyaltyPoints': FieldValue.increment(points),
        'totalPoints': FieldValue.increment(points),
      });

      // Add to loyalty history
      await _firestore.collection('loyaltyHistory').add({
        'userId': userId,
        'type': 'payment',
        'points': points,
        'description': 'نقاط من الدفع',
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding loyalty points: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'amount': data['amount'],
          'paymentMethod': data['paymentMethod'],
          'status': data['status'],
          'createdAt': data['createdAt'],
          'tripId': data['tripId'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> refundPayment(String paymentId) async {
    try {
      final paymentDoc = await _firestore.collection('payments').doc(paymentId).get();
      final paymentData = paymentDoc.data();

      if (paymentData == null) {
        return {'success': false, 'error': 'Payment not found'};
      }

      // Update payment status
      await _firestore.collection('payments').doc(paymentId).update({
        'status': REFUNDED,
        'refundedAt': Timestamp.now(),
      });

      // Refund to wallet if applicable
      if (paymentData['paymentMethod'] == WALLET) {
        await _firestore.collection('users').doc(paymentData['userId']).update({
          'walletBalance': FieldValue.increment(paymentData['amount']),
        });
      }

      return {'success': true, 'message': 'تم استرداد المبلغ بنجاح'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

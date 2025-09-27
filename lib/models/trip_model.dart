class TripModel {
  final String id;
  final String userId;
  final String kidId;
  final String driverId;
  final String schoolId;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String schoolAddress;
  final double schoolLatitude;
  final double schoolLongitude;
  final DateTime scheduledDate;
  final DateTime pickupTime;
  final DateTime dropoffTime;
  final TripStatus status;
  final TripType type; // 'going' or 'return'
  final double price;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripModel({
    required this.id,
    required this.userId,
    required this.kidId,
    required this.driverId,
    required this.schoolId,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.schoolAddress,
    required this.schoolLatitude,
    required this.schoolLongitude,
    required this.scheduledDate,
    required this.pickupTime,
    required this.dropoffTime,
    required this.status,
    required this.type,
    required this.price,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      kidId: map['kidId'] ?? '',
      driverId: map['driverId'] ?? '',
      schoolId: map['schoolId'] ?? '',
      pickupAddress: map['pickupAddress'] ?? '',
      pickupLatitude: map['pickupLatitude']?.toDouble() ?? 0.0,
      pickupLongitude: map['pickupLongitude']?.toDouble() ?? 0.0,
      schoolAddress: map['schoolAddress'] ?? '',
      schoolLatitude: map['schoolLatitude']?.toDouble() ?? 0.0,
      schoolLongitude: map['schoolLongitude']?.toDouble() ?? 0.0,
      scheduledDate: DateTime.parse(map['scheduledDate'] ?? DateTime.now().toIso8601String()),
      pickupTime: DateTime.parse(map['pickupTime'] ?? DateTime.now().toIso8601String()),
      dropoffTime: DateTime.parse(map['dropoffTime'] ?? DateTime.now().toIso8601String()),
      status: TripStatus.values.firstWhere(
        (e) => e.toString() == 'TripStatus.${map['status']}',
        orElse: () => TripStatus.pending,
      ),
      type: TripType.values.firstWhere(
        (e) => e.toString() == 'TripType.${map['type']}',
        orElse: () => TripType.going,
      ),
      price: map['price']?.toDouble() ?? 0.0,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'kidId': kidId,
      'driverId': driverId,
      'schoolId': schoolId,
      'pickupAddress': pickupAddress,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'schoolAddress': schoolAddress,
      'schoolLatitude': schoolLatitude,
      'schoolLongitude': schoolLongitude,
      'scheduledDate': scheduledDate.toIso8601String(),
      'pickupTime': pickupTime.toIso8601String(),
      'dropoffTime': dropoffTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'price': price,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum TripStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

enum TripType {
  going,
  returning,
}


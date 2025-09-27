class KidModel {
  final String id;
  final String userId;
  final String name;
  final String gender; // 'Boy' or 'Girl'
  final String educationPeriod;
  final String? profileImage;
  final String? schoolId;
  final String? schoolName;
  final String? pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  KidModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.gender,
    required this.educationPeriod,
    this.profileImage,
    this.schoolId,
    this.schoolName,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory KidModel.fromMap(Map<String, dynamic> map) {
    return KidModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      gender: map['gender'] ?? 'Boy',
      educationPeriod: map['educationPeriod'] ?? '',
      profileImage: map['profileImage'],
      schoolId: map['schoolId'],
      schoolName: map['schoolName'],
      pickupAddress: map['pickupAddress'],
      pickupLatitude: map['pickupLatitude']?.toDouble(),
      pickupLongitude: map['pickupLongitude']?.toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'gender': gender,
      'educationPeriod': educationPeriod,
      'profileImage': profileImage,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'pickupAddress': pickupAddress,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  KidModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? gender,
    String? educationPeriod,
    String? profileImage,
    String? schoolId,
    String? schoolName,
    String? pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return KidModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      educationPeriod: educationPeriod ?? this.educationPeriod,
      profileImage: profileImage ?? this.profileImage,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}


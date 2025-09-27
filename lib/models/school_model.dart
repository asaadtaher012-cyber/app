class SchoolModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? email;
  final String? website;
  final String? description;
  final String? image;
  final String government;
  final String city;
  final List<String> educationPeriods;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SchoolModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.email,
    this.website,
    this.description,
    this.image,
    required this.government,
    required this.city,
    required this.educationPeriods,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SchoolModel.fromMap(Map<String, dynamic> map) {
    return SchoolModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      phone: map['phone'],
      email: map['email'],
      website: map['website'],
      description: map['description'],
      image: map['image'],
      government: map['government'] ?? '',
      city: map['city'] ?? '',
      educationPeriods: List<String>.from(map['educationPeriods'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'description': description,
      'image': image,
      'government': government,
      'city': city,
      'educationPeriods': educationPeriods,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SchoolModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? description,
    String? image,
    String? government,
    String? city,
    List<String>? educationPeriods,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      description: description ?? this.description,
      image: image ?? this.image,
      government: government ?? this.government,
      city: city ?? this.city,
      educationPeriods: educationPeriods ?? this.educationPeriods,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


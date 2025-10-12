import 'dart:io';

class RegistrationData {
  final String name;
  final String email;
  final String? phone;
  final String? notes;
  final File imageFile;
  final DateTime registeredAt;

  RegistrationData({
    required this.name,
    required this.email,
    this.phone,
    this.notes,
    required this.imageFile,
    DateTime? registeredAt,
  }) : registeredAt = registeredAt ?? DateTime.now();

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'notes': notes,
      'registered_at': registeredAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory RegistrationData.fromJson(Map<String, dynamic> json, File imageFile) {
    return RegistrationData(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
      imageFile: imageFile,
      registeredAt: DateTime.parse(json['registered_at'] as String),
    );
  }

  // Copy with
  RegistrationData copyWith({
    String? name,
    String? email,
    String? phone,
    String? notes,
    File? imageFile,
    DateTime? registeredAt,
  }) {
    return RegistrationData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      imageFile: imageFile ?? this.imageFile,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }
}
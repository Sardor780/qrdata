import 'dart:convert';

class Doctor {
  final String id;
  final String fullName;
  final String specialization;
  final int birthYear;
  final String username;
  final String? password;
  final String? phone;
  final String? position; // Добавляем position
  final int? experience; // Добавляем experience
  final String? photoPath;
  final String? photoBase64;

  Doctor({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.birthYear,
    required this.username,
    this.password,
    this.phone,
    this.position,
    this.experience,
    this.photoPath,
    this.photoBase64,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      specialization: json['specialization'] ?? '',
      birthYear: json['birth_year'] ?? 0,
      username: json['username'] ?? '',
      password: json['password'],
      phone: json['phone'],
      position: json['position'],
      experience: json['experience'],
      photoPath: json['photo_path'],
      photoBase64: json['photo_base64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'specialization': specialization,
      'birth_year': birthYear,
      'username': username,
      'password': password,
      'phone': phone,
      'position': position,
      'experience': experience,
      'photo_path': photoPath,
      'photo_base64': photoBase64,
    };
  }
}

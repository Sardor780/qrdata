import 'dart:convert';
import 'anthropometric_data.dart';
import 'vaccination.dart';
import 'surgery.dart';
import 'diagnosis.dart';
import 'treatment.dart';
import 'prescription.dart';
import 'appointment.dart';
import 'medical_review.dart';

class Patient {
  final String id;
  final String? fullName;
  final String? birthDate;
  final String? gender;
  final String? bloodType;
  final String? allergies;
  final String? chronicDiseases;
  final String? placeOfResidence;
  final String? mahallaName;
  final String? passportSeries;
  final String? pinfl;
  final String? placeOfWork;
  final String? position;
  final String? phone;
  final String? username;
  final String? password;
  final List<AnthropometricData>? anthropometricData;
  final List<Vaccination>? vaccinations;
  final List<Surgery>? surgeries;
  final List<Diagnosis>? diagnoses;
  final List<Treatment>? treatments;
  final List<Prescription>? prescriptions;
  final List<dynamic>? appointments;
  final List<MedicalReview>? medicalReviews;
  final String? photoPath;
  final String? photoBase64;

  Patient({
    required this.id,
    this.fullName,
    this.birthDate,
    this.gender,
    this.bloodType,
    this.allergies,
    this.chronicDiseases,
    this.placeOfResidence,
    this.mahallaName,
    this.passportSeries,
    this.pinfl,
    this.placeOfWork,
    this.position,
    this.phone,
    this.username,
    this.password,
    this.anthropometricData,
    this.vaccinations,
    this.surgeries,
    this.diagnoses,
    this.treatments,
    this.prescriptions,
    this.appointments,
    this.medicalReviews,
    this.photoPath,
    this.photoBase64,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'].toString(),
      fullName: json['full_name'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      bloodType: json['blood_type'],
      allergies: json['allergies'],
      chronicDiseases: json['chronic_diseases'],
      placeOfResidence: json['place_of_residence'],
      mahallaName: json['mahalla_name'],
      passportSeries: json['passport_series'],
      pinfl: json['pinfl'],
      placeOfWork: json['place_of_work'],
      position: json['position'],
      phone: json['phone'],
      username: json['username'],
      password: json['password'],
      anthropometricData: json['anthropometric_data'] != null
          ? (json['anthropometric_data'] as List).map((e) => AnthropometricData.fromJson(e)).toList()
          : null,
      vaccinations: json['vaccinations'] != null
          ? (json['vaccinations'] as List).map((e) => Vaccination.fromJson(e)).toList()
          : null,
      surgeries: json['surgeries'] != null
          ? (json['surgeries'] as List).map((e) => Surgery.fromJson(e)).toList()
          : null,
      diagnoses: json['diagnoses'] != null
          ? (json['diagnoses'] as List).map((e) => Diagnosis.fromJson(e)).toList()
          : null,
      treatments: json['treatments'] != null
          ? (json['treatments'] as List).map((e) => Treatment.fromJson(e)).toList()
          : null,
      prescriptions: json['prescriptions'] != null
          ? (json['prescriptions'] as List).map((e) => Prescription.fromJson(e)).toList()
          : null,
      appointments: json['appointments'],
      medicalReviews: json['medical_reviews'] != null
          ? (json['medical_reviews'] as List).map((e) => MedicalReview.fromJson(e)).toList()
          : null,
      photoPath: json['photo_path'],
      photoBase64: json['photo_base64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'birth_date': birthDate,
      'gender': gender,
      'blood_type': bloodType,
      'allergies': allergies,
      'chronic_diseases': chronicDiseases,
      'place_of_residence': placeOfResidence,
      'mahalla_name': mahallaName,
      'passport_series': passportSeries,
      'pinfl': pinfl,
      'place_of_work': placeOfWork,
      'position': position,
      'phone': phone,
      'username': username,
      'password': password,
      'anthropometric_data': anthropometricData?.map((e) => e.toJson()).toList(),
      'vaccinations': vaccinations?.map((e) => e.toJson()).toList(),
      'surgeries': surgeries?.map((e) => e.toJson()).toList(),
      'diagnoses': diagnoses?.map((e) => e.toJson()).toList(),
      'treatments': treatments?.map((e) => e.toJson()).toList(),
      'prescriptions': prescriptions?.map((e) => e.toJson()).toList(),
      'appointments': appointments,
      'medical_reviews': medicalReviews?.map((e) => e.toJson()).toList(),
      'photo_path': photoPath,
      'photo_base64': photoBase64,
    }..removeWhere((key, value) => value == null);
  }
}

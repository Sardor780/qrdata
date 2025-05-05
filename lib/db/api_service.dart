import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/patient.dart';
import '../models/doctor.dart';
import '../models/diagnosis.dart';
import '../models/treatment.dart';
import '../models/prescription.dart';
import '../models/medical_review.dart';

class ApiService {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost/api'; // Исправляем путь для веб-версии
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2/api'; // Для Android-эмулятора
      // return 'http://192.168.1.x/api'; // Для реального устройства (замените на ваш IP)
    } else {
      return 'http://localhost/api'; // Для других платформ
    }
  }

  static Future<String> registerPatient(Patient patient) async {
    final url = Uri.parse('$_baseUrl/register_patient.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(patient.toJson()),
      );

      print('Register patient - Response status: ${response.statusCode}');
      print('Register patient - Response body: ${response.body}');

      // Проверяем, является ли ответ валидным JSON
      if (!response.body.trim().startsWith('{')) {
        throw Exception('Invalid JSON response: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'].toString();
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to register patient: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Register patient error: $e');
      throw Exception('Failed to register patient: $e');
    }
  }

  static Future<String> registerDoctor(Doctor doctor) async {
    final url = Uri.parse('$_baseUrl/register_doctor.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(doctor.toJson()),
      );

      print('Register doctor - Response status: ${response.statusCode}');
      print('Register doctor - Response body: ${response.body}');

      // Проверяем, является ли ответ валидным JSON
      if (!response.body.trim().startsWith('{')) {
        throw Exception('Invalid JSON response: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'].toString();
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to register doctor: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Register doctor error: $e');
      throw Exception('Failed to register doctor: $e');
    }
  }

  static Future<dynamic> login(String username, String password, String userType) async {
    final url = Uri.parse('$_baseUrl/login.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'user_type': userType,
        }),
      );

      print('Login - Response status: ${response.statusCode}');
      print('Login - Response body: ${response.body}');

      // Проверяем, является ли ответ валидным JSON
      if (!response.body.trim().startsWith('{')) {
        throw Exception('Invalid JSON response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (userType == 'patient') {
          return Patient.fromJson(data);
        } else {
          return Doctor.fromJson(data);
        }
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to login: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Failed to login: $e');
    }
  }

  static Future<Patient> getPatient(String username) async {
    final url = Uri.parse('$_baseUrl/get_patient.php?username=$username');
    try {
      final response = await http.get(url);

      print('Get patient - Response status: ${response.statusCode}');
      print('Get patient - Response body: ${response.body}');

      if (!response.body.trim().startsWith('{')) {
        throw FormatException('Invalid JSON response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Patient.fromJson(json);
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to load patient: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Get patient error: $e');
      throw Exception('Failed to load patient: $e');
    }
  }

  static Future<void> savePatient(Patient patient) async {
    final url = Uri.parse('$_baseUrl/update_patient.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(patient.toJson()),
      );

      print('Save patient - Response status: ${response.statusCode}');
      print('Save patient - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return;
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to save patient: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Save patient error: $e');
      throw Exception('Failed to save patient: $e');
    }
  }

  static Future<void> addHistoricalData({
    required String patientId,
    required String dataType,
    String? vaccinationDate,
    String? vaccineName,
    String? surgeryDate,
    String? surgeryName,
    int? age,
    double? heightCm,
    double? weightKg,
    String? notes,
    String? recordedDate,
    required String doctorId,
  }) async {
    final url = Uri.parse('$_baseUrl/add_historical_data.php');
    try {
      final Map<String, dynamic> body = {
        'patient_id': patientId,
        'data_type': dataType,
        'doctor_id': doctorId,
        'recorded_date': recordedDate ?? DateTime.now().toString().split(' ')[0],
      };

      if (dataType == 'vaccination') {
        body['vaccination_date'] = vaccinationDate;
        body['vaccine_name'] = vaccineName;
        body['notes'] = notes;
      } else if (dataType == 'surgery') {
        body['surgery_date'] = surgeryDate;
        body['surgery_name'] = surgeryName;
        body['notes'] = notes;
      } else if (dataType == 'anthropometric') {
        body['age'] = age;
        body['height_cm'] = heightCm;
        body['weight_kg'] = weightKg;
        body['notes'] = notes;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body..removeWhere((key, value) => value == null)),
      );

      print('Add historical data - Response status: ${response.statusCode}');
      print('Add historical data - Response body: ${response.body}');

      if (!response.body.trim().startsWith('{')) {
        throw FormatException('Invalid JSON response: ${response.body}');
      }

      if (response.statusCode == 201) {
        return;
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to add historical data: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Add historical data error: $e');
      throw Exception('Failed to add historical data: $e');
    }
  }

  static Future<String> addAppointment({
    required String patientId,
    required String doctorId,
    required String appointmentDate,
    String? reason,
  }) async {
    final url = Uri.parse('$_baseUrl/add_appointment.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patientId': patientId,
          'doctorId': doctorId,
          'appointmentDate': appointmentDate,
          'reason': reason,
        }),
      );

      print('Add appointment - Response status: ${response.statusCode}');
      print('Add appointment - Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['appointmentId'].toString();
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to add appointment: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Add appointment error: $e');
      throw Exception('Failed to add appointment: $e');
    }
  }

  static Future<String> addDiagnosis(Diagnosis diagnosis) async {
    final url = Uri.parse('$_baseUrl/add_diagnosis.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(diagnosis.toJson()),
      );

      print('Add diagnosis - Response status: ${response.statusCode}');
      print('Add diagnosis - Response body: ${response.body}');

      if (!response.body.trim().startsWith('{')) {
        throw FormatException('Invalid JSON response: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'].toString();
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to add diagnosis: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Add diagnosis error: $e');
      throw Exception('Failed to add diagnosis: $e');
    }
  }

  static Future<String> addTreatment(Treatment treatment) async {
    final url = Uri.parse('$_baseUrl/add_treatment.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(treatment.toJson()),
      );

      print('Add treatment - Response status: ${response.statusCode}');
      print('Add treatment - Response body: ${response.body}');

      if (!response.body.trim().startsWith('{')) {
        throw FormatException('Invalid JSON response: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'].toString();
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to add treatment: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Add treatment error: $e');
      throw Exception('Failed to add treatment: $e');
    }
  }

  static Future<String> addPrescription(Prescription prescription) async {
    final url = Uri.parse('$_baseUrl/add_prescription.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(prescription.toJson()),
      );

      print('Add prescription - Response status: ${response.statusCode}');
      print('Add prescription - Response body: ${response.body}');

      if (!response.body.trim().startsWith('{')) {
        throw FormatException('Invalid JSON response: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'].toString();
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to add prescription: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Add prescription error: $e');
      throw Exception('Failed to add prescription: $e');
    }
  }

  static Future<String> addMedicalReview(MedicalReview review) async {
    final url = Uri.parse('$_baseUrl/add_medical_review.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(review.toJson()),
      );

      print('Add medical review - Response status: ${response.statusCode}');
      print('Add medical review - Response body: ${response.body}');

      if (!response.body.trim().startsWith('{')) {
        throw FormatException('Invalid JSON response: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'].toString(); // Возвращаем ID записи
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to add medical review: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Add medical review error: $e');
      throw Exception('Failed to add medical review: $e');
    }
  }

  static Future<Map<String, String>> addMedicalRecord({
    required String patientId,
    required String doctorId,
    required String diseaseName,
    String? severityLevel,
    required int diseaseYear,
    required String treatmentType,
    int? durationDays,
    String? medication1,
    String? medication2,
    String? medication3,
    String? rules1,
    String? rules2,
    String? rules3,
    String? prescriptionDate,
    required String conclusion,
    String? recommendations,
    required String diagnosisDate,
    String? reviewDate,
    String? vaccinationType,
    String? vaccinationDate,
    double? height,
    double? weight,
    double? bmi,
  }) async {
    // 1. Добавляем диагноз
    final diagnosis = Diagnosis(
      id: '',
      patientId: patientId,
      doctorId: doctorId, // Передаём doctorId
      diagnosisDate: diagnosisDate,
      diseaseName: diseaseName,
      severityLevel: severityLevel,
      diseaseYear: diseaseYear,
      treatmentType: treatmentType,
      conclusion: conclusion,
      durationDays: durationDays,
      reviewDate: reviewDate,
    );
    final diagnosisId = await addDiagnosis(diagnosis);

    // 2. Добавляем лечение
    final treatment = Treatment(
      id: '',
      patientId: patientId,
      doctorId: doctorId,
      diagnosisId: diagnosisId,
      treatmentType: treatmentType,
      durationDays: durationDays,
      conclusion: conclusion,
    );
    final treatmentId = await addTreatment(treatment);

    // 3. Добавляем рецепт, если есть данные
    String? prescriptionId;
    if (medication1 != null || medication2 != null || medication3 != null) {
      final prescription = Prescription(
        id: '',
        patientId: patientId,
        doctorId: doctorId,
        treatmentId: treatmentId,
        medication1: medication1,
        medication2: medication2,
        medication3: medication3,
        rules1: rules1,
        rules2: rules2,
        rules3: rules3,
        prescriptionDate: prescriptionDate ?? DateTime.now().toString().split(' ')[0],
      );
      prescriptionId = await addPrescription(prescription);
    }

    // 4. Добавляем медицинский осмотр
    final review = MedicalReview(
      id: '',
      patientId: patientId,
      doctorId: doctorId,
      treatmentId: treatmentId,
      reviewDate: reviewDate ?? 'Не указано',
      recommendations: recommendations,
      conclusion: conclusion,
      vaccinationType: vaccinationType,
      vaccinationDate: vaccinationDate,
      height: height,
      weight: weight,
      bmi: bmi,
    );
    final reviewId = await addMedicalReview(review);

    return {
      'diagnosisId': diagnosisId,
      'treatmentId': treatmentId,
      'prescriptionId': prescriptionId ?? '',
      'reviewId': reviewId,
    };
  }
  static Future<Patient> getPatientById(String patientId) async {
    final url = Uri.parse('$_baseUrl/get_patient_by_id.php?id=$patientId');
    try {
      final response = await http.get(url);

      print('Get patient by ID - Response status: ${response.statusCode}');
      print('Get patient by ID - Response body: ${response.body}');

      if (!response.body.trim().startsWith('{')) {
        throw FormatException('Invalid JSON response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Patient.fromJson(json);
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to load patient by ID: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Get patient by ID error: $e');
      throw Exception('Failed to load patient by ID: $e');
    }
  }
}

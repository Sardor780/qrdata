class Diagnosis {
  final String id;
  final String patientId;
  final String? doctorId;
  final String? diagnosisDate;
  final String? diseaseName;
  final String? severityLevel;
  final int? diseaseYear;
  // Временные поля для передачи данных в treatments и medical_reviews
  final String? treatmentType;
  final String? conclusion;
  final int? durationDays;
  final String? reviewDate;

  Diagnosis({
    required this.id,
    required this.patientId,
    this.doctorId,
    this.diagnosisDate,
    this.diseaseName,
    this.severityLevel,
    this.diseaseYear,
    this.treatmentType,
    this.conclusion,
    this.durationDays,
    this.reviewDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'diagnosis_date': diagnosisDate,
      'disease_name': diseaseName,
      'severity_level': severityLevel,
      'disease_year': diseaseYear,
      'treatment_type': treatmentType,
      'conclusion': conclusion,
      'duration_days': durationDays,
      'review_date': reviewDate,
    }..removeWhere((key, value) => value == null);
  }

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      doctorId: json['doctor_id']?.toString(),
      diagnosisDate: json['diagnosis_date'],
      diseaseName: json['disease_name'],
      severityLevel: json['severity_level'],
      diseaseYear: json['disease_year'] != null ? int.parse(json['disease_year'].toString()) : null,
    );
  }
}

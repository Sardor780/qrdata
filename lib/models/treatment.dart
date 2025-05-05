class Treatment {
  final String id;
  final String patientId;
  final String? doctorId; // Делаем doctorId необязательным
  final String diagnosisId;
  final String treatmentType;
  final int? durationDays;
  final String conclusion;

  Treatment({
    required this.id,
    required this.patientId,
    this.doctorId, // Убираем required
    required this.diagnosisId,
    required this.treatmentType,
    this.durationDays,
    required this.conclusion,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      doctorId: json['doctor_id']?.toString(), // Может быть null
      diagnosisId: json['diagnosis_id'].toString(),
      treatmentType: json['treatment_type'] ?? 'Не указано',
      durationDays: json['duration_days'] != null ? int.parse(json['duration_days'].toString()) : null,
      conclusion: json['conclusion'] ?? 'Не указано',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'diagnosis_id': diagnosisId,
      'treatment_type': treatmentType,
      'duration_days': durationDays,
      'conclusion': conclusion,
    }..removeWhere((key, value) => value == null);
  }
}

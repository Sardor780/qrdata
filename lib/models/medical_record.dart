class MedicalRecord {
  final String? recordId;
  final String patientId;
  final String doctorId;
  final String date;
  final String diagnosis;
  final String treatment;
  final String? notes;

  MedicalRecord({
    this.recordId,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.diagnosis,
    required this.treatment,
    this.notes,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      recordId: json['recordId']?.toString(), // Преобразуем int в String
      patientId: json['patientId'].toString(), // Преобразуем int в String
      doctorId: json['doctorId'].toString(), // Преобразуем int в String
      date: json['date'] as String,
      diagnosis: json['diagnosis'] as String,
      treatment: json['treatment'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordId': recordId,
      'patientId': patientId,
      'doctorId': doctorId,
      'date': date,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
    };
  }
}

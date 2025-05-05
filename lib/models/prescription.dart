class Prescription {
  final String id;
  final String patientId;
  final String doctorId; // Добавляем doctorId
  final String treatmentId;
  final String? medication1;
  final String? medication2;
  final String? medication3;
  final String? rules1;
  final String? rules2;
  final String? rules3;
  final String? prescriptionDate;

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorId, // Добавляем в конструктор
    required this.treatmentId,
    this.medication1,
    this.medication2,
    this.medication3,
    this.rules1,
    this.rules2,
    this.rules3,
    this.prescriptionDate,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      doctorId: json['doctor_id'].toString(), // Добавляем doctorId
      treatmentId: json['treatment_id'].toString(),
      medication1: json['medication1'],
      medication2: json['medication2'],
      medication3: json['medication3'],
      rules1: json['rules1'],
      rules2: json['rules2'],
      rules3: json['rules3'],
      prescriptionDate: json['prescription_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId, // Добавляем doctorId
      'treatment_id': treatmentId,
      'medication1': medication1,
      'medication2': medication2,
      'medication3': medication3,
      'rules1': rules1,
      'rules2': rules2,
      'rules3': rules3,
      'prescription_date': prescriptionDate,
    }..removeWhere((key, value) => value == null);
  }
}

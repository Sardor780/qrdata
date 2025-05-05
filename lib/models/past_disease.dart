class PastDisease {
  final String id;
  final String patientId;
  final String? doctorId;
  final int diseaseYear;
  final String diseaseName;
  final String treatment;
  final String? complications;

  PastDisease({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.diseaseYear,
    required this.diseaseName,
    required this.treatment,
    this.complications,
  });

  factory PastDisease.fromJson(Map<String, dynamic> json) {
    return PastDisease(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      doctorId: json['doctor_id']?.toString(),
      diseaseYear: json['disease_year'] as int,
      diseaseName: json['disease_name'] as String,
      treatment: json['treatment'] as String,
      complications: json['complications'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'disease_year': diseaseYear,
      'disease_name': diseaseName,
      'treatment': treatment,
      'complications': complications,
    };
  }
}

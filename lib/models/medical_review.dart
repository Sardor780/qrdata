class MedicalReview {
  final String id;
  final String patientId;
  final String doctorId;
  final String treatmentId;
  final String reviewDate;
  final String? recommendations;
  final String? conclusion; // Делаем conclusion опциональным
  final String? vaccinationType;
  final String? vaccinationDate;
  final double? height;
  final double? weight;
  final double? bmi;

  MedicalReview({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.treatmentId,
    required this.reviewDate,
    this.recommendations,
    this.conclusion, // Убираем required
    this.vaccinationType,
    this.vaccinationDate,
    this.height,
    this.weight,
    this.bmi,
  });

  factory MedicalReview.fromJson(Map<String, dynamic> json) {
    return MedicalReview(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      treatmentId: json['treatment_id']?.toString() ?? '',
      reviewDate: json['review_date'] ?? '',
      recommendations: json['recommendations'],
      conclusion: json['conclusion'], // Убираем ?? '', так как поле уже опциональное
      vaccinationType: json['vaccination_type'],
      vaccinationDate: json['vaccination_date'],
      height: json['height'] != null ? double.tryParse(json['height'].toString()) : null,
      weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
      bmi: json['bmi'] != null ? double.tryParse(json['bmi'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'treatment_id': treatmentId,
      'review_date': reviewDate,
      'recommendations': recommendations,
      'conclusion': conclusion,
      'vaccination_type': vaccinationType,
      'vaccination_date': vaccinationDate,
      'height': height,
      'weight': weight,
      'bmi': bmi,
    }..removeWhere((key, value) => value == null);
  }
}

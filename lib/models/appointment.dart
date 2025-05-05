class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String appointmentDate;
  final String? reason;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    this.reason,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      doctorId: json['doctor_id'].toString(),
      appointmentDate: json['appointment_date'] ?? 'Не указано',
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_date': appointmentDate,
      'reason': reason,
    }..removeWhere((key, value) => value == null);
  }
}

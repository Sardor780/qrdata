class Vaccination {
  final String? date;
  final String? vaccine;
  final String? notes;
  final String? recordedDate; // Добавляем поле

  Vaccination({
    this.date,
    this.vaccine,
    this.notes,
    this.recordedDate,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      date: json['vaccination_date'],
      vaccine: json['vaccine_name'],
      notes: json['notes'],
      recordedDate: json['recorded_date'], // Добавляем
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vaccination_date': date,
      'vaccine_name': vaccine,
      'notes': notes,
      'recorded_date': recordedDate, // Добавляем
    }..removeWhere((key, value) => value == null);
  }
}

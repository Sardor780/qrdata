class Surgery {
  final String? date;
  final String? operation;
  final String? notes;
  final String? recordedDate; // Добавляем поле

  Surgery({
    this.date,
    this.operation,
    this.notes,
    this.recordedDate,
  });

  factory Surgery.fromJson(Map<String, dynamic> json) {
    return Surgery(
      date: json['surgery_date'],
      operation: json['surgery_name'],
      notes: json['notes'],
      recordedDate: json['recorded_date'], // Добавляем
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surgery_date': date,
      'surgery_name': operation,
      'notes': notes,
      'recorded_date': recordedDate, // Добавляем
    }..removeWhere((key, value) => value == null);
  }
}

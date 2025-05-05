class AnthropometricData {
  final int? age;
  final double? height;
  final double? weight;
  final String? notes;
  final String? recordedDate; // Добавляем поле

  AnthropometricData({
    this.age,
    this.height,
    this.weight,
    this.notes,
    this.recordedDate,
  });

  factory AnthropometricData.fromJson(Map<String, dynamic> json) {
    return AnthropometricData(
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      height: json['height_cm'] != null ? double.tryParse(json['height_cm'].toString()) : null,
      weight: json['weight_kg'] != null ? double.tryParse(json['weight_kg'].toString()) : null,
      notes: json['notes'],
      recordedDate: json['recorded_date'], // Добавляем
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'height_cm': height,
      'weight_kg': weight,
      'notes': notes,
      'recorded_date': recordedDate, // Добавляем
    }..removeWhere((key, value) => value == null);
  }
}

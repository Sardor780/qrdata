import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../db/api_service.dart';

class ProfileScreen extends StatelessWidget {
  final Patient patient;

  const ProfileScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    // Исправляем присваивание с учётом возможных null значений
    final String fullName = patient.fullName ?? 'Не указано';
    final String birthDate = patient.birthDate ?? 'Не указано';
    final String phone = patient.phone ?? 'Не указано';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль пациента'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Имя: $fullName', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Дата рождения: $birthDate', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Телефон: $phone', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Группа крови: ${patient.bloodType ?? "Не указано"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Аллергии: ${patient.allergies ?? "Не указано"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Хронические заболевания: ${patient.chronicDiseases ?? "Не указано"}',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

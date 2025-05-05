import 'package:flutter/material.dart';
import '../db/api_service.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/diagnosis.dart';
import '../models/treatment.dart';
import '../models/prescription.dart';
import '../models/medical_review.dart';
import '../models/anthropometric_data.dart';
import '../models/vaccination.dart';
import '../models/surgery.dart';

class DoctorDashboard extends StatefulWidget {
  final Doctor doctor;

  const DoctorDashboard({super.key, required this.doctor});

  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final _patientUsernameController = TextEditingController();
  final _diseaseNameController = TextEditingController();
  final _severityLevelController = TextEditingController();
  final _diseaseYearController = TextEditingController();
  final _treatmentTypeController = TextEditingController();
  final _durationDaysController = TextEditingController();
  final _medication1Controller = TextEditingController();
  final _medication2Controller = TextEditingController();
  final _medication3Controller = TextEditingController();
  final _rules1Controller = TextEditingController();
  final _rules2Controller = TextEditingController();
  final _rules3Controller = TextEditingController();
  final _prescriptionDateController = TextEditingController();
  final _conclusionController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _reviewDateController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();
  final _anthropometricNotesController = TextEditingController();
  final _vaccineDateController = TextEditingController();
  final _vaccineController = TextEditingController();
  final _vaccineNotesController = TextEditingController();
  final _surgeryDateController = TextEditingController();
  final _operationController = TextEditingController();
  final _surgeryNotesController = TextEditingController();
  Patient? _patient;
  bool _isLoading = false;

  void _loadPatient() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patient = await ApiService.getPatient(_patientUsernameController.text);
      setState(() {
        _patient = patient;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки пациента: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMedicalRecord() async {
    if (_patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала выберите пациента')),
      );
      return;
    }

    if (_diseaseNameController.text.isEmpty ||
        _treatmentTypeController.text.isEmpty ||
        _conclusionController.text.isEmpty ||
        _diseaseYearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Пожалуйста, заполните все обязательные поля: Диагноз, Год заболевания, Лечение, Заключение')),
      );
      return;
    }

    try {
      final record = await ApiService.addMedicalRecord(
        patientId: _patient!.id,
        doctorId: widget.doctor.id, // doctorId уже передаётся
        diseaseName: _diseaseNameController.text,
        severityLevel: _severityLevelController.text.isNotEmpty ? _severityLevelController.text : null,
        diseaseYear: int.parse(_diseaseYearController.text),
        treatmentType: _treatmentTypeController.text,
        durationDays: _durationDaysController.text.isNotEmpty ? int.parse(_durationDaysController.text) : null,
        medication1: _medication1Controller.text.isNotEmpty ? _medication1Controller.text : null,
        medication2: _medication2Controller.text.isNotEmpty ? _medication2Controller.text : null,
        medication3: _medication3Controller.text.isNotEmpty ? _medication3Controller.text : null,
        rules1: _rules1Controller.text.isNotEmpty ? _rules1Controller.text : null,
        rules2: _rules2Controller.text.isNotEmpty ? _rules2Controller.text : null,
        rules3: _rules3Controller.text.isNotEmpty ? _rules3Controller.text : null,
        prescriptionDate: _prescriptionDateController.text.isNotEmpty ? _prescriptionDateController.text : null,
        conclusion: _conclusionController.text,
        recommendations: _recommendationsController.text.isNotEmpty ? _recommendationsController.text : null,
        diagnosisDate: DateTime.now().toString().split(' ')[0],
        reviewDate: _reviewDateController.text.isNotEmpty ? _reviewDateController.text : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись добавлена успешно')),
      );

      final updatedPatient = await ApiService.getPatient(_patient!.username!);
      setState(() {
        _patient = updatedPatient;
      });

      _diseaseNameController.clear();
      _severityLevelController.clear();
      _diseaseYearController.clear();
      _treatmentTypeController.clear();
      _durationDaysController.clear();
      _medication1Controller.clear();
      _medication2Controller.clear();
      _medication3Controller.clear();
      _rules1Controller.clear();
      _rules2Controller.clear();
      _rules3Controller.clear();
      _prescriptionDateController.clear();
      _conclusionController.clear();
      _recommendationsController.clear();
      _reviewDateController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления записи: $e')),
      );
    }
  }

  Future<void> _addAnthropometricData() async {
    if (_patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала выберите пациента')),
      );
      return;
    }

    if (_ageController.text.isEmpty || _heightController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все обязательные поля: Возраст, Рост, Вес')),
      );
      return;
    }

    try {
      await ApiService.addHistoricalData(
        patientId: _patient!.id,
        dataType: 'anthropometric',
        age: int.parse(_ageController.text),
        heightCm: double.parse(_heightController.text),
        weightKg: double.parse(_weightController.text),
        notes: _anthropometricNotesController.text.isNotEmpty ? _anthropometricNotesController.text : null,
        recordedDate: DateTime.now().toString().split(' ')[0],
        doctorId: widget.doctor.id,
      );

      final updatedPatient = await ApiService.getPatient(_patient!.username!);
      setState(() {
        _patient = updatedPatient;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Антропометрические данные добавлены')),
      );

      _ageController.clear();
      _heightController.clear();
      _weightController.clear();
      _anthropometricNotesController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления данных: $e')),
      );
    }
  }

  Future<void> _addVaccination() async {
    if (_patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала выберите пациента')),
      );
      return;
    }

    if (_vaccineDateController.text.isEmpty || _vaccineController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все обязательные поля: Дата вакцинации, Название вакцины')),
      );
      return;
    }

    try {
      await ApiService.addHistoricalData(
        patientId: _patient!.id,
        dataType: 'vaccination',
        vaccinationDate: _vaccineDateController.text,
        vaccineName: _vaccineController.text,
        notes: _vaccineNotesController.text.isNotEmpty ? _vaccineNotesController.text : null,
        recordedDate: DateTime.now().toString().split(' ')[0], // Добавляем recordedDate
        doctorId: widget.doctor.id,
      );

      final updatedPatient = await ApiService.getPatient(_patient!.username!);
      setState(() {
        _patient = updatedPatient;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вакцинация добавлена')),
      );

      _vaccineDateController.clear();
      _vaccineController.clear();
      _vaccineNotesController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления вакцинации: $e')),
      );
    }
  }

  Future<void> _addSurgery() async {
    if (_patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала выберите пациента')),
      );
      return;
    }

    if (_surgeryDateController.text.isEmpty || _operationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все обязательные поля: Дата операции, Название операции')),
      );
      return;
    }

    try {
      await ApiService.addHistoricalData(
        patientId: _patient!.id,
        dataType: 'surgery',
        surgeryDate: _surgeryDateController.text,
        surgeryName: _operationController.text,
        notes: _surgeryNotesController.text.isNotEmpty ? _surgeryNotesController.text : null,
        recordedDate: DateTime.now().toString().split(' ')[0], // Добавляем recordedDate
        doctorId: widget.doctor.id,
      );

      final updatedPatient = await ApiService.getPatient(_patient!.username!);
      setState(() {
        _patient = updatedPatient;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Операция добавлена')),
      );

      _surgeryDateController.clear();
      _operationController.clear();
      _surgeryNotesController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления операции: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Врач: ${widget.doctor.fullName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Специализация: ${widget.doctor.specialization}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                controller: _patientUsernameController,
                decoration: const InputDecoration(labelText: 'Логин пациента'),
              ),
              const SizedBox(height: 10),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _loadPatient,
                child: const Text('Загрузить данные пациента'),
              ),
              const SizedBox(height: 20),
              if (_patient != null) ...[
                Text('Пациент: ${_patient!.fullName}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                Text('Дата рождения: ${_patient!.birthDate}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Группа крови: ${_patient!.bloodType ?? "Не указано"}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Аллергии: ${_patient!.allergies ?? "Не указано"}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Хронические заболевания: ${_patient!.chronicDiseases ?? "Не указано"}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                const Text('История болезни:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (_patient!.diagnoses != null && _patient!.diagnoses!.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _patient!.diagnoses!.length,
                    itemBuilder: (context, index) {
                      final diagnosis = _patient!.diagnoses![index];
                      final treatment = _patient!.treatments?.firstWhere(
                            (t) => t.diagnosisId == diagnosis.id,
                        orElse: () => Treatment(
                          id: '',
                          patientId: diagnosis.patientId,
                          diagnosisId: diagnosis.id,
                          treatmentType: 'Не указано',
                          conclusion: 'Не указано',
                        ),
                      );
                      final review = _patient!.medicalReviews?.firstWhere(
                            (r) => r.treatmentId == treatment!.id,
                        orElse: () => MedicalReview(
                          id: '',
                          patientId: diagnosis.patientId,
                          doctorId: widget.doctor.id,
                          treatmentId: treatment!.id,
                          reviewDate: 'Не указано',
                          conclusion: 'Не указано',
                        ),
                      );
                      return Card(
                        child: ListTile(
                          title: Text('Дата: ${diagnosis.diagnosisDate}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Диагноз: ${diagnosis.diseaseName}'),
                              if (diagnosis.severityLevel != null) Text('Серьезность: ${diagnosis.severityLevel}'),
                              Text('Лечение: ${treatment?.treatmentType ?? "Не указано"}'),
                              if (treatment?.durationDays != null) Text('Длительность: ${treatment!.durationDays} дней'),
                              Text('Заключение: ${treatment?.conclusion ?? "Не указано"}'),
                              if (review?.recommendations != null) Text('Рекомендации: ${review!.recommendations}'),
                              Text('Дата повторного осмотра: ${review?.reviewDate ?? "Не указано"}'),
                              if (review?.vaccinationType != null) Text('Вакцинация: ${review!.vaccinationType}'),
                              if (review?.vaccinationDate != null) Text('Дата вакцинации: ${review!.vaccinationDate}'),
                              if (review?.height != null) Text('Рост: ${review!.height} см'),
                              if (review?.weight != null) Text('Вес: ${review!.weight} кг'),
                              if (review?.bmi != null) Text('ИМТ: ${review!.bmi}'),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Text('Нет записей'),
                const SizedBox(height: 20),
                const Text('Антропометрические данные:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (_patient!.anthropometricData != null && _patient!.anthropometricData!.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _patient!.anthropometricData!.length,
                    itemBuilder: (context, index) {
                      final data = _patient!.anthropometricData![index];
                      return Card(
                        child: ListTile(
                          title: Text('Дата: ${data.recordedDate ?? "Не указано"}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Возраст: ${data.age}'),
                              Text('Рост: ${data.height} см'),
                              Text('Вес: ${data.weight} кг'),
                              if (data.notes != null) Text('Примечания: ${data.notes}'),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Text('Нет антропометрических данных'),
                const SizedBox(height: 20),
                const Text('Вакцинации:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (_patient!.vaccinations != null && _patient!.vaccinations!.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _patient!.vaccinations!.length,
                    itemBuilder: (context, index) {
                      final vaccination = _patient!.vaccinations![index];
                      return Card(
                        child: ListTile(
                          title: Text('Дата: ${vaccination.date}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Вакцина: ${vaccination.vaccine}'),
                              if (vaccination.notes != null) Text('Примечания: ${vaccination.notes}'),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Text('Нет вакцинаций'),
                const SizedBox(height: 20),
                const Text('Операции:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (_patient!.surgeries != null && _patient!.surgeries!.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _patient!.surgeries!.length,
                    itemBuilder: (context, index) {
                      final surgery = _patient!.surgeries![index];
                      return Card(
                        child: ListTile(
                          title: Text('Дата: ${surgery.date}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Операция: ${surgery.operation}'),
                              if (surgery.notes != null) Text('Примечания: ${surgery.notes}'),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Text('Нет операций'),
                const SizedBox(height: 20),
                const Text('Добавить новую запись:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _diseaseNameController,
                  decoration: const InputDecoration(labelText: 'Диагноз'),
                ),
                TextField(
                  controller: _severityLevelController,
                  decoration: const InputDecoration(labelText: 'Серьезность (опционально)'),
                ),
                TextField(
                  controller: _diseaseYearController,
                  decoration: const InputDecoration(labelText: 'Год заболевания'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _treatmentTypeController,
                  decoration: const InputDecoration(labelText: 'Лечение'),
                ),
                TextField(
                  controller: _durationDaysController,
                  decoration: const InputDecoration(labelText: 'Длительность лечения (дни, опционально)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                const Text('Рецепт:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _medication1Controller,
                  decoration: const InputDecoration(labelText: 'Медикамент 1 (опционально)'),
                ),
                TextField(
                  controller: _rules1Controller,
                  decoration: const InputDecoration(labelText: 'Правила приёма 1 (опционально)'),
                ),
                TextField(
                  controller: _medication2Controller,
                  decoration: const InputDecoration(labelText: 'Медикамент 2 (опционально)'),
                ),
                TextField(
                  controller: _rules2Controller,
                  decoration: const InputDecoration(labelText: 'Правила приёма 2 (опционально)'),
                ),
                TextField(
                  controller: _medication3Controller,
                  decoration: const InputDecoration(labelText: 'Медикамент 3 (опционально)'),
                ),
                TextField(
                  controller: _rules3Controller,
                  decoration: const InputDecoration(labelText: 'Правила приёма 3 (опционально)'),
                ),
                TextField(
                  controller: _prescriptionDateController,
                  decoration: const InputDecoration(labelText: 'Дата рецепта (опционально, ГГГГ-ММ-ДД)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _conclusionController,
                  decoration: const InputDecoration(labelText: 'Заключение'),
                ),
                TextField(
                  controller: _recommendationsController,
                  decoration: const InputDecoration(labelText: 'Рекомендации (опционально)'),
                ),
                TextField(
                  controller: _reviewDateController,
                  decoration: const InputDecoration(labelText: 'Дата повторного осмотра (опционально, ГГГГ-ММ-ДД)'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addMedicalRecord,
                  child: const Text('Добавить запись'),
                ),
                const SizedBox(height: 20),
                const Text('Добавить антропометрические данные:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Возраст (например, 5 лет)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: 'Рост (см)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Вес (кг)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _anthropometricNotesController,
                  decoration: const InputDecoration(labelText: 'Примечания (опционально)'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addAnthropometricData,
                  child: const Text('Добавить антропометрические данные'),
                ),
                const SizedBox(height: 20),
                const Text('Добавить вакцинацию:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _vaccineDateController,
                  decoration: const InputDecoration(labelText: 'Дата вакцинации (ГГГГ-ММ-ДД)'),
                ),
                TextField(
                  controller: _vaccineController,
                  decoration: const InputDecoration(labelText: 'Название вакцины'),
                ),
                TextField(
                  controller: _vaccineNotesController,
                  decoration: const InputDecoration(labelText: 'Примечания (опционально)'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addVaccination,
                  child: const Text('Добавить вакцинацию'),
                ),
                const SizedBox(height: 20),
                const Text('Добавить операцию:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _surgeryDateController,
                  decoration: const InputDecoration(labelText: 'Дата операции (ГГГГ-ММ-ДД)'),
                ),
                TextField(
                  controller: _operationController,
                  decoration: const InputDecoration(labelText: 'Название операции'),
                ),
                TextField(
                  controller: _surgeryNotesController,
                  decoration: const InputDecoration(labelText: 'Примечания (опционально)'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addSurgery,
                  child: const Text('Добавить операцию'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _patientUsernameController.dispose();
    _diseaseNameController.dispose();
    _severityLevelController.dispose();
    _diseaseYearController.dispose();
    _treatmentTypeController.dispose();
    _durationDaysController.dispose();
    _medication1Controller.dispose();
    _medication2Controller.dispose();
    _medication3Controller.dispose();
    _rules1Controller.dispose();
    _rules2Controller.dispose();
    _rules3Controller.dispose();
    _prescriptionDateController.dispose();
    _conclusionController.dispose();
    _recommendationsController.dispose();
    _reviewDateController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _anthropometricNotesController.dispose();
    _vaccineDateController.dispose();
    _vaccineController.dispose();
    _vaccineNotesController.dispose();
    _surgeryDateController.dispose();
    _operationController.dispose();
    _surgeryNotesController.dispose();
    super.dispose();
  }
}

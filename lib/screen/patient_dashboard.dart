import 'package:flutter/material.dart';
import 'package:qr_data/db/api_service.dart';
import 'package:qr_data/models/patient.dart';
import '../ProfileScreen.dart';
import '../models/medical_review.dart';
import '../models/prescription.dart';
import '../models/treatment.dart';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui';

class PatientDashboard extends StatefulWidget {
  final Patient patient;

  const PatientDashboard({super.key, required this.patient});

  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> with SingleTickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _genderController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();
  final _placeOfResidenceController = TextEditingController();
  final _mahallaNameController = TextEditingController();
  final _passportSeriesController = TextEditingController();
  final _pinflController = TextEditingController();
  final _placeOfWorkController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  late Patient _patient;
  Timer? _refreshTimer;
  bool _isQrExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;
    _fullNameController.text = _patient.fullName ?? '';
    _birthDateController.text = _patient.birthDate ?? '';
    _genderController.text = _patient.gender ?? '';
    _bloodTypeController.text = _patient.bloodType ?? '';
    _allergiesController.text = _patient.allergies ?? '';
    _chronicDiseasesController.text = _patient.chronicDiseases ?? '';
    _placeOfResidenceController.text = _patient.placeOfResidence ?? '';
    _mahallaNameController.text = _patient.mahallaName ?? '';
    _passportSeriesController.text = _patient.passportSeries ?? '';
    _pinflController.text = _patient.pinfl ?? '';
    _placeOfWorkController.text = _patient.placeOfWork ?? '';
    _positionController.text = _patient.position ?? '';
    _phoneController.text = _patient.phone ?? '';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _refreshPatientData();

    _refreshTimer = Timer.periodic(Duration(seconds: 40), (timer) {
      _refreshPatientData();
    });
  }

  Future<void> _updateProfile() async {
    try {
      final updatedPatient = Patient(
        id: _patient.id,
        fullName: _fullNameController.text.isNotEmpty ? _fullNameController.text : null,
        birthDate: _birthDateController.text.isNotEmpty ? _birthDateController.text : null,
        gender: _genderController.text.isNotEmpty ? _genderController.text : null,
        bloodType: _bloodTypeController.text.isNotEmpty ? _bloodTypeController.text : null,
        allergies: _allergiesController.text.isNotEmpty ? _allergiesController.text : null,
        chronicDiseases: _chronicDiseasesController.text.isNotEmpty ? _chronicDiseasesController.text : null,
        placeOfResidence: _placeOfResidenceController.text.isNotEmpty ? _placeOfResidenceController.text : null,
        mahallaName: _mahallaNameController.text.isNotEmpty ? _mahallaNameController.text : null,
        passportSeries: _passportSeriesController.text.isNotEmpty ? _passportSeriesController.text : null,
        pinfl: _pinflController.text.isNotEmpty ? _pinflController.text : null,
        placeOfWork: _placeOfWorkController.text.isNotEmpty ? _placeOfWorkController.text : null,
        position: _positionController.text.isNotEmpty ? _positionController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        username: _patient.username,
        password: _patient.password,
        anthropometricData: _patient.anthropometricData,
        vaccinations: _patient.vaccinations,
        surgeries: _patient.surgeries,
        diagnoses: _patient.diagnoses,
        treatments: _patient.treatments,
        prescriptions: _patient.prescriptions,
        appointments: _patient.appointments,
        medicalReviews: _patient.medicalReviews,
        photoPath: _patient.photoPath,
        photoBase64: _patient.photoBase64,
      );

      await ApiService.savePatient(updatedPatient);
      setState(() {
        _patient = updatedPatient;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль обновлён')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления профиля: $e')),
      );
    }
  }

  Future<void> _refreshPatientData() async {
    try {
      final updatedPatient = await ApiService.getPatient(_patient.username!);
      setState(() {
        if (_patient.anthropometricData?.length != updatedPatient.anthropometricData?.length ||
            _patient.vaccinations?.length != updatedPatient.vaccinations?.length ||
            _patient.surgeries?.length != updatedPatient.surgeries?.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Новые данные добавлены')),
          );
        }
        _patient = updatedPatient;

        // Отладочный вывод для проверки данных
        print('Patient data loaded:');
        print('Diagnoses: ${_patient.diagnoses}');
        print('Treatments: ${_patient.treatments}');
        print('Prescriptions: ${_patient.prescriptions}');
        print('Medical Reviews: ${_patient.medicalReviews}');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления данных: $e')),
      );
      _refreshTimer?.cancel();
      _refreshTimer = Timer.periodic(Duration(minutes: 2), (timer) {
        _refreshPatientData();
      });
    }
  }

  void _toggleQrCode() {
    setState(() {
      _isQrExpanded = !_isQrExpanded;
      if (_isQrExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const Text('Профиль пациента:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Полное имя'),
                  ),
                  TextField(
                    controller: _birthDateController,
                    decoration: const InputDecoration(labelText: 'Дата рождения (ГГГГ-ММ-ДД)'),
                  ),
                  TextField(
                    controller: _genderController,
                    decoration: const InputDecoration(labelText: 'Пол'),
                  ),
                  TextField(
                    controller: _bloodTypeController,
                    decoration: const InputDecoration(labelText: 'Группа крови'),
                  ),
                  TextField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(labelText: 'Аллергии'),
                  ),
                  TextField(
                    controller: _chronicDiseasesController,
                    decoration: const InputDecoration(labelText: 'Хронические заболевания'),
                  ),
                  TextField(
                    controller: _placeOfResidenceController,
                    decoration: const InputDecoration(labelText: 'Место жительства'),
                  ),
                  TextField(
                    controller: _mahallaNameController,
                    decoration: const InputDecoration(labelText: 'Название махалли'),
                  ),
                  TextField(
                    controller: _passportSeriesController,
                    decoration: const InputDecoration(labelText: 'Серия паспорта'),
                  ),
                  TextField(
                    controller: _pinflController,
                    decoration: const InputDecoration(labelText: 'ПИНФЛ'),
                  ),
                  TextField(
                    controller: _placeOfWorkController,
                    decoration: const InputDecoration(labelText: 'Место работы'),
                  ),
                  TextField(
                    controller: _positionController,
                    decoration: const InputDecoration(labelText: 'Должность'),
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Телефон'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Обновить профиль'),
                  ),
                  const SizedBox(height: 20),
                  // Центрированный заголовок "МЕДИЦИНСКАЯ КАРТА ПАЦИЕНТА"
                  const Center(
                    child: Text(
                      'МЕДИЦИНСКАЯ КAРТА ПАЦИЕНТА:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Данные о диагнозах в виде карточек
                  _patient.diagnoses != null && _patient.diagnoses!.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _patient.diagnoses!.length,
                    itemBuilder: (context, index) {
                      final diagnosis = _patient.diagnoses![index];

                      // Безопасно ищем treatment
                      final treatment = (_patient.treatments != null && _patient.treatments!.isNotEmpty)
                          ? _patient.treatments!.firstWhere(
                            (t) => t.diagnosisId == diagnosis.id,
                        orElse: () => Treatment(
                          id: '',
                          patientId: diagnosis.patientId,
                          diagnosisId: diagnosis.id,
                          treatmentType: 'Не указано',
                          conclusion: 'Не указано',
                        ),
                      )
                          : Treatment(
                        id: '',
                        patientId: diagnosis.patientId,
                        diagnosisId: diagnosis.id,
                        treatmentType: 'Не указано',
                        conclusion: 'Не указано',
                      );

                      // Безопасно ищем review
                      final review = (_patient.medicalReviews != null && _patient.medicalReviews!.isNotEmpty)
                          ? _patient.medicalReviews!.firstWhere(
                            (r) => r.treatmentId == treatment.id,
                        orElse: () => MedicalReview(
                          id: '',
                          patientId: diagnosis.patientId,
                          doctorId: '',
                          treatmentId: treatment.id,
                          reviewDate: 'Не указано',
                        ),
                      )
                          : MedicalReview(
                        id: '',
                        patientId: diagnosis.patientId,
                        doctorId: '',
                        treatmentId: treatment.id,
                        reviewDate: 'Не указано',
                      );

                      // Безопасно ищем prescription
                      final prescription = (_patient.prescriptions != null && _patient.prescriptions!.isNotEmpty)
                          ? _patient.prescriptions!.firstWhere(
                            (p) => p.treatmentId == treatment.id,
                        orElse: () => Prescription(
                          id: '',
                          patientId: diagnosis.patientId,
                          doctorId: '',
                          treatmentId: treatment.id,
                          medication1: 'Не указано',
                          rules1: 'Не указано',
                          medication2: 'Не указано',
                          rules2: 'Не указано',
                          medication3: 'Не указано',
                          rules3: 'Не указано',
                          prescriptionDate: 'Не указано',
                        ),
                      )
                          : Prescription(
                        id: '',
                        patientId: diagnosis.patientId,
                        doctorId: '',
                        treatmentId: treatment.id,
                        medication1: 'Не указано',
                        rules1: 'Не указано',
                        medication2: 'Не указано',
                        rules2: 'Не указано',
                        medication3: 'Не указано',
                        rules3: 'Не указано',
                        prescriptionDate: 'Не указано',
                      );

                      // Отладочный вывод
                      print('Diagnosis ${index + 1}: id=${diagnosis.id}, diseaseName=${diagnosis.diseaseName}, diseaseYear=${diagnosis.diseaseYear}');
                      print('Treatment for Diagnosis ${index + 1}: id=${treatment.id}, diagnosisId=${treatment.diagnosisId}, treatmentType=${treatment.treatmentType}, conclusion=${treatment.conclusion}, durationDays=${treatment.durationDays}');
                      print('Review for Treatment: id=${review.id}, treatmentId=${review.treatmentId}, reviewDate=${review.reviewDate}, recommendations=${review.recommendations}');
                      print('Prescription for Treatment: id=${prescription.id}, treatmentId=${prescription.treatmentId}, medication1=${prescription.medication1}, rules1=${prescription.rules1}');

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.grey.shade100, // Серый фон, как на скриншоте
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'История болезни ${index + 1}:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Диагноз: ${diagnosis.diseaseName ?? "Не указано"}'),
                              Text('Серьезность: ${diagnosis.severityLevel ?? "Не указано"}'),
                              Text('Год заболевания: ${diagnosis.diseaseYear?.toString() ?? "Не указано"}'),
                              Text('Лечение: ${treatment.treatmentType ?? "Не указано"}'),
                              Text('Длительность лечения: ${treatment.durationDays?.toString() ?? "Не указано"} дней'),
                              const SizedBox(height: 8),
                              const Text(
                                'Рецепт:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Медикамент 1: ${prescription.medication1 ?? "Не указано"}'),
                              Text('Правила приёма 1: ${prescription.rules1 ?? "Не указано"}'),
                              Text('Медикамент 2: ${prescription.medication2 ?? "Не указано"}'),
                              Text('Правила приёма 2: ${prescription.rules2 ?? "Не указано"}'),
                              Text('Медикамент 3: ${prescription.medication3 ?? "Не указано"}'),
                              Text('Правила приёма 3: ${prescription.rules3 ?? "Не указано"}'),
                              Text('Дата рецепта: ${prescription.prescriptionDate ?? "Не указано"}'),
                              Text('Заключение: ${treatment.conclusion ?? "Не указано"}'),
                              Text('Рекомендации: ${review.recommendations ?? "Не указано"}'),
                              Text('Дата повторного осмотра: ${review.reviewDate ?? "Не указано"}'),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                      : const Center(child: Text('Данные о диагнозах отсутствуют')),
                  const SizedBox(height: 20),
                  const Text('Антропометрические данные:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (_patient.anthropometricData != null && _patient.anthropometricData!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _patient.anthropometricData!.length,
                      itemBuilder: (context, index) {
                        final data = _patient.anthropometricData![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.grey.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Возраст: ${data.age ?? "Не указано"}'),
                                Text('Рост: ${data.height ?? "Не указано"} см'),
                                Text('Вес: ${data.weight ?? "Не указано"} кг'),
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
                  if (_patient.vaccinations != null && _patient.vaccinations!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _patient.vaccinations!.length,
                      itemBuilder: (context, index) {
                        final vaccination = _patient.vaccinations![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.grey.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Дата: ${vaccination.date ?? "Не указано"}'),
                                Text('Вакцина: ${vaccination.vaccine ?? "Не указано"}'),
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
                  if (_patient.surgeries != null && _patient.surgeries!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _patient.surgeries!.length,
                      itemBuilder: (context, index) {
                        final surgery = _patient.surgeries![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.grey.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Дата: ${surgery.date ?? "Не указано"}'),
                                Text('Операция: ${surgery.operation ?? "Не указано"}'),
                                if (surgery.notes != null) Text('Примечания: ${surgery.notes}'),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    const Text('Нет операций'),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: Text('Пациент: ${_patient.fullName ?? "Не указано"}'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: _toggleQrCode,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshPatientData,
                ),
              ],
            ),
          ),
          if (_isQrExpanded)
            GestureDetector(
              onTap: _toggleQrCode,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: _patient.id ?? _patient.username ?? 'No ID',
                          version: QrVersions.auto,
                          size: 300.0,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshTimer?.cancel();
    _fullNameController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _chronicDiseasesController.dispose();
    _placeOfResidenceController.dispose();
    _mahallaNameController.dispose();
    _passportSeriesController.dispose();
    _pinflController.dispose();
    _placeOfWorkController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

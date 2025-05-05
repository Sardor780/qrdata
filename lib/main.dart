import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'models/patient.dart';
import 'models/doctor.dart';
import 'qr_scan_page.dart';
import 'utils.dart';
import 'db/api_service.dart';
import 'screen/user_type_selection.dart';
import 'screen/doctor_dashboard.dart';
import 'screen/patient_dashboard.dart';

// Добавляем функцию showErrorDialog
void showErrorDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Ошибка',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          errorMessage,
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ОК',
              style: GoogleFonts.poppins(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Медицинское приложение',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserTypeSelectionScreen(),
    );
  }
}

class SomeScreen extends StatefulWidget {
  @override
  _SomeScreenState createState() => _SomeScreenState();
}

class _SomeScreenState extends State<SomeScreen> {
  Patient? _patient;

  void _loadUser() async {
    try {
      _patient = await ApiService.login('ivanov123', 'password123', 'patient') as Patient;
      setState(() {});
    } catch (e) {
      showErrorDialog(context, 'Ошибка загрузки пациента: $e');
    }
  }

  void _saveUser() async {
    if (_patient != null) {
      try {
        await ApiService.savePatient(_patient!);
        showErrorDialog(context, 'Пациент успешно сохранён');
      } catch (e) {
        showErrorDialog(context, 'Ошибка сохранения пациента: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _loadUser,
              child: const Text('Загрузить пациента'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUser,
              child: const Text('Сохранить пациента'),
            ),
            if (_patient != null) ...[
              const SizedBox(height: 20),
              Text('Пациент: ${_patient!.fullName}'),
            ],
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _genderController = TextEditingController();
  final _specializationController = TextEditingController();
  bool _isLoginMode = true;
  bool _isDoctor = false;

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showErrorDialog(context, 'Пожалуйста, заполните все поля');
      return;
    }

    try {
      if (_isLoginMode) {
        // Вход
        final userType = _isDoctor ? 'doctor' : 'patient';
        print('Logging in with username: $username, password: $password, userType: $userType');
        final userData = await ApiService.login(username, password, userType);
        if (userData is Patient) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(user: userData, userType: 'patient')),
          );
        } else if (userData is Doctor) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DoctorDashboard(doctor: userData)),
          );
        }
      } else {
        // Регистрация
        final fullName = _fullNameController.text.trim();
        if (fullName.isEmpty) {
          showErrorDialog(context, 'Пожалуйста, заполните полное имя');
          return;
        }
        if (_isDoctor && _birthYearController.text.isEmpty) {
          showErrorDialog(context, 'Пожалуйста, укажите год рождения');
          return;
        }
        if (!_isDoctor && (_birthDateController.text.isEmpty || _genderController.text.isEmpty)) {
          showErrorDialog(context, 'Пожалуйста, укажите дату рождения и пол');
          return;
        }
        if (_isDoctor && _specializationController.text.isEmpty) {
          showErrorDialog(context, 'Пожалуйста, укажите специализацию');
          return;
        }

        if (_isDoctor) {
          final doctor = Doctor(
            id: '',
            fullName: fullName,
            specialization: _specializationController.text,
            birthYear: int.parse(_birthYearController.text),
            username: username,
            password: password,
          );
          final doctorId = await ApiService.registerDoctor(doctor);
          print('Registered doctor with ID: $doctorId');
          final userData = await ApiService.login(username, password, 'doctor');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DoctorDashboard(doctor: userData as Doctor)),
          );
        } else {
          final patient = Patient(
            id: '',
            fullName: fullName,
            birthDate: _birthDateController.text,
            gender: _genderController.text,
            username: username,
            password: password,
          );
          final patientId = await ApiService.registerPatient(patient);
          print('Registered patient with ID: $patientId');
          final userData = await ApiService.login(username, password, 'patient');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(user: userData as Patient, userType: 'patient')),
          );
        }
      }
    } catch (e) {
      showErrorDialog(context, 'Ошибка: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _birthDateController.dispose();
    _birthYearController.dispose();
    _genderController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bckg_for_ms.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLoginMode ? 'Вход' : 'Регистрация',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Логин',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                      ),
                      if (!_isLoginMode) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Полное имя',
                            labelStyle: GoogleFonts.poppins(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_isDoctor) ...[
                          TextField(
                            controller: _specializationController,
                            decoration: InputDecoration(
                              labelText: 'Специализация',
                              labelStyle: GoogleFonts.poppins(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _birthYearController,
                            decoration: InputDecoration(
                              labelText: 'Год рождения',
                              labelStyle: GoogleFonts.poppins(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ] else ...[
                          TextField(
                            controller: _birthDateController,
                            decoration: InputDecoration(
                              labelText: 'Дата рождения (ГГГГ-ММ-ДД)',
                              labelStyle: GoogleFonts.poppins(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _genderController,
                            decoration: InputDecoration(
                              labelText: 'Пол (Male/Female/Other)',
                              labelStyle: GoogleFonts.poppins(),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _isDoctor,
                              onChanged: (value) {
                                setState(() {
                                  _isDoctor = value ?? false;
                                });
                              },
                            ),
                            Text('Я врач', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _isLoginMode ? 'Войти' : 'Зарегистрироваться',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                          });
                        },
                        child: Text(
                          _isLoginMode ? 'Нет аккаунта? Зарегистрируйтесь' : 'Уже есть аккаунт? Войдите',
                          style: GoogleFonts.poppins(color: Colors.blue[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _genderController = TextEditingController();
  final _specializationController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isDoctor = false;

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();

    if (username.isEmpty || password.isEmpty || fullName.isEmpty) {
      showErrorDialog(context, 'Все поля должны быть заполнены');
      return;
    }

    if (_isDoctor && _birthYearController.text.isEmpty) {
      showErrorDialog(context, 'Пожалуйста, укажите год рождения');
      return;
    }
    if (!_isDoctor && (_birthDateController.text.isEmpty || _genderController.text.isEmpty)) {
      showErrorDialog(context, 'Пожалуйста, укажите дату рождения и пол');
      return;
    }
    if (_isDoctor && _specializationController.text.isEmpty) {
      showErrorDialog(context, 'Пожалуйста, укажите специализацию');
      return;
    }

    try {
      if (_isDoctor) {
        final doctor = Doctor(
          id: '',
          fullName: fullName,
          specialization: _specializationController.text,
          birthYear: int.parse(_birthYearController.text),
          username: username,
          password: password,
        );
        final doctorId = await ApiService.registerDoctor(doctor);
        print('Registered doctor with ID: $doctorId');
        final userData = await ApiService.login(username, password, 'doctor');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoctorDashboard(doctor: userData as Doctor)),
        );
      } else {
        final patient = Patient(
          id: '',
          fullName: fullName,
          birthDate: _birthDateController.text,
          gender: _genderController.text,
          username: username,
          password: password,
        );
        final patientId = await ApiService.registerPatient(patient);
        print('Registered patient with ID: $patientId');
        final userData = await ApiService.login(username, password, 'patient');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(user: userData as Patient, userType: 'patient')),
        );
      }
    } catch (e) {
      showErrorDialog(context, 'Ошибка регистрации: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _birthDateController.dispose();
    _birthYearController.dispose();
    _genderController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bckg_for_ms.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          Column(
            children: [
              AppBar(
                title: Text(
                  'Регистрация',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.white.withOpacity(0.8),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Создай аккаунт',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Логин',
                                labelStyle: GoogleFonts.poppins(),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Пароль',
                                labelStyle: GoogleFonts.poppins(),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: AnimatedOpacity(
                                  opacity: _isPasswordVisible ? 1.0 : 0.6,
                                  duration: const Duration(milliseconds: 200),
                                  child: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: _isPasswordVisible ? Colors.blue : Colors.grey,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              obscureText: !_isPasswordVisible,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: 'Полное имя',
                                labelStyle: GoogleFonts.poppins(),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isDoctor) ...[
                              TextField(
                                controller: _specializationController,
                                decoration: InputDecoration(
                                  labelText: 'Специализация',
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _birthYearController,
                                decoration: InputDecoration(
                                  labelText: 'Год рождения',
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ] else ...[
                              TextField(
                                controller: _birthDateController,
                                decoration: InputDecoration(
                                  labelText: 'Дата рождения (ГГГГ-ММ-ДД)',
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _genderController,
                                decoration: InputDecoration(
                                  labelText: 'Пол (Male/Female/Other)',
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: _isDoctor,
                                  onChanged: (value) {
                                    setState(() {
                                      _isDoctor = value ?? false;
                                    });
                                  },
                                ),
                                Text('Я врач', style: GoogleFonts.poppins()),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                              ),
                              child: Text(
                                'Зарегистрироваться',
                                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Patient user;
  final String userType;

  const MainScreen({super.key, required this.user, required this.userType});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Patient _currentUser;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _currentUser = Patient(
            id: _currentUser.id,
            fullName: _currentUser.fullName,
            birthDate: _currentUser.birthDate,
            gender: _currentUser.gender,
            bloodType: _currentUser.bloodType,
            allergies: _currentUser.allergies,
            chronicDiseases: _currentUser.chronicDiseases,
            placeOfResidence: _currentUser.placeOfResidence,
            mahallaName: _currentUser.mahallaName,
            passportSeries: _currentUser.passportSeries,
            pinfl: _currentUser.pinfl,
            placeOfWork: _currentUser.placeOfWork,
            position: _currentUser.position,
            phone: _currentUser.phone,
            username: _currentUser.username,
            password: _currentUser.password,
            anthropometricData: _currentUser.anthropometricData,
            vaccinations: _currentUser.vaccinations,
            surgeries: _currentUser.surgeries,
            diagnoses: _currentUser.diagnoses,
            treatments: _currentUser.treatments,
            prescriptions: _currentUser.prescriptions,
            appointments: _currentUser.appointments,
            medicalReviews: _currentUser.medicalReviews,
            photoBase64: base64String, // Обновляем photoBase64
            photoPath: null,
          );
        });
      } else {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Обрезать фото',
              toolbarColor: Colors.blue[800],
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
          ],
        );
        if (croppedFile != null) {
          final directory = await getApplicationDocumentsDirectory();
          final String newPath = '${directory.path}/user_photo.png';
          await File(croppedFile.path).copy(newPath);
          setState(() {
            _currentUser = Patient(
              id: _currentUser.id,
              fullName: _currentUser.fullName,
              birthDate: _currentUser.birthDate,
              gender: _currentUser.gender,
              bloodType: _currentUser.bloodType,
              allergies: _currentUser.allergies,
              chronicDiseases: _currentUser.chronicDiseases,
              placeOfResidence: _currentUser.placeOfResidence,
              mahallaName: _currentUser.mahallaName,
              passportSeries: _currentUser.passportSeries,
              pinfl: _currentUser.pinfl,
              placeOfWork: _currentUser.placeOfWork,
              position: _currentUser.position,
              phone: _currentUser.phone,
              username: _currentUser.username,
              password: _currentUser.password,
              anthropometricData: _currentUser.anthropometricData,
              vaccinations: _currentUser.vaccinations,
              surgeries: _currentUser.surgeries,
              diagnoses: _currentUser.diagnoses,
              treatments: _currentUser.treatments,
              prescriptions: _currentUser.prescriptions,
              appointments: _currentUser.appointments,
              medicalReviews: _currentUser.medicalReviews,
              photoPath: newPath, // Обновляем photoPath
              photoBase64: null,
            );
          });
        }
      }
      await ApiService.savePatient(_currentUser);
    }
  }

  void _scanQR() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanPage())).then((result) async {
      if (result != null) {
        try {
          Patient patient;
          if (result is Patient) {
            patient = result;
          } else {
            patient = await ApiService.login(result, _currentUser.password!, 'patient') as Patient;
          }
          if (patient != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: patient, userType: 'patient')),
            );
          } else {
            showErrorDialog(context, 'Пациент не найден');
          }
        } catch (e) {
          showErrorDialog(context, 'Ошибка: $e');
        }
      }
    });
  }

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  Future<void> _editProfile() async {
    final updatedUser = await showDialog<Patient>(
      context: context,
      builder: (context) => EditProfileDialog(user: _currentUser),
    );
    if (updatedUser != null) {
      await ApiService.savePatient(updatedUser);
      setState(() {
        _currentUser = updatedUser;
      });
    }
  }

  Future<void> _viewDashboard() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PatientDashboard(patient: _currentUser)),
    );
  }

  ImageProvider _getImageProvider() {
    if (kIsWeb && _currentUser.photoBase64 != null) {
      return MemoryImage(base64Decode(_currentUser.photoBase64!));
    } else if (!kIsWeb && _currentUser.photoPath != null && File(_currentUser.photoPath!).existsSync()) {
      return FileImage(File(_currentUser.photoPath!));
    }
    return const AssetImage('assets/user_photo.jpg') as ImageProvider;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bckg_for_ms.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          Column(
            children: [
              AppBar(
                title: Text(
                  'Профиль',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.blue[800]!.withOpacity(0.7),
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Выйти',
                    onPressed: _logout,
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.white.withOpacity(0.7),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: _getImageProvider(),
                                backgroundColor: Colors.blue[100],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: _pickImage,
                                  child: Text(
                                    'Изменить фото',
                                    style: GoogleFonts.poppins(color: Colors.orange, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                TextButton(
                                  onPressed: _editProfile,
                                  child: Text(
                                    'Изменить профиль',
                                    style: GoogleFonts.poppins(color: Colors.orange, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Имя: ${_currentUser.fullName}',
                                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.blue[800]),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_currentUser.pinfl != null)
                                        Text(
                                          'ПИНФЛ: ${_currentUser.pinfl}',
                                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.blue[800]),
                                        ),
                                      if (_currentUser.passportSeries != null)
                                        Text(
                                          'Серия паспорта: ${_currentUser.passportSeries}',
                                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.blue[800]),
                                        ),
                                      if (_currentUser.placeOfResidence != null)
                                        Text(
                                          'Место жительства: ${_currentUser.placeOfResidence}',
                                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.blue[800]),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8),
                              child: QrImageView(
                                data: 'myapp://profile?patientId=${_currentUser.id}',
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: _scanQR,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[800],
                                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 4,
                                    ),
                                    child: Text(
                                      'Сканировать QR',
                                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _viewDashboard,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[800],
                                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 4,
                                    ),
                                    child: Text(
                                      'Посмотреть дашборд',
                                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final Patient user;

  const EditProfileDialog({super.key, required this.user});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pinflController;
  late TextEditingController _passportSeriesController;
  late TextEditingController _placeOfResidenceController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _pinflController = TextEditingController(text: widget.user.pinfl ?? '');
    _passportSeriesController = TextEditingController(text: widget.user.passportSeries ?? '');
    _placeOfResidenceController = TextEditingController(text: widget.user.placeOfResidence ?? '');
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _pinflController.dispose();
    _passportSeriesController.dispose();
    _placeOfResidenceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePinfl(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length != 14) return 'ПИНФЛ должен содержать\nровно 14 цифр';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'ПИНФЛ должен содержать\nтолько цифры';
    return null;
  }

  String? _validatePassportSeries(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length != 9) return 'Серия паспорта должна\nсодержать 2 буквы и 7 цифр';
    if (!RegExp(r'^[A-Z]{2}\d{7}$').hasMatch(value)) {
      return 'Серия паспорта должна\nначинаться с 2 букв, затем 7 цифр\n(например, AA1234567)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Изменить профиль', style: GoogleFonts.poppins()),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _pinflController,
                decoration: InputDecoration(
                  labelText: 'ПИНФЛ',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorStyle: GoogleFonts.poppins(color: Colors.red),
                ),
                validator: _validatePinfl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passportSeriesController,
                decoration: InputDecoration(
                  labelText: 'Серия паспорта',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorStyle: GoogleFonts.poppins(color: Colors.red),
                ),
                validator: _validatePassportSeries,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _placeOfResidenceController,
                decoration: InputDecoration(
                  labelText: 'Место жительства',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Телефон',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена', style: GoogleFonts.poppins()),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final updatedUser = Patient(
                id: widget.user.id,
                fullName: widget.user.fullName,
                birthDate: widget.user.birthDate,
                gender: widget.user.gender,
                bloodType: widget.user.bloodType,
                allergies: widget.user.allergies,
                chronicDiseases: widget.user.chronicDiseases,
                placeOfResidence: _placeOfResidenceController.text.isNotEmpty ? _placeOfResidenceController.text : null,
                mahallaName: widget.user.mahallaName,
                passportSeries: _passportSeriesController.text.isNotEmpty ? _passportSeriesController.text : null,
                pinfl: _pinflController.text.isNotEmpty ? _pinflController.text : null,
                placeOfWork: widget.user.placeOfWork,
                position: widget.user.position,
                phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
                username: widget.user.username,
                password: widget.user.password,
                anthropometricData: widget.user.anthropometricData,
                vaccinations: widget.user.vaccinations,
                surgeries: widget.user.surgeries,
                diagnoses: widget.user.diagnoses,
                treatments: widget.user.treatments,
                prescriptions: widget.user.prescriptions,
                appointments: widget.user.appointments,
                medicalReviews: widget.user.medicalReviews,
                photoPath: widget.user.photoPath,
                photoBase64: widget.user.photoBase64,
              );
              Navigator.pop(context, updatedUser);
            }
          },
          child: Text('Сохранить', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}

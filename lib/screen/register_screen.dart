import 'package:flutter/material.dart';
import 'dart:ui'; // Для ImageFilter
import '../db/api_service.dart';
import '../models/patient.dart';
import '../models/doctor.dart';

class RegisterScreen extends StatefulWidget {
  final String userType;

  const RegisterScreen({super.key, required this.userType});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _genderController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.userType == 'patient') {
        final patient = Patient(
          id: '',
          fullName: _fullNameController.text,
          birthDate: _birthDateController.text,
          gender: _genderController.text,
          bloodType: _bloodTypeController.text.isNotEmpty ? _bloodTypeController.text : null,
          allergies: _allergiesController.text.isNotEmpty ? _allergiesController.text : null,
          chronicDiseases: _chronicDiseasesController.text.isNotEmpty ? _chronicDiseasesController.text : null,
          username: _usernameController.text,
          password: _passwordController.text,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        );
        final patientId = await ApiService.registerPatient(patient);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Регистрация успешна!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final doctor = Doctor(
          id: '',
          fullName: _fullNameController.text,
          specialization: _specializationController.text,
          birthYear: int.parse(_birthYearController.text),
          username: _usernameController.text,
          password: _passwordController.text,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        );
        final doctorId = await ApiService.registerDoctor(doctor);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Регистрация успешна!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка регистрации: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Фоновое изображение с размытием
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/log_bckg.png'),
                fit: BoxFit.cover,
                opacity: 0.995,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          // Кнопка "Назад" в верхнем левом углу
          Positioned(
            top: 40,
            left: 16,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Полупрозрачный фон (glassmorphism)
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          // Круг с аватаром врача или пациента
          Positioned(
            top: 30,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.white,
                    child: Image.asset(
                      widget.userType == 'patient'
                          ? 'assets/patient_avatar.jpg'
                          : 'assets/doctor_avatar.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Основной контент
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 120),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    widget.userType == 'patient' ? 'Регистрация пациента' : 'Регистрация врача',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Карточка с полями ввода
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _usernameController,
                            label: 'Логин',
                            iconPath: 'assets/icons/username_icon.png',
                            defaultIcon: Icons.person,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Пароль',
                            iconPath: 'assets/icons/password_icon.png',
                            defaultIcon: Icons.lock,
                            obscureText: true,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _fullNameController,
                            label: 'Полное имя',
                            iconPath: 'assets/icons/fullname_icon.png',
                            defaultIcon: Icons.account_circle,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Телефон (опционально)',
                            iconPath: 'assets/icons/phone_icon.png',
                            defaultIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          if (widget.userType == 'patient') ...[
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _birthDateController,
                              label: 'Дата рождения (ГГГГ-ММ-ДД)',
                              iconPath: 'assets/icons/calendar_icon.png',
                              defaultIcon: Icons.calendar_today,
                              keyboardType: TextInputType.datetime,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _genderController,
                              label: 'Пол (Male/Female/Other)',
                              iconPath: 'assets/icons/gender_icon.png',
                              defaultIcon: Icons.wc,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _bloodTypeController,
                              label: 'Группа крови (опционально)',
                              iconPath: 'assets/icons/bloodtype_icon.png',
                              defaultIcon: Icons.bloodtype,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _allergiesController,
                              label: 'Аллергии (опционально)',
                              iconPath: 'assets/icons/allergies_icon.png',
                              defaultIcon: Icons.warning,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _chronicDiseasesController,
                              label: 'Хронические заболевания (опционально)',
                              iconPath: 'assets/icons/chronic_icon.png',
                              defaultIcon: Icons.medical_services,
                            ),
                          ],
                          if (widget.userType == 'doctor') ...[
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _specializationController,
                              label: 'Специализация',
                              iconPath: 'assets/icons/specialization_icon.png',
                              defaultIcon: Icons.work,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _birthYearController,
                              label: 'Год рождения',
                              iconPath: 'assets/icons/birthyear_icon.png',
                              defaultIcon: Icons.cake,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Кнопка "Зарегистрироваться"
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: GestureDetector(
                    onTap: _isLoading ? null : _register,
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.8),
                            Colors.blueAccent.withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          'Зарегистрироваться',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String iconPath,
    required IconData defaultIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                defaultIcon,
                color: Colors.white,
                size: 24,
              );
            },
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _specializationController.dispose();
    _birthDateController.dispose();
    _birthYearController.dispose();
    _genderController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _chronicDiseasesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

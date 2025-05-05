import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/patient.dart';
import 'db/api_service.dart';
import 'main.dart' show showErrorDialog;

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  Patient? _patient;
  MobileScannerController? _controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  bool _isFlashOn = false;

  Future<String?> _promptPassword(BuildContext context) async {
    final passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Введите пароль', style: GoogleFonts.poppins()),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Пароль',
            labelStyle: GoogleFonts.poppins(),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: Text('ОК', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(MobileScannerController controller) {
    setState(() {
      _controller = controller;
    });
    controller.barcodes.listen((BarcodeCapture capture) async {
      final scannedData = capture.barcodes.first.rawValue;
      if (scannedData != null) {
        final uri = Uri.tryParse(scannedData);
        if (uri != null && uri.scheme == 'myapp' && uri.host == 'profile') {
          final username = uri.queryParameters['username'];
          final patientId = uri.queryParameters['patientId'];

          if (username != null || patientId != null) {
            try {
              Patient patient;
              if (patientId != null) {
                patient = await ApiService.getPatientById(patientId);
              } else {
                final password = await _promptPassword(context);
                if (password == null || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пароль не введён')),
                  );
                  return;
                }
                patient = await ApiService.login(username!, password, 'patient') as Patient;
              }

              setState(() {
                _patient = patient;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Пациент найден: ${patient.fullName}')),
              );
              _controller?.stop();
              Navigator.pop(context, patient);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка: $e')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Некорректный формат QR-кода')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Некорректный QR-код')),
          );
        }
      }
    });
  }

  void _toggleFlash() {
    if (_controller != null) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      _controller!.toggleTorch();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканировать QR'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              key: _qrKey,
              controller: _controller,
              onDetect: (capture) => _onQRViewCreated(_controller ?? MobileScannerController()),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: _patient != null
                  ? Text('Пациент: ${_patient!.fullName}')
                  : const Text('Сканируйте QR-код'),
            ),
          ),
        ],
      ),
    );
  }
}
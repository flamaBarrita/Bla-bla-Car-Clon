import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Para el selector de fecha estilo iOS
import 'package:intl/intl.dart'; // Para formatear la fecha (añade 'intl' a tu pubspec.yaml si no lo tienes)

import '../../services/auth_service.dart';
import 'confirmar_email.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controlador del Wizard (Paso a paso)
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Controladores de texto para capturar los datos
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DateTime? _selectedDate;
  bool _wantsPromotions = false;
  bool _isPasswordVisible = false;

  final Color _bg = const Color(0xFF191919);
  final Color _blue = const Color(0xFF00AFF5);

  // --- LÓGICA DE NAVEGACIÓN ---
  void _nextPage() {
    if (_currentPage < 3) {
      // Validaciones básicas antes de avanzar
      if (_currentPage == 0 &&
          (_firstNameController.text.isEmpty ||
              _lastNameController.text.isEmpty)) {
        _showError("Por favor ingresa tu nombre y apellido");
        return;
      }
      if (_currentPage == 1 && _selectedDate == null) {
        _showError("Por favor selecciona tu fecha de nacimiento");
        return;
      }
      if (_currentPage == 2 && !_emailController.text.contains("@")) {
        _showError("El e-mail ingresado no tiene un formato válido.");
        return;
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Si estamos en la última página (Contraseña), hacemos el registro en Cognito
      _submitRegistration();
    }
  }

  // --- LÓGICA DE REGISTRO EN COGNITO ---
  Future<void> _submitRegistration() async {
    if (_passwordController.text.length < 8) {
      _showError("La contraseña debe tener al menos 8 caracteres.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedDate!);
      final String fullName =
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

      await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: fullName,
        birthdate: formattedDate,
      );

      // Si todo sale bien, lo mandamos a la pantalla de poner el código del correo
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmEmailPage(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              name:
                  "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
            ),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFD32F2F), // Rojo similar a la imagen
        behavior: SnackBarBehavior.floating, // Flotante estilo BlaBlaCar
      ),
    );
  }

  // --- CONSTRUCCIÓN DE LA UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00AFF5)),
          onPressed: () {
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context); // Volver al login
            }
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // PageView que contiene los 4 pasos
            PageView(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // Desactiva el swipe con el dedo
              onPageChanged: (int page) => setState(() => _currentPage = page),
              children: [
                _buildNameStep(), // Paso 0
                _buildDobStep(), // Paso 1
                _buildEmailStep(), // Paso 2
                _buildPasswordStep(), // Paso 3
              ],
            ),

            // Botón flotante de "Siguiente" abajo a la derecha
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: _blue,
                elevation: 0,
                onPressed: _isLoading ? null : _nextPage,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //widgets para cada paso
  // Paso 0: Nombre
  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "¿Cómo te llamas?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildInput(_firstNameController, "Nombre"),
          const SizedBox(height: 15),
          _buildInput(_lastNameController, "Apellido"),
        ],
      ),
    );
  }

  // Paso 1: Fecha de Nacimiento (con selector iOS)
  Widget _buildDobStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "¿Cuál es tu fecha de\nnacimiento?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _mostrarCalendarioIOS,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _bg, // Fondo oscuro
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _blue,
                  width: 2,
                ), // Borde azul al estar "seleccionado"
              ),
              child: Text(
                _selectedDate == null
                    ? "DD / MM / AAAA"
                    : DateFormat('d MMMM yyyy').format(_selectedDate!),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Paso 2: Email
  Widget _buildEmailStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "¿Cuál es tu e-mail?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildInput(_emailController, "ejemplo@correo.com", isEmail: true),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _wantsPromotions,
                onChanged: (val) => setState(() => _wantsPromotions = val!),
                activeColor: _blue,
                side: const BorderSide(color: Colors.grey),
              ),
              Expanded(
                child: Text(
                  "No quiero recibir ofertas comerciales ni recomendaciones de BlaBlaCar por correo e-mail.",
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Paso 3: Contraseña
  Widget _buildPasswordStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Establece tu contraseña",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Deberá contener al menos 8 caracteres, 1 letra, 1 número y 1 carácter especial.",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 30),
          _buildInput(_passwordController, "Contraseña", isPassword: true),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : IconButton(
                  // El botón 'x' para borrar como en tus capturas
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: () => controller.clear(),
                ),
        ),
      ),
    );
  }

  void _mostrarCalendarioIOS() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: const Color(0xFF191919), // Fondo oscuro para el popup
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16, top: 10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Cerrar",
                  style: TextStyle(
                    color: Color(0xFF00AFF5),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime(2000, 1, 1),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (val) {
                    setState(() => _selectedDate = val);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

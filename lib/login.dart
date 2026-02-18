import 'package:flutter/material.dart';
import 'home_page.dart';
import 'auth_service.dart';
import 'widgets/boton_principal.dart';
import 'widgets/entrada_datos.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Entradas del usuario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instancia de nuestro servicio de lógica
  final _authService = AuthService();

  bool _cargando = false;

  // Colores
  final Color _backgroundColor = const Color(0xFF191919);
  final Color _textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _checkSessionStatus();
  }

  // Verificar sesión al inicio
  Future<void> _checkSessionStatus() async {
    // Usamos el AuthService para preguntar si hay sesión
    final isLoggedIn = await _authService.checkSession();

    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  // Lógica de inicio de sesión
  Future<void> _signIn() async {
    setState(() => _cargando = true);

    try {
      final userLoggeado = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (userLoggeado && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF00AFF5), size: 28),
          onPressed: () => print("Cerrar"),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Inicia sesión con tu\ne-mail",
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 40),

                // Entrada de datos usando widget personalizado
                _buildLabel("Correo electrónico"),
                const SizedBox(height: 8),
                CustomInputField(
                  controller: _emailController,
                  hint: "ejemplo@correo.com",
                  icon: Icons.email_outlined,
                  inputType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 24),

                _buildLabel("Contraseña"),
                const SizedBox(height: 8),
                CustomInputField(
                  controller: _passwordController,
                  hint: "Introduce tu contraseña",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 40),

                PrimaryButton(
                  text: "Iniciar sesión",
                  isLoading: _cargando,
                  onPressed: _signIn,
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "¿Todavía no tienes una cuenta? ",
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () => print("Ir a registro"),
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(
                          color: Color(0xFF00AFF5),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

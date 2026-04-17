import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/app_providers.dart';
import '../home_page.dart';
import '/widgets/boton_principal.dart';
import '/widgets/entrada_datos.dart';
import 'signup_page.dart';
import '/services/api_service.dart';
import '/themes/app_theme.dart'; // Importamos la nueva paleta de colores institucionales

class LoginPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // Entradas del usuario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _checkSessionStatus();
  }

  // Verificar sesión al inicio
  Future<void> _checkSessionStatus() async {
    final authService = ref.read(authServiceProvider);

    // preguntamos a Cognito si hay sesión activa
    final isLoggedIn = await authService.checkSession();

    //si hay sesión, extraemos el ID y lo guardamos en Riverpod, luego vamos a ProfilePage
    if (isLoggedIn && mounted) {
      final userId = await authService.getCurrentUserId();

      if (userId != null) {
        ref.read(currentUserIdProvider.notifier).setUserId(userId);
        try {
          final apiService = ref.read(apiServiceProvider);
          final userData = await apiService.obtenerPerfil(userId);
          if (userData != null) {
            ref.read(userProfileProvider.notifier).setProfile(userData);
          }
        } catch (e) {
          rethrow;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      }
    }
  }

  // Lógica de inicio de sesión
  Future<void> _signIn() async {
    setState(() => _cargando = true);

    try {
      // llamamos a riverpod para obtener el servicio de autenticacion
      final authService = ref.read(authServiceProvider);
      final apiService = ref.read(apiServiceProvider);

      // Intentamos iniciar sesión
      await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final userId = await authService.getCurrentUserId();

      if (userId != null && mounted) {
        ref.read(currentUserIdProvider.notifier).setUserId(userId);

        try {
          final userData = await apiService.obtenerPerfil(userId);
          if (userData != null) {
            ref.read(userProfileProvider.notifier).setProfile(userData);
          }
        } catch (e) {
          rethrow;
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
            (route) => false,
          );
        }
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
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors
            .red.shade400, // Un rojo más suave y profesional para el modo claro
        behavior: SnackBarBehavior
            .floating, // Hace que el snackbar flote, viéndose más moderno
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo blanco institucional
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // Cambiamos el ícono azul por el naranja institucional
          icon:
              Icon(Icons.close, color: AnahuacColors.PRIMARY_ORANGE, size: 28),
          onPressed: () => Navigator.pop(context),
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
                    color: AnahuacColors
                        .TEXT_DARK, // Gris oscuro para máxima legibilidad
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 40),
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
                      style: TextStyle(
                        color: AnahuacColors
                            .TEXT_SECONDARY, // Gris medio para no competir con el enlace
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text(
                        "Registrarse",
                        style: TextStyle(
                          color: AnahuacColors
                              .PRIMARY_ORANGE, // El enlace de acción en naranja
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
        color:
            AnahuacColors.TEXT_SECONDARY, // Gris profesional para las etiquetas
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

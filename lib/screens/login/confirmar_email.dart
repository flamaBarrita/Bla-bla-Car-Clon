import 'package:flutter/material.dart';
import '../home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/app_providers.dart';

class ConfirmEmailPage extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final String name;

  const ConfirmEmailPage({
    Key? key,
    required this.email,
    required this.password,
    required this.name,
  }) : super(key: key);

  @override
  ConsumerState<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends ConsumerState<ConfirmEmailPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _confirmar() async {
    final authService = ref.read(authServiceProvider);
    final apiService = ref.read(apiServiceProvider);
    setState(() => _isLoading = true);

    try {
      // Confirmamos usando cognito
      await authService.confirmSignUp(
        email: widget.email,
        code: _codeController.text.trim(),
      );

      // iniciamos sesion por debajo
      await authService.signIn(widget.email, widget.password);

      final userId = await authService.getCurrentUserId();

      if (userId == null) {
        throw Exception(
            "No se pudo obtener el ID de Cognito tras iniciar sesión.");
      }

      await apiService.registrarUsuarioInicial(
        userId: userId,
        name: widget.name,
      );

      //registramos a nuestro usuario en la db

      //Refrescamos la memoria de Riverpod antes de navegar
      ref.invalidate(userProfileProvider);

      try {
        final Map<String, dynamic>? userData =
            await apiService.obtenerPerfil(userId);

        if (userData != null) {
          // Guardamos datos nuevos en la caché
          ref.read(userProfileProvider.notifier).setProfile(userData);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error interno. Inténtalo de nuevo'),
              backgroundColor: Colors.redAccent),
        );
      }

      // Solo si llegamos hasta aquí sin errores, navegamos.
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: Verifica tu código e intenta de nuevo.'),
            backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Confirma tu e-mail",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Hemos enviado un código a ${widget.email}",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 10,
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "000000",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AFF5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Verificar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

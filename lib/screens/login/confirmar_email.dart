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
    //utilizamos los providers para obtener las instancias de los servicios
    final authService = ref.read(authServiceProvider);
    final apiService = ref.read(apiServiceProvider);
    setState(() => _isLoading = true);
    try {
      // Confirmamos el código con Cognito
      await authService.confirmSignUp(
        email: widget.email,
        code: _codeController.text.trim(),
      );

      // Logeamos automaticamente al usuario para obtener el ID
      await authService.signIn(widget.email, widget.password);

      // Obtener el ID del usuario autenticado
      final userId = await authService.getCurrentUserId();

      // Se triggera la creación del usuario en la db con el ID obtenido
      if (userId != null) {
        await apiService.registrarUsuarioInicial(
          userId: userId,
          name: widget.name,
        );
      }

      // si el user sigue en la pantalla, navegamos a la homepage
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
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

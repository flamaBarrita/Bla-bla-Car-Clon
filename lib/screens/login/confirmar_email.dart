import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../home_page.dart';

class ConfirmEmailPage extends StatefulWidget {
  final String email;
  final String password; // Recibimos la contraseña para el auto-login
  final String name; // Recibimos el nombre para Postgres

  const ConfirmEmailPage({
    Key? key,
    required this.email,
    required this.password,
    required this.name,
  }) : super(key: key);

  @override
  _ConfirmEmailPageState createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _confirmar() async {
    setState(() => _isLoading = true);
    try {
      // 1. Confirmamos el código con AWS
      await AuthService().confirmSignUp(
        email: widget.email,
        code: _codeController.text.trim(),
      );

      // 2. SOLUCIÓN AL BUG: Hacemos el Login automáticamente por detrás
      await AuthService().signIn(widget.email, widget.password);

      // 3. Obtenemos el ID real que Cognito nos acaba de asignar
      final userId = await AuthService().getCurrentUserId();

      // 4. EL "TRIGGER": Mandamos a Postgres el ID y el Nombre
      if (userId != null) {
        await ApiService().registrarUsuarioInicial(
          userId: userId,
          name: widget.name,
        );
      }

      // 5. ¡Todo listo! Mandamos al Home
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

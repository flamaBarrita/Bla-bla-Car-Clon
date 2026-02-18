import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login.dart';

class HomePage extends StatelessWidget {
  final Color _backgroundColor = const Color(0xFF191919);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Hola, Mario",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0,
        actions: [
          // Botón de salir
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿A dónde quieres ir hoy?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Cierre de sesion y eliminar el historial para que no puedan volver atrás
  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService().signOut();
      // Llevar al login y eliminamos la pila de navegación
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al salir: $e')));
    }
  }
}

import 'package:amplify_flutter/amplify_flutter.dart';

// Este servicio centraliza toda la lógica de autenticación con Amplify

class AuthService {
  // Patrón Singleton: Para aseugurarnos de que solo haya una instancia de AuthService en toda la app
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Verificar si el usuario ya tiene una sesión activa
  Future<bool> checkSession() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      print("Error revisando sesión: $e");
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      print("Error saliendo: $e");
    }
  }

  // Iniciar sesión con email y contraseña
  Future<bool> signIn(String email, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      return result.isSignedIn;
    } catch (e) {
      throw e; // Reenviamos el error para que la UI muestre el mensaje
    }
  }
}

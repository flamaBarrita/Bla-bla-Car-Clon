import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

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

  // Obtener el ID del usuario actual
  Future<String?> getCurrentUserId() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user.userId;
    } catch (e) {
      print("Error obteniendo el ID del usuario: $e");
      return null;
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

  // Registrar al user
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String birthdate,
  }) async {
    try {
      final userAttributes = {
        AuthUserAttributeKey.name: name,
        AuthUserAttributeKey.birthdate: birthdate,
      };

      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(userAttributes: userAttributes),
      );

      // Devuelve true si requiere confirmación o si ya se completó
      return result.isSignUpComplete ||
          result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp;
    } catch (e) {
      print("Error en registro: $e");
      rethrow; // Lanzamos el error para que la UI lo atrape y muestre la barra roja
    }
  }

  // confirmar el registro con el código enviado al email
  Future<bool> confirmSignUp({
    required String email,
    required String code,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: code,
      );
      return result.isSignUpComplete;
    } catch (e) {
      print("Error confirmando registro: $e");
      rethrow;
    }
  }

  /// Obtiene el token JWT actual de Cognito para enviarlo a FastAPI
  Future<String?> getCognitoToken() async {
    try {
      // 1. Obtenemos el plugin específico de Cognito (La forma moderna recomendada por AWS)
      final cognitoPlugin = Amplify.Auth.getPlugin(
        AmplifyAuthCognito.pluginKey,
      );

      // 2. Pedimos la sesión directamente al plugin
      final session = await cognitoPlugin.fetchAuthSession();

      // 3. Verificamos si el usuario tiene la sesión iniciada
      if (session.isSignedIn) {
        // Extraemos los tokens de forma segura
        final tokens = session.userPoolTokensResult.value;

        // Retornamos el token de acceso como texto
        return tokens.accessToken.raw;
      }

      return null; // No hay sesión activa
    } on SignedOutException {
      print("El usuario no ha iniciado sesión.");
      return null;
    } catch (e) {
      print("🔥 Error obteniendo el token de Cognito: $e");
      return null;
    }
  }
}

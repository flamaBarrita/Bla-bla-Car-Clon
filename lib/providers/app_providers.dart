import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/google_maps.dart';

// Servicios globales
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final googleMapsServiceProvider = Provider<GoogleMapsService>((ref) {
  return GoogleMapsService();
});

//Creamos una clase para manejar el id del usuario
class CurrentUserNotifier extends Notifier<String?> {
  @override
  String? build() {
    // Estado inicial: null (nadie ha iniciado sesión)
    return null;
  }

  // Única función autorizada para cambiar el ID
  void setUserId(String? newId) {
    state = newId;
  }
}

// Providers globales, es el que se usará en toda la app
final currentUserIdProvider = NotifierProvider<CurrentUserNotifier, String?>(
  () {
    return CurrentUserNotifier();
  },
);

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, Map<String, dynamic>?>(() {
      return UserProfileNotifier();
    });

// Controlador del perfil del usuario que se encargará de almacenar los datos que lleguen de FastAPI
class UserProfileNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() {
    return null; // Empieza vacío (sin caché)
  }

  // Función para guardar los datos que lleguen de FastAPI
  void setProfile(Map<String, dynamic> profileData) {
    state = profileData;
  }

  // Función para borrar el caché, se ocupará cuando el usuario cierre sesión o se quiera refrescar la información
  void clearProfile() {
    state = null;
  }
}

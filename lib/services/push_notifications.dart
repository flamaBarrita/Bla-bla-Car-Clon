import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';

class PushNotificationService {
  static Future<void> inicializarYGuardarToken(ApiService apiService) async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    // Pedimos permiso al usuario para recibir notificaciones
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Extraer el Token único de este celular
      try {
        String? fcmToken = await firebaseMessaging.getToken();

        if (fcmToken != null) {
          await apiService.actualizarTokenNotificaciones(fcmToken);
        }
      } catch (e) {
        throw Exception('Error desconocido. Inténtalo de nuevo más tarde');
      }

      firebaseMessaging.onTokenRefresh.listen((nuevoToken) {
        apiService.actualizarTokenNotificaciones(nuevoToken);
      });
    }
  }
}

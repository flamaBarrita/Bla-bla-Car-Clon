import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart'; // Asegúrate de importar tu ApiService

class PushNotificationService {
  static Future<void> inicializarYGuardarToken(ApiService apiService) async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    // Pedimos permiso al usuario para recibir notificaciones (importante en iOS)
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso de notificaciones concedido por el usuario.');

      // 2. Extraer el Token único de este celular
      try {
        String? fcmToken = await firebaseMessaging.getToken();

        if (fcmToken != null) {
          print("📱 Tu FCM Token es: $fcmToken");

          // 3. Mandarlo a FastAPI para guardarlo en PostgreSQL
          await apiService.actualizarTokenNotificaciones(fcmToken);
        }
      } catch (e) {
        print("Error obteniendo el token de Firebase: $e");
      }

      // (Opcional) Escuchar si el token cambia por alguna razón en el futuro
      firebaseMessaging.onTokenRefresh.listen((nuevoToken) {
        apiService.actualizarTokenNotificaciones(nuevoToken);
      });
    } else {
      print('El usuario denegó el permiso de notificaciones.');
    }
  }
}

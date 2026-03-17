import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // Patrón Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = 'http://140.84.167.187:8000';

  final AuthService _authService = AuthService();

  /// Función auxiliar que crea los encabezados seguros con el token de autenticación.
  /// Devuelve los headers necesarios para hacer peticiones autenticadas al servidor.
  Future<Map<String, String>> _getSecureHeaders() async {
    final String? token = await _authService.getCognitoToken();

    if (token != null) {
      return {
        'Content-Type': 'application/json',
        // le pegamos el header al token
        'Authorization': 'Bearer $token',
      };
    } else {
      // Si no hay token, mandamos solo el tipo de contenido
      return {'Content-Type': 'application/json'};
    }
  }

  /// Obtiene los datos del perfil de un usuario específico.
  /// Retorna un mapa con la información del perfil o null si hay error.
  Future<Map<String, dynamic>?> obtenerPerfil(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/profile/$userId');
      final headers = await _getSecureHeaders(); // añadimos seguridad
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Publica un nuevo viaje en la plataforma.
  /// El conductor especifica origen, destino, horario, precio y plazas disponibles.
  /// Retorna true si se publica correctamente, false si hay error.
  Future<bool> publicarViaje({
    required String driverId,
    required String originName,
    required double originLat,
    required double originLng,
    required String destName,
    required double destLat,
    required double destLng,
    required String distanceText,
    required String durationText,
    required String departureTime,
    required double price,
    required int seatsAvailable,
    required String encodedPolyline,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/trips/$driverId');
      final headers = await _getSecureHeaders();

      final response = await http.post(
        url,
        headers: headers, // <-- USAMOS LOS HEADERS SEGUROS
        body: jsonEncode({
          "origin_name": originName,
          "origin_lat": originLat,
          "origin_lng": originLng,
          "dest_name": destName,
          "dest_lat": destLat,
          "dest_lng": destLng,
          "distance_text": distanceText,
          "duration_text": durationText,
          "departure_time": departureTime,
          "price": price,
          "seats_available": seatsAvailable,
          "encoded_polyline": encodedPolyline,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201)
        return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Envía una solicitud para que un pasajero se una a un viaje existente.
  /// Retorna un mapa indicando si la solicitud fue exitosa o con mensaje de error.
  Future<Map<String, dynamic>> solicitarUnirse({
    required int tripId,
    required String senderId,
    required String passengerId,
    required String passengerName,
    required String passengerPhoto,
    required String passengerRating,
    required int seatsRequested,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/trips/$tripId/requests');
      final headers = await _getSecureHeaders();

      final response = await http.post(
        url,
        headers: headers, // <-- USAMOS LOS HEADERS SEGUROS
        body: jsonEncode({
          "passenger_id": passengerId,
          "passenger_name": passengerName,
          "passenger_photo": passengerPhoto,
          "passenger_rating": passengerRating,
          "seats_requested": seatsRequested,
          "sender_id": senderId,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Solicitud enviada'};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  /// Registra un nuevo usuario en la base de datos al crear la cuenta.
  /// Guarda el ID y nombre del usuario.
  /// Retorna true si se crea correctamente, false si hay error.
  Future<bool> registrarUsuarioInicial({
    required String userId,
    required String name,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId');
      final headers = await _getSecureHeaders();

      final response = await http.post(
        url,
        headers: headers, // <-- USAMOS LOS HEADERS SEGUROS
        body: jsonEncode({"name": name}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Fallo al crear usuario en la base de datos: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Actualiza la información del perfil del usuario (biografía, preferencias, vehículos).
  /// Retorna true si se guarda correctamente, false si hay error.
  Future<bool> guardarPerfil({
    required String userId,
    required String biography,
    required String preferences,
    required String vehicles,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/profile/$userId');
      final headers = await _getSecureHeaders();

      final response = await http.put(
        url,
        headers: headers, // <-- USAMOS LOS HEADERS SEGUROS
        body: jsonEncode({
          "biography": biography,
          "preferences": preferences,
          "vehicles": vehicles,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el viaje activo/en curso de un conductor.
  /// Retorna los datos del viaje o null si no hay viaje activo.
  Future<Map<String, dynamic>?> getActiveTrip(String driverId) async {
    try {
      final url = Uri.parse('$_baseUrl/trips/active/$driverId');
      final headers = await _getSecureHeaders();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 && response.body != 'null') {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('Error desconocido. Inténtalo de nuevo más tarde');
    }
    return null;
  }

  /// Obtiene todas las solicitudes de pasajeros pendientes para un viaje específico.
  /// Retorna una lista de solicitudes o lista vacía si hay error.
  Future<List<dynamic>> getTripRequests(int tripId) async {
    try {
      final url = Uri.parse('$_baseUrl/trips/$tripId/requests');
      final headers = await _getSecureHeaders();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('Error desconocido. Inténtalo de nuevo más tarde');
    }
    return [];
  }

  /// Responde a una solicitud de pasajero (aprobar o rechazar).
  /// El status puede ser 'aceptado' o 'rechazado'
  /// Retorna true si se actualiza correctamente, false si hay error.
  Future<bool> respondToRequest(int requestId, String status) async {
    try {
      final url = Uri.parse('$_baseUrl/requests/$requestId/status');
      final headers = await _getSecureHeaders();

      final response = await http.put(
        url,
        headers: headers, // <-- USAMOS LOS HEADERS SEGUROS
        body: jsonEncode({"status": status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Busca todos los viajes disponibles según el origen y destino especificados.
  /// Usa coordenadas (latitud/longitud) para encontrar rutas que coincidan.
  /// Retorna una lista de viajes disponibles o lista vacía si hay error.
  Future<List<dynamic>> buscarViajes(
    double oLat,
    double oLng,
    double dLat,
    double dLng,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/trips/search?olat=$oLat&olng=$oLng&dlat=$dLat&dlng=$dLng',
      );
      final headers = await _getSecureHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('Error desconocido. Inténtalo de nuevo más tarde');
    }
    return [];
  }

  /// Cancela un viaje publicado por el conductor.
  /// Retorna true si se cancela correctamente, false si hay error.
  Future<bool> eliminarViaje(String viajeId) async {
    try {
      final headers = await _getSecureHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl/trips/$viajeId/cancelar'),
        headers: headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Guarda el token FCM (Firebase Cloud Messaging) en la base de datos.
  /// Este token se usa para enviar notificaciones push al usuario.
  Future<void> actualizarTokenNotificaciones(String token) async {
    try {
      final headers = await _getSecureHeaders();

      final body = jsonEncode({"fcm_token": token});

      await http.patch(
        Uri.parse('$_baseUrl/api/users/update-fcm-token'),
        headers: headers,
        body: body,
      );
    } catch (e) {
      throw Exception(
          'Error al actualizar el token. Inténtalo de nuevo más tarde');
    }
  }

  /// Obtiene todos los viajes aprobados/confirmados de un pasajero.
  /// Retorna una lista de viajes reservados o null si hay error.
  Future<List<dynamic>?> obtenerMisViajesAprobados(String passengerId) async {
    try {
      final headers = await _getSecureHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/mis-viajes/aprobados/$passengerId'),
        headers: headers,
      );

      // Evaluamos lo que nos contestó el servidor
      if (response.statusCode == 200) {
        // Traducimos el texto JSON a una Lista que Flutter entienda
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Cancela un asiento reservado en un viaje (acción del pasajero).
  /// Retorna true si se cancela correctamente, false si hay error.
  Future<bool> cancelarAsientoPasajero(
    String tripId,
    String passengerId,
  ) async {
    try {
      final headers = await _getSecureHeaders();

      final response = await http.patch(
        Uri.parse('$_baseUrl/trips/$tripId/pasajeros/$passengerId/cancelar'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

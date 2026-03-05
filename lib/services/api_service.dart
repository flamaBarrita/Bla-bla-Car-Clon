import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // Patrón Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = 'http://192.168.1.76:8000';

  final AuthService _authService = AuthService();

  // Función auxiliar para armar las cabeceras con el candado
  Future<Map<String, String>> _getSecureHeaders() async {
    final String? token = await _authService.getCognitoToken();

    if (token != null) {
      return {
        'Content-Type': 'application/json',
        // ¡Aquí está la magia! Le pegamos el token al Header
        'Authorization': 'Bearer $token',
      };
    } else {
      // Si no hay token, mandamos solo el tipo de contenido
      return {'Content-Type': 'application/json'};
    }
  }

  Future<Map<String, dynamic>?> obtenerPerfil(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/profile/$userId');
      final headers = await _getSecureHeaders(); // <-- SEGURIDAD AÑADIDA
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error obteniendo perfil: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error de red al obtener perfil: $e");
      return null;
    }
  }

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
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/trips/$driverId');
      final headers = await _getSecureHeaders(); // <-- SEGURIDAD AÑADIDA

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
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
          "🔥 Error de FastAPI: Código ${response.statusCode} -> ${response.body}",
        );
        return false;
      }

      return true;
    } catch (e) {
      print("Error de red publicando viaje: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> solicitarUnirse({
    required int tripId,
    required String passengerId,
    required String passengerName,
    required String passengerPhoto,
    required String passengerRating,
    required int seatsRequested,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/trips/$tripId/requests');
      final headers = await _getSecureHeaders(); // <-- SEGURIDAD AÑADIDA

      final response = await http.post(
        url,
        headers: headers, // <-- USAMOS LOS HEADERS SEGUROS
        body: jsonEncode({
          "passenger_id": passengerId,
          "passenger_name": passengerName,
          "passenger_photo": passengerPhoto,
          "passenger_rating": passengerRating,
          "seats_requested": seatsRequested,
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
      print("Error enviando solicitud: $e");
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<bool> registrarUsuarioInicial({
    required String userId,
    required String name,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId');
      final headers = await _getSecureHeaders(); // <-- SEGURIDAD AÑADIDA

      final response = await http.post(
        url,
        headers: headers, // <-- USAMOS LOS HEADERS SEGUROS
        body: jsonEncode({"name": name}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error creando usuario en Postgres: $e");
      return false;
    }
  }

  Future<bool> guardarPerfil({
    required String userId,
    required String biography,
    required String preferences,
    required String vehicles,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/profile/$userId');
      final headers = await _getSecureHeaders(); // <-- SEGURIDAD AÑADIDA

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
        print("Error del backend: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de red: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getActiveTrip(String driverId) async {
    try {
      final url = Uri.parse('$_baseUrl/trips/active/$driverId');
      final headers = await _getSecureHeaders(); // <-- SEGURIDAD AÑADIDA

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 && response.body != 'null') {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error obteniendo viaje activo: $e");
    }
    return null;
  }

  Future<List<dynamic>> getTripRequests(int tripId) async {
    try {
      final url = Uri.parse('$_baseUrl/trips/$tripId/requests');
      final headers = await _getSecureHeaders(); // <-- SEGURIDAD AÑADIDA

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error obteniendo peticiones: $e");
    }
    return [];
  }

  Future<bool> respondToRequest(int requestId, String status) async {
    try {
      final url = Uri.parse('$_baseUrl/requests/$requestId/status');
      final headers = await _getSecureHeaders(); // <-- SEGURIDAD AÑADIDA

      final response = await http.put(
        url,
        headers: headers, // <-- USAMOS LOS HEADERS SEGUROS
        body: jsonEncode({"status": status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error actualizando estado: $e");
      return false;
    }
  }

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
      print("Error buscando viajes: $e");
    }
    return [];
  }
}

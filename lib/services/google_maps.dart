import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleMapsService {
  static final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // 1. Obtener sugerencias de direcciones (Autocomplete)
  Future<List<dynamic>> getAutocomplete(String search) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&key=$_apiKey&language=es&components=country:mx';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['predictions']; // Devuelve la lista de lugares
    }
    return [];
  }

  // 2. Obtener las coordenadas (Lat, Lng) de un lugar seleccionado
  Future<LatLng?> getPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final location = json['result']['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    }
    return null;
  }

  // 4. Obtener dirección en texto a partir de coordenadas GPS (Reverse Geocoding)
  Future<String?> getAddressFromLatLng(LatLng coords) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${coords.latitude},${coords.longitude}&key=$_apiKey&language=es';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK' && (json['results'] as List).isNotEmpty) {
          // Devolvemos la primera dirección encontrada (la más exacta)
          return json['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      print("Error en Reverse Geocoding: $e");
    }
    return null; // Si falla, devolvemos null
  }

  // 3. Obtener la ruta, distancia y tiempo entre dos puntos
  Future<Map<String, dynamic>?> getDirections(
    LatLng origin,
    LatLng dest,
  ) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${dest.latitude},${dest.longitude}&alternatives=true&key=$_apiKey&language=es';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // 🛡️ 1. ESCUDO DEFENSIVO: Verificamos qué nos respondió Google
        if (json['status'] != 'OK') {
          print('⚠️ Error de Google Maps: ${json['status']}');
          if (json['error_message'] != null) {
            print('Detalle: ${json['error_message']}');
          }
          return null; // Abortamos misión limpiamente, sin crashear la app
        }

        // 🛡️ 2. Verificamos que sí existan rutas
        if (json['routes'] == null || (json['routes'] as List).isEmpty) {
          print('⚠️ No se encontraron rutas viables para este trayecto.');
          return null;
        }

        // Tomamos la primera ruta sugerida (la más rápida)
        final route = json['routes'][0];
        final leg = route['legs'][0];

        // ⚡ 3. ¡EL TESORO PARA POSTGIS! Guardamos el string crudo
        final String rawEncodedPolyline = route['overview_polyline']['points'];

        // Decodificamos la línea azul para el mapa de Flutter
        // (Nota: Asegúrate de instanciar PolylinePoints() si la librería lo requiere)
        // ⚡ LA SOLUCIÓN: Agregamos el parámetro nombrado apiKey
        // ⚡ LA SOLUCIÓN: Quitamos los paréntesis (). Ahora es un método estático.
        List<PointLatLng> result = PolylinePoints.decodePolyline(
          rawEncodedPolyline,
        );
        List<LatLng> polylineCoordinates = result
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        return {
          'distance': leg['distance']['text'], // Ej. "456 km"
          'duration': leg['duration']['text'], // Ej. "6 h 11 min"
          'summary': route['summary'], // Ej. "México 135D"
          'polyline': polylineCoordinates, // Lista para dibujar en tu UI
          'encodedPolyline':
              rawEncodedPolyline, // ⚡ ¡El nuevo dato para tu backend!
        };
      } else {
        print('Error del servidor al buscar ruta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión o parseo en getDirections: $e');
    }

    return null;
  }
}

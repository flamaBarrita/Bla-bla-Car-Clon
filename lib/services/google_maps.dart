import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleMapsService {
  static final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // Obtener sugerencias de direcciones (Autocomplete)
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

  // Obtener las coordenadas (Lat, Lng) de un lugar seleccionado
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

  // Obtener dirección en texto a partir de coordenadas GPS
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
      rethrow;
    }
    return null; // Si falla, devolvemos null
  }

  // Obtener la ruta, distancia y tiempo entre dos puntos
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

        // Verificamos qué nos respondió Google
        if (json['status'] != 'OK')
          return null; // Abortamos limpiamente, sin crashear la app

        // Verificamos que sí existan rutas
        if (json['routes'] == null || (json['routes'] as List).isEmpty) {
          return null;
        }

        // Tomamos la primera ruta sugerida (la más rápida)
        final route = json['routes'][0];
        final leg = route['legs'][0];

        // Guardamos el string crudo
        final String rawEncodedPolyline = route['overview_polyline']['points'];

        // Pedimos los polynes
        List<PointLatLng> result = PolylinePoints.decodePolyline(
          rawEncodedPolyline,
        );
        List<LatLng> polylineCoordinates = result
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        return {
          'distance': leg['distance']['text'],
          'duration': leg['duration']['text'],
          'summary': route['summary'],
          'polyline': polylineCoordinates, // Lista para dibujar en tu UI
          'encodedPolyline': rawEncodedPolyline,
        };
      } else {
        throw Exception('Error desconocido. Inténtalo de nuevo más tarde');
      }
    } catch (e) {
      //
    }

    return null;
  }
}

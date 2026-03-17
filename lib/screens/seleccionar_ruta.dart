import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/google_maps.dart';
import '/providers/app_providers.dart'; // Para usar Riverpod y acceder a los servicios desde el provider
import 'fecha_hora_viaje.dart';

class RouteSelectionScreen extends ConsumerStatefulWidget {
  final LatLng origin;
  final LatLng destination;
  final String originName;
  final String destName;

  const RouteSelectionScreen({
    Key? key,
    required this.origin,
    required this.destination,
    required this.originName,
    required this.destName,
  }) : super(key: key);

  @override
  ConsumerState<RouteSelectionScreen> createState() =>
      _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends ConsumerState<RouteSelectionScreen> {
  GoogleMapsService get mapService => ref.read(googleMapsServiceProvider);
  late GoogleMapController _mapController;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  String _distance = "";
  String _duration = "";
  String _routeSummary = "";
  String _encodedPolylineParaPostgis = "";
  // String? _encodedPolylineParaPostgis;
  bool _isLoading = true;

  // JSON para pintar el mapa de Google en colores oscuros
  final String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
    {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
    {"featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [{"color": "#9e9e9e"}]},
    {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#bdbdbd"}]},
    {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
    {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _setMarkers();
    _fetchRoute();
  }

  void _setMarkers() {
    _markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: widget.origin,
        infoWindow: InfoWindow(title: widget.originName),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('dest'),
        position: widget.destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  Future<void> _fetchRoute() async {
    final routeData = await mapService.getDirections(
      widget.origin,
      widget.destination,
    );

    if (routeData != null) {
      setState(() {
        _distance = routeData['distance'];
        _duration = routeData['duration'];
        _routeSummary = routeData['summary'];
        _encodedPolylineParaPostgis = routeData['encodedPolyline'];

        // Dibujamos la línea azul de la ruta
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: const Color(0xFF00AFF5), // Azul de tu diseño
            width: 5,
            points: routeData['polyline'],
          ),
        );
        _isLoading = false;
      });

      // Movemos la cámara para que Origen y Destino quepan en la pantalla
      if (_mapController != null) {
        // Buena práctica asegurar que el controlador esté listo
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(
                widget.origin.latitude < widget.destination.latitude
                    ? widget.origin.latitude
                    : widget.destination.latitude,
                widget.origin.longitude < widget.destination.longitude
                    ? widget.origin.longitude
                    : widget.destination.longitude,
              ),
              northeast: LatLng(
                widget.origin.latitude > widget.destination.latitude
                    ? widget.origin.latitude
                    : widget.destination.latitude,
                widget.origin.longitude > widget.destination.longitude
                    ? widget.origin.longitude
                    : widget.destination.longitude,
              ),
            ),
            100.0, // Espacio de margen (padding)
          ),
        );
      }
    } else {
      // 🛡️ ESCUDO: Si mapService devuelve null, quitamos el loader y avisamos
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo calcular la ruta. Intenta mover los puntos.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _continuarHaciaFechaYHora() {
    // 1. Armamos nuestro "paquete" con todo lo que llevamos del viaje
    final Map<String, dynamic> tripData = {
      'originName': widget.originName,
      'originLat': widget.origin.latitude,
      'originLng': widget.origin.longitude,
      'destName': widget.destName,
      'destLat': widget.destination.latitude,
      'destLng': widget.destination.longitude,
      'distanceText': _distance,
      'durationText': _duration,
      'encodedPolyline': _encodedPolylineParaPostgis,
    };

    // 2. Pasamos la estafeta a la pantalla de Fecha y Hora
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectDateTimeScreen(tripData: tripData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.origin,
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController.setMapStyle(_darkMapStyle);
            },
          ),

          // Tarjeta inferior de confirmación
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Color(0xFF191919),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '¿Qué ruta tomarás?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00AFF5),
                      ),
                    )
                  else
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.radio_button_checked,
                        color: Color(0xFF00AFF5),
                      ),
                      title: Text(
                        '$_duration - $_routeSummary',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '$_distance - Ruta recomendada',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // BOTÓN PARA GUARDAR EL VIAJE EN LA BASE DE DATOS
                  // BOTÓN PARA CONTINUAR A LA PANTALLA DE FECHA Y HORA
                  Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF00AFF5),
                      onPressed:
                          _continuarHaciaFechaYHora, // ⚡ Solo llamamos a la función
                      // Cambié el ícono a una flecha, ya que aún no es el paso final
                      child:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

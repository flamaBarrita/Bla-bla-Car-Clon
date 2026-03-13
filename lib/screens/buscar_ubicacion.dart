import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/google_maps.dart';
import 'package:geolocator/geolocator.dart';

class SearchLocationScreen extends StatefulWidget {
  final String title;
  const SearchLocationScreen({Key? key, required this.title}) : super(key: key);

  @override
  _SearchLocationScreenState createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GoogleMapsService _mapsService = GoogleMapsService();

  // Lista de predicciones que vienen de Google
  List<dynamic> _predictions = [];

  bool _isProcessing = false;

  // Función que se llama cada vez que el texto del TextField cambia
  void _onSearchChanged(String value) async {
    if (value.length > 2) {
      final results = await _mapsService.getAutocomplete(value);
      setState(() => _predictions = results);
    } else {
      setState(() => _predictions = []);
    }
  }

  // Función para usar el GPS del celular
  Future<void> _useCurrentLocation() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Verificar si el GPS está prendido
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _mostrarError('Por favor, enciende tu GPS para usar esta función.');
        return;
      }

      // Pedir permisos al usuario
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _mostrarError('Se requieren permisos de ubicación.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _mostrarError(
          'Los permisos de ubicación están bloqueados permanentemente.',
        );
        return;
      }

      // Sacar las coordenadas exactas
      Position position = await Geolocator.getCurrentPosition();
      LatLng myCoords = LatLng(position.latitude, position.longitude);

      // Preguntarle a Google el nombre de la calle
      String? myAddress = await _mapsService.getAddressFromLatLng(myCoords);

      if (!mounted) return;

      // Regresar los datos a la pantalla principal
      if (Navigator.canPop(context)) {
        Navigator.pop(context, {
          'coords': myCoords,
          // Si por alguna razón Google no sabe la calle, le ponemos un texto por defecto
          'name': myAddress ?? 'Ubicación actual',
        });
      }
    } catch (e) {
      _mostrarError('Error al obtener ubicación: $e');
    } finally {
      // Apagamos la barra circular si hubo un error y no navegó
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Pequeño helper para mostrar errores rápidos
  void _mostrarError(String mensaje) {
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  void _selectPlace(String placeId, String description) async {
    if (_isProcessing) return;

    // ESCONDEMOS EL TECLADO FORZOSAMENTE
    FocusScope.of(context).unfocus();

    setState(() => _isProcessing = true);

    LatLng? coords = await _mapsService.getPlaceDetails(placeId);

    if (!mounted) return;

    if (coords != null) {
      // Regresamos a la pantalla anterior con los datos del lugar seleccionado
      final puedeRegresar = await Navigator.maybePop(context, {
        'coords': coords,
        'name': description,
      });

      if (!puedeRegresar) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se pudo regresar a la pantalla anterior.')),
        );
      }
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener la ubicación.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00AFF5)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se puede regresar.')),
              );
            }
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Pantalla principal con el TextField y las predicciones (si las hay)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ingresa la dirección completa',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _predictions = []);
                        },
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              //spread operator para meter varios widgets en un if
              if (widget.title == '¿Desde dónde sales?') ...[
                ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.white),
                  title: const Text(
                    'Utilizar ubicación actual',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                  onTap:
                      _useCurrentLocation, // Llamamos a la función para usar el GPS
                ),
                const Divider(color: Colors.grey, height: 1),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final place = _predictions[index];
                    return ListTile(
                      leading: const Icon(Icons.schedule, color: Colors.grey),
                      title: Text(
                        place['structured_formatting']['main_text'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        place['structured_formatting']['secondary_text'],
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                      onTap: () =>
                          _selectPlace(place['place_id'], place['description']),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF00AFF5)),
              ),
            ),
        ],
      ),
    );
  }
}

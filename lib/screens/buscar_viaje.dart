import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'buscar_ubicacion.dart';
import 'resultados_busqueda_viaje.dart';
import '/widgets/navegacion_button.dart';

class SearchTripScreen extends StatefulWidget {
  const SearchTripScreen({Key? key}) : super(key: key);

  @override
  _SearchTripScreenState createState() => _SearchTripScreenState();
}

class _SearchTripScreenState extends State<SearchTripScreen> {
  String? _originName;
  LatLng? _originCoords;

  String? _destName;
  LatLng? _destCoords;

  // Función para abrir la pantalla de buscar lugar usando bool para diferenciar origen de destino
  Future<void> _selectLocation(bool isOrigin) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchLocationScreen(
          title: isOrigin ? '¿De dónde te recogemos?' : '¿A dónde viajas?',
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (isOrigin) {
          _originName = result['name'];
          _originCoords = result['coords'];
        } else {
          _destName = result['name'];
          _destCoords = result['coords'];
        }
      });
    }
  }

  void _searchTrips() {
    // Validamos que el pasajero haya elegido puntos reales en el mapa
    if (_originCoords == null || _destCoords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona origen y destino en el mapa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navegamos a los resultados pasándole los nombres Y las coordenadas exactas
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripResultsScreen(
          originName: _originName!,
          originCoords: _originCoords!, // pasamos el LatLng del origen
          destName: _destName!,
          destCoords: _destCoords!, // pasamos el LatLng del destino
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        title: const Text(
          'Buscar viaje',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF191919),
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿A dónde quieres ir?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Contenedor que simula un formulario
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Botón de Origen
                  ListTile(
                    leading: const Icon(
                      Icons.radio_button_checked,
                      color: Colors.white,
                    ),
                    title: Text(
                      _originName ?? 'Dejar en blanco para usar tu GPS',
                      style: TextStyle(
                        color: _originName == null
                            ? Colors.grey[500]
                            : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.search, color: Colors.grey),
                    onTap: () => _selectLocation(true),
                  ),

                  Container(
                    margin: const EdgeInsets.only(left: 50),
                    height: 1,
                    color: Colors.grey[800],
                  ),

                  // Botón de Destino
                  ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Color(0xFF00AFF5),
                    ),
                    title: Text(
                      _destName ?? 'Destino exacto',
                      style: TextStyle(
                        color:
                            _destName == null ? Colors.grey[500] : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.search, color: Colors.grey),
                    onTap: () => _selectLocation(false),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Botón de Buscar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _searchTrips,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AFF5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Buscar viajes disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // Conectado al índice 0 (Buscar / Inicio)
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

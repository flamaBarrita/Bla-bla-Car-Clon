import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'buscar_ubicacion.dart';
import 'resultados_busqueda_viaje.dart';
import '/widgets/navegacion_button.dart';
import '../themes/app_theme.dart';

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
          backgroundColor: AnahuacColors.ERROR_RED,
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
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      appBar: AppBar(
        title: const Text(
          'Buscar viaje',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AnahuacColors.BACKGROUND_WHITE,
        elevation: 0,
        foregroundColor: AnahuacColors.TEXT_DARK,
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
                color: AnahuacColors.TEXT_DARK,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Contenedor que simula un formulario
            Container(
              decoration: BoxDecoration(
                color: AnahuacColors.NEUTRAL_LIGHT_BG,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Botón de Origen
                  ListTile(
                    leading: const Icon(
                      Icons.radio_button_checked,
                      color: AnahuacColors.TEXT_DARK,
                    ),
                    title: Text(
                      _originName ?? 'Dejar en blanco para usar tu GPS',
                      style: TextStyle(
                        color: _originName == null
                            ? AnahuacColors.TEXT_LIGHT
                            : AnahuacColors.TEXT_DARK,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.search,
                        color: AnahuacColors.TEXT_SECONDARY),
                    onTap: () => _selectLocation(true),
                  ),

                  Container(
                    margin: const EdgeInsets.only(left: 50),
                    height: 1,
                    color: AnahuacColors.NEUTRAL_BORDER,
                  ),

                  // Botón de Destino
                  ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: AnahuacColors.PRIMARY_ORANGE,
                    ),
                    title: Text(
                      _destName ?? 'Destino exacto',
                      style: TextStyle(
                        color: _destName == null
                            ? AnahuacColors.TEXT_LIGHT
                            : AnahuacColors.TEXT_DARK,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.search,
                        color: AnahuacColors.TEXT_SECONDARY),
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
                  backgroundColor: AnahuacColors.PRIMARY_ORANGE,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Buscar viajes disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AnahuacColors.BACKGROUND_WHITE,
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

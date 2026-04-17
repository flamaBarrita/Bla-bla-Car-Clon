import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'trip_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../themes/app_theme.dart'; // Importamos tu paleta Anáhuac

class TripResultsScreen extends ConsumerStatefulWidget {
  final String originName;
  final LatLng originCoords;
  final String destName;
  final LatLng destCoords;

  const TripResultsScreen({
    Key? key,
    required this.originName,
    required this.originCoords,
    required this.destName,
    required this.destCoords,
  }) : super(key: key);

  @override
  ConsumerState<TripResultsScreen> createState() => _TripResultsScreenState();
}

class _TripResultsScreenState extends ConsumerState<TripResultsScreen> {
  bool _isLoading = true;
  List<dynamic> _viajesDisponibles = [];

  @override
  void initState() {
    super.initState();
    _realizarBusqueda();
  }

  Future<void> _realizarBusqueda() async {
    final apiService = ref.read(apiServiceProvider);
    final resultados = await apiService.buscarViajes(
      widget.originCoords.latitude,
      widget.originCoords.longitude,
      widget.destCoords.latitude,
      widget.destCoords.longitude,
    );

    if (mounted) {
      setState(() {
        _viajesDisponibles = resultados;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo blanco institucional
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      appBar: AppBar(
        title: const Text(
          'Viajes disponibles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AnahuacColors.BACKGROUND_WHITE,
        elevation: 0,
        foregroundColor: AnahuacColors.TEXT_DARK,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de la ruta refactorizado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              // Le ponemos un borde sutil abajo para separarlo de la lista que hace scroll
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Agregamos una línea de ruta visual con tu color primario
                Column(
                  children: [
                    Icon(Icons.radio_button_checked,
                        color: AnahuacColors.PRIMARY_ORANGE, size: 20),
                    Container(
                        height: 15,
                        width: 2,
                        color: AnahuacColors.PRIMARY_ORANGE.withOpacity(0.5)),
                    Icon(Icons.location_on,
                        color: AnahuacColors.PRIMARY_ORANGE, size: 20),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.originName,
                        style: TextStyle(
                          color: AnahuacColors.TEXT_DARK,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                          height: 16), // Separación para alinear con los íconos
                      Text(
                        widget.destName,
                        style: TextStyle(
                          color: AnahuacColors.TEXT_DARK,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _isLoading
                  ? 'Buscando conductores...'
                  : '${_viajesDisponibles.length} conductores encontrados',
              style: TextStyle(
                color: AnahuacColors.TEXT_SECONDARY, // Gris profesional
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Lista de resultados
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: AnahuacColors.PRIMARY_ORANGE),
                  )
                : _viajesDisponibles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay viajes en esta ruta.',
                              style: TextStyle(
                                color: AnahuacColors.TEXT_DARK,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¡Intenta ampliar el área o buscar más tarde!',
                              style: TextStyle(
                                  color: AnahuacColors.TEXT_SECONDARY),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _viajesDisponibles.length,
                        itemBuilder: (context, index) {
                          // Importante: Asegúrate de refactorizar también el archivo trip_card.dart
                          return TripCard(viaje: _viajesDisponibles[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

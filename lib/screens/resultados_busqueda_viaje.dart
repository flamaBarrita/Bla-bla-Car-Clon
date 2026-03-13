import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'trip_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

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
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        title: const Text(
          'Viajes disponibles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF191919),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de la ruta
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2C2C2C),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.originName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.arrow_downward,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.destName,
                        style: const TextStyle(
                          color: Colors.white,
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
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _isLoading
                  ? 'Buscando conductores...'
                  : '${_viajesDisponibles.length} conductores encontrados',
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          // Lista de resultados
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00AFF5)),
                  )
                : _viajesDisponibles.isEmpty
                ? const Center(
                    child: Text(
                      'No hay viajes en esta ruta. ¡Intenta ampliar el área!',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _viajesDisponibles.length,
                    itemBuilder: (context, index) {
                      // AQUÍ USAMOS NUESTRO NUEVO WIDGET LIMPIO
                      return TripCard(viaje: _viajesDisponibles[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

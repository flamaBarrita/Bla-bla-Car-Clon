import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '/widgets/navegacion_button.dart';
import '/screens/detalle_viaje.dart';
import '/widgets/formatear_fecha.dart';
import '../themes/app_theme.dart';

class MisViajesScreen extends ConsumerStatefulWidget {
  const MisViajesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MisViajesScreen> createState() => _MisViajesScreenState();
}

class _MisViajesScreenState extends ConsumerState<MisViajesScreen> {
  bool _isLoading = true;
  List<dynamic> _misViajes = [];

  @override
  void initState() {
    super.initState();
    _cargarMisViajes();
  }

  Future<void> _cargarMisViajes() async {
    setState(() => _isLoading = true);
    // Instanciamos a los providers
    final apiService = ref.read(apiServiceProvider);
    final miId = ref.read(currentUserIdProvider);

    if (miId != null) {
      // Llamamos a la nueva función del API por medio del provider
      final viajes = await apiService.obtenerMisViajesAprobados(miId);
      if (mounted) {
        setState(() {
          _misViajes = viajes ?? [];
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      appBar: AppBar(
        title: const Text(
          'Mis Viajes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AnahuacColors.BACKGROUND_WHITE,
        elevation: 0,
        foregroundColor: AnahuacColors.TEXT_DARK,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AnahuacColors.PRIMARY_ORANGE),
            )
          : _misViajes.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  // Permite al usuario deslizar hacia abajo para recargar
                  color: AnahuacColors.PRIMARY_ORANGE,
                  backgroundColor: AnahuacColors.NEUTRAL_LIGHT_BG,
                  onRefresh: _cargarMisViajes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _misViajes.length,
                    itemBuilder: (context, index) {
                      final viaje = _misViajes[index];
                      return _buildViajeCard(viaje);
                    },
                  ),
                ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  // Widget en estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_filled_outlined,
            size: 80,
            color: AnahuacColors.TEXT_SECONDARY,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes viajes confirmados',
            style: TextStyle(
              color: AnahuacColors.TEXT_DARK,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Busca una ruta y solicita unirte a un viaje.',
            style: TextStyle(color: AnahuacColors.TEXT_LIGHT, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Widget viaje aprobado
  Widget _buildViajeCard(Map<String, dynamic> viaje) {
    // Si la fecha viene nula, ponemos un default.
    final fecha = viaje['departure_time']?.toString() ?? 'Fecha por definir';

    final fecha_formateda = formatearFechaEstetica(fecha);

    return Card(
      color: AnahuacColors.NEUTRAL_LIGHT_BG,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AnahuacColors.PRIMARY_ORANGE.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final huboCambios = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleViajeScreen(viaje: viaje),
            ),
          );

          // Si hubo algún cambio(eliminación), disparamos la recarga de la lista automáticamente
          if (huboCambios == true) {
            _cargarMisViajes(); // Función vuelve a ir al back y limpia la pantalla
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: Etiqueta Verde y Fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AnahuacColors.SUCCESS_GREEN.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: AnahuacColors.SUCCESS_GREEN, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Lugar Asegurado',
                          style: TextStyle(
                            color: AnahuacColors.SUCCESS_GREEN,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    fecha_formateda,
                    style: const TextStyle(
                        color: AnahuacColors.TEXT_SECONDARY, fontSize: 14),
                  ),
                ],
              ),
              const Divider(color: AnahuacColors.NEUTRAL_BORDER, height: 24),

              // Ruta (Origen y Destino)
              Row(
                children: [
                  const Icon(
                    Icons.radio_button_checked,
                    color: AnahuacColors.TEXT_DARK,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viaje['origin_name'] ?? 'Origen',
                      style: const TextStyle(
                        color: AnahuacColors.TEXT_DARK,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 7),
                height: 16,
                width: 2,
                color: AnahuacColors.TEXT_SECONDARY,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AnahuacColors.PRIMARY_ORANGE,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viaje['dest_name'] ?? 'Destino',
                      style: const TextStyle(
                        color: AnahuacColors.TEXT_DARK,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Conductor info rápida
              Row(
                children: [
                  const Icon(Icons.person,
                      color: AnahuacColors.TEXT_SECONDARY, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Conductor: ${viaje['driver_name'] ?? 'Asignado'}',
                    style: const TextStyle(
                        color: AnahuacColors.TEXT_LIGHT, fontSize: 14),
                  ),
                  const Spacer(),
                  const Text(
                    'Ver detalles',
                    style: TextStyle(
                      color: AnahuacColors.PRIMARY_ORANGE,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AnahuacColors.PRIMARY_ORANGE,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

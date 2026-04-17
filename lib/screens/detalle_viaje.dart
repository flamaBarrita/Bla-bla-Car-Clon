import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'perfil_pasagero.dart';
import '/widgets/formatear_fecha.dart';
import '/screens/chat.dart';
import '../themes/app_theme.dart';

class DetalleViajeScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> viaje;

  const DetalleViajeScreen({Key? key, required this.viaje}) : super(key: key);

  @override
  ConsumerState<DetalleViajeScreen> createState() => _DetalleViajeScreenState();
}

class _DetalleViajeScreenState extends ConsumerState<DetalleViajeScreen> {
  bool _isCanceling = false;

  Future<void> _cancelarMiLugar() async {
    // Confirmación de seguridad
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AnahuacColors.NEUTRAL_LIGHT_BG,
        title: const Text(
          '¿Cancelar tu lugar?',
          style: TextStyle(color: AnahuacColors.TEXT_DARK),
        ),
        content: const Text(
          'El conductor será notificado y perderás tu asiento reservado en este viaje.',
          style: TextStyle(color: AnahuacColors.TEXT_SECONDARY),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'No, mantener',
              style: TextStyle(color: AnahuacColors.TEXT_SECONDARY),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: AnahuacColors.ERROR_RED),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Ejecutar la cancelación
    setState(() => _isCanceling = true);
    final apiService = ref.read(apiServiceProvider);
    final miId = ref.read(currentUserIdProvider);

    if (miId != null) {
      final exito = await apiService.cancelarAsientoPasajero(
        widget.viaje['id'].toString(),
        miId,
      );

      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Lugar cancelado. El conductor ha sido notificado.',
              ),
              backgroundColor: AnahuacColors.SUCCESS_GREEN,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cancelar el lugar'),
              backgroundColor: AnahuacColors.ERROR_RED,
            ),
          );
        }
      }
    }
    if (mounted) setState(() => _isCanceling = false);
  }

  @override
  Widget build(BuildContext context) {
    final driverPhoto =
        widget.viaje['driver_photo'] ?? 'https://i.pravatar.cc/150?img=3';
    final fecha =
        widget.viaje['departure_time']?.toString() ?? 'Fecha por definir';
    //con la función importada le damos formato a la fecha
    final fecha_formateada = formatearFechaEstetica(fecha);

    return Scaffold(
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      appBar: AppBar(
        title: const Text('Detalles del viaje'),
        backgroundColor: AnahuacColors.BACKGROUND_WHITE,
        elevation: 0,
        foregroundColor: AnahuacColors.TEXT_DARK,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostramos el estatus del viaje y precio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AnahuacColors.SUCCESS_GREEN.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Lugar Asegurado',
                    style: TextStyle(
                      color: AnahuacColors.SUCCESS_GREEN,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${widget.viaje['price'] ?? '0.00'}',
                  style: const TextStyle(
                    color: AnahuacColors.TEXT_DARK,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Mostramos la informacíón de la ruta y el precio
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AnahuacColors.NEUTRAL_LIGHT_BG,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AnahuacColors.PRIMARY_ORANGE,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fecha_formateada,
                        style: const TextStyle(
                          color: AnahuacColors.TEXT_DARK,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                      color: AnahuacColors.NEUTRAL_BORDER, height: 30),
                  Row(
                    children: [
                      const Icon(
                        Icons.radio_button_checked,
                        color: AnahuacColors.TEXT_DARK,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.viaje['origin_name'] ?? 'Origen',
                          style: const TextStyle(
                            color: AnahuacColors.TEXT_DARK,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 9),
                    height: 24,
                    width: 2,
                    color: AnahuacColors.TEXT_SECONDARY,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AnahuacColors.PRIMARY_ORANGE,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.viaje['dest_name'] ?? 'Destino',
                          style: const TextStyle(
                            color: AnahuacColors.TEXT_DARK,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mostramos la información del conductor
            const Text(
              'Tu conductor',
              style: TextStyle(
                color: AnahuacColors.TEXT_DARK,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilPasagero(
                      passengerId: widget.viaje['driver_id'].toString(),
                      initialName: widget.viaje['driver_name'],
                      initialPhoto: driverPhoto,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AnahuacColors.NEUTRAL_LIGHT_BG,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(driverPhoto),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.viaje['driver_name'] ?? 'Conductor',
                            style: const TextStyle(
                              color: AnahuacColors.TEXT_DARK,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: AnahuacColors.TEXT_SECONDARY,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.viaje['driver_vehicles'] ??
                                      'Auto estándar',
                                  style: const TextStyle(
                                    color: AnahuacColors.TEXT_LIGHT,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AnahuacColors.TEXT_SECONDARY),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botones de acción
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        viajeId: widget.viaje['id'].toString(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text(
                  'Contactar al conductor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnahuacColors.PRIMARY_ORANGE,
                  foregroundColor: AnahuacColors.BACKGROUND_WHITE,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón de cancelar
            Center(
              child: _isCanceling
                  ? const CircularProgressIndicator(
                      color: AnahuacColors.ERROR_RED)
                  : TextButton(
                      onPressed: _cancelarMiLugar,
                      child: const Text(
                        'Cancelar mi lugar',
                        style: TextStyle(
                          color: AnahuacColors.ERROR_RED,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

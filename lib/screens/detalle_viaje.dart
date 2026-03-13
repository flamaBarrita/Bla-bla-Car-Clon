import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'perfil_pasagero.dart';

class DetalleViajeScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> viaje;

  const DetalleViajeScreen({Key? key, required this.viaje}) : super(key: key);

  @override
  ConsumerState<DetalleViajeScreen> createState() => _DetalleViajeScreenState();
}

class _DetalleViajeScreenState extends ConsumerState<DetalleViajeScreen> {
  bool _isCanceling = false;

  Future<void> _cancelarMiLugar() async {
    // 1. Confirmación de seguridad
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          '¿Cancelar tu lugar?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'El conductor será notificado y perderás tu asiento reservado en este viaje.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'No, mantener',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // 2. Ejecutar la cancelación
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
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cancelar el lugar'),
              backgroundColor: Colors.redAccent,
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

    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        title: const Text('Detalles del viaje'),
        backgroundColor: const Color(0xFF191919),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ESTATUS Y PRECIO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Lugar Asegurado',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${widget.viaje['price'] ?? '0.00'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 2. RUTA Y FECHA ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF00AFF5),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fecha,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, height: 30),
                  Row(
                    children: [
                      const Icon(
                        Icons.radio_button_checked,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.viaje['origin_name'] ?? 'Origen',
                          style: const TextStyle(
                            color: Colors.white,
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
                    color: Colors.grey[700],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF00AFF5),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.viaje['dest_name'] ?? 'Destino',
                          style: const TextStyle(
                            color: Colors.white,
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

            // --- 3. DATOS DEL CONDUCTOR Y AUTO ---
            const Text(
              'Tu conductor',
              style: TextStyle(
                color: Colors.white,
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
                  color: const Color(0xFF2C2C2C),
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
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.viaje['car'] ?? 'Auto estándar',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Placas: ${widget.viaje['plates'] ?? 'Por confirmar'}',
                            style: const TextStyle(
                              color: Color(0xFF00AFF5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- 4. BOTONES DE ACCIÓN ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aquí conectaremos la funcionalidad del CHAT en el futuro
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abriendo chat con el conductor...'),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text(
                  'Contactar al conductor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AFF5),
                  foregroundColor: Colors.white,
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
                  ? const CircularProgressIndicator(color: Colors.red)
                  : TextButton(
                      onPressed: _cancelarMiLugar,
                      child: const Text(
                        'Cancelar mi lugar',
                        style: TextStyle(
                          color: Colors.redAccent,
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

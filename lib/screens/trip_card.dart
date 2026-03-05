import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart'; // <-- 1. IMPORTANTE: Agregamos el AuthService
import 'perfil_pasagero.dart';

class TripCard extends StatelessWidget {
  final Map<String, dynamic> viaje;
  final ApiService apiService;

  const TripCard({Key? key, required this.viaje, required this.apiService})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Limpiamos la fecha si es necesario
    final String fechaStr = viaje['departure_time']?.toString() ?? 'Pronto';
    final String driverPhoto =
        viaje['driver_photo'] ?? 'https://i.pravatar.cc/150?img=3';

    return Card(
      color: const Color(0xFF2C2C2C),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Encabezado: Fecha y Precio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fechaStr,
                  style: const TextStyle(
                    color: Color(0xFF00AFF5),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${viaje['price']}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 24),

            // 2. Zona del Conductor (Tocar para ver perfil)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilPasagero(
                      passengerId: viaje['driver_id'].toString(),
                      initialName: viaje['driver_name'],
                      initialPhoto: driverPhoto,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(driverPhoto),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viaje['driver_name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${viaje['rating'] ?? '5.0'}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.directions_car,
                                color: Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  viaje['car'] ?? 'Auto estándar',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Botón de Solicitar Unirse
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AFF5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _enviarSolicitud(context),
                child: Text(
                  'Solicitar ${viaje['seats_available']} asientos disp.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LÓGICA DE SOLICITUD CON DATOS REALES ---
  Future<void> _enviarSolicitud(BuildContext context) async {
    final authService = AuthService();

    // Mostramos que estamos preparando todo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Obteniendo tu información...')),
    );

    // 1. Obtenemos el ID del usuario actual (el pasajero que está usando la app)
    final miId = await authService.getCurrentUserId();

    if (miId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No has iniciado sesión'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Descargamos el perfil real del pasajero desde tu API
    // ⚠️ NOTA: Asegúrate de que tu método en api_service.dart se llame getProfile.
    // Si se llama diferente (ej. getUserProfile), cámbialo aquí abajo.
    final miPerfil = await apiService.obtenerPerfil(miId);

    if (miPerfil == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al leer tu perfil de la base de datos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!context.mounted) return;

    // Avisamos que ahora sí va la solicitud al backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enviando solicitud al conductor...')),
    );

    // 3. ¡Mandamos la petición con la información real extraída de PostgreSQL!
    final resultado = await apiService.solicitarUnirse(
      tripId: viaje['id'],
      passengerId: miId,
      passengerName: miPerfil['name'] ?? 'Usuario',
      passengerPhoto:
          miPerfil['photo_url'] ?? 'https://i.pravatar.cc/150?img=11',
      passengerRating: miPerfil['rating'] ?? '5.0',
      seatsRequested: 1, // Por ahora pide 1 asiento por defecto
    );

    if (!context.mounted) return;

    // 4. Evaluamos la respuesta de FastAPI
    if (resultado['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Solicitud enviada! El conductor ha sido notificado.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'perfil_pasagero.dart';
import '/providers/app_providers.dart';
import 'home_page.dart';
// IMPORTA AQUÍ LA PANTALLA A LA QUE QUIERES IR DESPUÉS
// import 'pantalla_x.dart';

// 1. Lo convertimos a ConsumerStatefulWidget para manejar el estado del botón
class TripCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> viaje;

  const TripCard({Key? key, required this.viaje}) : super(key: key);

  @override
  ConsumerState<TripCard> createState() => _TripCardState();
}

class _TripCardState extends ConsumerState<TripCard> {
  // 2. Variable para controlar la animación del botón
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    // Como ahora es Stateful, accedemos al mapa usando "widget.viaje"
    final String fechaStr =
        widget.viaje['departure_time']?.toString() ?? 'Pronto';
    final String driverPhoto =
        widget.viaje['driver_photo'] ?? 'https://i.pravatar.cc/150?img=3';

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
                  '\$${widget.viaje['price']}',
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
                      passengerId: widget.viaje['driver_id'].toString(),
                      initialName: widget.viaje['driver_name'],
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
                            widget.viaje['driver_name'],
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
                                '${widget.viaje['rating'] ?? '5.0'}',
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
                                  widget.viaje['car'] ?? 'Auto estándar',
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

            // 3. Botón de Solicitar Unirse Animado
            SizedBox(
              width: double.infinity,
              height:
                  48, // Altura fija para que no brinque cuando salga el spinner
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AFF5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Si ya está cargando, bloqueamos el botón mandando "null" para evitar doble tap
                onPressed: _isRequesting
                    ? null
                    : () => _enviarSolicitud(context),

                // Mostramos el spinner o el texto dependiendo del estado
                child: _isRequesting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Solicitar ${widget.viaje['seats_available']} asientos disp.',
                        style: const TextStyle(
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

  // --- LÓGICA DE SOLICITUD OPTIMIZADA ---
  Future<void> _enviarSolicitud(BuildContext context) async {
    // 1. Encendemos la animación del botón
    setState(() => _isRequesting = true);

    final apiService = ref.read(apiServiceProvider);
    final String? miId = ref.read(currentUserIdProvider);

    final miPerfil = ref.read(userProfileProvider);

    if (miId == null || miPerfil == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Perfil no cargado'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isRequesting = false);
      }
      return;
    }

    // 2. Mandamos la petición a FastAPI
    final resultado = await apiService.solicitarUnirse(
      tripId: widget.viaje['id'],
      passengerId: miId,
      passengerName: miPerfil['name'] ?? 'Usuario',
      passengerPhoto:
          miPerfil['photo_url'] ?? 'https://i.pravatar.cc/150?img=11',
      passengerRating: miPerfil['rating'] ?? '5.0',
      seatsRequested: 1,
      senderId: miId,
    );

    if (!mounted) return;

    // 3. Evaluamos la respuesta de FastAPI
    if (resultado['success'] == true) {
      // Apagamos el spinner (opcional, ya que cambiaremos de pantalla)
      setState(() => _isRequesting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Solicitud enviada al conductor!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
        (route) => false, // Esto borra las pantallas anteriores
      );
    } else {
      // Si falló, apagamos el spinner para que el usuario pueda reintentar
      setState(() => _isRequesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message'] ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

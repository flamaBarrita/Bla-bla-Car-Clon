import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/app_providers.dart';
import '/widgets/formatear_fecha.dart';
import 'perfil_pasagero.dart';
import 'home_page.dart';
import '../themes/app_theme.dart';

/// Versión refactorizada de TripCard - Diseño Light Profesional Anáhuac
class TripCardRefactored extends ConsumerStatefulWidget {
  final Map<String, dynamic> viaje;

  const TripCardRefactored({Key? key, required this.viaje}) : super(key: key);

  @override
  ConsumerState<TripCardRefactored> createState() => _TripCardRefactoredState();
}

class _TripCardRefactoredState extends ConsumerState<TripCardRefactored> {
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    final String fechaStr =
        widget.viaje['departure_time']?.toString() ?? 'Pronto';
    final String driverPhoto =
        widget.viaje['driver_photo'] ?? 'https://i.pravatar.cc/150?img=3';

    return Card(
      color: AnahuacColors.BACKGROUND_WHITE,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AnahuacColors.NEUTRAL_BORDER,
          width: 0.5,
        ),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Encabezado de Fecha y Precio con tonos profesionales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Fecha con naranja Anáhuac
                Text(
                  formatearFechaEstetica(fechaStr),
                  style: const TextStyle(
                    color: AnahuacColors.PRIMARY_ORANGE,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
                // Precio con verde suavizado
                Text(
                  '\$${widget.viaje['price']}',
                  style: const TextStyle(
                    color: AnahuacColors.SUCCESS_GREEN,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const Divider(
              color: AnahuacColors.NEUTRAL_BORDER,
              height: 24,
              thickness: 0.5,
            ),

            // Sección de información del conductor (clickeable para perfil)
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
                    // Avatar del conductor
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AnahuacColors.NEUTRAL_LIGHT_BG,
                      backgroundImage: NetworkImage(driverPhoto),
                    ),
                    const SizedBox(width: 12),

                    // Información del conductor
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del conductor
                          Text(
                            widget.viaje['driver_name'],
                            style: const TextStyle(
                              color: AnahuacColors.TEXT_DARK,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Rating y vehículo
                          Row(
                            children: [
                              // Icono de estrella (naranja)
                              const Icon(
                                Icons.star,
                                color: AnahuacColors.PRIMARY_ORANGE,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              // Rating
                              Text(
                                '${widget.viaje['rating'] ?? '5.0'}',
                                style: const TextStyle(
                                  color: AnahuacColors.TEXT_SECONDARY,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Icono de coche
                              const Icon(
                                Icons.directions_car,
                                color: AnahuacColors.TEXT_LIGHT,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              // Modelo de vehículo
                              Expanded(
                                child: Text(
                                  widget.viaje['car'] ?? 'Auto estándar',
                                  style: const TextStyle(
                                    color: AnahuacColors.TEXT_SECONDARY,
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

                    // Icono next
                    const Icon(
                      Icons.chevron_right,
                      color: AnahuacColors.TEXT_LIGHT,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón de solicitud - Naranja Anáhuac
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnahuacColors.PRIMARY_ORANGE,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AnahuacColors.PRIMARY_ORANGE.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor:
                      AnahuacColors.PRIMARY_ORANGE.withOpacity(0.2),
                ),
                onPressed:
                    _isRequesting ? null : () => _enviarSolicitud(context),
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
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviarSolicitud(BuildContext context) async {
    setState(() => _isRequesting = true);

    final apiService = ref.read(apiServiceProvider);
    final String? miId = ref.read(currentUserIdProvider);
    final miPerfil = ref.read(userProfileProvider);

    if (miId == null || miPerfil == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Perfil no cargado'),
            backgroundColor: AnahuacColors.ERROR_RED,
          ),
        );
        setState(() => _isRequesting = false);
      }
      return;
    }

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

    if (resultado['success'] == true) {
      setState(() => _isRequesting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Solicitud enviada al conductor!'),
          backgroundColor: AnahuacColors.SUCCESS_GREEN,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
        (route) => false,
      );
    } else {
      setState(() => _isRequesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message'] ?? 'Error desconocido'),
          backgroundColor: AnahuacColors.ERROR_RED,
        ),
      );
    }
  }
}

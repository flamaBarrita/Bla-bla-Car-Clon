import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'perfil_pasagero.dart';
import '/providers/app_providers.dart';
import 'home_page.dart';
import '/widgets/formatear_fecha.dart';
import '../themes/app_theme.dart';

class TripCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> viaje;

  const TripCard({Key? key, required this.viaje}) : super(key: key);

  @override
  ConsumerState<TripCard> createState() => _TripCardState();
}

class _TripCardState extends ConsumerState<TripCard> {
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    final String fechaStr =
        widget.viaje['departure_time']?.toString() ?? 'Pronto';
    final String driverPhoto =
        widget.viaje['driver_photo'] ?? 'https://i.pravatar.cc/150?img=3';

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 2, right: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // 1. EL TRUCO VISUAL: Un borde gris suave que enmarca la tarjeta
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            // 2. Sombra ligeramente más fuerte (de 0.05 a 0.08) para separarla más
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Encabezado de Fecha y Precio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatearFechaEstetica(fechaStr),
                    style: const TextStyle(
                      // 3. FECHA EN NEGRO con un grosor fuerte para que destaque
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '\$${widget.viaje['price']}',
                    style: TextStyle(
                      color: Colors.green.shade700, // Verde un poco más oscuro
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey.shade200, height: 24, thickness: 1),

              // Zona de información del conductor
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
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                AnahuacColors.PRIMARY_ORANGE.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: NetworkImage(driverPhoto),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.viaje['driver_name'],
                              style: TextStyle(
                                color: AnahuacColors.TEXT_DARK,
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
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.viaje['rating'] ?? '5.0'}',
                                  style: TextStyle(
                                    color: AnahuacColors.TEXT_SECONDARY,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.directions_car,
                                  color: AnahuacColors.PRIMARY_ORANGE
                                      .withOpacity(0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.viaje['car'] ?? 'Auto estándar',
                                    style: TextStyle(
                                      color: AnahuacColors.TEXT_SECONDARY,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón de solicitar unirse
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AnahuacColors.PRIMARY_ORANGE,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AnahuacColors.PRIMARY_ORANGE.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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
                          ),
                        ),
                ),
              ),
            ],
          ),
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
          SnackBar(
            content: const Text('Error: Perfil no cargado'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isRequesting = false);
      }
      return;
    }

    final resultado = await apiService.solicitarUnirse(
      tripId: widget.viaje['id'],
      passengerId: miId,
      passengerName: miPerfil['name'] ?? 'Mario',
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
        SnackBar(
          content: const Text(
            '¡Solicitud enviada al conductor!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

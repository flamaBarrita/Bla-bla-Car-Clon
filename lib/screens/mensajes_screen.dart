import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '/widgets/navegacion_button.dart';
import '/screens/perfil_pasagero.dart';
import '../providers/app_providers.dart';
import 'lista_pasajeros_page.dart';
import '../themes/app_theme.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  bool _isLoading = true;
  bool _isDeleting = false;
  // Variable que guarda el viaje activo
  Map<String, dynamic>? _activeTrip;
  //Variable que guarda los solicitudes
  List<dynamic> _solicitudes = [];

  // Importamos los providers
  ApiService get apiService => ref.read(apiServiceProvider);
  AuthService get authService => ref.read(authServiceProvider);

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    setState(() => _isLoading = true);
    // Obtenemos el id del provider y hacemos
    final String? driverId = ref.read(currentUserIdProvider);
    if (driverId != null) {
      // Obtenemos el viaje activo de la db (si es que lo tiene)
      _activeTrip = await apiService.getActiveTrip(driverId);

      if (_activeTrip != null) {
        // Si hay un viaje activo, obtenemos todas las peticiones relacionadas a dicho viaje
        _solicitudes = await apiService.getTripRequests(_activeTrip!['id']);
      }
    }
    // Actualizamos la UI
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Eliminar viaje
  Future<void> _confirmarYEliminarViaje(String viajeId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AnahuacColors.BACKGROUND_WHITE,
          title: const Text(
            '¿Eliminar viaje?',
            style: TextStyle(color: AnahuacColors.TEXT_DARK),
          ),
          content: const Text(
            'Esta acción cancelará el viaje. Se notificará a los pasajeros (si los hay) y ya no aparecerás en las búsquedas.',
            style: TextStyle(color: AnahuacColors.TEXT_SECONDARY),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'No, mantener',
                style: TextStyle(color: AnahuacColors.TEXT_SECONDARY),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sí, eliminar',
                style: TextStyle(color: AnahuacColors.ERROR_RED),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    if (mounted) setState(() => _isDeleting = true);
    // Si el usuario acepta la cancelación del viaje, se hace la llamada al API
    final exito = await apiService.eliminarViaje(viajeId);

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Viaje cancelado exitosamente',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AnahuacColors.SUCCESS_GREEN,
          ),
        );
        setState(() {
          _activeTrip = null;
          _solicitudes.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error al cancelar el viaje',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AnahuacColors.ERROR_RED,
          ),
        );
      }
      setState(() => _isDeleting = false);
    }
  }

  // Respuesta por parte del conductor
  Future<void> _responder(int index, String respuesta) async {
    final solicitud = _solicitudes[index];
    setState(() => solicitud['procesando'] = true);

    final exito = await apiService.respondToRequest(solicitud['id'], respuesta);

    if (exito && mounted) {
      setState(() {
        _solicitudes.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        // Mostramos el mensaje de acuerdo a la respuesta del conductor
        SnackBar(
          content: Text(
            respuesta == 'aceptado'
                ? '¡Pasajero aceptado!'
                : 'Solicitud rechazada',
          ),
          backgroundColor: respuesta == 'aceptado'
              ? AnahuacColors.SUCCESS_GREEN
              : AnahuacColors.ERROR_RED,
        ),
      );
    } else {
      setState(() => solicitud['procesando'] = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar la solicitud'),
          backgroundColor: AnahuacColors.ERROR_RED,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      appBar: AppBar(
        title: const Text(
          'Bandeja de entrada',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu viaje activo',
                    style: TextStyle(
                      color: AnahuacColors.TEXT_DARK,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Si no tiene viajes publicados, le mostramos esta UI
                  if (_activeTrip == null)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AnahuacColors.NEUTRAL_LIGHT_BG,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'No tienes viajes publicados activos.',
                          style: TextStyle(color: AnahuacColors.TEXT_DARK),
                        ),
                      ),
                    )
                  else
                    // Mostramos la información de su viaje
                    Card(
                      color: AnahuacColors.BACKGROUND_WHITE,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: AnahuacColors.PRIMARY_ORANGE,
                          width: 2,
                        ),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _activeTrip!['duration_text'] ??
                                      'Tiempo est.',
                                  style: const TextStyle(
                                    color: AnahuacColors.PRIMARY_ORANGE,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Mostramos que el viaje esta publicado y el botón de eliminar viaje
                                Row(
                                  children: [
                                    // Boton para mensajeria con los pasajeros
                                    IconButton(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      icon: const Icon(
                                        Icons.people_outline,
                                        color: AnahuacColors.PRIMARY_ORANGE,
                                        size: 20,
                                      ),
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        // Obtenemos la lista de pasajeros del JSON del viaje
                                        // (Ajusta 'passengers' por la llave real que uses en tu backend)
                                        final List<dynamic> listaPasajeros =
                                            _activeTrip!['passengers'] ?? [];
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ListaPasajerosPage(
                                              viajeId:
                                                  _activeTrip!['id'].toString(),
                                              pasajeros: listaPasajeros,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // ----------------------------------
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AnahuacColors.SUCCESS_GREEN
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Publicado',
                                        style: TextStyle(
                                          color: AnahuacColors.SUCCESS_GREEN,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // El botón del basurero
                                    _isDeleting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: AnahuacColors.ERROR_RED,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: AnahuacColors.ERROR_RED,
                                              size: 20,
                                            ),
                                            constraints:
                                                const BoxConstraints(), // Quita el padding por defecto del botón
                                            padding: EdgeInsets.zero,
                                            onPressed: () =>
                                                _confirmarYEliminarViaje(
                                              _activeTrip!['id'].toString(),
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(
                                color: AnahuacColors.NEUTRAL_BORDER,
                                height: 24),
                            // Mostramos la ruta de origen del viaje
                            Row(
                              children: [
                                const Icon(
                                  Icons.radio_button_checked,
                                  color: AnahuacColors.PRIMARY_ORANGE,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _activeTrip!['origin_name'],
                                    style: const TextStyle(
                                      color: AnahuacColors.TEXT_DARK,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(left: 7),
                                height: 20,
                                width: 2,
                                color: AnahuacColors.NEUTRAL_BORDER,
                              ),
                            ),
                            // Mostramos la ruta de destino del viaje
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
                                    _activeTrip!['dest_name'],
                                    style: const TextStyle(
                                      color: AnahuacColors.TEXT_DARK,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  const Text(
                    'Peticiones de ingreso',
                    style: TextStyle(
                      color: AnahuacColors.TEXT_DARK,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mostramos las peticiones de ingreso para el viaje
                  if (_solicitudes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No tienes solicitudes pendientes.',
                          style: TextStyle(color: AnahuacColors.TEXT_SECONDARY),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _solicitudes.length,
                      itemBuilder: (context, index) {
                        final solicitud = _solicitudes[index];
                        final bool procesando =
                            solicitud['procesando'] ?? false;
                        // Extracción segura de la info del pasagero si nos devuelve null
                        final String pName =
                            solicitud['passenger_name']?.toString() ??
                                'Usuario desconocido';

                        final String pPhoto =
                            solicitud['passenger_photo']?.toString() ??
                                'https://i.pravatar.cc/150?img=3';

                        final String pRating =
                            solicitud['passenger_rating']?.toString() ?? '5.0';

                        final String pSeats =
                            solicitud['seats_requested']?.toString() ?? '1';
                        final String pId =
                            solicitud['passenger_id']?.toString() ?? '';

                        return Card(
                          color: AnahuacColors.BACKGROUND_WHITE,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (pId.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PerfilPasagero(
                                              passengerId: pId,
                                              initialName: pName,
                                              initialPhoto: pPhoto,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Hero(
                                          tag: 'avatar_$pId',
                                          child: CircleAvatar(
                                            radius: 24,
                                            backgroundImage: NetworkImage(
                                              pPhoto,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pName,
                                                style: const TextStyle(
                                                  color:
                                                      AnahuacColors.TEXT_DARK,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: AnahuacColors
                                                        .WARNING_AMBER,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    pRating,
                                                    style: const TextStyle(
                                                      color: AnahuacColors
                                                          .TEXT_SECONDARY,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.person,
                                                    color: AnahuacColors
                                                        .TEXT_SECONDARY,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$pSeats asient.',
                                                    style: const TextStyle(
                                                      color: AnahuacColors
                                                          .TEXT_SECONDARY,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (procesando)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AnahuacColors.PRIMARY_ORANGE,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                else ...[
                                  // Monstramos el status de la petición
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: AnahuacColors.ERROR_RED,
                                    ),
                                    onPressed: () =>
                                        _responder(index, 'rechazado'),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AnahuacColors.PRIMARY_ORANGE,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      onPressed: () =>
                                          _responder(index, 'aceptado'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}

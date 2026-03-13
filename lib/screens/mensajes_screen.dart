import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '/widgets/navegacion_button.dart';
import '/screens/perfil_pasagero.dart';
import '../providers/app_providers.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  bool _isLoading = true;
  bool _isDeleting = false; // <-- Nuevo estado para el spinner de borrar
  Map<String, dynamic>? _activeTrip;
  List<dynamic> _solicitudes = [];

  ApiService get apiService => ref.read(apiServiceProvider);
  AuthService get authService => ref.read(authServiceProvider);

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    setState(() => _isLoading = true);

    final String? driverId = ref.read(currentUserIdProvider);
    if (driverId != null) {
      _activeTrip = await apiService.getActiveTrip(driverId);

      if (_activeTrip != null) {
        _solicitudes = await apiService.getTripRequests(_activeTrip!['id']);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // --- NUEVA LÓGICA: ELIMINAR VIAJE ---
  Future<void> _confirmarYEliminarViaje(String viajeId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text(
            '¿Eliminar viaje?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Esta acción cancelará el viaje. Se notificará a los pasajeros (si los hay) y ya no aparecerás en las búsquedas.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'No, mantener',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sí, eliminar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    if (mounted) setState(() => _isDeleting = true);

    final exito = await apiService.eliminarViaje(viajeId);

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Viaje cancelado exitosamente',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      setState(() => _isDeleting = false);
    }
  }

  Future<void> _responder(int index, String respuesta) async {
    final solicitud = _solicitudes[index];
    setState(() => solicitud['procesando'] = true);

    final exito = await apiService.respondToRequest(solicitud['id'], respuesta);

    if (exito && mounted) {
      setState(() {
        _solicitudes.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            respuesta == 'aceptado'
                ? '¡Pasajero aceptado!'
                : 'Solicitud rechazada',
          ),
          backgroundColor: respuesta == 'aceptado' ? Colors.green : Colors.red,
        ),
      );
    } else {
      setState(() => solicitud['procesando'] = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar la solicitud'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        title: const Text(
          'Bandeja de entrada',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF191919),
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00AFF5)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu viaje activo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_activeTrip == null)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'No tienes viajes publicados activos.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00AFF5).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _activeTrip!['duration_text'] ?? 'Tiempo est.',
                                style: const TextStyle(
                                  color: Color(0xFF00AFF5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // --- NUEVA SECCIÓN DE ETIQUETA Y BOTÓN DE BORRAR ---
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Publicado',
                                      style: TextStyle(
                                        color: Colors.green,
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
                                            color: Colors.red,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
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
                          const Divider(color: Colors.grey, height: 24),
                          Row(
                            children: [
                              const Icon(
                                Icons.radio_button_checked,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _activeTrip!['origin_name'],
                                  style: const TextStyle(
                                    color: Colors.white,
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
                              color: Colors.grey[700],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF00AFF5),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _activeTrip!['dest_name'],
                                  style: const TextStyle(
                                    color: Colors.white,
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

                  const SizedBox(height: 32),
                  const Text(
                    'Peticiones de ingreso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_solicitudes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),

                        child: Text(
                          'No tienes solicitudes pendientes.',

                          style: TextStyle(color: Colors.grey[500]),
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

                        // --- EXTRACCIÓN SEGURA DE DATOS ---

                        // Si el backend no manda la variable o viene nula, ponemos un default para que Flutter no explote

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
                          color: const Color(0xFF2C2C2C),
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
                                                  color: Colors.white,

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

                                                    color: Colors.amber,

                                                    size: 14,
                                                  ),

                                                  const SizedBox(width: 4),

                                                  Text(
                                                    pRating,

                                                    style: TextStyle(
                                                      color: Colors.grey[400],

                                                      fontSize: 12,
                                                    ),
                                                  ),

                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.person,
                                                    color: Colors.grey,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$pSeats asient.',
                                                    style: TextStyle(
                                                      color: Colors.grey[400],
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
                                        color: Color(0xFF00AFF5),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                else ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _responder(index, 'rechazado'),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF00AFF5),
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

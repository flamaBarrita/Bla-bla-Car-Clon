import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/app_providers.dart';

class SetPriceScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> tripData;

  const SetPriceScreen({Key? key, required this.tripData}) : super(key: key);

  @override
  ConsumerState<SetPriceScreen> createState() => _SetPriceScreenState();
}

class _SetPriceScreenState extends ConsumerState<SetPriceScreen> {
  final TextEditingController _priceController = TextEditingController();
  bool _isPublishing = false;

  // Contador de asientos, por defecto 3
  int _asientos = 3;

  Future<void> _publicarViaje() async {
    if (_priceController.text.isEmpty) return;

    setState(() => _isPublishing = true);

    try {
      // Obtenemos los providers
      final driverId = ref.read(currentUserIdProvider);
      final apiService = ref.read(apiServiceProvider);

      if (driverId == null) {
        throw Exception("No se encontró la sesión del usuario.");
      }

      // Formateamos la fecha
      final String fecha = widget.tripData['date'];

      final List<String> timeParts = widget.tripData['time'].split(':');
      // Verificamos la sintaxis de la fecha
      final String hora =
          "${timeParts[0].padLeft(2, '0')}:${timeParts[1].padLeft(2, '0')}";

      final String departureTime =
          DateTime.parse("${fecha}T$hora:00").toIso8601String();

      // Ya con toda la información recabada, mandamos la petición final al back
      final exito = await apiService.publicarViaje(
        driverId: driverId,
        originName: widget.tripData['originName'],
        originLat: widget.tripData['originLat'],
        originLng: widget.tripData['originLng'],
        destName: widget.tripData['destName'],
        destLat: widget.tripData['destLat'],
        destLng: widget.tripData['destLng'],
        distanceText: widget.tripData['distanceText'],
        durationText: widget.tripData['durationText'],
        departureTime: departureTime,
        price: double.parse(_priceController.text),
        seatsAvailable: _asientos,
        encodedPolyline: widget.tripData['encodedPolyline'],
      );

      if (exito && mounted) {
        // Si es exitoso, matamos todas las pantallas y nos regresamos a la pantalla inicial
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Viaje publicado con éxito! 🚗💨'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception("La base de datos rechazó el viaje.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // El contenido scrolleable envuelto en Expanded + SingleChildScrollView
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detalles finales",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Fija tu aportación por asiento y cuántos pasajeros puedes llevar.",
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    // Guardamos el costo del viaje del conductor
                    const Text("Aportación por persona",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("\$",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  color: Color(0xFF00AFF5),
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "0",
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              onChanged: (val) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Guardamos la cantidad de asientos disponibles
                    const Text("Asientos disponibles",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón Menos
                          IconButton(
                            onPressed: _asientos > 1
                                ? () => setState(() => _asientos--)
                                : null,
                            icon: Icon(Icons.remove_circle_outline,
                                color: _asientos > 1
                                    ? const Color(0xFF00AFF5)
                                    : Colors.grey,
                                size: 32),
                          ),

                          // Número central
                          Text(
                            "$_asientos",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold),
                          ),

                          // Botón Más
                          IconButton(
                            onPressed: _asientos < 6
                                ? () => setState(() => _asientos++)
                                : null,
                            icon: Icon(Icons.add_circle_outline,
                                color: _asientos < 6
                                    ? const Color(0xFF00AFF5)
                                    : Colors.grey,
                                size: 32),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // El botón final se queda fuera del Scroll, anclado al fondo
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 24.0, bottom: 24.0, top: 8.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_priceController.text.isNotEmpty && !_isPublishing)
                          ? _publicarViaje
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AFF5),
                    disabledBackgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: _isPublishing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Publicar viaje",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

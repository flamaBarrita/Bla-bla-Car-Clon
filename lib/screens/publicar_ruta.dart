import 'package:flutter/material.dart';
import '../widgets/navegacion_button.dart';
import 'buscar_ubicacion.dart';
import 'seleccionar_ruta.dart';
import '../themes/app_theme.dart';

class PublishRouteScreen extends StatefulWidget {
  const PublishRouteScreen({Key? key}) : super(key: key);

  @override
  _PublishRouteScreenState createState() => _PublishRouteScreenState();
}

class _PublishRouteScreenState extends State<PublishRouteScreen> {
  // --- EL DIRECTOR DE ORQUESTA: Controla el flujo de las 3 pantallas ---
  Future<void> _iniciarFlujoViaje() async {
    // PASO 1: Abrimos la pantalla de Origen por encima de esta
    final originData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SearchLocationScreen(title: '¿Desde dónde sales?'),
      ),
    );

    // Si el usuario canceló o le dio a la flecha de atrás, detenemos el flujo
    if (originData == null || !mounted) return;

    // PASO 2: Abrimos la pantalla de Destino
    final destData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SearchLocationScreen(title: '¿A dónde viajas?'),
      ),
    );

    if (destData == null || !mounted) return;

    // PASO 3: Abrimos el mapa final pasándole ambas coordenadas
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteSelectionScreen(
          origin: originData['coords'],
          originName: originData['name'],
          destination: destData['coords'],
          destName: destData['name'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      appBar: AppBar(
        title: const Text(
          'Publicar un viaje',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AnahuacColors.BACKGROUND_WHITE,
        elevation: 0,
        foregroundColor: AnahuacColors.TEXT_DARK,
        automaticallyImplyLeading:
            false, // Ocultamos la flecha de atrás porque es pantalla principal
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono gigante para adornar la pantalla base
              const Icon(
                Icons.directions_car_filled_outlined,
                size: 120,
                color: AnahuacColors.PRIMARY_ORANGE,
              ),
              const SizedBox(height: 30),

              const Text(
                "¿Listo para tu próximo viaje?",
                style: TextStyle(
                  color: AnahuacColors.TEXT_DARK,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              Text(
                "Comparte tus gastos de viaje llevando pasajeros contigo.",
                style: TextStyle(
                    color: AnahuacColors.TEXT_SECONDARY, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // BOTÓN QUE DISPARA EL FLUJO
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _iniciarFlujoViaje,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  label: const Text(
                    'Planear nueva ruta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AnahuacColors.PRIMARY_ORANGE,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Mantenemos seleccionada la pestaña de Publicar (Índice 1)
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}

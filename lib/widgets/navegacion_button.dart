import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '/screens/publicar_ruta.dart';
import '/screens/mensajes_screen.dart';
import '/screens/buscar_viaje.dart';
import '/screens/viajes_aprobados.dart';
import '../themes/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({Key? key, required this.currentIndex})
      : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex)
      return; // Si tocamos la pestaña actual, no hacemos nada

    Widget nextScreen;

    // Asignamos la pantalla correspondiente a cada índice
    switch (index) {
      case 0:
        nextScreen = SearchTripScreen(); // Pantalla de buscar viaje
        break;
      case 1:
        nextScreen = const PublishRouteScreen(); // Pantalla de publicar viaje
        break;
      case 2:
        nextScreen = MisViajesScreen(); // Pantalla de mis viajes actuales
        break;
      case 3:
        nextScreen = const MessagesScreen(); // Pantalla de mensajes
        break;
      case 4:
        nextScreen = ProfilePage(); // Pantalla de perfil
        break;
      default:
        nextScreen = ProfilePage();
    }

    // Navegación instantánea sin animaciones
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AnahuacColors.PRIMARY_ORANGE,
      unselectedItemColor: AnahuacColors.TEXT_SECONDARY,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Publicar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.directions_car_outlined),
          label: 'Tus viajes',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.chat_bubble_outline),
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: AnahuacColors.ERROR_RED,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(
                        color: AnahuacColors.BACKGROUND_WHITE, fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          label: 'Mensajes',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    );
  }
}

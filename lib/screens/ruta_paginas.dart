import 'package:flutter/material.dart';

// Importa aquí todas tus pantallas
import '../screens/home_page.dart';
import '../screens/publicar_ruta.dart';

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
        nextScreen = ProfilePage(); // Suponiendo que tu Home es "Buscar"
        break;
      case 1:
        nextScreen = const PublishRouteScreen(); // Tu nueva pantalla de mapas
        break;
      case 2:
        nextScreen =
            ProfilePage(); // Cambiar luego por tu pantalla de "Tus Viajes"
        break;
      case 3:
        nextScreen =
            ProfilePage(); // Cambiar luego por tu pantalla de "Mensajes"
        break;
      case 4:
        nextScreen = ProfilePage(); // Tu pantalla de perfil
        break;
      default:
        nextScreen = ProfilePage();
    }

    // Navegación instantánea sin animaciones raras
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
      backgroundColor: const Color(0xFF191919),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00AFF5),
      unselectedItemColor: Colors.grey,
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
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(color: Colors.white, fontSize: 8),
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

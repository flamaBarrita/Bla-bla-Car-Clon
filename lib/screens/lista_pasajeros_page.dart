import 'package:flutter/material.dart';
import 'chat.dart'; // Asegúrate de importar tu ChatPage
import '../themes/app_theme.dart'; // Importamos tu archivo de colores institucionales

class ListaPasajerosPage extends StatelessWidget {
  final String viajeId;
  final List<dynamic> pasajeros;

  const ListaPasajerosPage({
    Key? key,
    required this.viajeId,
    required this.pasajeros,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Cambiamos el fondo oscuro por el blanco de fondo Anáhuac
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      appBar: AppBar(
        title: const Text(
          'Pasajeros del viaje',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // 2. AppBar limpia y blanca, con texto oscuro para máximo contraste
        backgroundColor: AnahuacColors.BACKGROUND_WHITE,
        elevation: 0,
        foregroundColor: AnahuacColors.TEXT_DARK,
      ),
      body: pasajeros.isEmpty
          ? Center(
              child: Text(
                'Aún no hay pasajeros unidos a este viaje.',
                style: TextStyle(
                  color: AnahuacColors
                      .TEXT_SECONDARY, // Texto gris para estados vacíos
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pasajeros.length,
              itemBuilder: (context, index) {
                final pasajero = pasajeros[index];

                final pasajeroId = pasajero['id'].toString();
                final pasajeroNombre = pasajero['name'] ?? 'Usuario';
                final chatUnicoId = '${viajeId}_$pasajeroId';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, // Fondo puro para la tarjeta
                    borderRadius: BorderRadius.circular(12),
                    // 3. Sombra sutil para darle profundidad y que no se pierda en el fondo blanco
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      // 4. Avatar con el Naranja principal
                      backgroundColor: AnahuacColors.PRIMARY_ORANGE,
                      child: Text(
                        pasajeroNombre[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      pasajeroNombre,
                      style: TextStyle(
                        color: AnahuacColors
                            .TEXT_DARK, // Nombre en gris oscuro/negro suave
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Pasajero confirmado',
                      style: TextStyle(
                        color: AnahuacColors
                            .TEXT_SECONDARY, // Subtítulo más discreto
                        fontSize: 13,
                      ),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        // 5. Fondo suave del botón con el naranja Anáhuac
                        color: AnahuacColors.PRIMARY_ORANGE.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.chat_bubble_rounded,
                          color: AnahuacColors
                              .PRIMARY_ORANGE, // Ícono naranja vibrante
                        ),
                        tooltip: 'Enviar mensaje',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                viajeId: chatUnicoId,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

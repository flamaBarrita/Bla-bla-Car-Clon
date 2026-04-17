import 'package:flutter/material.dart';
import 'chat.dart'; // Asegúrate de importar tu ChatPage

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
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        title: const Text('Pasajeros del viaje'),
        backgroundColor: const Color(0xFF191919),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: pasajeros.isEmpty
          ? const Center(
              child: Text(
                'Aún no hay pasajeros unidos a este viaje.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pasajeros.length,
              itemBuilder: (context, index) {
                final pasajero = pasajeros[index];

                // Extraemos los datos (Asegúrate de que coincidan con las llaves de tu backend FastAPI)
                final pasajeroId = pasajero['id'].toString();
                final pasajeroNombre = pasajero['name'] ?? 'Usuario';

                // CREAMOS UN ID DE CHAT ÚNICO: viajeId + pasajeroId
                // Así Firestore separa los mensajes de cada persona
                final chatUnicoId = '${viajeId}_$pasajeroId';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00AFF5),
                      child: Text(
                        pasajeroNombre[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      pasajeroNombre,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Pasajero confirmado',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00AFF5).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_rounded,
                            color: Color(0xFF00AFF5)),
                        tooltip: 'Enviar mensaje',
                        onPressed: () {
                          // Navegamos al chat, pasándole el ID ÚNICO de esta conversación
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                viajeId: chatUnicoId,
                                // Opcional: Podrías modificar tu ChatPage para que reciba el nombre y lo ponga en el AppBar
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

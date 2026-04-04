import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/providers/app_providers.dart';
import '/models/chat.dart';
import '/providers/chat_provider.dart';

class ChatPage extends ConsumerWidget {
  final String viajeId;
  final TextEditingController _mensajeController = TextEditingController();

  ChatPage({Key? key, required this.viajeId}) : super(key: key);

  void _enviarMensaje(WidgetRef ref) async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    // Obtenemos quién es el usuario actual usando tu provider existente
    final miId = ref.read(currentUserIdProvider);
    final miPerfil = ref.read(userProfileProvider);

    final nuevoMensaje = Mensaje(
      senderId: miId!,
      senderName: miPerfil?['name'] ?? 'Usuario',
      texto: texto,
      timestamp: DateTime.now(),
    );

    _mensajeController.clear();

    // Escribimos directo en Firestore
    await FirebaseFirestore.instance
        .collection('viajes_chats')
        .doc(viajeId)
        .collection('mensajes')
        .add(nuevoMensaje.toJson());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos los mensajes en tiempo real
    final chatAsyncValue = ref.watch(chatStreamProvider(viajeId));
    final miId = ref.read(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Chat del Viaje')),
      body: Column(
        children: [
          Expanded(
            child: chatAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (mensajes) {
                final mensajesList = mensajes as List<Mensaje>;
                if (mensajesList.isEmpty) {
                  return const Center(
                      child: Text('No hay mensajes aún. ¡Di hola!'));
                }
                return ListView.builder(
                  reverse: true, // Empieza desde abajo
                  itemCount: mensajesList.length,
                  itemBuilder: (context, index) {
                    final msg = mensajesList[index];
                    final soyYo = msg.senderId == miId;

                    return Align(
                      alignment:
                          soyYo ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        padding: const EdgeInsets.all(20),
                        color: soyYo
                            ? const Color.fromARGB(255, 1, 28, 50)
                            : Colors.grey[200],
                        child: Text("${msg.senderName}: ${msg.texto}"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Campo de texto y botón de enviar
          SafeArea(
            // Le decimos que solo nos proteja de la parte de abajo
            bottom: true,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensajeController,
                      decoration: InputDecoration(
                        hintText: "Escribe un mensaje...",
                        // Opcional: Un borde redondeado hace que se vea más pro
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // Un pequeño espacio
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 0, 37, 67), // El color de tu app
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _enviarMensaje(ref),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

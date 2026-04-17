import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/providers/app_providers.dart';
import '/models/chat.dart';
import '/providers/chat_provider.dart';
import '../themes/app_theme.dart';

/// Versión refactorizada de ChatPage - Diseño Light Profesional Anáhuac
class ChatPageRefactored extends ConsumerWidget {
  final String viajeId;
  final TextEditingController _mensajeController = TextEditingController();

  ChatPageRefactored({Key? key, required this.viajeId}) : super(key: key);

  void _enviarMensaje(WidgetRef ref) async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    final miId = ref.read(currentUserIdProvider);
    final miPerfil = ref.read(userProfileProvider);

    final nuevoMensaje = Mensaje(
      senderId: miId!,
      senderName: miPerfil?['name'] ?? 'Usuario',
      texto: texto,
      timestamp: DateTime.now(),
    );

    _mensajeController.clear();

    await FirebaseFirestore.instance
        .collection('viajes_chats')
        .doc(viajeId)
        .collection('mensajes')
        .add(nuevoMensaje.toJson());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatAsyncValue = ref.watch(chatStreamProvider(viajeId));
    final miId = ref.read(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      appBar: AppBar(
        backgroundColor: AnahuacColors.BACKGROUND_WHITE,
        elevation: 0,
        title: const Text('Chat del Viaje'),
        titleTextStyle: const TextStyle(
          color: AnahuacColors.TEXT_DARK,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AnahuacColors.PRIMARY_ORANGE,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(
            color: AnahuacColors.NEUTRAL_BORDER,
            height: 0.5,
            thickness: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Área de mensajes
          Expanded(
            child: chatAsyncValue.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AnahuacColors.PRIMARY_ORANGE,
                ),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: AnahuacColors.TEXT_DARK),
                ),
              ),
              data: (mensajes) {
                final mensajesList = mensajes as List<Mensaje>;
                if (mensajesList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_outline,
                          size: 64,
                          color: AnahuacColors.NEUTRAL_BORDER,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay mensajes aún. ¡Di hola!',
                          style: TextStyle(
                            color: AnahuacColors.TEXT_SECONDARY,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: mensajesList.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemBuilder: (context, index) {
                    final msg = mensajesList[index];
                    final soyYo = msg.senderId == miId;

                    return Align(
                      alignment: soyYo
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: soyYo
                              ? AnahuacColors.PRIMARY_ORANGE
                              : AnahuacColors.NEUTRAL_LIGHT_BG,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre del remitente en mensajes recibidos
                            if (!soyYo)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  msg.senderName,
                                  style: const TextStyle(
                                    color: AnahuacColors.TEXT_SECONDARY,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            // Texto del mensaje
                            Text(
                              msg.texto,
                              style: TextStyle(
                                color: soyYo
                                    ? Colors.white
                                    : AnahuacColors.TEXT_DARK,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            // Timestamp
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                _formatTimestamp(msg.timestamp),
                                style: TextStyle(
                                  color: soyYo
                                      ? Colors.white.withOpacity(0.7)
                                      : AnahuacColors.TEXT_LIGHT,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Campo de entrada de mensaje
          SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: AnahuacColors.BACKGROUND_WHITE,
                border: Border(
                  top: BorderSide(
                    color: AnahuacColors.NEUTRAL_BORDER,
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                children: [
                  // Campo de texto con estilo píldora
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AnahuacColors.NEUTRAL_LIGHT_BG,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AnahuacColors.NEUTRAL_BORDER,
                          width: 0.5,
                        ),
                      ),
                      child: TextField(
                        controller: _mensajeController,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          color: AnahuacColors.TEXT_DARK,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: const TextStyle(
                            color: AnahuacColors.TEXT_LIGHT,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Botón de envío con naranja Anáhuac
                  Container(
                    decoration: BoxDecoration(
                      color: AnahuacColors.PRIMARY_ORANGE,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AnahuacColors.PRIMARY_ORANGE.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _enviarMensaje(ref),
                      tooltip: 'Enviar mensaje',
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

  /// Formatea el timestamp para mostrar hora o fecha según corresponda
  String _formatTimestamp(DateTime timestamp) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(timestamp);

    if (diferencia.inMinutes < 1) {
      return 'Ahora';
    } else if (diferencia.inMinutes < 60) {
      return 'hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'hace ${diferencia.inHours} h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Mensaje {
  final String senderId;
  final String senderName;
  final String texto;
  final DateTime timestamp;

  Mensaje({
    required this.senderId,
    required this.senderName,
    required this.texto,
    required this.timestamp,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Usuario',
      texto: json['texto'] ?? '',
      // Convertimos el Timestamp de Firebase a DateTime de Dart
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'texto': texto,
      'timestamp': FieldValue.serverTimestamp(), // Firebase pone la hora exacta
    };
  }
}

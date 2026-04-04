import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';

// Usamos .family para poder pasarle el ID del viaje específico que queremos escuchar
final chatStreamProvider =
    StreamProvider.family<List<Mensaje>, String>((ref, viajeId) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('viajes_chats')
      .doc(viajeId)
      .collection('mensajes')
      .orderBy('timestamp', descending: true) // Los más nuevos arriba
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Mensaje.fromJson(doc.data())).toList();
  });
});

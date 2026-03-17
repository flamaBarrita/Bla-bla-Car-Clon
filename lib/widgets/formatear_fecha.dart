// Funcion para formatear la fecha de raw a estético

String formatearFechaEstetica(String fechaRaw) {
  try {
    // 1. Convertimos el texto feo a un objeto DateTime real
    final DateTime fecha = DateTime.parse(fechaRaw).toLocal();
    final DateTime ahora = DateTime.now();

    // 2. Comparamos los días para ver si es Hoy o Mañana
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime manana = hoy.add(const Duration(days: 1));
    final DateTime fechaViaje = DateTime(fecha.year, fecha.month, fecha.day);

    // 3. Formateamos la hora a mano (ej. 09:05 AM)
    String hora = fecha.hour.toString().padLeft(2, '0');
    String minuto = fecha.minute.toString().padLeft(2, '0');
    String amPm = fecha.hour >= 12 ? 'PM' : 'AM';
    if (fecha.hour > 12) hora = (fecha.hour - 12).toString().padLeft(2, '0');
    if (fecha.hour == 0) hora = '12';
    String horaFormateada = "$hora:$minuto $amPm";

    // 4. Devolvemos el texto final estético
    if (fechaViaje == hoy) {
      return "Hoy • $horaFormateada";
    } else if (fechaViaje == manana) {
      return "Mañana • $horaFormateada";
    } else {
      // Arreglo de meses en español para que no requieras paquetes extra
      const meses = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic'
      ];
      String mesStr = meses[fecha.month - 1];
      return "${fecha.day} $mesStr • $horaFormateada";
    }
  } catch (e) {
    return fechaRaw; // Si algo falla (ej. string vacío), regresa el original para no crashear
  }
}

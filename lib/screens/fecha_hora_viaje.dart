import 'package:flutter/material.dart';
import 'precio_viaje.dart';

class SelectDateTimeScreen extends StatefulWidget {
  final Map<String, dynamic>
      tripData; // Todo el pool que datos acerca del viaje

  const SelectDateTimeScreen({Key? key, required this.tripData})
      : super(key: key);

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 30)), // Máximo 1 mes a futuro
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00AFF5),
              onPrimary: Colors.white,
              surface: Color(0xFF2C2C2C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00AFF5),
              surface: Color(0xFF2C2C2C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _continuar() {
    if (_selectedDate == null || _selectedTime == null) return;

    // Guardamos la fecha y hora en nuestro pool de datos
    final updatedTripData = Map<String, dynamic>.from(widget.tripData);
    updatedTripData['date'] = _selectedDate!.toIso8601String().split('T')[0];
    updatedTripData['time'] = '${_selectedTime!.hour}:${_selectedTime!.minute}';

    Navigator.push(
      context,
      MaterialPageRoute(
        // mandamos a la siguiente pantalla de precios, añadiendo la fecha del viaje
        builder: (context) => SetPriceScreen(tripData: updatedTripData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Cuándo sales?",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Botón para Fecha
            ListTile(
              onTap: _pickDate,
              tileColor: const Color(0xFF2C2C2C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading:
                  const Icon(Icons.calendar_month, color: Color(0xFF00AFF5)),
              title: Text(
                _selectedDate == null
                    ? "Seleccionar fecha"
                    : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 16),
            ),
            const SizedBox(height: 20),

            // Botón para Hora
            ListTile(
              onTap: _pickTime,
              tileColor: const Color(0xFF2C2C2C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading: const Icon(Icons.access_time, color: Color(0xFF00AFF5)),
              title: Text(
                _selectedTime == null
                    ? "Seleccionar hora"
                    : _selectedTime!.format(context),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 16),
            ),

            const Spacer(),

            // Botón de Continuar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedDate != null && _selectedTime != null)
                    ? _continuar
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AFF5),
                  disabledBackgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text("Continuar",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

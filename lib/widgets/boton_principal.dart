import 'package:flutter/material.dart';
import '../themes/app_theme.dart'; // Importamos tu paleta Anáhuac

class PrimaryButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.isLoading = false,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ocupa todo el ancho disponible
      height: 56, // Altura estándar para botones móviles cómodos
      child: ElevatedButton(
        // Si está cargando, deshabilitamos el botón (null) para evitar dobles clics
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          // ¡AQUÍ ESTÁ LA MAGIA! El fondo naranja institucional
          backgroundColor: AnahuacColors.PRIMARY_ORANGE,
          // Color del botón cuando está deshabilitado (cargando)
          disabledBackgroundColor:
              AnahuacColors.PRIMARY_ORANGE.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Bordes tipo píldora
          ),
          elevation: 4, // Una sombra sutil para resaltar
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white, // Ruedita de carga en blanco
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      Colors.white, // Texto en blanco para contraste perfecto
                ),
              ),
      ),
    );
  }
}

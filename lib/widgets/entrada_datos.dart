import 'package:flutter/material.dart';
import '../themes/app_theme.dart'; // Importamos tu paleta Anáhuac

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType inputType;

  const CustomInputField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.inputType = TextInputType.text,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.inputType,
      // 1. LA SOLUCIÓN: Forzamos a que el texto que el usuario escribe sea oscuro
      style: TextStyle(
        color: AnahuacColors
            .TEXT_DARK, // Gris oscuro/negro para que se lea perfecto
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        // 2. Color del texto fantasma (ejemplo@correo.com)
        hintStyle: TextStyle(color: AnahuacColors.TEXT_SECONDARY),
        // 3. Ícono de la izquierda en color institucional
        prefixIcon: Icon(widget.icon, color: AnahuacColors.PRIMARY_ORANGE),
        // Lógica del ojito para las contraseñas
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey, // Ojito en gris neutro
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        filled: true,
        // 4. Fondo de la caja en gris MUY clarito para que resalte del fondo blanco del Scaffold
        fillColor: Colors.grey[100],
        // 5. Bordes redondeados sin línea dura por defecto
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        // 6. El toque premium: Cuando el usuario toca la caja, el borde se pinta de naranja
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AnahuacColors.PRIMARY_ORANGE, width: 2),
        ),
      ),
    );
  }
}

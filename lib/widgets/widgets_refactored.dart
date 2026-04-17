import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Botón principal refactorizado - Estilo Anáhuac Light
class BotonPrincipalRefactored extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary; // Para variantes
  final IconData? icon;

  const BotonPrincipalRefactored({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return _buildSecondaryButton();
    }
    return _buildPrimaryButton();
  }

  /// Botón primario - Naranja Anáhuac
  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: icon != null
            ? Icon(icon)
            : const SizedBox.shrink(),
        label: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  color: Colors.white,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AnahuacColors.PRIMARY_ORANGE,
          disabledBackgroundColor:
              AnahuacColors.PRIMARY_ORANGE.withOpacity(0.4),
          disabledForegroundColor: Colors.white.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: AnahuacColors.PRIMARY_ORANGE.withOpacity(0.3),
        ),
      ),
    );
  }

  /// Botón secundario - Outline naranja
  Widget _buildSecondaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: icon != null
            ? Icon(icon, color: AnahuacColors.PRIMARY_ORANGE)
            : const SizedBox.shrink(),
        label: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AnahuacColors.PRIMARY_ORANGE,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  color: AnahuacColors.PRIMARY_ORANGE,
                ),
              ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AnahuacColors.PRIMARY_ORANGE,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

/// Botón de acción flotante refactorizado
class ActionButtonRefactored extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDanger; // Para botones de eliminar/cancelar

  const ActionButtonRefactored({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDanger = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDanger
            ? AnahuacColors.ERROR_RED
            : AnahuacColors.PRIMARY_ORANGE,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 2,
        shadowColor: (isDanger
                ? AnahuacColors.ERROR_RED
                : AnahuacColors.PRIMARY_ORANGE)
            .withOpacity(0.3),
      ),
    );
  }
}

/// Campo de entrada refactorizado con estilo píldora
class InputFieldRefactored extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const InputFieldRefactored({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
    this.validator,
  }) : super(key: key);

  @override
  State<InputFieldRefactored> createState() => _InputFieldRefactoredState();
}

class _InputFieldRefactoredState extends State<InputFieldRefactored> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: AnahuacColors.TEXT_DARK,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        // Campo de entrada con borde redondeado
        Focus(
          onFocusChange: (focused) {
            setState(() => _isFocused = focused);
          },
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            validator: widget.validator,
            style: const TextStyle(
              color: AnahuacColors.TEXT_DARK,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: AnahuacColors.TEXT_LIGHT,
                fontSize: 14,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AnahuacColors.PRIMARY_ORANGE
                          : AnahuacColors.TEXT_LIGHT,
                    )
                  : null,
              filled: true,
              fillColor: AnahuacColors.NEUTRAL_LIGHT_BG,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AnahuacColors.NEUTRAL_BORDER,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AnahuacColors.NEUTRAL_BORDER,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AnahuacColors.PRIMARY_ORANGE,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AnahuacColors.ERROR_RED,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Card de información refactorizada
class InfoCardRefactored extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool isDanger;

  const InfoCardRefactored({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.isDanger = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AnahuacColors.NEUTRAL_LIGHT_BG;
    final iconColor =
        isDanger ? AnahuacColors.ERROR_RED : AnahuacColors.PRIMARY_ORANGE;

    return Card(
      color: AnahuacColors.BACKGROUND_WHITE,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AnahuacColors.NEUTRAL_BORDER,
          width: 0.5,
        ),
      ),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icono con fondo coloreado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AnahuacColors.TEXT_DARK,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AnahuacColors.TEXT_SECONDARY,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Arrow si es clickeable
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AnahuacColors.TEXT_LIGHT,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status badge refactorizado
class StatusBadgeRefactored extends StatelessWidget {
  final String label;
  final BadgeStatus status;

  const StatusBadgeRefactored({
    Key? key,
    required this.label,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors['border'],
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors['text'],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Map<String, Color> _getStatusColors(BadgeStatus status) {
    switch (status) {
      case BadgeStatus.success:
        return {
          'bg': AnahuacColors.SUCCESS_LIGHT,
          'text': AnahuacColors.SUCCESS_GREEN,
          'border': AnahuacColors.SUCCESS_GREEN,
        };
      case BadgeStatus.error:
        return {
          'bg': AnahuacColors.ERROR_LIGHT,
          'text': AnahuacColors.ERROR_RED,
          'border': AnahuacColors.ERROR_RED,
        };
      case BadgeStatus.warning:
        return {
          'bg': const Color(0xFFFFF9C4),
          'text': AnahuacColors.WARNING_AMBER,
          'border': AnahuacColors.WARNING_AMBER,
        };
      case BadgeStatus.info:
        return {
          'bg': const Color(0xFFE1F5FE),
          'text': AnahuacColors.INFO_BLUE,
          'border': AnahuacColors.INFO_BLUE,
        };
      case BadgeStatus.pending:
        return {
          'bg': AnahuacColors.NEUTRAL_LIGHT_BG,
          'text': AnahuacColors.TEXT_SECONDARY,
          'border': AnahuacColors.NEUTRAL_BORDER,
        };
    }
  }
}

enum BadgeStatus { success, error, warning, info, pending }

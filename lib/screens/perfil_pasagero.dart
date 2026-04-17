import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../themes/app_theme.dart'; // Importamos tu paleta Anáhuac

class PerfilPasagero extends ConsumerStatefulWidget {
  final String passengerId;
  final String initialName;
  final String initialPhoto;

  const PerfilPasagero({
    Key? key,
    required this.passengerId,
    required this.initialName,
    required this.initialPhoto,
  }) : super(key: key);

  @override
  ConsumerState<PerfilPasagero> createState() => _PerfilPasageroState();
}

class _PerfilPasageroState extends ConsumerState<PerfilPasagero> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    // Llamamos a las providers
    final apiService = ref.read(apiServiceProvider);
    final data = await apiService.obtenerPerfil(widget.passengerId);

    if (mounted) {
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo blanco institucional
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // Flecha de retroceso en naranja vibrante
          icon: Icon(Icons.arrow_back, color: AnahuacColors.PRIMARY_ORANGE),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: AnahuacColors.PRIMARY_ORANGE),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar del usuario
                    Hero(
                      tag: 'avatar_${widget.initialName}',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Le damos un borde sutil naranja al avatar para que resalte
                          border: Border.all(
                            color:
                                AnahuacColors.PRIMARY_ORANGE.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[
                              200], // Fondo por si tarda en cargar la imagen
                          backgroundImage: NetworkImage(widget.initialPhoto),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Nombre del pasajero
                    Text(
                      _profileData?['name'] ?? widget.initialName,
                      style: TextStyle(
                        color:
                            AnahuacColors.TEXT_DARK, // Gris oscuro/negro suave
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Tarjeta de información del backend
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white, // Tarjeta blanca pura
                          borderRadius: BorderRadius.circular(
                              20), // Bordes más redondeados
                          // Sombra premium para separarlo del fondo
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Biografía
                            Text(
                              'Sobre mí',
                              style: TextStyle(
                                color: AnahuacColors.TEXT_DARK,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _profileData?['biography'] != null &&
                                      _profileData!['biography'].isNotEmpty
                                  ? _profileData!['biography']
                                  : 'Sin información adicional.',
                              style: TextStyle(
                                color: AnahuacColors
                                    .TEXT_SECONDARY, // Gris profesional
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),

                            // Separador más suave
                            Divider(
                                color: Colors.grey[200],
                                height: 40,
                                thickness: 1),

                            // Preferencias
                            Text(
                              'Preferencias',
                              style: TextStyle(
                                color: AnahuacColors.TEXT_DARK,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _profileData?['preferences'] != null &&
                                      _profileData!['preferences'].isNotEmpty
                                  ? _profileData!['preferences']
                                  : 'No especificadas.',
                              style: TextStyle(
                                color: AnahuacColors.TEXT_SECONDARY,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),

                            Divider(
                                color: Colors.grey[200],
                                height: 40,
                                thickness: 1),

                            // Vehículos
                            Text(
                              'Vehículos',
                              style: TextStyle(
                                color: AnahuacColors.TEXT_DARK,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  color: AnahuacColors
                                      .PRIMARY_ORANGE, // Icono en color institucional
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _profileData?['vehicles'] != null &&
                                            _profileData!['vehicles'].isNotEmpty
                                        ? _profileData!['vehicles']
                                        : 'No tiene vehículo registrado',
                                    style: TextStyle(
                                      color: AnahuacColors.TEXT_SECONDARY,
                                      fontSize: 16,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

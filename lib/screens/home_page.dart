import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login/login.dart';
import '../widgets/navegacion_button.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = "Cargando...";
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _prefController = TextEditingController();
  final TextEditingController _vehiclesController = TextEditingController();

  // Nuevos estados para controlar la vista
  bool _isFetching =
      true; // ¿Está trayendo datos de la BD al abrir la pantalla?
  bool _isEditing = false; // ¿Están los campos de texto desbloqueados?
  bool _isLoading = false; // ¿Está guardando los datos?

  @override
  void initState() {
    super.initState();
    _cargarPerfil(); // Llamamos a la BD apenas se abre la pantalla
  }

  // --- 1. LÓGICA: TRAER DATOS (GET) ---
  Future<void> _cargarPerfil() async {
    final userId = await AuthService().getCurrentUserId();

    if (userId != null) {
      final datos = await ApiService().obtenerPerfil(userId);

      if (datos != null && mounted) {
        // Llenamos las cajas de texto con lo que llegó de Postgres
        setState(() {
          _userName = datos['name'] ?? 'Usuario';
          _bioController.text = datos['biography'] ?? '';
          _prefController.text = datos['preferences'] ?? '';
          _vehiclesController.text = datos['vehicles'] ?? '';
        });
      }
    }

    // Apagamos la animación de carga
    if (mounted) setState(() => _isFetching = false);
  }

  // --- 2. LÓGICA: GUARDAR DATOS (PUT) ---
  Future<void> _guardarPerfil() async {
    setState(() => _isLoading = true);

    final userId = await AuthService().getCurrentUserId();

    if (userId == null) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No hay sesión activa')),
        );
      setState(() => _isLoading = false);
      return;
    }

    final exito = await ApiService().guardarPerfil(
      userId: userId,
      biography: _bioController.text,
      preferences: _prefController.text,
      vehicles: _vehiclesController.text,
    );

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Perfil guardado con éxito',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Si fue exitoso, bloqueamos las cajas de nuevo
        setState(() => _isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error al guardar el perfil',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService().signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al salir: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF191919),
        appBar: AppBar(
          backgroundColor: const Color(0xFF191919),
          elevation: 0,
          toolbarHeight: 10,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Información personal"),
              Tab(text: "Cuenta"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Si está descargando datos, mostramos un spinner. Si ya terminó, mostramos la UI.
            _isFetching
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00AFF5)),
                  )
                : _buildPersonalInfoTab(),
            _buildAccountTab(),
          ],
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Principiante",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          const Text(
            "Acerca de ti",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          // Fíjate cómo ahora le pasamos la variable _isEditing
          _buildTextField(
            "Minibiografía",
            "Ej. Soy un estudiante de TI...",
            _bioController,
            maxLines: 3,
            enabled: _isEditing,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            "Preferencias de viaje",
            "Ej. Me gusta escuchar música, no fumo",
            _prefController,
            enabled: _isEditing,
          ),

          const SizedBox(height: 30),
          const Text(
            "Vehículos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildTextField(
            "Vehículo principal",
            "Ej. Volkswagen Jetta 2018 - Blanco",
            _vehiclesController,
            enabled: _isEditing,
          ),

          const SizedBox(height: 40),

          // LÓGICA DEL BOTÓN CAMALEÓN
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_isEditing) {
                        // Si estaba editando, guardamos los datos
                        _guardarPerfil();
                      } else {
                        // Si estaba solo leyendo, activamos la edición
                        setState(() => _isEditing = true);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing
                    ? const Color(0xFF00AFF5)
                    : Colors.grey[800], // Azul para guardar, Gris para editar
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _isEditing
                          ? "Guardar Información"
                          : "Modificar Información",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tu cuenta",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star_outline, color: Colors.white),
            title: const Text(
              "Tus reseñas",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
            onTap: () {},
          ),
          const Divider(color: Colors.grey),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text(
                "Cerrar Sesión",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Actualizamos el widget para que acepte "enabled"
  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF00AFF5),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled, // Bloquea o desbloquea el campo
          style: TextStyle(
            color: enabled ? Colors.white : Colors.grey[400],
          ), // Si está bloqueado, el texto es un poco más opaco
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: enabled
                ? const Color(0xFF2C2C2C)
                : const Color(0xFF1F1F1F), // Fondo más oscuro si está bloqueado
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

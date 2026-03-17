import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login/login.dart';
import '../widgets/navegacion_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/app_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String _userName = "Cargando...";
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _prefController = TextEditingController();
  final TextEditingController _vehiclesController = TextEditingController();

  // Estados para controlar la vista
  bool _isFetching = true; // Trayendo los datos de la bd
  bool _isEditing = false; // Campos de texto desbloqueados al inicio
  bool _isLoading = false; // Guardando los datos

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarPerfil(); // Cargamos el perfil apenas se abre la pantalla
    });
  }
  // Creamod un alias del servicio de riverpod para usarlo directamente en todo el archivo

  ApiService get apiService => ref.read(apiServiceProvider);
  AuthService get authService => ref.read(authServiceProvider);

  // Cargamos los datos del perfil del usuario
  Future<void> _cargarPerfil() async {
    final perfilCache = ref.read(userProfileProvider);

    if (perfilCache != null) {
      if (mounted) {
        setState(() {
          _userName = perfilCache['name'] ?? 'Usuario';
          _bioController.text = perfilCache['biography'] ?? '';
          _prefController.text = perfilCache['preferences'] ?? '';
          _vehiclesController.text = perfilCache['vehicles'] ?? '';
          _isFetching = false;
        });
      }
      return; // Cortamos la ejecución aquí, ya no bajamos a hacer la petición.
    }
    // ya que no tenemos caché guardado, hacemos una petición
    // Obtenemos del id del usuario directamente del provider
    final String? miId = ref.read(currentUserIdProvider);
    if (miId != null) {
      final datos = await apiService.obtenerPerfil(miId);

      if (datos != null && mounted) {
        ref.read(userProfileProvider.notifier).setProfile(datos);
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

  // Actualizar los datos del usuario
  Future<void> _guardarPerfil() async {
    setState(() => _isLoading = true);

    final String? miId = ref.read(currentUserIdProvider);

    if (miId == null) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No hay sesión activa')),
        );
      setState(() => _isLoading = false);
      return;
    }

    final exito = await apiService.guardarPerfil(
      userId: miId,
      biography: _bioController.text,
      preferences: _prefController.text,
      vehicles: _vehiclesController.text,
    );

    if (mounted) {
      if (exito) {
        final perfilViejo = ref.read(userProfileProvider) ?? {};
        final perfilNuevo = {
          ...perfilViejo,
          'biography':
              _bioController.text, // añadimos la nueva información del usuario
          'preferences': _prefController.text,
          'vehicles': _vehiclesController.text,
        };

        // Actualizamos los cambios a la bóveda de riverpod
        // Esto hace que cualquier pantalla que lo esté viendo se actualice sola.
        ref.read(userProfileProvider.notifier).setProfile(perfilNuevo);
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
      // Hacemos logout usando cognito por medio del provider
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      //  Limpiamos la bóveda
      ref.invalidate(currentUserIdProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(googleMapsServiceProvider);
      // Regresamos a la página inicial
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
    final userData = ref.watch(userProfileProvider);
    if (userData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF191919),
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF00AFF5))),
      );
    }
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
                    "Nuevo usuario",
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

          // Lógica del botón modificar información
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

  // Pestaña de configuración de la cuenta, donde se encuentra el botón de logout
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

  // Actualizamos el widget
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

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PerfilPasagero extends StatefulWidget {
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
  _PerfilPasageroState createState() => _PerfilPasageroState();
}

class _PerfilPasageroState extends State<PerfilPasagero> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    // Usamos TU endpoint directamente
    final data = await _apiService.obtenerPerfil(widget.passengerId);
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
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00AFF5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00AFF5)),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Hero(
                      tag: 'avatar_${widget.initialName}',
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(widget.initialPhoto),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _profileData?['name'] ?? widget.initialName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // INFORMACIÓN DEL BACKEND
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Biografía
                            const Text(
                              'Sobre mí',
                              style: TextStyle(
                                color: Colors.white,
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
                                color: Colors.grey[300],
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const Divider(color: Colors.grey, height: 32),

                            // Preferencias
                            const Text(
                              'Preferencias',
                              style: TextStyle(
                                color: Colors.white,
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
                                color: Colors.grey[300],
                                fontSize: 16,
                              ),
                            ),
                            const Divider(color: Colors.grey, height: 32),

                            // Vehículos
                            const Text(
                              'Vehículos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.directions_car,
                                  color: Color(0xFF00AFF5),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _profileData?['vehicles'] != null &&
                                            _profileData!['vehicles'].isNotEmpty
                                        ? _profileData!['vehicles']
                                        : 'No tiene vehículo registrado',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 16,
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

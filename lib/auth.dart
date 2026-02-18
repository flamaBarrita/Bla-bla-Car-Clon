import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'home_page.dart';
import 'login.dart';

//Clase padre Auth que hereda stateful ya que es dinamica y necesita actualizar su estado
class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool _cargando = true;
  bool _autenticado = false;

  // Instanciamos el servicio de autenticación para usarlo en esta clase
  final _authService = AuthService();

  //llamamos al constructor de la clase para ir verificando al user
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  //Función que revisa si el usuario ya tiene una sesión activa
  void _checkUser() async {
    //validamos con el servicio de autenticación si el usuario ya tiene una sesión activa
    bool isLoggedIn = await _authService.checkSession();
    //Utilizamos mounted para verificar que la pantalla sigue activa antes de seguir con el estado
    if (mounted) {
      setState(() {
        _autenticado = isLoggedIn;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //mientas este cargando la validación, mostramos un spinner de carga
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    //Si esta autenticado, mostramos la HomePage, si no, mostramos la pantalla de Login
    return _autenticado ? HomePage() : LoginPage();
  }
}

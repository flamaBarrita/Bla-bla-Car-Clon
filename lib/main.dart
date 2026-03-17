import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'services/auth.dart';
import 'services/amplify_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'firebase_options.dart';
//import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(
  //  options: DefaultFirebaseOptions.currentPlatform,
  //);
  await dotenv.load(fileName: ".env");
  runApp(
    // Envolvemos toda la aplicación con ProviderScope para usar Riverpod
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _AmplifyConfigurado = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      if (!Amplify.isConfigured) {
        await Amplify.addPlugin(AmplifyAuthCognito());
        await Amplify.configure(config);
      }
      setState(() => _AmplifyConfigurado = true);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dame Ride!',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF191919),
        primaryColor: const Color(0xFF00AFF5),
      ),
      // Nuestra primera acción es mandarlo a nuestro servicio de Auth y si esta autorizado puede entrar a la aplicación
      home: _AmplifyConfigurado
          ? Auth()
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

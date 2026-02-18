import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'auth.dart';
import 'amplify_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
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
      print('Error configurando Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bla Bla Car',
      // Mantenemos el tema oscuro global
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF191919),
        primaryColor: const Color(0xFF00AFF5),
      ),
      home: _AmplifyConfigurado
          ? Auth()
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

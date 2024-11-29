import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/vista1_screen.dart';
import 'screens/vista2_screen.dart';

Future <void> main() async {
  // Asegura que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase antes de ejecutar la aplicación
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Desactiva temporalmente App Check para evitar errores en el emulador
  FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(false);

  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',  // Pantalla inicial
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/vista1': (context) => Vista1Screen(),
        '/vista2': (context) => Vista2Screen(),
      },
    );
  }
}

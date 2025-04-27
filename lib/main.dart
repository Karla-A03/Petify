import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_pet.dart';
import 'providers/mascota_provider.dart';
import 'services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz; // Importamos las zonas horarias
import 'screens/programar_notificacion_screen.dart';

Future<void> main() async {
  // Inicializa las zonas horarias antes de ejecutar la aplicación
  tz.initializeTimeZones(); // Aquí se llama correctamente sin esperar un valor

  // Asegura que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase antes de ejecutar la aplicación
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Desactiva temporalmente App Check para evitar errores en el emulador
  FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(false);

  runApp(
    MultiProvider( // Agrega el MultiProvider
      providers: [
        ChangeNotifierProvider(create: (_) => MascotaProvider()), // Agrega el MascotaProvider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',  // Pantalla inicial
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(userEmail: ModalRoute.of(context)!.settings.arguments as String), // Pantalla principal, pasando correo del us
        '/register_pet': (context) => RegisterPetScreen(userEmail: ModalRoute.of(context)!.settings.arguments as String),
        '/programar_notificacion': (context) => ProgramarNotificacionScreen(),
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Mascota {
  String nombre;
  int nivel;
  int experiencia;
  int energia;
  int felicidad;
  int maxExperiencia;
  int maxEnergia;
  int maxFelicidad;

  Mascota({
    required this.nombre,
    this.nivel = 1,
    this.experiencia = 0,
    this.energia = 100,
    this.felicidad = 100,
    this.maxExperiencia = 100,
    this.maxEnergia = 100,
    this.maxFelicidad = 100,
  });

  void alimentar() {
    energia = (energia + 20).clamp(0, maxEnergia);
  }

  void dormir() {
    energia = maxEnergia;
  }

  void jugar() {
    if (energia > 10) {
      energia -= 10;
      felicidad = (felicidad + 15).clamp(0, maxFelicidad);
      experiencia += 10;
      _revisarNivel();
    }
  }

  void _revisarNivel() {
    if (experiencia >= maxExperiencia) {
      experiencia -= maxExperiencia;
      nivel++;
      maxExperiencia += 50;
    }
  }

  void disminuirFelicidad() {
    felicidad = (felicidad - 5).clamp(0, maxFelicidad);
  }

  void disminuirEnergia() {
    energia = (energia - 2).clamp(0, maxEnergia);
  }

  void iniciarCiclo() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      disminuirFelicidad();
      disminuirEnergia();
      if (felicidad == 0 && energia == 0) {
        timer.cancel();
      }
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'nivel': nivel,
      'experiencia': experiencia,
      'energia': energia,
      'felicidad': felicidad,
      'maxExperiencia': maxExperiencia,
      'maxEnergia': maxEnergia,
      'maxFelicidad': maxFelicidad,
    };
  }

  factory Mascota.fromMap(Map<String, dynamic> map) {
    return Mascota(
      nombre: map['nombre'],
      nivel: map['nivel'],
      experiencia: map['experiencia'],
      energia: map['energia'],
      felicidad: map['felicidad'],
      maxExperiencia: map['maxExperiencia'],
      maxEnergia: map['maxEnergia'],
      maxFelicidad: map['maxFelicidad'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userEmail;

  HomeScreen({required this.userEmail});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Mascota miMascota;
  late CollectionReference mascotasRef;

  @override
  void initState() {
    super.initState();
    mascotasRef = FirebaseFirestore.instance.collection('mascotas');
    _cargarMascota();
  }

  void _cargarMascota() async {
    DocumentSnapshot docSnapshot = await mascotasRef.doc(widget.userEmail).get();
    if (docSnapshot.exists) {
      setState(() {
        miMascota = Mascota.fromMap(docSnapshot.data() as Map<String, dynamic>);
        miMascota.iniciarCiclo();
      });
    } else {
      setState(() {
        miMascota = Mascota(nombre: 'Fluffy');
        miMascota.iniciarCiclo();
        _guardarMascota();
      });
    }
  }

  void _guardarMascota() {
    mascotasRef.doc(widget.userEmail).set(miMascota.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cuidando a ${miMascota.nombre}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido a ${miMascota.nombre}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Nivel: ${miMascota.nivel}'),
            Text('Experiencia: ${miMascota.experiencia}'),
            Text('Energía: ${miMascota.energia}'),
            Text('Felicidad: ${miMascota.felicidad}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  miMascota.alimentar();
                  _guardarMascota();
                });
              },
              child: Text('Alimentar a ${miMascota.nombre}'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  miMascota.dormir();
                  _guardarMascota();
                });
              },
              child: Text('Dejar que ${miMascota.nombre} duerma'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  miMascota.jugar();
                  _guardarMascota();
                });
              },
              child: Text('Jugar con ${miMascota.nombre}'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: HomeScreen(userEmail: 'usuario@example.com'),
  ));
}

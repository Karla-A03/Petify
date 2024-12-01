import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Mascota {
  final String petName;
  int nivel;
  int experiencia;
  int energia;
  int felicidad;
  int maxExperiencia;
  int maxEnergia;
  int maxFelicidad;

  Mascota({
    required this.petName,
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
      'petName': petName,
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
      petName: map['petName'] ?? 'Default',
      nivel: map['nivel']?.toInt() ?? 1,
      experiencia: map['experiencia']?.toInt() ?? 0,
      energia: map['energia']?.toInt() ?? 100,
      felicidad: map['felicidad']?.toInt() ?? 100,
      maxExperiencia: map['maxExperiencia']?.toInt() ?? 100,
      maxEnergia: map['maxEnergia']?.toInt() ?? 100,
      maxFelicidad: map['maxFelicidad']?.toInt() ?? 100,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userEmail;
  const HomeScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _mascotaStream;
  Mascota? miMascota;

  @override
  void initState() {
    super.initState();
    _mascotaStream = FirebaseFirestore.instance
        .collection('mascotas')
        .doc(widget.userEmail)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          miMascota = Mascota.fromMap(snapshot.data()!);
          miMascota!.iniciarCiclo(); // Inicia el ciclo de la mascota
        });
      } else {
        setState(() {
          miMascota = null;
        });
      }
    }, onError: (error) {
      print('Error al obtener los datos de la mascota: $error');
      setState(() {
        miMascota = null;
      });
    });
  }

  @override
  void dispose() {
    _mascotaStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido, ${widget.userEmail}')),
      body: Center(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('mascotas')
              .doc(widget.userEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('No se encontraron datos de la mascota.');
            }

            Mascota mascota = Mascota.fromMap(snapshot.data!.data()!);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nombre de la mascota: ${mascota.petName}'),
                Text('Nivel: ${mascota.nivel}'),
                Text('Experiencia: ${mascota.experiencia}/${mascota.maxExperiencia}'),
                Text('Energía: ${mascota.energia}/${mascota.maxEnergia}'),
                Text('Felicidad: ${mascota.felicidad}/${mascota.maxFelicidad}'),
                ElevatedButton(
                  onPressed: () {
                    mascota.alimentar();
                    _guardarMascota(mascota);
                  },
                  child: const Text('Alimentar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    mascota.jugar();
                    _guardarMascota(mascota);
                  },
                  child: const Text('Jugar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    mascota.dormir();
                    _guardarMascota(mascota);
                  },
                  child: const Text('Dormir'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _guardarMascota(Mascota mascota) async {
    try {
      await FirebaseFirestore.instance
          .collection('mascotas')
          .doc(widget.userEmail)
          .update(mascota.toMap());
    } catch (e) {
      print('Error al guardar los datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar los datos: $e')),
      );
    }
  }
}
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class Mascota {
  final String petName;
  int nivel;
  int experiencia;
  int energia;
  int felicidad;
  int maxExperiencia;
  int maxEnergia;
  int maxFelicidad;
  String imagenActual;


  static const Map<String, String> imagenesPorAccion = {
    'alimentar': 'assets/Images/mascota.comiendo.png',
    'jugar': 'assets/Images/mascota.jugando.png',
    'dormir': 'assets/Images/mascota.durmiendo.png',
  };

  Mascota({
    required this.petName,
    this.nivel = 1,
    this.experiencia = 0,
    this.energia = 100,
    this.felicidad = 100,
    this.maxExperiencia = 100,
    this.maxEnergia = 100,
    this.maxFelicidad = 100,
    this.imagenActual = 'assets/Images/mascota.principal.png',
  });

  void realizarAccion(String accion) {
    switch (accion) {
      case 'alimentar':
        energia = (energia + 20).clamp(0, maxEnergia);
        break;
      case 'jugar':
        if (energia > 0) {
          energia = (energia - 10).clamp(0, maxEnergia);
          felicidad = (felicidad + 15).clamp(0, maxFelicidad);
          experiencia += 10;
        }
        break;
      case 'dormir':
        energia = maxEnergia;
        break;
    }


    if (experiencia >= maxExperiencia) {
      nivel++;
      experiencia = experiencia - maxExperiencia;
      maxExperiencia += 50;
    }
  }

  void cambiarImagen(String accion) {
    imagenActual = imagenesPorAccion[accion] ?? 'assets/Images/mascota.principal.png';
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
      'imagenActual': imagenActual,
    };
  }

  factory Mascota.fromMap(Map<String, dynamic> map) {
    return Mascota(
      petName: map['petName'] ?? 'Mascota',
      nivel: map['nivel'] ?? 1,
      experiencia: map['experiencia'] ?? 0,
      energia: map['energia'] ?? 100,
      felicidad: map['felicidad'] ?? 100,
      maxExperiencia: map['maxExperiencia'] ?? 100,
      maxEnergia: map['maxEnergia'] ?? 100,
      maxFelicidad: map['maxFelicidad'] ?? 100,
      imagenActual: map['imagenActual'] ?? 'assets/Images/mascota.principal.png',
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userEmail;
  const HomeScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<HomeScreen> createState() => _Vista1ScreenState();
}

class _Vista1ScreenState extends State<HomeScreen> {
  Mascota? miMascota;
  Timer? _timer;
  late StreamSubscription<
      DocumentSnapshot<Map<String, dynamic>>> _mascotaStream;

  @override
  void initState() {
    super.initState();
    _cargarMascota();
  }

  void _cargarMascota() {
    _mascotaStream = FirebaseFirestore.instance
        .collection('mascotas')
        .doc(widget.userEmail)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          miMascota = Mascota.fromMap(snapshot.data()!);
        });
      } else {
        setState(() {
          miMascota = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _mascotaStream.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _guardarMascota(Mascota mascota) async {
    try {
      await FirebaseFirestore.instance
          .collection('mascotas')
          .doc(widget.userEmail)
          .update(mascota.toMap());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  void _accionMascota(String accion) {
    if (miMascota == null) return;

    _timer?.cancel();

    setState(() {
      miMascota!.cambiarImagen(accion);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        miMascota!.realizarAccion(accion);
      });

      _timer = Timer(const Duration(seconds: 3), () {
        setState(() {
          miMascota!.imagenActual =
          'assets/Images/mascota.principal.png';
        });

        _guardarMascota(miMascota!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascota', style: TextStyle(fontWeight: FontWeight
            .bold, color: Colors.white)),
        backgroundColor: const Color(0xFF00BCD4),
      ),
      drawer: AppDrawer(userEmail: widget.userEmail),
      body: miMascota == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Nivel: ${miMascota!.nivel}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.transparent, width: 4),
                  ),
                  child: Image.asset(
                      miMascota!.imagenActual, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 30),
              _buildStats('Experiencia',
                  miMascota!.experiencia / miMascota!.maxExperiencia),
              _buildStats(
                  'Felicidad', miMascota!.felicidad / miMascota!.maxFelicidad),
              _buildStats(
                  'Energía', miMascota!.energia / miMascota!.maxEnergia),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFF00BCD4))),
        LinearProgressIndicator(value: value,
            backgroundColor: Colors.grey[300],
            color: Colors.green),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _accionMascota('alimentar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,

            side: BorderSide(color: const Color(0xFF00BCD4), width: 2),

            minimumSize: const Size(150, 60),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Alimentar',
                style: TextStyle(color: Color(0xFF00BCD4)),
              ),
              Icon(Icons.add, color: Color(0xFF00BCD4)),

            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _accionMascota('jugar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,

            side: BorderSide(color: const Color(0xFF00BCD4), width: 2),

            minimumSize: const Size(150, 60),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Jugar',
                style: TextStyle(color: Color(0xFF00BCD4)),
              ),
              Icon(Icons.add, color: Color(0xFF00BCD4)),

            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _accionMascota('dormir'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,

            side: BorderSide(color: const Color(0xFF00BCD4), width: 2),

            minimumSize: const Size(150, 60),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Dormir',
                style: TextStyle(color: Color(0xFF00BCD4)),
              ),
              Icon(Icons.add, color: Color(0xFF00BCD4)),

            ],
          ),
        ),
      ],
    );
  }
}

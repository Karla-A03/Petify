import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/mascota_provider.dart';
import '../widgets/app_drawer.dart';
import '../services/climaAPI.dart';
import '../services/locationService.dart';


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
  String? _petName;
  String? _clima; // Para mostrar el clima
  String? _ubicacion; // Para mostrar la ubicación
  bool _isLoading = false; // Para mostrar un indicador de carga
  late StreamSubscription<
      DocumentSnapshot<Map<String, dynamic>>> _mascotaStream;


  @override
  void initState() {
    super.initState();
    _cargarMascota();
    _getWeatherAndLocation();
  }

  // Método para obtener la ubicación y el clima
  Future<void> _getWeatherAndLocation() async {
    setState(() {
      _isLoading = true; // Mostrar el indicador de carga
    });

    // Obtener la ubicación
    Position? position = await obtenerUbicacion();
    if (position != null) {
      _ubicacion = 'Lat: ${position.latitude}, Lon: ${position.longitude}';

      // Obtener el clima usando la ubicación
      Map<String, dynamic>? climaData = await obtenerClima(position.latitude, position.longitude);
      if (climaData != null) {
        _clima = 'Temperatura: ${climaData['main']['temp']}°C\n'
            'Condición: ${climaData['weather'][0]['description']}';
      } else {
        _clima = 'No se pudo obtener el clima';
      }
    } else {
      _ubicacion = 'No se pudo obtener la ubicación';
      _clima = 'No se pudo obtener el clima';
    }

    setState(() {
      _isLoading = false; // Ocultar el indicador de carga
    });
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
          _petName = miMascota!.petName; // Asignar el valor aquí
        });
      } else {
        setState(() {
          miMascota = null;
          _petName = null; // Asignar el valor aquí
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

      Provider.of<MascotaProvider>(context, listen: false).alimentarMascota();

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
        title: const Text('Mascota', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
              // Your existing widget structure (pet details)
              Text('Nombre: ${_petName ?? 'No disponible'}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('Nivel: ${miMascota!.nivel}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.transparent, width: 4),
                  ),
                  child: Image.asset(miMascota!.imagenActual, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
              _buildStats('Experiencia', miMascota!.experiencia / miMascota!.maxExperiencia),
              _buildStats('Felicidad', miMascota!.felicidad / miMascota!.maxFelicidad),
              _buildStats('Energía', miMascota!.energia / miMascota!.maxEnergia),
              const SizedBox(height: 10),
              Consumer<MascotaProvider>(
                builder: (context, provider, child) {
                  if (provider.mostrarMensajeAlimentacion) {
                    return FutureBuilder(
                      future: Future.delayed(const Duration(seconds: 2)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          provider.reiniciarAlimentaciones();
                          return Container();
                        } else {
                          return Text(
                            '3 Streaks',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00BCD4)),
                          );
                        }
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FutureBuilder(
        future: _obtenerClimaYUbicacion(), // Call to get weather and location
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const BottomAppBar(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Cargando clima y ubicación...', style: TextStyle(color: Colors.white)),
              ),
            );
          } else if (snapshot.hasError) {
            return const BottomAppBar(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Error al obtener clima y ubicación', style: TextStyle(color: Colors.white)),
              ),
            );
          } else {
            return BottomAppBar(
              color: Color(0xFF00BCD4), // You can change the color of the bottom bar
              child: Container(
                height: 120, // Adjust the height of the bottom bar here
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Weather and location info
                    if (snapshot.hasData) _buildClimaInfo(snapshot.data),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

// Method to get weather and location
  Future<Map<String, dynamic>?> _obtenerClimaYUbicacion() async {
    final position = await obtenerUbicacion();
    if (position != null) {
      final clima = await obtenerClima(position.latitude, position.longitude);
      return clima; // Returns the weather data if available
    }
    return null; // Returns null if no location is found
  }

// Method to build weather and location info
  Widget _buildClimaInfo(Map<String, dynamic>? clima) {
    if (clima == null) {
      return const Text('No se pudo obtener el clima.');
    }

    final temperatura = clima['main']['temp'];
    final descripcion = clima['weather'][0]['description'];
    final ciudad = clima['name'];

    return Column(
      children: [
        Text('Ubicación: $ciudad' , style: TextStyle(fontSize: 14, color: Colors.white)),
        Text('Clima: $temperatura°C - $descripcion', style: TextStyle(fontSize: 14, color: Colors.white)),
      ],
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

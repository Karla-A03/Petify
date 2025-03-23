import 'package:geolocator/geolocator.dart';

Future<Position?> obtenerUbicacion() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Verificar si el servicio de ubicación está habilitado
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null; // El usuario debe habilitar la ubicación
  }

  // Verificar permisos
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return null; // Permisos denegados permanentemente
    }
  }

  // Obtener la ubicación actual
  return await Geolocator.getCurrentPosition();
}

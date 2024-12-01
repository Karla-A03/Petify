//Código para guardar las mascotas con el id de la autenticacion

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Guardar datos de la mascota
  Future<void> savePetData(String petName, String birthday, String description) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("El usuario no está autenticado");
      return;
    }

    // Guardar la mascota con los datos proporcionados
    await _db.collection('mascotas').doc(user.uid).set({
      'nombre': petName,
      'fechaCumpleaños': birthday,
      'descripcion': description,
      'usuarioId': user.uid,
    }).catchError((e) {
      print("Error al guardar los datos de la mascota: $e");
    });
  }

  // Obtener datos de la mascota
  Future<Map<String, dynamic>?> getPetData() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("El usuario no está autenticado");
      return null;
    }

    DocumentSnapshot doc = await _db.collection('mascotas').doc(user.uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/material.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para registrarse con correo electrónico y contraseña
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Manejo de errores
      print('Error en el registro: ${e.message}');
      return null;
    }
  }

  // Método para iniciar sesión con correo electrónico y contraseña
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Manejo de errores
      print('Error en el inicio de sesión: ${e.message}');
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Método para obtener el usuario actual
  Future<User?> getCurrentUser() async {
    User? user = _auth.currentUser;
    return user;
  }
}

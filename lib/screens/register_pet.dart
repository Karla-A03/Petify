import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class RegisterPetScreen extends StatefulWidget {
  final String userEmail;

  RegisterPetScreen({required this.userEmail});

  @override
  _RegisterPetScreenState createState() => _RegisterPetScreenState();
}

class _RegisterPetScreenState extends State<RegisterPetScreen> {
  final _petNameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _petName = '';
  String _birthday = '';
  String _description = '';

  Future<void> _savePetData() async {
    try {
      String petName = _petNameController.text;
      if (petName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El nombre de la mascota es obligatorio.')),
        );
        return;
      }

      // Guardar la mascota en Firestore
      await FirebaseFirestore.instance.collection('pets').add({
        'userEmail': widget.userEmail,
        'petName': petName,
        'birthday': _birthdayController.text,
        'description': _descriptionController.text,
        'level': 1, // Nivel inicial de la mascota
        'experience': 0, // Experiencia inicial
        'energy': 100, // Energía inicial
        'happiness': 100, // Felicidad inicial
      });

      // Navegar a la pantalla de inicio después de guardar los datos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userEmail: widget.userEmail)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la mascota: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Mascota')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _petNameController,
              decoration: InputDecoration(labelText: 'Nombre de la mascota'),
              onChanged: (value) => _petName = value,
            ),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(labelText: 'Fecha de cumpleaños'),
              onChanged: (value) => _birthday = value,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
              onChanged: (value) => _description = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePetData,
              child: Text('Guardar Mascota'),
            ),
          ],
        ),
      ),
    );
  }
}

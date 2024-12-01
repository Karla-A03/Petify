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

  bool _isLoading = false;

  Future<void> _savePetData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String petName = _petNameController.text.trim();
      String birthday = _birthdayController.text.trim();
      String description = _descriptionController.text.trim();

      if (petName.isEmpty || birthday.isEmpty || description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Todos los campos son obligatorios.')),
        );
        return;
      }

      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthday)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El formato de la fecha debe ser AAAA-MM-DD.')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('mascotas').doc(widget.userEmail).set({
        'userEmail': widget.userEmail,
        'petName': petName,
        'birthday': birthday,
        'description': description,
        'level': 1,
        'experience': 0,
        'energy': 100,
        'happiness': 100,
      });

      // Simula la pantalla de carga por 5 segundos
      await Future.delayed(Duration(seconds: 2));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userEmail: widget.userEmail)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la mascota: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Mascota')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _petNameController,
              decoration: InputDecoration(labelText: 'Nombre de la Mascota'),
            ),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(labelText: 'Cumpleaños (AAAA-MM-DD)'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePetData,
              child: Text('Registrar Mascota'),
            ),
          ],
        ),
      ),
    );
  }
}

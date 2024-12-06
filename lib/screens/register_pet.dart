import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_drawer.dart';
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

  Future<void> _registerPet() async {
    if (_petNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El nombre de la mascota no puede estar vacío')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('mascotas')
          .doc(widget.userEmail)
          .set({
        'petName': _petNameController.text,
        'birthday': _birthdayController.text,
        'description': _descriptionController.text,
        'nivel': 1,
        'experiencia': 0,
        'energia': 100,
        'felicidad': 100,
        'maxExperiencia': 100,
        'maxEnergia': 100,
        'maxFelicidad': 100,
        'imagenActual': 'assets/Images/mascota.principal.png',
      });

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
      appBar: AppBar(
        title: const Text(
          'Registrar Mascota',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00BCD4),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Nombre de la Mascota',
              controller: _petNameController,
              hint: 'Ejemplo: Firulais',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Cumpleaños (Opcional)',
              controller: _birthdayController,
              hint: 'Ejemplo: 12/05/2020',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Descripción',
              controller: _descriptionController,
              hint: 'Describe a tu mascota...',
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _registerPet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Registrar',
                  style: TextStyle(
                    color: Color(0xFF00BCD4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF00BCD4),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00BCD4)),
            ),
          ),
        ),
      ],
    );
  }
}

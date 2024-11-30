import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyect_final/services/auth_service.dart'; // Asegúrate de importar el servicio
import '../services/auth_service.dart';
import 'home_screen.dart'; // Importa la pantalla principal para redirigir después del login

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Instancia del servicio de autenticación

  String _errorMessage = '';
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Cambia la opacidad a 1.0 después de un retraso
      });
    });
  }

  // Función para manejar el login
  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Llamamos al servicio de autenticación
    User? user = await _authService.signInWithEmailPassword(email, password);

    if (user != null) {
      // Si el login es exitoso, redirigimos al home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = 'Error en el inicio de sesión. Intenta nuevamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF57F5FF), // Color superior
              Color(0xFF0E5C61), // Color inferior
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Titulo(),
              SizedBox(height: 10),
              ImagenLogin(),
              SizedBox(height: 10),
              CampoEmail(_emailController),
              CampoPassword(_passwordController),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signIn, // Llama a la función de inicio de sesión
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 40), // Tamaño mínimo del botón
                  backgroundColor: Colors.white, // Color de fondo del botón (blanco)
                  foregroundColor: Color(0xFF2E8F95), // Color del texto del botón (#2E8F95)
                  side: BorderSide(color: Color(0xFF2E8F95)), // Borde #2E8F95
                  shape: RoundedRectangleBorder( // Forma del botón
                    borderRadius: BorderRadius.circular(10), // Esquinas redondas
                  ),
                ),
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 15, // Tamaño del texto
                    fontWeight: FontWeight.bold, // Fuente en negrita
                    color: Color(0xFF2E8F95), // Color del texto (#2E8F95)
                  ),
                ),
              ),
              SizedBox(height: 5),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              BotonRegistro(),
              SizedBox(height: 5),
              TextoPetify(_opacity),
            ],
          ),
        ),
      ),
    );
  }
}

class Titulo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Text(
        'Petify',
        style: TextStyle(
          fontSize: 40, // Tamaño de letra grande
          fontFamily: 'RubikDoodleShadow', // Fuente personalizada
          fontWeight: FontWeight.bold, // Peso de la fuente
          color: Colors.white, // Color blanco
        ),
      ),
    );
  }
}

class ImagenLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/Images/icon-login.png', // Ruta de la imagen
      width: 130, // Ancho de la imagen
      height: 130, // Alto de la imagen
    );
  }
}

class CampoEmail extends StatelessWidget {
  final TextEditingController _emailController;

  CampoEmail(this._emailController);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 40, right: 40, bottom: 10), // Espacio exterior
      padding: EdgeInsets.all(5), // Espacio interior
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Fondo transparente
        borderRadius: BorderRadius.circular(10), // Esquinas redondas
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Correo Electrónico',
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder( // Borde cuando no está seleccionado
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder( // Borde cuando está seleccionado
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class CampoPassword extends StatelessWidget {
  final TextEditingController _passwordController;

  CampoPassword(this._passwordController);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0, left: 40, right: 40, bottom: 10), // Ajusta el margen superior
      padding: EdgeInsets.all(5), // Espacio interior
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Fondo transparente
        borderRadius: BorderRadius.circular(10), // Esquinas redondas
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: true, // Oculta la contraseña
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Contraseña',
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder( // Borde cuando no está seleccionado
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder( // Borde cuando está seleccionado
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class BotonRegistro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/register');
      },
      child: Text(
        '¿No tienes cuenta? Regístrate',
        style: TextStyle(color: Colors.white), // Texto blanco
      ),
    );
  }
}

class TextoPetify extends StatelessWidget {
  final double _opacity;

  TextoPetify(this._opacity);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity, // Variable que controla la opacidad
      duration: Duration(milliseconds: 1000), // Tiempo de la animación
      child: Text(
        '¡Diviértete con tu Petify!',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontFamily: 'ZenKurenaido', // Agrega la fuente personalizada
        ),
      ),
    );
  }
}
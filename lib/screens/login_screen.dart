import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyect_final/services/auth_service.dart';
import 'home_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
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
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: user.email, // Pasamos el correo del usuario a la pantalla de inicio
      );
    } else {
      _showErrorDialog('Error en el inicio de sesión. Intenta nuevamente.');
    }
  }

  // Función para mostrar el cuadro de diálogo de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Widgets para mostrar los elementos de la pantalla de login
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF57F5FF),
              Color(0xFF0E5C61),
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
                  minimumSize: Size(200, 40),
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF2E8F95),
                  side: BorderSide(color: Color(0xFF2E8F95)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E8F95),
                  ),
                ),
              ),
              SizedBox(height: 5),
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
          fontSize: 40,
          fontFamily: 'RubikDoodleShadow',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ImagenLogin extends StatefulWidget {
  @override
  _ImagenLoginState createState() => _ImagenLoginState();
}

class _ImagenLoginState extends State<ImagenLogin> {
  bool _isScaled = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _isScaled = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: Duration(seconds: 2),
        curve: Curves.easeInOut,
        width: _isScaled ? 200 : 150,
        height: _isScaled ? 200 : 150,
        onEnd: () {
          setState(() {
            _isScaled = !_isScaled;
          });
        },
        child: Image.network(
          'https://media.tenor.com/mP0SLXgz71QAAAAj/peachcat-cat.gif',
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.error, size: 50, color: Colors.red),
        ),
      ),
    );
  }
}





class CampoEmail extends StatelessWidget {
  final TextEditingController _emailController;

  CampoEmail(this._emailController);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 40, right: 40, bottom: 10),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
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
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
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
      margin: EdgeInsets.only(top: 0, left: 40, right: 40, bottom: 10),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
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
        obscureText: true,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Contraseña',
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
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
        style: TextStyle(color: Colors.white),
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
      opacity: _opacity,
      duration: Duration(milliseconds: 500),
      child: Text(
        '¡Tu mejor amigo espera por ti!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

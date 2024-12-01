import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF50C2C9),
                  Color(0xFF0E5C61),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                'Menú Petify',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ZenKurenaido', // Fuente personalizada
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.pets, color: Color(0xFF50C2C9)),
            title: Text(
              'Agrega tu mascota',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'ZenKurenaido',
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.games, color: Color(0xFF50C2C9)),
            title: Text(
              'Juega con tu mascota',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'ZenKurenaido',
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/register_pet');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Color(0xFF50C2C9)),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'ZenKurenaido',
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      drawer: AppDrawer(),
      body: Center(
        child: Text('Esta es la pantalla de perfil'),
      ),
    );
  }
}

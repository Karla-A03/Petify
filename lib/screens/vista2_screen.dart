import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class Vista2Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vista 2')),
      drawer: AppDrawer(),
      body: Center(
        child: Text('Contenido de la Vista 2'),
      ),
    );
  }
}

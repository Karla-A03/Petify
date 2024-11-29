import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class Vista1Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vista 1')),
      drawer: AppDrawer(),
      body: Center(
        child: Text('Contenido de la Vista 1'),
      ),
    );
  }
}

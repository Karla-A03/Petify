import 'package:flutter/cupertino.dart';

class MascotaProvider with ChangeNotifier {
  int _alimentaciones = 0;

  int get alimentaciones => _alimentaciones;

  bool get mostrarMensajeAlimentacion => _alimentaciones >= 3;

  void alimentarMascota() {
    _alimentaciones++;
    notifyListeners();
  }

  void reiniciarAlimentaciones() {
    _alimentaciones = 0;
    notifyListeners();
  }
}
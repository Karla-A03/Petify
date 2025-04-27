import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart'; // Para el manejo de fechas
import 'package:timezone/timezone.dart' as tz; // Para manejo de zonas horarias
import 'package:timezone/data/latest.dart' as tz; // Cargar las zonas horarias

class ProgramarNotificacionScreen extends StatefulWidget {
  @override
  _ProgramarNotificacionScreenState createState() =>
      _ProgramarNotificacionScreenState();
}

class _ProgramarNotificacionScreenState
    extends State<ProgramarNotificacionScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _cuerpoController = TextEditingController();
  TimeOfDay? _horaSeleccionada;

  // Aquí se inicializa el servicio de notificaciones
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones(); // Inicializamos las zonas horarias sin esperar un valor de retorno

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Ícono de la notificación
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    tz.setLocalLocation(tz.getLocation('America/Chicago')); // Establecer la zona horaria local
  }

  // Función para programar la notificación
  Future<void> _programarNotificacion() async {
    if (_tituloController.text.isEmpty || _cuerpoController.text.isEmpty || _horaSeleccionada == null) {
      // Si falta algún dato, mostrar un error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor complete todos los campos")),
      );
      return;
    }

    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    // Convertir DateTime a TZDateTime
    tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    // Llamar a zonedScheduleNotification() con los datos proporcionados por el usuario
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      _tituloController.text,
      _cuerpoController.text,
      scheduledTZDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          importance: Importance.high,
          priority: Priority.high,
          onlyAlertOnce: true,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time, // Solo programamos por hora
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, // Definimos la interpretación de la hora
      androidScheduleMode: AndroidScheduleMode.exact, // Aquí se agrega el parámetro necesario
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notificación programada exitosamente")),
    );
  }

  // Función para elegir la hora
  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _horaSeleccionada)
      setState(() {
        _horaSeleccionada = picked;
      });
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // Inicializar las notificaciones
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Programar Notificación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00BCD4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Título',
              controller: _tituloController,
              hint: 'Introduce el título de la notificación...',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Cuerpo',
              controller: _cuerpoController,
              hint: 'Introduce el cuerpo de la notificación...',
            ),
            const SizedBox(height: 16),
            _buildTimePickerButton(),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _programarNotificacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Programar',
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

  Widget _buildTimePickerButton() {
    return TextButton(
      onPressed: () => _seleccionarHora(context),
      child: Text(
        _horaSeleccionada == null
            ? 'Seleccionar hora'
            : 'Hora seleccionada: ${_horaSeleccionada!.format(context)}',
        style: const TextStyle(
          color: Color(0xFF00BCD4),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

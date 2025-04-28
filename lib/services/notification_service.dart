import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart'; // Para formateo de fechas si es necesario

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicialización de la notificación
  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Ícono de la notificación
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Método para mostrar una notificación INSTANTÁNEA
  Future<void> showNotification(int id, String title, String body) async {
    await _flutterLocalNotificationsPlugin.show(
      id, // ID único de la notificación
      title, // Título de la notificación
      body, // Cuerpo de la notificación
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id', // ID del canal de notificación
          'your_channel_name', // Nombre del canal visible al usuario
          channelDescription:
              'your_channel_description', // Descripción del canal
          importance: Importance.high, // Importancia alta para que sea visible
          priority: Priority.high, // Prioridad alta para aparecer de inmediato
          ticker:
              'ticker', // Texto breve que se puede mostrar en la barra de estado
        ),
      ),
    );
  }

  // Método para PROGRAMAR una notificación en un horario específico
  Future<void> zonedScheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    // Convertir DateTime a TZDateTime
    tz.TZDateTime scheduledDateTime =
        tz.TZDateTime.from(scheduledDate, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id, // ID único de la notificación programada
      title, // Título de la notificación
      body, // Cuerpo de la notificación
      scheduledDateTime, // Fecha y hora programada
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id', // ID del canal de notificación
          'your_channel_name', // Nombre del canal visible al usuario
          channelDescription:
              'your_channel_description', // Descripción del canal
          importance: Importance.high, // Importancia alta
          priority: Priority.high, // Prioridad alta
          ticker: 'ticker',
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime, // Interpretar la fecha exacta
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // Permitir notificaciones aunque el dispositivo esté inactivo
    );
  }
}

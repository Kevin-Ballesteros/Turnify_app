// lib/services/notification_service.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Configuraciones globales (se pueden modificar desde la pantalla de config)
  bool enableVibration = true; // Cambiado a true por defecto
  bool enableSound = true;

  // Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    // Inicializa las zonas horarias
    tz.initializeTimeZones();

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicita permisos en Android 13+
    await _requestPermissions();
  }

  // Solicita permisos de notificación
  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Maneja cuando el usuario toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      print('Notificación tocada con payload: $payload');
      // Aquí puedes navegar a una pantalla específica
      // Por ejemplo: Navigator.push(...);
    }
  }

  // Muestra una notificación simple
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'turnify_channel',
      'Notificaciones Turnify',
      channelDescription: 'Notificaciones de turnos y recordatorios',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: enableVibration,
      playSound: enableSound,
      vibrationPattern: enableVibration ? Int64List.fromList([0, 500, 200, 500]) : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Programa una notificación para una fecha específica
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Verifica que la fecha sea futura
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('⚠️ La fecha de programación ya pasó, no se programará la notificación');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'turnify_scheduled_v3', // Cambiado a v3
      'Turnos Programados',
      channelDescription: 'Recordatorios de turnos programados',
      importance: Importance.high,
      priority: Priority.high,
      playSound: enableSound,
      vibrationPattern: enableVibration ? Int64List.fromList([0, 300]) : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('✅ Notificación programada para: $scheduledDate');
    } catch (e) {
      debugPrint('❌ Error al programar notificación: $e');
      rethrow;
    }
  }

  // Programa notificación de recordatorio de turno (X minutos antes)
  Future<void> scheduleAppointmentReminder({
    required int appointmentId,
    required String clientName,
    required String serviceName,
    required DateTime appointmentTime,
    int minutesBefore = 30,
  }) async {
    final reminderTime = appointmentTime.subtract(Duration(minutes: minutesBefore));
    
    // No programa si la fecha ya pasó
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    await scheduleNotification(
      id: appointmentId,
      title: '⏰ Recordatorio de turno',
      body: '$clientName tiene turno de $serviceName en $minutesBefore minutos',
      scheduledDate: reminderTime,
      payload: 'appointment_$appointmentId',
    );
  }

  // Notificación de turno confirmado
  Future<void> showAppointmentConfirmed({
    required int appointmentId,
    required String clientName,
    required String serviceName,
    required DateTime appointmentTime,
  }) async {
    final timeStr = '${appointmentTime.day}/${appointmentTime.month} a las ${appointmentTime.hour}:${appointmentTime.minute.toString().padLeft(2, '0')}';
    
    final androidDetails = AndroidNotificationDetails(
      'turnify_channel_v3', // Cambiado a v3
      'Notificaciones Turnify',
      channelDescription: 'Notificaciones de turnos y recordatorios',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: enableSound,
      vibrationPattern: enableVibration ? Int64List.fromList([0, 300]) : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      appointmentId,
      '✅ Turno confirmado',
      '$clientName - $serviceName el $timeStr',
      notificationDetails,
      payload: 'appointment_$appointmentId',
    );
  }

  // Notificación de turno cancelado
  Future<void> showAppointmentCancelled({
    required int appointmentId,
    required String clientName,
    required DateTime appointmentTime,
  }) async {
    final timeStr = '${appointmentTime.day}/${appointmentTime.month} a las ${appointmentTime.hour}:${appointmentTime.minute.toString().padLeft(2, '0')}';
    
    final androidDetails = AndroidNotificationDetails(
      'turnify_channel_v3', // Cambiado a v3
      'Notificaciones Turnify',
      channelDescription: 'Notificaciones de turnos y recordatorios',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: enableSound,
      vibrationPattern: enableVibration ? Int64List.fromList([0, 300]) : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      appointmentId + 10000,
      '❌ Turno cancelado',
      'El turno de $clientName del $timeStr ha sido cancelado',
      notificationDetails,
      payload: 'cancelled_$appointmentId',
    );
  }

  // Muestra notificación inmediata (alias de showNotification)
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'turnify_channel_v3', // Cambiado a v3
      'Notificaciones Turnify',
      channelDescription: 'Notificaciones de turnos y recordatorios',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: enableSound,
      vibrationPattern: enableVibration ? Int64List.fromList([0, 300]) : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Programa una notificación (alias de scheduleNotification)
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
  }

  // Programa una notificación diaria a una hora específica
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Si la hora ya pasó hoy, programa para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      'turnify_daily_v3', // Cambiado a v3
      'Recordatorios Diarios',
      channelDescription: 'Recordatorios diarios programados',
      importance: Importance.high,
      priority: Priority.high,
      playSound: enableSound,
      vibrationPattern: enableVibration ? Int64List.fromList([0, 300]) : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('✅ Recordatorio diario programado para las ${time.hour}:${time.minute}');
    } catch (e) {
      debugPrint('❌ Error al programar recordatorio diario: $e');
      rethrow;
    }
  }

  // Cancela una notificación específica
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  // Cancela una notificación específica (alias)
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Obtiene las notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
// lib/screens/pantalla_configuracion_notificaciones.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '/services/notification_service.dart';

class PantallaConfiguracionNotificaciones extends StatefulWidget {
  const PantallaConfiguracionNotificaciones({super.key});

  @override
  State<PantallaConfiguracionNotificaciones> createState() => _PantallaConfiguracionNotificacionesState();
}

class _PantallaConfiguracionNotificacionesState extends State<PantallaConfiguracionNotificaciones> {
  static const String _kRecordatoriosKey = 'prefs_recordatorios';
  static const String _kGeneralesKey = 'prefs_generales';
  static const String _kVibracionKey = 'prefs_vibracion';
  static const String _kAlertasKey = 'prefs_alertas';

  bool _recordatoriosActivos = true;
  bool _generalesActivas = true;
  bool _vibracionActiva = true; // Cambiado a true por defecto
  bool _alertasActivas = true;
  bool _permisoConcedido = false;

  static const int _idRecordatorioDiario = 1000;
  static const int _idTestImmediate = 1111;
  static const int _idTestDelayed = 1112;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoad();
  }

  Future<void> _checkPermissionAndLoad() async {
    await _checkNotificationPermission();
    await _loadPreferences();
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _permisoConcedido = status.isGranted;
    });
    debugPrint('📱 Estado del permiso de notificación: $status');
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recordatoriosActivos = prefs.getBool(_kRecordatoriosKey) ?? true;
      _generalesActivas = prefs.getBool(_kGeneralesKey) ?? true;
      _vibracionActiva = prefs.getBool(_kVibracionKey) ?? false;
      _alertasActivas = prefs.getBool(_kAlertasKey) ?? true;
    });

    // Sincroniza la configuración con el servicio de notificaciones
    NotificationService().enableVibration = _vibracionActiva;

    if (_recordatoriosActivos && _permisoConcedido) {
      await _scheduleDailyReminder();
    }
  }

  Future<void> _saveBoolPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> _requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.status;
    debugPrint('📱 Estado actual del permiso: $status');

    if (status.isGranted) {
      setState(() => _permisoConcedido = true);
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.notification.request();
      debugPrint('📱 Resultado de la solicitud: $result');

      if (result.isGranted) {
        setState(() => _permisoConcedido = true);
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      if (!mounted) return false;
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('⚙️ Permisos de notificación'),
          content: const Text(
            'Las notificaciones están bloqueadas permanentemente. '
            'Debes activarlas manualmente desde los ajustes del sistema.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Abrir Ajustes'),
            ),
          ],
        ),
      );

      if (shouldOpen == true) {
        await openAppSettings();
      }
      return false;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Permiso de notificación denegado')),
      );
    }
    return false;
  }

  Future<void> _onToggleRecordatorios(bool value) async {
    if (value) {
      final granted = await _requestNotificationPermission(context);
      if (!granted) {
        setState(() => _recordatoriosActivos = false);
        await _saveBoolPref(_kRecordatoriosKey, false);
        return;
      }

      setState(() => _recordatoriosActivos = true);
      await _saveBoolPref(_kRecordatoriosKey, true);
      await _scheduleDailyReminder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Recordatorios activados')),
        );
      }
    } else {
      setState(() => _recordatoriosActivos = false);
      await _saveBoolPref(_kRecordatoriosKey, false);
      await NotificationService().cancel(_idRecordatorioDiario);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🔕 Recordatorios desactivados')),
        );
      }
    }
  }

  Future<void> _scheduleDailyReminder() async {
    const TimeOfDay time = TimeOfDay(hour: 9, minute: 0);
    try {
      await NotificationService().scheduleDaily(
        id: _idRecordatorioDiario,
        title: '📅 Recordatorio diario',
        body: 'Revisa tus turnos del día en Turnify',
        time: time,
        payload: 'recordatorio_diario',
      );
      debugPrint('✅ Recordatorio diario programado para las 9:00 AM');
    } catch (e) {
      debugPrint('❌ Error al programar recordatorio: $e');
    }
  }

  Future<void> _onToggleGenerales(bool value) async {
    setState(() => _generalesActivas = value);
    await _saveBoolPref(_kGeneralesKey, value);
    final msg = value ? '✅ Notificaciones generales activadas' : '🔕 Notificaciones generales desactivadas';
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onToggleVibracion(bool value) async {
    setState(() => _vibracionActiva = value);
    await _saveBoolPref(_kVibracionKey, value);
    
    // Actualiza la configuración del servicio de notificaciones
    NotificationService().enableVibration = value;
    
    final msg = value ? '📳 Vibración activada' : '🔇 Vibración desactivada';
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onToggleAlertas(bool value) async {
    setState(() => _alertasActivas = value);
    await _saveBoolPref(_kAlertasKey, value);
    final msg = value ? '🚨 Alertas críticas activadas' : '🔕 Alertas críticas desactivadas';
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _sendTestNotifications() async {
    // Verificar permiso
    final granted = await _requestNotificationPermission(context);
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Permiso de notificación requerido')),
        );
      }
      return;
    }

    try {
      // Notificación inmediata
      await NotificationService().showImmediate(
        id: _idTestImmediate,
        title: '🔔 Prueba inmediata',
        body: 'Esta es una notificación de prueba instantánea',
        payload: 'test_immediate',
      );
      debugPrint('✅ Notificación inmediata enviada (ID: $_idTestImmediate)');

      // Notificación programada a 10 segundos
      final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
      await NotificationService().schedule(
        id: _idTestDelayed,
        title: '⏰ Prueba programada',
        body: 'Esta notificación fue programada para 10 segundos después',
        scheduledDate: scheduledTime,
        payload: 'test_scheduled',
      );
      debugPrint('✅ Notificación programada para 10 segundos (ID: $_idTestDelayed)');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Notificaciones de prueba enviadas\n🔔 Inmediata + ⏰ En 10 segundos'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al enviar notificaciones de prueba: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final headingColor = textTheme.titleLarge?.color ?? colorScheme.onBackground;
    final subtitleColor = colorScheme.onSurface.withOpacity(0.7);
    final dividerColor = colorScheme.surfaceVariant.withOpacity(0.6);
    final primary = const Color(0xFF4ECDC4);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notificaciones',
          style: textTheme.titleLarge?.copyWith(
            color: primary,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado del permiso
            if (!_permisoConcedido)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permisos desactivados',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Activa las notificaciones para recibir recordatorios',
                            style: TextStyle(color: subtitleColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Sección: Notificaciones Principales
            Text(
              'Notificaciones Principales',
              style: textTheme.titleMedium?.copyWith(
                color: headingColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: dividerColor, thickness: 1),
            const SizedBox(height: 8),

            _buildSwitchTile(
              context: context,
              icon: Icons.alarm,
              title: 'Recordatorios de Turnos',
              subtitle: 'Recibe notificaciones antes de cada turno',
              value: _recordatoriosActivos,
              onChanged: _onToggleRecordatorios,
              activeColor: primary,
            ),

            _buildSwitchTile(
              context: context,
              icon: Icons.notification_important,
              title: 'Alertas Críticas',
              subtitle: 'Cambios o cancelaciones en tus turnos',
              value: _alertasActivas,
              onChanged: _onToggleAlertas,
              activeColor: primary,
            ),

            _buildSwitchTile(
              context: context,
              icon: Icons.info_outline,
              title: 'Notificaciones Generales',
              subtitle: 'Noticias y actualizaciones de la app',
              value: _generalesActivas,
              onChanged: _onToggleGenerales,
              activeColor: primary,
            ),

            const SizedBox(height: 30),

            // Sección: Experiencia
            Text(
              'Experiencia de Aplicación',
              style: textTheme.titleMedium?.copyWith(
                color: headingColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: dividerColor, thickness: 1),
            const SizedBox(height: 8),

            _buildSwitchTile(
              context: context,
              icon: Icons.vibration,
              title: 'Vibración',
              subtitle: 'Vibrar al recibir notificaciones',
              value: _vibracionActiva,
              onChanged: _onToggleVibracion,
              activeColor: primary,
            ),

            const SizedBox(height: 30),

            // Sección: Pruebas
            Text(
              'Pruebas de Notificaciones',
              style: textTheme.titleMedium?.copyWith(
                color: headingColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: dividerColor, thickness: 1),
            const SizedBox(height: 16),

            // Botón de prueba principal
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _sendTestNotifications,
                icon: const Icon(Icons.notifications_active, size: 22),
                label: const Text(
                  'Enviar Notificaciones de Prueba',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Botón para cancelar pruebas
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await NotificationService().cancel(_idTestImmediate);
                  await NotificationService().cancel(_idTestDelayed);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🗑️ Notificaciones de prueba canceladas')),
                    );
                  }
                },
                icon: const Icon(Icons.clear, size: 20),
                label: const Text(
                  'Cancelar Pruebas Programadas',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDarkMode ? Colors.white70 : Colors.black87,
                  side: BorderSide(
                    color: isDarkMode ? Colors.white30 : Colors.black26,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? const Color(0xFF263238) 
                    : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Las notificaciones de prueba se envían inmediatamente y a los 10 segundos',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color activeColor,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF1E1E1E) 
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.1) 
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Icon(icon, color: activeColor, size: 28),
        title: Text(
          title,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      ),
    );
  }
}
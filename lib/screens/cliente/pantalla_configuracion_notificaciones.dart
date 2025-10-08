import 'package:flutter/material.dart';

// Colores de Turnify (Asumiendo que se usan en toda la app)
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
}

class PantallaConfiguracionNotificaciones extends StatefulWidget {
  const PantallaConfiguracionNotificaciones({super.key});

  @override
  State<PantallaConfiguracionNotificaciones> createState() => _PantallaConfiguracionNotificacionesState();
}

class _PantallaConfiguracionNotificacionesState extends State<PantallaConfiguracionNotificaciones> {
  // Variables de estado para las configuraciones
  bool _recordatoriosActivos = true;
  bool _generalesActivas = true;
  bool _vibracionActiva = false;
  bool _alertasActivas = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TurnifyColors.white,
      appBar: AppBar(
        backgroundColor: TurnifyColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: TurnifyColors.primaryTeal,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Configuración de Notificaciones',
          style: TextStyle(
            color: TurnifyColors.primaryTeal,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificaciones Principales',
              style: TextStyle(
                color: TurnifyColors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            
            // 1. Recordatorios de Turnos
            _buildSettingSwitch(
              title: 'Recordatorios de Turnos',
              subtitle: 'Recibe una notificación antes de que inicie tu turno.',
              value: _recordatoriosActivos,
              onChanged: (bool newValue) {
                setState(() {
                  _recordatoriosActivos = newValue;
                });
              },
            ),

            // 2. Alertas Urgentes
            _buildSettingSwitch(
              title: 'Alertas (Cambios/Cancelaciones)',
              subtitle: 'Notificaciones críticas sobre el estado de tus turnos.',
              value: _alertasActivas,
              onChanged: (bool newValue) {
                setState(() {
                  _alertasActivas = newValue;
                });
              },
            ),
            
            // 3. Notificaciones Generales
            _buildSettingSwitch(
              title: 'Notificaciones Generales',
              subtitle: 'Información sobre la aplicación, noticias o nuevas funciones.',
              value: _generalesActivas,
              onChanged: (bool newValue) {
                setState(() {
                  _generalesActivas = newValue;
                });
              },
            ),
            
            const SizedBox(height: 30),

            Text(
              'Experiencia de Aplicación',
              style: TextStyle(
                color: TurnifyColors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            
            // 4. Vibración
            _buildSettingSwitch(
              title: 'Vibración',
              subtitle: 'Vibrar el teléfono cuando llega una notificación (si está activa).',
              value: _vibracionActiva,
              onChanged: (bool newValue) {
                setState(() {
                  _vibracionActiva = newValue;
                });
              },
            ),

          ],
        ),
      ),
    );
  }
  
  // Widget auxiliar para crear los SwitchListTile de forma consistente
  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: TurnifyColors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: TurnifyColors.textGray,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: TurnifyColors.primaryTeal,
    );
  }
}
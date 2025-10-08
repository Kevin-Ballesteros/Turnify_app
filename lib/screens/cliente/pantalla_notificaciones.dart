import 'package:flutter/material.dart';
import 'pantalla_configuracion_notificaciones.dart';

// Colores de Turnify 
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color cardBackground = Color(0xFFF5F5F5);
}

class PantallaNotificaciones extends StatefulWidget {
  const PantallaNotificaciones({super.key});

  @override
  State<PantallaNotificaciones> createState() => _PantallaNotificacionesState();
}

class _PantallaNotificacionesState extends State<PantallaNotificaciones> {
  String filtroSeleccionado = 'Hoy'; // 'Hoy', 'Ayer', 'Todos'

  // Lista de notificaciones de ejemplo
  final List<Map<String, dynamic>> notificaciones = [
    {
      'titulo': 'Blanqueamiento Dental',
      'descripcion': 'Se programó un nuevo turno en tu agenda.',
      'tiempo': '2 M',
      'dia': 'Hoy',
    },
    {
      'titulo': 'Corte De Cabello',
      'descripcion': 'Se reprogramó un nuevo turno para tu agenda',
      'tiempo': '2 H',
      'dia': 'Hoy',
    },
    {
      'titulo': 'Notas Médicas',
      'descripcion': 'Se creó un nuevo turno para tu agenda.',
      'tiempo': '3 H',
      'dia': 'Hoy',
    },
    {
      'titulo': 'Cita Programada',
      'descripcion': 'Se programó un nuevo turno en tu agenda.',
      'tiempo': '1 D',
      'dia': 'Ayer',
    },
  ];

  List<Map<String, dynamic>> get notificacionesFiltradas {
    if (filtroSeleccionado == 'Todos') {
      // Ordenar para mostrar 'Hoy' primero
      notificaciones.sort((a, b) {
        if (a['dia'] == 'Hoy' && b['dia'] != 'Hoy') return -1;
        if (a['dia'] != 'Hoy' && b['dia'] == 'Hoy') return 1;
        return 0;
      });
      return notificaciones;
    }
    return notificaciones.where((n) => n['dia'] == filtroSeleccionado).toList();
  }

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
          'Notificaciones',
          style: TextStyle(
            color: TurnifyColors.primaryTeal,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        // ÍCONO DE CONFIGURACIÓN
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: TurnifyColors.primaryTeal,
            ),
            onPressed: () {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => const PantallaConfiguracionNotificaciones()),
              );
            },
          ),
          const SizedBox(width: 10), 
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align filters to start
        children: [
          const SizedBox(height: 20),
          
          // Filtros: Hoy y Todos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                _buildFilterButton('Hoy'),
                const SizedBox(width: 10),
                _buildFilterButton('Todos'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Lista de notificaciones
          Expanded(
            child: notificacionesFiltradas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay notificaciones',
                      style: TextStyle(
                        color: TurnifyColors.lightGray,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: notificacionesFiltradas.length,
                    itemBuilder: (context, index) {
                      final notif = notificacionesFiltradas[index];
                      
                      // Lógica para mostrar separador "Ayer"
                      bool mostrarSeparadorAyer = false;
                      if (filtroSeleccionado == 'Todos' && index > 0) {
                        // Si la notificación anterior era 'Hoy' y esta es 'Ayer'
                        if (notificacionesFiltradas[index - 1]['dia'] == 'Hoy' &&
                            notif['dia'] == 'Ayer') {
                          mostrarSeparadorAyer = true;
                        }
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align the separator title
                        children: [
                          // Separador "Ayer"
                          if (mostrarSeparadorAyer) ...[
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Ayer',
                                style: TextStyle(
                                  color: TurnifyColors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          
                          // Card de notificación
                          _buildNotificationCard(
                            titulo: notif['titulo'],
                            descripcion: notif['descripcion'],
                            tiempo: notif['tiempo'],
                          ),
                          
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String texto) {
    final bool isSelected = filtroSeleccionado == texto;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          filtroSeleccionado = texto;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? TurnifyColors.lightTeal.withOpacity(0.3) : TurnifyColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: isSelected ? TurnifyColors.primaryTeal : TurnifyColors.lightGray,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String titulo,
    required String descripcion,
    required String tiempo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TurnifyColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icono de calendario
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: TurnifyColors.primaryTeal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: TurnifyColors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          
          // Contenido de la notificación
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: TurnifyColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      tiempo,
                      style: TextStyle(
                        color: TurnifyColors.lightGray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: TextStyle(
                    color: TurnifyColors.textGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
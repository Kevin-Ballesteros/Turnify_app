import 'package:flutter/material.dart';
import 'pantalla_reagendar_turnos.dart';

// Colores de Turnify (valores base, se accede vía la extensión)
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color cardBackground = Color(0xFFF5F5F5);
}

/// Helper immutable que contiene la paleta derivada del Theme
class _TurnifyColors {
  final bool isDark;
  const _TurnifyColors(this.isDark);

  Color get primaryTeal => const Color.fromARGB(255, 67, 188, 180);
  Color get lightTeal => isDark ? const Color.fromARGB(255, 60, 150, 145) : const Color.fromARGB(255, 149, 214, 211);

  Color get textGray => isDark ? Colors.grey.shade300 : const Color(0xFF666666);
  Color get lightGray => isDark ? Colors.grey.shade400 : const Color(0xFF999999);

  Color get white => isDark ? const Color(0xFF0B0B0B) : Colors.white;
  Color get black => isDark ? Colors.white : const Color(0xFF333333);

  Color get cardBackground => isDark ? const Color.fromARGB(255, 20, 20, 20) : const Color(0xFFF5F5F5);
}

/// Extensión que expone la instancia vía context.turnify
extension TurnifyExtension on BuildContext {
  _TurnifyColors get turnify => _TurnifyColors(Theme.of(this).brightness == Brightness.dark);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class PantallaMisTurnos extends StatefulWidget {
  const PantallaMisTurnos({super.key});

  @override
  State<PantallaMisTurnos> createState() => _PantallaMisTurnosState();
}

class _PantallaMisTurnosState extends State<PantallaMisTurnos> {
  // Filtro seleccionado
  String filtroSeleccionado = 'Próximos';

  // Lista de turnos de ejemplo
  final List<Map<String, dynamic>> turnos = [
    {
      'negocio': 'Barbería El Estilo',
      'tipo': 'Barbería',
      'estado': 'Próximos',
      'servicio': 'Corte de Pelo',
      'fecha': 'Sábado, 24 de Agosto 2024',
      'hora': '10:00 AM',
      'duracion': '30 min',
      'precio': '25\$',
      'ubicacion': 'Calle Principal 123',
    },
    {
      'negocio': 'Consultorio Odontológico',
      'tipo': 'Consultorio Luna',
      'estado': 'Próximos',
      'servicio': 'Limpieza Bucal',
      'fecha': 'Lunes, 26 de Agosto 2024',
      'hora': '3:00 PM',
      'duracion': '45 min',
      'precio': '50\$',
      'ubicacion': 'Avenida Central 456',
    },
    {
      'negocio': 'Veterinaria San Martin',
      'tipo': 'Veterinario',
      'estado': 'Próximos',
      'servicio': 'Consulta General',
      'fecha': 'Miércoles, 28 de Agosto 2024',
      'hora': '11:30 AM',
      'duracion': '30 min',
      'precio': '48\$',
      'ubicacion': 'Plaza Mayor 789',
    },
    {
      'negocio': 'Spa Relax Total',
      'tipo': 'Spa',
      'estado': 'Completados',
      'servicio': 'Masaje Relajante',
      'fecha': 'Jueves, 15 de Agosto 2024',
      'hora': '2:00 PM',
      'duracion': '60 min',
      'precio': '60\$',
      'ubicacion': 'Calle Spa 101',
    },
    {
      'negocio': 'Peluquería Estilo',
      'tipo': 'Peluquería',
      'estado': 'Cancelados',
      'servicio': 'Tinte de Cabello',
      'fecha': 'Martes, 20 de Agosto 2024',
      'hora': '4:00 PM',
      'duracion': '90 min',
      'precio': '45\$',
      'ubicacion': 'Avenida Belleza 202',
    },
  ];

  List<Map<String, dynamic>> get turnosFiltrados {
    return turnos.where((t) => t['estado'] == filtroSeleccionado).toList();
  }

  int get cantidadProximos => turnos.where((t) => t['estado'] == 'Próximos').length;
  int get cantidadCompletados => turnos.where((t) => t['estado'] == 'Completados').length;
  int get cantidadCancelados => turnos.where((t) => t['estado'] == 'Cancelados').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TurnifyExtension(context).turnify.cardBackground,
      appBar: AppBar(
        backgroundColor: TurnifyExtension(context).turnify.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Mis Turnos',
          style: TextStyle(
            color: TurnifyExtension(context).turnify.primaryTeal,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Subtítulo
          Container(
            width: double.infinity,
            color: TurnifyExtension(context).turnify.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              'Gestiona todas tus reservas',
              style: TextStyle(
                color: TurnifyExtension(context).turnify.lightGray,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Filtros de estado
          Container(
            color: TurnifyExtension(context).turnify.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('Próximos', cantidadProximos),
                _buildFilterChip('Completados', cantidadCompletados),
                _buildFilterChip('Cancelados', cantidadCancelados),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista de turnos
          Expanded(
            child: turnosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: TurnifyExtension(context).turnify.lightGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes turnos $filtroSeleccionado',
                          style: TextStyle(
                            color: TurnifyExtension(context).turnify.lightGray,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: turnosFiltrados.length,
                    itemBuilder: (context, index) {
                      final turno = turnosFiltrados[index];
                      return _buildTurnoCard(turno);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int cantidad) {
    final bool isSelected = filtroSeleccionado == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          filtroSeleccionado = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? TurnifyExtension(context).turnify.primaryTeal : TurnifyExtension(context).turnify.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              '$cantidad',
              style: TextStyle(
                color: isSelected ? Colors.white : TurnifyExtension(context).turnify.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : TurnifyExtension(context).turnify.textGray,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnoCard(Map<String, dynamic> turno) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TurnifyExtension(context).turnify.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TurnifyExtension(context).isDark ? const Color.fromARGB(255, 28, 28, 28).withOpacity(0.6) : const Color.fromARGB(255, 28, 28, 28).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con nombre y menú
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TurnifyExtension(context).turnify.primaryTeal.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business,
                  color: TurnifyExtension(context).turnify.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turno['negocio'],
                      style: TextStyle(
                        color: TurnifyExtension(context).turnify.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: TurnifyExtension(context).turnify.primaryTeal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          turno['tipo'],
                          style: TextStyle(
                            color: TurnifyExtension(context).turnify.primaryTeal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: TurnifyExtension(context).turnify.lightGray),
                onPressed: () {
                  _mostrarOpciones(context, turno);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: TurnifyExtension(context).turnify.cardBackground),
          const SizedBox(height: 12),

          // Información del turno
          _buildInfoRow('Servicio:', turno['servicio']),
          const SizedBox(height: 8),
          _buildInfoRow('Fecha:', turno['fecha']),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Hora:', turno['hora'])),
              Expanded(child: _buildInfoRow('Duración:', turno['duracion'])),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Precio:', turno['precio']),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: TurnifyExtension(context).turnify.textGray),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  turno['ubicacion'],
                  style: TextStyle(
                    color: TurnifyExtension(context).turnify.textGray,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botones de acción
          if (turno['estado'] == 'Próximos') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                   onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReagendarTurnoScreen(turno: turno),
                        ),
                      );
                    },
                    icon: Icon(Icons.refresh, size: 18, color: TurnifyExtension(context).turnify.primaryTeal),
                    label: Text('Reprogramar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TurnifyExtension(context).turnify.primaryTeal,
                      side: BorderSide(color: TurnifyExtension(context).turnify.primaryTeal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _confirmarCancelacion(context, turno);
                    },
                    icon: Icon(Icons.cancel_outlined, size: 18, color: Colors.red),
                    label: Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: TurnifyExtension(context).turnify.textGray,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: TurnifyExtension(context).turnify.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _mostrarOpciones(BuildContext context, Map<String, dynamic> turno) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          color: TurnifyExtension(context).turnify.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                turno['negocio'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: TurnifyExtension(context).turnify.black,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.info_outline, color: TurnifyExtension(context).turnify.primaryTeal),
                title: Text('Ver detalles', style: TextStyle(color: TurnifyExtension(context).turnify.black)),
                onTap: () {
                  Navigator.pop(context);
                  print('Ver detalles del turno');
                },
              ),
              if (turno['estado'] == 'Próximos') ...[
                ListTile(
                  leading: Icon(Icons.refresh, color: TurnifyExtension(context).turnify.primaryTeal),
                  title: Text('Reprogramar', style: TextStyle(color: TurnifyExtension(context).turnify.black)),
                  onTap: () {
                    Navigator.pop(context);
                    print('Reprogramar turno');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: Text('Cancelar turno', style: TextStyle(color: TurnifyExtension(context).turnify.black)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmarCancelacion(context, turno);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _confirmarCancelacion(BuildContext context, Map<String, dynamic> turno) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TurnifyExtension(context).turnify.white,
          title: Text('¿Cancelar turno?', style: TextStyle(color: TurnifyExtension(context).turnify.black)),
          content: Text(
            '¿Estás seguro de que deseas cancelar tu turno en ${turno['negocio']}?',
            style: TextStyle(color: TurnifyExtension(context).turnify.textGray),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No', style: TextStyle(color: TurnifyExtension(context).turnify.lightGray)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  turno['estado'] = 'Cancelados';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Turno cancelado exitosamente'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}

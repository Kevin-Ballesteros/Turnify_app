// lib/screens/Pantalla_mis_turnos.dart
import 'dart:async'; // ¡Importante para el Timer!
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/turnos_provider.dart';
import 'pantalla_cancelar_turnos.dart';
import 'pantalla_detalles_turnos.dart';


// Se asumen estas clases Placeholder para que el código compile si no las tienes
class ReagendarTurnoScreen extends StatelessWidget {
  final Map<String, dynamic> turno;
  const ReagendarTurnoScreen({super.key, required this.turno});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Reagendar Turno')), body: Center(child: Text('Pantalla de Reagendar para ${turno['negocio']}')));
}
class PantallaVerDetalles extends StatelessWidget {
  final Map<String, dynamic> turno;
  const PantallaVerDetalles({super.key, required this.turno});
  @override
  // Esta es la implementación que te lleva a la pantalla de detalles
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Detalles de ${turno['negocio']}')), body: Center(child: Text('Pantalla de Detalles para ${turno['negocio']}')));
}

class PantallaMisTurnos extends StatefulWidget {
  const PantallaMisTurnos({Key? key}) : super(key: key);

  @override
  State<PantallaMisTurnos> createState() => _PantallaMisTurnosState();
}

class _PantallaMisTurnosState extends State<PantallaMisTurnos> with TickerProviderStateMixin {
  int _activeIndex = 0;
  bool _loading = false;
  
  // 1. Declarar el Timer
  Timer? _timer; 

  @override
  void initState() {
    super.initState();
    _maybeLoadSample();
    // 2. Inicializar el Timer para el contador en tiempo real
    _startTimer();
  }

  BusinessData _mapTurnoToBusinessData(Map<String, dynamic> turno) {
  // Los datos del turno solo tienen la información del negocio y el servicio reservado.
  // Aquí simulamos los datos completos que necesita PantallaDetallesTurno.
  
  final servicioReservado = {
    'name': turno['servicio'] ?? 'Servicio Desconocido',
    'description': 'Duración: ${turno['duracion'] ?? 30} min.',
    'duration': turno['duracion'] ?? 30, // en minutos
    'price': turno['precio'] ?? 0,
  };

  return BusinessData(
    name: turno['negocio'] ?? 'Negocio Desconocido',
    category: 'Cita Reservada', // Categoría genérica
    rating: 4.5, // Rating simulado
    address: turno['direccion'] ?? 'Dirección no disponible',
    description: 'Este es el detalle del negocio asociado al turno reservado. Aquí iría la descripción completa del negocio, simulada a partir de los datos del turno.',
    // Solo mostramos el servicio reservado como la lista de servicios del negocio
    services: [servicioReservado], 
  );
}
  // 3. Crear la función para iniciar el Timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        // Llama a setState para recalcular las listas 'proximos' y 'completados'
        setState(() {});
      }
    });
  }

  void _abrirDetallesDesdeTarjeta(Map<String, dynamic> turno) {
  final businessData = _mapTurnoToBusinessData(turno);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PantallaDetallesTurno(business: businessData),
    ),
  );
}

  @override
  void dispose() {
    // 4. Cancelar el Timer en dispose
    _timer?.cancel(); 
    super.dispose();
  }

  Future<void> _maybeLoadSample() async {
    final prov = Provider.of<TurnosProvider>(context, listen: false);
    if (prov.activos.isEmpty && prov.cancelados.isEmpty) {
      setState(() => _loading = true);
      await Future.delayed(const Duration(milliseconds: 250));
      final now = DateTime.now();
      final sample = <Map<String, dynamic>>[
        {'id':'t1','negocio':'Barbería El Estilo','servicio':'Corte de Pelo','startAt': now.add(const Duration(days:3, hours:2)).toUtc().toIso8601String(),'duracion':30,'precio':255,'direccion':'Calle Principal 123','cancelado':false},
        {'id':'t2','negocio':'Consultorio Odontológico','servicio':'Limpieza Bucal','startAt': now.add(const Duration(days:5, hours:6)).toUtc().toIso8601String(),'duracion':45,'precio':350,'direccion':'Avenida Central 456','cancelado':false},
        {'id':'t3','negocio':'Veterinaria San Martín','servicio':'Consulta General','startAt': now.add(const Duration(days:7)).toUtc().toIso8601String(),'duracion':40,'precio':400,'direccion':'Plaza Mayor 789','cancelado':false},
        {'id':'c1','negocio':'Spa Dental Centro','servicio':'Blanqueamiento','startAt': now.subtract(const Duration(days:6)).toUtc().toIso8601String(),'duracion':60,'precio':1200,'direccion':'Calle 8 #45','cancelado':false},
        {'id':'c2','negocio':'Clínica Salud','servicio':'Consulta General','startAt': now.subtract(const Duration(days:4)).toUtc().toIso8601String(),'duracion':30,'precio':200,'direccion':'Av. Salud 12','cancelado':false},
        {'id':'x1','negocio':'Centro Óptico','servicio':'Revisión Oftalmológica','startAt': now.add(const Duration(days:2)).toUtc().toIso8601String(),'duracion':30,'precio':150,'direccion':'Av Ojo 77','cancelado':true},
      ];

      final activos = sample.where((s) {
        final d = DateTime.tryParse(s['startAt'] ?? '')?.toLocal();
        return s['cancelado'] != true && d != null && d.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      }).toList();

      final completados = sample.where((s) {
        final d = DateTime.tryParse(s['startAt'] ?? '')?.toLocal();
        return s['cancelado'] != true && d != null && d.isBefore(DateTime.now());
      }).toList();

      final cancelados = sample.where((s) => s['cancelado'] == true).toList();

      final provRef = Provider.of<TurnosProvider>(context, listen: false);
      provRef.setTurnos(activos);
      for (final c in completados) provRef.actualizarTurno(c);
      for (final x in cancelados) provRef.moverACancelados(x);

      if (mounted) setState(() => _loading = false);
    }
  }

  // Lógica de reagendar: ya incluye el setState para actualizar inmediatamente
  Future<void> _abrirReagendar(Map<String, dynamic> turno) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => ReagendarTurnoScreen(turno: turno)),
    );
    if (result == null) return;
    final provider = Provider.of<TurnosProvider>(context, listen: false);

    if (result['rescheduled'] == true && result['turno'] is Map<String, dynamic>) {
      provider.actualizarTurno(Map<String, dynamic>.from(result['turno']));
      setState(() {
        _activeIndex = 0; 
      });
      
    } else if (result['cancelled'] == true && result['turno'] is Map<String, dynamic>) {
      provider.moverACancelados(Map<String, dynamic>.from(result['turno']));
      setState(() {
        _activeIndex = 2; 
      });
    }
  }

  // Lógica de cancelar: ya incluye el setState para actualizar inmediatamente
  Future<void> _abrirCancelar(Map<String, dynamic> turno) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => PantallaCancelarTurno(turno: turno)),
    );
    if (result == null) return;
    final provider = Provider.of<TurnosProvider>(context, listen: false);
    
    // Si la cancelación fue exitosa y trae el turno
    if (result['cancelled'] == true && result['turno'] is Map<String, dynamic>) {
      provider.moverACancelados(Map<String, dynamic>.from(result['turno']));
      
      setState(() {
        _activeIndex = 2; // Mueve al usuario a la pestaña "Cancelados"
      });
    } else if (result['rescheduled'] == true && result['turno'] is Map<String, dynamic>) {
      provider.actualizarTurno(Map<String, dynamic>.from(result['turno']));
    }
  }

  Widget _tabPill(String label, int count, int index, Color accent) {
    final theme = Theme.of(context);
    final selected = _activeIndex == index;
    final textColor = selected ? accent : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.85);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeIndex = index),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: textColor, fontWeight: selected ? FontWeight.w700 : FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: selected ? accent : Theme.of(context).dividerColor.withOpacity(0.06), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('$count', style: TextStyle(color: selected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 4),
        ]),
      ),
    );
  }

Widget _cardTurno(Map<String, dynamic> turno, {bool showActions = true}) {
    final theme = Theme.of(context);
    final accent = const Color(0xFF4ECDC4);
    final startAt = _parseStartAt(turno);
    final fecha = startAt != null ? _formatFullDate(startAt) : (turno['fecha'] ?? '');
    final hora = startAt != null ? _formatTimeLabel(startAt) : (turno['hora'] ?? '');
    final estado = _calcularEstado(turno, startAt);

    // *** 1. ENVOLVEMOS EL CARD EN UN GESTUREDETECTOR ***
    return GestureDetector(
      onTap: () => _abrirDetallesDesdeTarjeta(turno), // <-- Llamamos a la nueva función aquí
      child: Card(
        color: theme.cardColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.dividerColor)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(turno['negocio'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: theme.textTheme.titleLarge?.color))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: _estadoColor(estado).withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Text(estado, style: TextStyle(color: _estadoColor(estado), fontWeight: FontWeight.w700, fontSize: 12))),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                onSelected: (v) async {
                  // Eliminamos la navegación a "Ver Detalles" del PopUp, ya que ahora va en el onTap del Card.
                  // if (v == 'details') Navigator.of(context).push(MaterialPageRoute(builder: (_) => PantallaVerDetalles(turno: turno)));
                  if (v == 'cancel') await _abrirCancelar(turno);
                },
                itemBuilder: (_) => const [ 
                  // Si quieres mantener "Ver detalles" en el PopUp, descomenta la línea de abajo y borra la línea que la precede.
                  // PopupMenuItem(value: 'details', child: Text('Ver detalles')), 
                  PopupMenuItem(value: 'cancel', child: Text('Cancelar')), 
                ],
              ),
            ]),
            const SizedBox(height: 8),
            Text(turno['servicio'] ?? '', style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.calendar_today, size: 14, color: theme.iconTheme.color),
              const SizedBox(width: 6),
              Flexible(child: Text(fecha, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85)))),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 14, color: theme.iconTheme.color),
              const SizedBox(width: 6),
              Text(hora, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.timer, size: 14, color: theme.iconTheme.color),
              const SizedBox(width: 6),
              Text('${turno['duracion']?.toString() ?? '30'} mins', style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85))),
              const SizedBox(width: 12),
              Icon(Icons.attach_money, size: 14, color: theme.iconTheme.color),
              const SizedBox(width: 6),
              Text('${turno['precio']?.toString() ?? ''}', style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85))),
            ]),
            const SizedBox(height: 8),
            if ((turno['direccion'] ?? '').toString().isNotEmpty) Row(children: [
              Icon(Icons.location_on, size: 14, color: theme.iconTheme.color),
              const SizedBox(width: 6),
              Flexible(child: Text(turno['direccion'] ?? '', style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85)))),
            ]),
            if (showActions) const SizedBox(height: 12),
            if (showActions) Row(children: [
              OutlinedButton(onPressed: () => _abrirReagendar(turno), style: OutlinedButton.styleFrom(side: BorderSide(color: accent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Reprogramar', style: TextStyle(color: accent))),
              const SizedBox(width: 10),
              OutlinedButton(onPressed: () => _abrirCancelar(turno), style: OutlinedButton.styleFrom(side: BorderSide(color: theme.dividerColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Cancelar', style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9)))),
            ]),
          ]),
        ),
      ),
    );
  }

  // Helpers (Sin cambios)
  String _calcularEstado(Map<String, dynamic> turno, DateTime? startAt) {
    final cancelled = turno['cancelado'] == true || turno['cancelled'] == true;
    if (cancelled) return 'Cancelado';
    if (startAt == null) return 'Programado';
    final now = DateTime.now();
    final duration = _parseDurationMinutes(turno);
    final end = startAt.add(Duration(minutes: duration));
    if (now.isAfter(end)) return 'Completado';
    final diff = startAt.difference(now);
    if (!diff.isNegative && diff.inHours < 24) return 'Próximo';
    if (_isSameDate(startAt, now)) return 'Hoy';
    return 'Programado';
  }

  Color _estadoColor(String label) {
    switch (label) {
      case 'Cancelado': return Colors.red;
      case 'Completado': return Colors.grey;
      case 'Próximo':
      case 'Hoy': return const Color(0xFF4ECDC4);
      default: return Colors.blueGrey;
    }
  }

  DateTime? _parseStartAt(Map<String, dynamic> turno) {
    final sa = turno['startAt'];
    if (sa is String) {
      try { final dt = DateTime.tryParse(sa); if (dt != null) return dt.toLocal(); } catch (_) {}
    }
    final fecha = turno['fecha']; final hora = turno['hora'];
    if (fecha is String && hora is String && fecha.isNotEmpty && hora.isNotEmpty) {
      try {
        final parts = fecha.split('-');
        if (parts.length == 3) {
          final y = int.parse(parts[0]); final m = int.parse(parts[1]); final d = int.parse(parts[2]);
          final hm = hora.split(':'); final hh = int.parse(hm[0]); final mm = int.parse(hm[1]);
          return DateTime(y, m, d, hh, mm);
        }
      } catch (_) {}
    }
    return null;
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  int _parseDurationMinutes(Map<String, dynamic> turno) {
    final d = turno['duracion'] ?? turno['duration'] ?? '';
    if (d is int) return d;
    if (d is String) {
      final m = RegExp(r'(\d+)').firstMatch(d);
      if (m != null) return int.tryParse(m.group(1)!) ?? 30;
    }
    return 30;
  }

  String _formatFullDate(DateTime d) {
    final weekday = ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb'][d.weekday % 7];
    final month = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'][d.month - 1];
    return '$weekday, ${d.day} de $month ${d.year}';
  }

  String _formatTimeLabel(DateTime d) {
    final h = d.hour; final m = d.minute.toString().padLeft(2,'0');
    final hh = h % 12 == 0 ? 12 : h % 12; final ampm = h >= 12 ? 'PM' : 'AM';
    return '$hh:$m $ampm';
  }

  Widget _emptyState(String text) => Center(child: Text(text, style: const TextStyle(color: Colors.grey)));

  @override
  Widget build(BuildContext context) {
    // Estas listas se recalculan cada vez que el Timer llama a setState o el Provider llama a notifyListeners()
    final provider = Provider.of<TurnosProvider>(context);
    final activos = provider.activos;
    final cancelados = provider.cancelados;

    // Calculamos los completados y próximos basados en la hora actual
    final completados = activos.where((t) {
      try {
        final dt = _parseStartAt(t);
        final duration = _parseDurationMinutes(t);
        // Es completado si la hora de fin ya pasó
        return dt != null && dt.add(Duration(minutes: duration)).isBefore(DateTime.now());
      } catch (_) { return false; }
    }).toList();

    final proximos = activos.where((t) {
      try {
        final dt = _parseStartAt(t);
        final duration = _parseDurationMinutes(t);
        // Es próximo si la hora de fin aún no ha pasado
        return dt != null && dt.add(Duration(minutes: duration)).isAfter(DateTime.now());
      } catch (_) { return true; }
    }).toList();

    final theme = Theme.of(context);
    final accent = const Color(0xFF4ECDC4);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Mis Turnos', style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Column(children: [
            const SizedBox(height: 6),
            // LayoutBuilder used to measure available width and place underline exactly centered
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final sectionWidth = totalWidth / 3.0; // 3 tabs with some spacing
                  final indicatorWidth = 66.0;
                  final leftForIndex = (sectionWidth * _activeIndex) + (sectionWidth - indicatorWidth) / 2;
                  return Column(
                    children: [
                      Row(children: [
                        _tabPill('Próximos', proximos.length, 0, accent),
                        _tabPill('Completados', completados.length, 1, accent),
                        _tabPill('Cancelados', cancelados.length, 2, accent),
                      ]),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 6,
                        child: Stack(children: [
                          Positioned.fill(child: Container()), // spacing layer
                          AnimatedPositioned(
                            left: leftForIndex,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: Container(width: indicatorWidth, height: 4, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6))),
                          ),
                        ]),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 2),
            const Divider(height: 1, thickness: 1),
          ]),
        ),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : IndexedStack(
        index: _activeIndex,
        children: [
          proximos.isEmpty ? _emptyState('No tienes turnos próximos') : RefreshIndicator(
            onRefresh: () async { await _maybeLoadSample(); },
            child: ListView.builder(padding: const EdgeInsets.only(top: 12, bottom: 24), itemCount: proximos.length, itemBuilder: (_, i) => _cardTurno(proximos[i], showActions: true)),
          ),
          completados.isEmpty ? _emptyState('No tienes turnos completados') : ListView.builder(padding: const EdgeInsets.only(top: 12, bottom: 24), itemCount: completados.length, itemBuilder: (_, i) => _cardTurno(completados[i], showActions: false)),
          cancelados.isEmpty ? _emptyState('No hay turnos cancelados') : ListView.builder(padding: const EdgeInsets.only(top: 12, bottom: 24), itemCount: cancelados.length, itemBuilder: (_, i) => _cardTurno(cancelados[i], showActions: false)),
        ],
      ),
    );
  }
}
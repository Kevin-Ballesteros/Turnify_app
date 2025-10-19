// lib/screens/pantalla_cancelar_turnos.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Asumo la existencia de esta pantalla, aunque no está definida en el código proporcionado
class Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Reagendar Turno')), body: Center(child: Text('Pantalla de Reagendar')));
  }
}

class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color danger = Color(0xFFD9534F);
}

class _TurnifyColors {
  final bool isDark;
  const _TurnifyColors(this.isDark);
  Color get primaryTeal => TurnifyColors.primaryTeal;
  Color get danger => TurnifyColors.danger;
  Color get textGray => isDark ? Colors.grey.shade300 : const Color(0xFF666666);
  Color get white => isDark ? const Color(0xFF0B0B0B) : Colors.white;
  Color get black => isDark ? Colors.white : const Color(0xFF141414);
  Color get surface => isDark ? const Color(0xFF121212) : Colors.white;
  Color get cardBackground => isDark ? const Color(0xFF0E0F10) : const Color(0xFFF5F5F5);
}


extension TurnifyExt on BuildContext {
  _TurnifyColors get turnify => _TurnifyColors(Theme.of(this).brightness == Brightness.dark);
}
class PantallaCancelarTurno extends StatefulWidget {
  final Map<String, dynamic> turno;
  const PantallaCancelarTurno({super.key, required this.turno});

  @override
  State<PantallaCancelarTurno> createState() => _PantallaCancelarTurnoState();
}

class _PantallaCancelarTurnoState extends State<PantallaCancelarTurno> {
  final List<String> _motivos = [
    'Cambio de estilo o motivo principal',
    'Encontré otro lugar más económico',
    'Encontré otro lugar más cercano',
    'No me atendieron bien por esta app',
    'El establecimiento no respondió',
    'El establecimiento canceló mi cita sin avisarme',
    'El establecimiento no está disponible',
    'No quiero decirlo',
    'Otro',
  ];

  String? _motivoSeleccionado;
  String _otroTexto = '';
  final TextEditingController _comentariosController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

  DateTime? _parseFechaHoraFromTurno() {
    final fecha = widget.turno['fecha'];
    final hora = widget.turno['hora'];
    if (fecha is String && hora is String) {
      try {
        final parts = fecha.split('-');
        if (parts.length == 3) {
          final y = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final d = int.parse(parts[2]);
          final hm = hora.split(':');
          if (hm.length >= 2) {
            final hh = int.parse(hm[0]);
            final mm = int.parse(hm[1]);
            return DateTime(y, m, d, hh, mm);
          }
        }
      } catch (_) {}
    }
    final startAt = widget.turno['startAt'];
    if (startAt is String) {
      final dt = DateTime.tryParse(startAt);
      if (dt != null) return dt.toLocal();
    }
    return null;
  }

  String _formatFullDate(DateTime d) {
    final weekday = ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb'][d.weekday % 7];
    final month = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'][d.month-1];
    return '$weekday, ${d.day} de $month ${d.year}';
  }

  String _formatTimeLabel(DateTime d) {
    final h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final hh = h % 12 == 0 ? 12 : h % 12;
    final ampm = h >= 12 ? 'PM' : 'AM';
    return '$hh:$m $ampm';
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  // *** FUNCIÓN MODIFICADA PARA DEVOLVER EL TURNO COMPLETO ***
  Future<void> _confirmCancel() async {
    if (_motivoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un motivo de cancelación'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _loading = true);
    // Simulación de la cancelación en el servidor
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _loading = false);

    final motivo = _motivoSeleccionado == 'Otro' ? _otroTexto.trim() : _motivoSeleccionado!;
    _comentariosController.text.trim();

    // 1. Clonar el turno actual y marcarlo como cancelado
    final Map<String, dynamic> turnoCancelado = Map.from(widget.turno);
    turnoCancelado['cancelado'] = true; 
    turnoCancelado['motivoCancelacion'] = motivo;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Turno cancelado • Motivo: $motivo'), backgroundColor: Colors.green));
      
      // 2. Devolver el turno cancelado al PantallaMisTurnos
      Navigator.of(context).pop({
        'cancelled': true, 
        'turno': turnoCancelado, // Clave que espera PantallaMisTurnos
      });
    }
  }

  void _mantenerCita() => Navigator.of(context).pop({'cancelled': false});

  void _irAReagendar() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Placeholder()));
  }

  Widget _buildResumenTurno(BuildContext context, _TurnifyColors t) {
    final negocio = widget.turno['negocio'] ?? '';
    final servicio = widget.turno['servicio'] ?? '';
    final descripcion = widget.turno['descripcion'] ?? '';
    final duracion = widget.turno['duracion'] ?? widget.turno['duration'] ?? '';
    final precio = widget.turno['precio'] ?? widget.turno['price'] ?? '';
    final ubicacion = widget.turno['ubicacion'] ?? '';
    final telefono = (widget.turno['telefono'] ?? '').toString().trim();
    final dt = _parseFechaHoraFromTurno();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.storefront, color: t.textGray),
          const SizedBox(width: 8),
          Expanded(child: Text(negocio, style: TextStyle(fontWeight: FontWeight.w800, color: t.black))),
          if (precio.toString().isNotEmpty)
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: t.cardBackground, borderRadius: BorderRadius.circular(8)), child: Text('\$ $precio', style: TextStyle(color: t.primaryTeal, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 10),
        Text(servicio, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.black)),
        if ((descripcion as String).isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(descripcion, style: TextStyle(color: t.textGray)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.access_time, color: t.textGray, size: 16),
          const SizedBox(width: 8),
          Text(duracion.toString().isNotEmpty ? duracion.toString() : '—', style: TextStyle(color: t.textGray)),
          const SizedBox(width: 12),
          Icon(Icons.location_on, color: t.textGray, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(ubicacion.toString().isNotEmpty ? ubicacion.toString() : 'Ubicación no disponible', style: TextStyle(color: t.textGray))),
        ]),
        if (telefono.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.phone, color: t.textGray, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(telefono, style: TextStyle(color: t.textGray))),
            IconButton(icon: Icon(Icons.copy, size: 18, color: t.textGray), onPressed: () {
              Clipboard.setData(ClipboardData(text: telefono));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Número copiado'), backgroundColor: Colors.green));
            }, tooltip: 'Copiar número'),
          ]),
        ],
        if (dt != null) ...[
          const SizedBox(height: 12),
          Divider(color: t.cardBackground),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Fecha', style: TextStyle(color: t.textGray, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(_formatFullDate(dt), style: TextStyle(color: t.black, fontWeight: FontWeight.w700)),
            ])),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hora', style: TextStyle(color: t.textGray, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: t.primaryTeal.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Text(_formatTimeLabel(dt), style: TextStyle(color: t.primaryTeal, fontWeight: FontWeight.w800))),
            ]),
          ]),
        ],
      ]),
    );
  }

  Widget _buildMotivosSeleccion(BuildContext context, _TurnifyColors t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Motivo de Cancelación', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
        const SizedBox(height: 10),
        ..._motivos.map((m) {
          final selected = m == _motivoSeleccionado;
          return InkWell(
            onTap: () {
              setState(() {
                _motivoSeleccionado = m;
                if (m != 'Otro') _otroTexto = '';
              });
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? t.primaryTeal.withOpacity(0.12) : t.cardBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? t.primaryTeal : Colors.transparent),
              ),
              child: Row(children: [
                Expanded(child: Text(m, style: TextStyle(color: selected ? t.primaryTeal : t.textGray, fontWeight: selected ? FontWeight.w700 : FontWeight.w600))),
                if (selected) Icon(Icons.check_circle, color: t.primaryTeal),
              ]),
            ),
          );
        }).toList(),
        if (_motivoSeleccionado == 'Otro') ...[
          const SizedBox(height: 6),
          TextField(
            onChanged: (v) => setState(() => _otroTexto = v),
            decoration: InputDecoration(
              hintText: 'Especifique el motivo',
              filled: true,
              fillColor: t.cardBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            maxLines: 2,
          ),
        ],
      ]),
    );
  }

  Widget _buildComentarios(BuildContext context, _TurnifyColors t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Comentarios Adicionales', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
        const SizedBox(height: 8),
        TextField(
          controller: _comentariosController,
          decoration: InputDecoration(
            hintText: 'Opcional - Ayúdanos a mejorar nuestro servicio',
            filled: true,
            fillColor: t.cardBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          maxLines: 4,
        ),
      ]),
    );
  }

  Widget _buildPolitica(BuildContext context, _TurnifyColors t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: t.cardBackground, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Política de Cancelación', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
        const SizedBox(height: 8),
        Text('Recuerda que puedes cancelar tu cita sin costo hasta 1 hora antes. Te enviaremos una confirmación por email/SMS.', style: TextStyle(color: t.textGray)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.turnify;
    final dt = _parseFechaHoraFromTurno();
    final isToday = dt != null && _isSameDate(dt, DateTime.now());
    final isTomorrow = dt != null && _isSameDate(dt, DateTime.now().add(const Duration(days: 1)));

    return Scaffold(
      backgroundColor: t.cardBackground,
      appBar: AppBar(
        backgroundColor: t.white,
        elevation: 0,
        iconTheme: IconThemeData(color: t.primaryTeal),
        title: Text('Cancelar turno', style: TextStyle(color: t.primaryTeal, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: _buildResumenTurno(context, t))]),
            const SizedBox(height: 12),

            if (dt != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.info_outline, color: t.textGray),
                  const SizedBox(width: 8),
                  Expanded(child: Text(isToday ? 'El turno es Hoy • ${_formatTimeLabel(dt)}' : (isTomorrow ? 'El turno es Mañana • ${_formatTimeLabel(dt)}' : _formatFullDate(dt)), style: TextStyle(color: t.textGray))),
                  TextButton(onPressed: _irAReagendar, child: const Text('Reagendar'), style: TextButton.styleFrom(foregroundColor: t.primaryTeal)),
                ]),
              ),

            const SizedBox(height: 12),
            _buildMotivosSeleccion(context, t),
            const SizedBox(height: 12),
            _buildComentarios(context, t),
            const SizedBox(height: 12),
            _buildPolitica(context, t),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : _mantenerCita,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: t.primaryTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    foregroundColor: t.primaryTeal,
                  ),
                  child: const Text('Mantener mi Cita', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : _confirmCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TurnifyColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Confirmar Cancelación', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}
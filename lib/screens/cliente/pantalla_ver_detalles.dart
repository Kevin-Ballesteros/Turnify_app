// lib/screens/pantalla_ver_detalles.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color danger = Color(0xFFD9534F);
}

class _TurnifyColors {
  final bool isDark;
  const _TurnifyColors(this.isDark);
  Color get primaryTeal => TurnifyColors.primaryTeal;
  Color get textGray => isDark ? Colors.grey.shade300 : const Color(0xFF666666);
  Color get white => isDark ? const Color(0xFF0B0B0B) : Colors.white;
  Color get black => isDark ? Colors.white : const Color(0xFF141414);
  Color get cardBackground => isDark ? const Color(0xFF0E0F10) : const Color(0xFFF5F5F5);
  Color get surface => isDark ? const Color(0xFF121212) : Colors.white;
}

extension TurnifyExtension on BuildContext {
  _TurnifyColors get turnify => _TurnifyColors(Theme.of(this).brightness == Brightness.dark);
}

const List<String> _dias = ['lun', 'mar', 'mie', 'jue', 'vie', 'sab', 'dom'];

class PantallaVerDetalles extends StatefulWidget {
  final Map<String, dynamic> turno;
  const PantallaVerDetalles({Key? key, required this.turno}) : super(key: key);

  @override
  State<PantallaVerDetalles> createState() => _PantallaVerDetallesState();
}

class _PantallaVerDetallesState extends State<PantallaVerDetalles> {
  bool _isCancelling = false;
  bool _isCancelled = false;
  Timer? _nowTimer;
  String? _cachedGeneratedId;

  @override
  void initState() {
    super.initState();
    _isCancelled = (widget.turno['status']?.toString().toLowerCase() == 'cancelled');
    _startNowTimer();
    _cachedGeneratedId = _makeDisplayedId();
  }

  @override
  void dispose() {
    _nowTimer?.cancel();
    super.dispose();
  }

  void _startNowTimer() {
    _nowTimer = Timer.periodic(const Duration(seconds: 60), (_) { if (mounted) setState(() {}); });
  }

  // ---------------- schedule helpers
  Map<String, Map<String, String>?> _getRawSchedule() {
    final raw = widget.turno['schedule'];
    if (raw is Map<String, dynamic>) {
      final out = <String, Map<String, String>?>{};
      for (final k in _dias) {
        if (raw.containsKey(k)) {
          final v = raw[k];
          if (v is Map<String, dynamic>) {
            out[k] = {
              'start': v['start']?.toString() ?? '',
              'end': v['end']?.toString() ?? '',
            };
          } else {
            out[k] = null;
          }
        } else {
          out[k] = null;
        }
      }
      final hasAny = out.values.any((e) {
        if (e == null) return false;
        final s = e['start'];
        final en = e['end'];
        return (s?.isNotEmpty == true) || (en?.isNotEmpty == true);
      });
      if (hasAny) return out;
    }
    return {
      'lun': {'start': '08:00 AM', 'end': '09:00 PM'},
      'mar': {'start': '08:00 AM', 'end': '09:00 PM'},
      'mie': {'start': '08:00 AM', 'end': '09:00 PM'},
      'jue': {'start': '08:00 AM', 'end': '09:00 PM'},
      'vie': {'start': '08:00 AM', 'end': '09:00 PM'},
      'sab': {'start': '08:00 AM', 'end': '09:00 PM'},
      'dom': null,
    };
  }

  List<String> _getClosedDatesIso() {
    final raw = widget.turno['closedDates'];
    if (raw is List) return raw.whereType<String>().toList();
    return <String>[];
  }

  String _isoDate(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  int? _parseTimeToMinutes(String? s) {
    if (s == null) return null;
    final str = s.trim();
    if (str.isEmpty) return null;
    final upper = str.toUpperCase();
    final ampmMatch = RegExp(r'^(.*?)(\s?(AM|PM))?$').firstMatch(upper);
    if (ampmMatch == null) return null;
    final timePart = ampmMatch.group(1)!.trim();
    final ampm = ampmMatch.group(3);
    final parts = timePart.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    int h = hour;
    if (ampm != null) {
      if (ampm == 'AM') {
        if (h == 12) h = 0;
      } else if (ampm == 'PM') {
        if (h != 12) h = h + 12;
      }
    }
    return h * 60 + minute;
  }

  Map<String, List<List<int>>> _parseScheduleToIntervals() {
    final raw = _getRawSchedule();
    final out = <String, List<List<int>>>{};
    for (final dia in _dias) {
      final entry = raw[dia];
      if (entry == null) {
        out[dia] = [];
        continue;
      }
      final startS = entry['start'];
      final endS = entry['end'];
      final startMin = _parseTimeToMinutes(startS);
      final endMin = _parseTimeToMinutes(endS);
      if (startMin == null || endMin == null) {
        out[dia] = [];
        continue;
      }
      if (endMin <= startMin) {
        out[dia] = [];
        continue;
      }
      out[dia] = [[startMin, endMin]];
    }
    return out;
  }

  bool _isOpenOn(DateTime date) {
    final iso = _isoDate(date);
    if (_getClosedDatesIso().contains(iso)) return false;
    final intervals = _parseScheduleToIntervals()[_dias[date.weekday - 1]] ?? [];
    if (intervals.isEmpty) return false;
    if (_isSameDate(date, DateTime.now())) {
      final nowMin = DateTime.now().hour * 60 + DateTime.now().minute;
      for (final iv in intervals) {
        final start = iv[0];
        final end = iv[1];
        if (nowMin >= start && nowMin < end) return true;
      }
      return false;
    }
    return true;
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool get _isOpenNow {
    final ref = _extractSelectedOrStartDate() ?? DateTime.now();
    return _isOpenOn(ref);
  }

  DateTime? _extractSelectedOrStartDate() {
    final startAt = widget.turno['startAt'];
    if (startAt is DateTime) return startAt;
    if (startAt is String) {
      final dt = DateTime.tryParse(startAt);
      if (dt != null) return dt.toLocal();
    }
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
    return null;
  }

  // Genera ID legible T{id} o fallback
  String _makeDisplayedId() {
    final rawId = widget.turno['id'];
    if (rawId != null) {
      final s = rawId.toString();
      if (s.startsWith('T')) return s;
      return 'T$s';
    }
    final fallback = DateTime.now().millisecondsSinceEpoch % 100000;
    return 'T$fallback';
  }

  // ---------------- Actions
  void _onReagendar() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Placeholder()));
  }

  Future<void> _onCancelar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final t = ctx.turnify;
        return AlertDialog(
          backgroundColor: t.white,
          title: const Text('Confirmar cancelación'),
          content: const Text('¿Estás seguro que quieres cancelar este turno?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: TurnifyColors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    setState(() => _isCancelling = true);
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _isCancelling = false;
      _isCancelled = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turno cancelado'), backgroundColor: Colors.green));
    }
  }

  // ---------------- Format helpers
  String _formatFullDate(DateTime d) {
    final weekday = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'][d.weekday % 7];
    final month = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'][d.month-1];
    return '$weekday, ${d.day} de $month ${d.year}';
  }

  String _formatTimeLabelFromDate(DateTime d) {
    final h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final hh = h % 12 == 0 ? 12 : h % 12;
    final ampm = h >= 12 ? 'PM' : 'AM';
    return '$hh:$m $ampm';
  }

  // Detectar si turno es hoy, mañana o en otra fecha
  String _computedRelativeDayLabel(DateTime dt) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    if (_isSameDate(dt, today)) return 'Hoy';
    if (_isSameDate(dt, tomorrow)) return 'Mañana';
    return _formatFullDate(dt);
  }

  // Copiar teléfono
  void _copyPhoneToClipboard(String phone) {
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Número copiado'), backgroundColor: Colors.green));
  }

  // ---------------- Widget pieces (service details more explícito)
  Widget _buildHeader(BuildContext context, _TurnifyColors t) {
    final servicio = widget.turno['servicio'] ?? '';
    final tipo = widget.turno['tipo'] ?? '';
    final fechaHora = _extractSelectedOrStartDate();
    final dateLabel = fechaHora != null ? _computedRelativeDayLabel(fechaHora) : (widget.turno['fecha'] ?? '');
    final timeLabel = fechaHora != null ? _formatTimeLabelFromDate(fechaHora) : (widget.turno['hora'] ?? '');
    final status = (widget.turno['status'] ?? '').toString().toLowerCase();
    final badgeText = _isCancelled || status == 'cancelled' ? 'Cancelado' : (_isOpenNow ? 'Abierto' : 'Cerrado');
    final badgeBg = _isCancelled || status == 'cancelled' ? Colors.grey.withOpacity(0.12) : (_isOpenNow ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12));
    final badgeTextColor = _isCancelled || status == 'cancelled' ? Colors.grey : (_isOpenNow ? Colors.green : Colors.red);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: t.primaryTeal.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.calendar_today, color: t.primaryTeal, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text('Detalle del turno', style: TextStyle(fontWeight: FontWeight.w700, color: t.primaryTeal))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)), child: Text(badgeText, style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 12),

        Text(servicio, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.black)),
        const SizedBox(height: 8),

        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Fecha', style: TextStyle(color: t.textGray, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(dateLabel, style: TextStyle(color: t.black, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hora', style: TextStyle(color: t.textGray, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: t.primaryTeal.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(timeLabel, style: TextStyle(color: t.primaryTeal, fontWeight: FontWeight.w800)),
            ),
          ]),
        ]),

        const SizedBox(height: 12),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: t.cardBackground, borderRadius: BorderRadius.circular(8)), child: Text(tipo, style: TextStyle(color: t.textGray, fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: t.cardBackground, borderRadius: BorderRadius.circular(8)), child: Text(_cachedGeneratedId ?? '', style: TextStyle(color: t.textGray, fontWeight: FontWeight.w700))),
        ]),
      ]),
    );
  }

  Widget _buildServiceCard(BuildContext context, _TurnifyColors t) {
    // Aquí mostramos la info del servicio igual que en DetallesTurno cliente:
    // nombre, descripción, precio, duración, extras (si vienen)
    final servicio = widget.turno['servicio'] ?? '';
    final descripcion = (widget.turno['descripcion'] ?? widget.turno['serviceDescription'] ?? '').toString();
    final precio = widget.turno['precio'] ?? widget.turno['price'] ?? '';
    final duracion = widget.turno['duracion'] ?? widget.turno['duration'] ?? ''; // puede venir '30' minutos o '00:30'
    final extras = widget.turno['extras']; // puede ser List<String> o String
    final List<String> extrasList = [];
    if (extras is List) extrasList.addAll(extras.whereType<String>());
    else if (extras is String && extras.isNotEmpty) extrasList.add(extras);

    String durLabel = '';
    if (duracion is int) {
      durLabel = '${duracion} min';
    } else if (duracion is String && duracion.isNotEmpty) {
      durLabel = duracion;
    }

    final precioLabel = precio != null ? precio.toString() : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.room_service, color: t.textGray),
          const SizedBox(width: 8),
          Text('Servicio', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
        ]),
        const SizedBox(height: 10),
        Text(servicio, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.black)),
        if (descripcion.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(descripcion, style: TextStyle(color: t.textGray)),
        ],
        const SizedBox(height: 12),
        Row(children: [
          if (precioLabel.isNotEmpty) ...[
            Text('Precio', style: TextStyle(color: t.textGray, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('\$ $precioLabel', style: TextStyle(color: t.primaryTeal, fontWeight: FontWeight.w800)),
          ] else ...[
            Text('Precio', style: TextStyle(color: t.textGray, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('—', style: TextStyle(color: t.textGray)),
          ],
          if (durLabel.isNotEmpty) ...[
            const SizedBox(width: 16),
            Text('Duración', style: TextStyle(color: t.textGray, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text(durLabel, style: TextStyle(color: t.textGray, fontWeight: FontWeight.w700)),
          ],
        ]),
        if (extrasList.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Extras', style: TextStyle(color: t.textGray, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: extrasList.map((x) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: t.cardBackground, borderRadius: BorderRadius.circular(8)), child: Text(x, style: TextStyle(color: t.textGray)))).toList()),
        ],
      ]),
    );
  }

  Widget _buildBusinessCard(BuildContext context, _TurnifyColors t) {
    final negocio = widget.turno['negocio'] ?? '';
    final ubicacion = widget.turno['ubicacion'] ?? '';
    final telefono = (widget.turno['telefono'] ?? '').toString().trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.business, color: t.textGray),
          const SizedBox(width: 8),
          Text('Negocio', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
        ]),
        const SizedBox(height: 10),
        Text(negocio, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.black)),
        if (ubicacion.toString().isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [Icon(Icons.location_on, color: t.textGray), const SizedBox(width: 8), Expanded(child: Text(ubicacion, style: TextStyle(color: t.textGray)))]),
        ],
        if (telefono.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.phone, color: t.textGray),
            const SizedBox(width: 8),
            Expanded(child: Text(telefono, style: TextStyle(color: t.textGray))),
            IconButton(icon: Icon(Icons.copy, size: 18, color: t.textGray), onPressed: () => _copyPhoneToClipboard(telefono), tooltip: 'Copiar número'),
          ]),
        ],
      ]),
    );
  }

  Widget _buildSchedulePreview(BuildContext context, _TurnifyColors t) {
    final scheduleRaw = _getRawSchedule();
    final intervals = _parseScheduleToIntervals();
    final closed = _getClosedDatesIso();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Horarios del negocio', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
        const SizedBox(height: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: _dias.map((dia) {
          final entry = scheduleRaw[dia];
          final dayIntervals = intervals[dia] ?? [];
          final closedDay = entry == null || entry['start'] == null || entry['start']!.isEmpty || entry['end'] == null || entry['end']!.isEmpty || dayIntervals.isEmpty;
          final displayName = _displayDia(dia);
          if (closedDay) {
            return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('$displayName: Cerrado', style: TextStyle(color: Colors.red)));
          }
          final start = entry['start'] ?? '';
          final end = entry['end'] ?? '';
          return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('$displayName: $start - $end', style: TextStyle(color: t.textGray)));
        }).toList()),
        if (closed.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Fechas cerradas', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: closed.map((iso) {
            final parts = iso.split('-');
            final legible = (parts.length == 3) ? '${parts[2]}/${parts[1]}/${parts[0]}' : iso;
            return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: t.cardBackground, borderRadius: BorderRadius.circular(8)), child: Text(legible, style: TextStyle(color: Colors.red)));
          }).toList()),
        ],
      ]),
    );
  }

  // ---------------- Build
  @override
  Widget build(BuildContext context) {
    final t = context.turnify;
    final status = (widget.turno['status'] ?? '').toString().toLowerCase();
    final showReagendar = status != 'cancelled'; // show Reagendar for completed and others
    final showCancelar = status != 'cancelled' && status != 'completed'; // hide Cancelar for completed and cancelled

    return Scaffold(
      backgroundColor: t.cardBackground,
      appBar: AppBar(
        backgroundColor: t.white,
        elevation: 0,
        iconTheme: IconThemeData(color: t.primaryTeal),
        title: Text('Ver detalles', style: TextStyle(color: t.primaryTeal, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(context, t),
          const SizedBox(height: 14),
          _buildServiceCard(context, t),
          const SizedBox(height: 14),
          _buildBusinessCard(context, t),
          const SizedBox(height: 14),
          _buildSchedulePreview(context, t),
          const SizedBox(height: 16),
          // botones con visibilidad según estado
          if (status != 'cancelled') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                if (showReagendar) Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onReagendar,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: const Text('Reagendar'),
                    style: ElevatedButton.styleFrom(backgroundColor: t.primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                if (showReagendar && showCancelar) const SizedBox(width: 12),
                if (showCancelar) Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCancelling ? null : _onCancelar,
                    icon: _isCancelling ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cancel_outlined),
                    label: Text('Cancelar', style: const TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(backgroundColor: TurnifyColors.danger, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ]),
            ),
          ],
          if (status == 'cancelled') ...[
            const SizedBox(height: 12),
            Center(child: Text('Este turno fue cancelado', style: TextStyle(color: t.textGray))),
          ],
          const SizedBox(height: 18),
        ]),
      ),
    );
  }

  String _displayDia(String diaKey) {
    switch (diaKey) {
      case 'lun': return 'Lun';
      case 'mar': return 'Mar';
      case 'mie': return 'Mié';
      case 'jue': return 'Jue';
      case 'vie': return 'Vie';
      case 'sab': return 'Sáb';
      case 'dom': return 'Dom';
      default: return diaKey;
    }
  }
}

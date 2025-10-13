// lib/screens/reagendar_turno.dart
import 'dart:async';
import 'package:flutter/material.dart';

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
  Color get cardBackground => isDark ? const Color(0xFF0E0F10) : const Color(0xFFF5F5F5);
  Color get surface => isDark ? const Color(0xFF121212) : Colors.white;
}

extension TurnifyExt on BuildContext {
  _TurnifyColors get turnify => _TurnifyColors(Theme.of(this).brightness == Brightness.dark);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// Pantalla para reagendar turno. Recibe `turno` como Map<String, dynamic>.
class ReagendarTurnoScreen extends StatefulWidget {
  final Map<String, dynamic> turno;
  const ReagendarTurnoScreen({Key? key, required this.turno}) : super(key: key);

  @override
  State<ReagendarTurnoScreen> createState() => _ReagendarTurnoScreenState();
}

class _ReagendarTurnoScreenState extends State<ReagendarTurnoScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Map<String, dynamic>? _availabilityForSelectedDate;
  final Map<String, Map<String, dynamic>> _availabilityCache = {};
  Timer? _nowTimer;

  static const List<String> _dias = ['lun', 'mar', 'mie', 'jue', 'vie', 'sab', 'dom'];

  @override
  void initState() {
    super.initState();
    _startNowTimer();
  }

  @override
  void dispose() {
    _nowTimer?.cancel();
    super.dispose();
  }

  void _startNowTimer() {
    _nowTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  // --- schedule helpers
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
    // fallback razonable
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

  // --- availability (simulación)
  Future<Map<String, dynamic>> _fetchAvailabilityForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final scheduleIntervals = _parseScheduleToIntervals();
    final weekdayIndex = date.weekday;
    final diaKey = _dias[weekdayIndex - 1];
    final intervals = scheduleIntervals[diaKey] ?? [];
    final booked = <int>[];
    final iso = _isoDate(date);
    if (_getClosedDatesIso().contains(iso)) {
      return {'intervals': <List<int>>[], 'booked': booked};
    }
    return {'intervals': intervals, 'booked': booked};
  }

  String _isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatFullDate(DateTime d) {
    final weekday = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'][d.weekday % 7];
    final month = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'][d.month - 1];
    return '$weekday, ${d.day} de $month ${d.year}';
  }
  // ----------------- Pickers y slots -----------------
  Future<void> _selectDateFromCalendar() async {
    if (!mounted) return;
    final now = DateTime.now();
    final first = now;
    final last = now.add(const Duration(days: 60));

    bool selectable(DateTime d) {
      final iso = _isoDate(d);
      if (_getClosedDatesIso().contains(iso)) return false;
      final intervals = _parseScheduleToIntervals()[_dias[d.weekday - 1]] ?? [];
      return intervals.isNotEmpty;
    }

    DateTime initialForPicker = _selectedDate ?? now;
    if (!selectable(initialForPicker)) {
      DateTime? found;
      for (var d = first; !d.isAfter(last); d = d.add(const Duration(days: 1))) {
        if (selectable(d)) {
          found = d;
          break;
        }
      }
      initialForPicker = found ?? first;
    }

    try {
      final picked = await showDatePicker(
        context: context,
        initialDate: initialForPicker,
        firstDate: first,
        lastDate: last,
        selectableDayPredicate: selectable,
        builder: (ctx, child) {
          final t = ctx.turnify;
          return Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(primary: t.primaryTeal),
              dialogBackgroundColor: t.white,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
      if (picked != null && mounted) {
        await _selectDate(picked);
      }
    } catch (e) {
      debugPrint('Error abriendo calendario: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error abriendo el calendario'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _selectDate(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
      _availabilityForSelectedDate = null;
    });
    final key = _isoDate(date);
    if (_availabilityCache.containsKey(key)) {
      setState(() => _availabilityForSelectedDate = _availabilityCache[key]);
      return;
    }
    final avail = await _fetchAvailabilityForDate(date);
    _availabilityCache[key] = avail;
    setState(() => _availabilityForSelectedDate = avail);
  }

  List<TimeOfDay> _generateSlotsForSelectedDate({int slotMinutes = 30}) {
    final avail = _availabilityForSelectedDate;
    if (avail == null) return [];
    final intervals = avail['intervals'] as List;
    final booked = (avail['booked'] as List).cast<int>();
    final List<TimeOfDay> slots = [];
    for (final iv in intervals) {
      int cursor = iv[0] as int;
      final end = iv[1] as int;
      while (cursor + slotMinutes <= end) {
        if (!booked.contains(cursor)) {
          final h = cursor ~/ 60;
          final m = cursor % 60;
          slots.add(TimeOfDay(hour: h, minute: m));
        }
        cursor += slotMinutes;
      }
    }
    return slots;
  }

  Future<void> _showTimePickerModal() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona primero una fecha'), backgroundColor: Colors.orange));
      return;
    }
    if (_availabilityForSelectedDate == null) {
      final avail = await _fetchAvailabilityForDate(_selectedDate!);
      final key = _isoDate(_selectedDate!);
      _availabilityCache[key] = avail;
      setState(() => _availabilityForSelectedDate = avail);
    }
    final slots = _generateSlotsForSelectedDate();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.turnify.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.25,
          initialChildSize: 0.45,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Text('Selecciona hora', style: TextStyle(fontWeight: FontWeight.w700, color: context.turnify.black)),
                    const Spacer(),
                    Text(_selectedDate == null ? '' : _formatFullDate(_selectedDate!), style: TextStyle(color: context.turnify.textGray)),
                  ]),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: slots.isEmpty
                      ? Center(child: Text('No hay horarios disponibles', style: TextStyle(color: context.turnify.textGray)))
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: slots.length,
                          itemBuilder: (ctx, i) {
                            final slot = slots[i];
                            final isSelected = _selectedTime != null && _selectedTime!.hour == slot.hour && _selectedTime!.minute == slot.minute;
                            return ListTile(
                              onTap: () {
                                setState(() => _selectedTime = slot);
                                Navigator.pop(ctx);
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              tileColor: isSelected ? context.turnify.primaryTeal.withOpacity(0.12) : context.turnify.white,
                              leading: Icon(Icons.access_time, color: isSelected ? context.turnify.primaryTeal : context.turnify.textGray),
                              title: Text(slot.format(context), style: TextStyle(color: isSelected ? context.turnify.primaryTeal : context.turnify.black, fontWeight: FontWeight.w600)),
                              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isSelectedSlotStillAvailable({int slotMinutes = 30}) {
    if (_selectedDate == null || _selectedTime == null || _availabilityForSelectedDate == null) return false;
    final minutes = _selectedTime!.hour * 60 + _selectedTime!.minute;
    final intervals = _availabilityForSelectedDate!['intervals'] as List;
    final booked = (_availabilityForSelectedDate!['booked'] as List).cast<int>();
    bool inside = false;
    for (final iv in intervals) {
      final start = iv[0] as int;
      final end = iv[1] as int;
      if (minutes >= start && minutes + slotMinutes <= end) {
        inside = true;
        break;
      }
    }
    if (!inside) return false;
    if (booked.contains(minutes)) return false;
    return true;
  }

  // ---------- NUEVO: confirmar reagendación y devolver payload ----------
  Future<void> _confirmReagendacion() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona fecha y hora'), backgroundColor: Colors.orange));
      return;
    }

    if (!_isSelectedSlotStillAvailable()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La hora seleccionada ya no está disponible'), backgroundColor: Colors.red));
      return;
    }

    final newDtLocal = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
    final newDtUtcIso = newDtLocal.toUtc().toIso8601String();

    // Mostrar feedback inmediato
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reagendando: ${widget.turno['negocio']} • ${_formatFullDate(newDtLocal)} ${_selectedTime!.format(context)}'), backgroundColor: Colors.green));

    try {
      // Simulación de llamada al backend: reemplaza por tu llamada real y usa la respuesta del servidor.
      await Future.delayed(const Duration(milliseconds: 400));
      // Ejemplo: final resp = await api.reagendarTurno(id: widget.turno['id'], startAt: newDtUtcIso);

      // Construir updatedTurno basado en la entidad local o respuesta del servidor
      final updatedTurno = Map<String, dynamic>.from(widget.turno);
      updatedTurno['startAt'] = newDtUtcIso;
      updatedTurno['fecha'] = '${newDtLocal.year.toString().padLeft(4,'0')}-${newDtLocal.month.toString().padLeft(2,'0')}-${newDtLocal.day.toString().padLeft(2,'0')}';
      updatedTurno['hora'] = '${newDtLocal.hour.toString().padLeft(2,'0')}:${newDtLocal.minute.toString().padLeft(2,'0')}';
      updatedTurno['duracion'] = widget.turno['duracion'] ?? widget.turno['duration'] ?? 30;
      updatedTurno['cancelado'] = false;

      // Devolver resultado al padre para que actualice provider/UI
      if (mounted) {
        Navigator.of(context).pop(<String, dynamic>{
          'rescheduled': true,
          'turno': updatedTurno,
        });
      }
    } catch (e, st) {
      debugPrint('Error reagendando turno: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo reagendar el turno'), backgroundColor: Colors.red));
      }
    }
  }

  // ----------------- BUILD -----------------
  @override
  Widget build(BuildContext context) {
    final t = context.turnify;
    final scheduleRaw = _getRawSchedule();
    final scheduleIntervals = _parseScheduleToIntervals();
    final closed = _getClosedDatesIso();

    return Scaffold(
      backgroundColor: t.cardBackground,
      appBar: AppBar(
        backgroundColor: t.white,
        elevation: 0,
        iconTheme: IconThemeData(color: t.primaryTeal),
        title: Text('Reagendar Turno', style: TextStyle(color: t.primaryTeal, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: t.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: context.isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: t.primaryTeal.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.info_outline, color: t.primaryTeal, size: 18)),
                const SizedBox(width: 10),
                Text('Cita a Reagendar', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
              ]),
              const SizedBox(height: 12),
              Text(widget.turno['negocio'] ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.black)),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: t.cardBackground, borderRadius: BorderRadius.circular(12)), child: Text(widget.turno['tipo'] ?? '', style: TextStyle(color: t.textGray, fontWeight: FontWeight.w600))),
              const SizedBox(height: 10),
              Text(widget.turno['servicio'] ?? '', style: TextStyle(color: t.textGray)),
              const SizedBox(height: 10),
              Text('Horarios de trabajo', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _dias.map((dia) {
                  final raw = scheduleRaw[dia];
                  final intervals = scheduleIntervals[dia] ?? [];
                  final opened = raw != null && raw['start'] != null && raw['start']!.isNotEmpty && raw['end'] != null && raw['end']!.isNotEmpty && intervals.isNotEmpty;
                  if (!opened) {
                    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('${_displayDia(dia)}: Cerrado', style: const TextStyle(color: Colors.red)));
                  }
                  final start = raw['start'] ?? '';
                  final end = raw['end'] ?? '';
                  final textStyle = TextStyle(color: t.primaryTeal, fontWeight: FontWeight.w800);
                  return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('${_displayDia(dia)}: $start - $end', style: textStyle));
                }).toList(),
              ),
              const SizedBox(height: 10),
              if (closed.isNotEmpty) ...[
                Text('Fechas cerradas', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, children: closed.map((iso) {
                  final parts = iso.split('-');
                  final legible = (parts.length == 3) ? '${parts[2]}/${parts[1]}/${parts[0]}' : iso;
                  return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: t.cardBackground, borderRadius: BorderRadius.circular(8)), child: Text(legible, style: const TextStyle(color: Colors.red)));
                }).toList()),
              ],
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: t.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: context.isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: t.cardBackground, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.calendar_today, color: t.textGray, size: 18)),
                const SizedBox(width: 10),
                Text('Selecciona Nueva Fecha', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
              ]),
              const SizedBox(height: 8),
              Text('Elige el día en el calendario', style: TextStyle(color: t.textGray, fontSize: 13)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDateFromCalendar,
                    icon: Icon(Icons.calendar_month, color: t.primaryTeal),
                    label: Text(_selectedDate == null ? 'Abrir calendario' : _formatFullDate(_selectedDate!), style: TextStyle(color: t.primaryTeal)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: t.primaryTeal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: t.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: context.isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: t.cardBackground, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.access_time, color: t.textGray, size: 18)),
                const SizedBox(width: 10),
                Text('Selecciona Hora', style: TextStyle(fontWeight: FontWeight.w700, color: t.black)),
              ]),
              const SizedBox(height: 8),
              Text('Primero selecciona la fecha, luego elige la hora desde el selector', style: TextStyle(color: t.textGray, fontSize: 13)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showTimePickerModal,
                    icon: Icon(Icons.access_time, color: _selectedDate != null ? t.primaryTeal : t.textGray),
                    label: Text(_selectedTime == null ? 'Elegir hora' : _selectedTime!.format(context), style: TextStyle(color: _selectedDate != null ? t.primaryTeal : t.textGray)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: _selectedDate != null ? t.primaryTeal : t.cardBackground), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              if (_selectedDate != null && _selectedTime != null) Text('Nueva cita: ${_formatFullDate(DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day))} • ${_selectedTime!.format(context)}', style: TextStyle(color: t.textGray)),
            ]),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_selectedDate != null && _selectedTime != null && _isSelectedSlotStillAvailable()) ? _confirmReagendacion : null,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar Reagendación'),
              style: ElevatedButton.styleFrom(backgroundColor: t.primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 8),
          Text('Puedes reagendar tu cita aquí. Sujeto a la disponibilidad del negocio.', style: TextStyle(color: t.textGray, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 28),
        ]),
      ),
    );
  }

  String _displayDia(String diaKey) {
    switch (diaKey) {
      case 'lun':
        return 'Lun';
      case 'mar':
        return 'Mar';
      case 'mie':
        return 'Mié';
      case 'jue':
        return 'Jue';
      case 'vie':
        return 'Vie';
      case 'sab':
        return 'Sáb';
      case 'dom':
        return 'Dom';
      default:
        return diaKey;
    }
  }
}

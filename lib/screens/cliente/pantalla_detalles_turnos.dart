// lib/screens/pantalla_detalles_turnos.dart
import 'package:flutter/material.dart';

class BusinessData {
  final String name;
  final String category;
  final double rating;
  final String address;
  final String description;
  final List<Map<String, dynamic>> services;
  final Map<String, Map<String, String>?> schedule;

  BusinessData({
    required this.name,
    required this.category,
    required this.rating,
    required this.address,
    required this.description,
    required this.services,
    Map<String, Map<String, String>?>? schedule,
  }) : schedule = schedule ??
            {
              'lun': {'start': '08:00 AM', 'end': '09:00 PM'},
              'mar': {'start': '08:00 AM', 'end': '09:00 PM'},
              'mie': {'start': '08:00 AM', 'end': '09:00 PM'},
              'jue': {'start': '08:00 AM', 'end': '09:00 PM'},
              'vie': {'start': '08:00 AM', 'end': '09:00 PM'},
              'sab': {'start': '08:00 AM', 'end': '09:00 PM'},
              'dom': null,
            };
}

class PantallaDetallesTurno extends StatefulWidget {
  final BusinessData business;
  const PantallaDetallesTurno({super.key, required this.business});

  @override
  State<PantallaDetallesTurno> createState() => _PantallaDetallesTurnoState();
}

class _PantallaDetallesTurnoState extends State<PantallaDetallesTurno> {
  int? _selectedServiceIndex;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Map<String, dynamic>? get _selectedService {
    if (_selectedServiceIndex == null) return null;
    return widget.business.services[_selectedServiceIndex!];
  }

  // ---------- helpers keys/labels ----------
  String _keyFromWeekday(int wd) {
    switch (wd) {
      case DateTime.monday:
        return 'lun';
      case DateTime.tuesday:
        return 'mar';
      case DateTime.wednesday:
        return 'mie';
      case DateTime.thursday:
        return 'jue';
      case DateTime.friday:
        return 'vie';
      case DateTime.saturday:
        return 'sab';
      case DateTime.sunday:
      default:
        return 'dom';
    }
  }

  String _labelFromKey(String k) {
    switch (k) {
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
      default:
        return 'Dom';
    }
  }

  Map<String, String>? _slotForKey(String key) => widget.business.schedule[key];

  Map<String, String>? _slotForDate(DateTime d) {
    final key = _keyFromWeekday(d.weekday);
    return _slotForKey(key);
  }

  int _parseToMinutes(String hhmm) {
  final parts = hhmm.trim().split(RegExp(r'[:\s]+'));
  if (parts.length < 2) return 0;

  int hour = int.tryParse(parts[0]) ?? 0;
  int minute = int.tryParse(parts[1]) ?? 0;

  // Detectar AM/PM
  final suffix = hhmm.toLowerCase().contains('pm') ? 'pm' : (hhmm.toLowerCase().contains('am') ? 'am' : '');

  if (suffix == 'pm' && hour < 12) hour += 12;
  if (suffix == 'am' && hour == 12) hour = 0;

  return hour * 60 + minute;
  }

  String _minutesToHHmm(int minutes) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  int _timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  // Construye intervalos efectivos para la fecha dada respetando slots que cruzan medianoche.
  // Devuelve lista de intervalos [startMin, endMin] relativos al día (0..1440).
  List<List<int>> _effectiveIntervalsForDate(DateTime date) {
    final List<List<int>> intervals = [];

    // Normalizar fecha a local midnight
    final localDate = DateTime(date.year, date.month, date.day);

    final slot = _slotForDate(localDate);
    if (slot != null) {
      final start = _parseToMinutes(slot['start']!);
      final end = _parseToMinutes(slot['end']!);
      if (start < end) {
        intervals.add([start, end]); // horario intra-día
      } else if (start > end) {
        // cruza medianoche: aporta desde start hasta 24:00 en este día
        intervals.add([start, 24 * 60]);
      }
      // start == end => cerrado explícito (no añadir)
    }

    final prevDate = localDate.subtract(const Duration(days: 1));
    final prevSlot = _slotForDate(prevDate);
    if (prevSlot != null) {
      final pStart = _parseToMinutes(prevSlot['start']!);
      final pEnd = _parseToMinutes(prevSlot['end']!);
      if (pStart > pEnd) {
        // el día anterior cruza medianoche y aporta desde 00:00 hasta pEnd en este día
        intervals.add([0, pEnd]);
      }
    }

    // Merge intervals (por solapamientos)
    intervals.sort((a, b) => a[0].compareTo(b[0]));
    final merged = <List<int>>[];
    for (final iv in intervals) {
      if (merged.isEmpty) {
        merged.add([iv[0], iv[1]]);
      } else {
        final last = merged.last;
        if (iv[0] <= last[1]) {
          last[1] = iv[1] > last[1] ? iv[1] : last[1];
        } else {
          merged.add([iv[0], iv[1]]);
        }
      }
    }
    return merged;
  }

  bool _isDayOpen(DateTime date) {
    final eff = _effectiveIntervalsForDate(date);
    return eff.isNotEmpty;
  }

  bool _isNowOpen() {
    final now = DateTime.now().toLocal();
    final intervals = _effectiveIntervalsForDate(now);
    if (intervals.isEmpty) return false;
    final nowM = now.hour * 60 + now.minute;
    return intervals.any((iv) => nowM >= iv[0] && nowM < iv[1]);
  }

  // Si está abierto ahora devuelve el minuto de cierre del intervalo actual
  int? _currentIntervalEndIfOpen() {
    final now = DateTime.now().toLocal();
    final intervals = _effectiveIntervalsForDate(now);
    final nowM = now.hour * 60 + now.minute;
    for (final iv in intervals) {
      if (nowM >= iv[0] && nowM < iv[1]) return iv[1];
    }
    return null;
  }

  // Determina si la selección (servicio+fecha+hora) es estrictamente válida.
  // Maneja nulos, formatos de duration, zonas locales y evita reservar en el pasado.
  bool _isSelectionValid() {
    try {
      if (_selectedService == null || _selectedDate == null || _selectedTime == null) return false;

      final dynamic durRaw = _selectedService!['duration'];
      final int duration = durRaw is int ? durRaw : int.tryParse('$durRaw') ?? 0;
      if (duration <= 0) return false;

      final int startSel = _timeOfDayToMinutes(_selectedTime!);
      final int endSel = startSel + duration;

      final now = DateTime.now().toLocal();
      final selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      ).toLocal();
      if (selectedDateTime.isBefore(now)) return false;

      final intervals = _effectiveIntervalsForDate(_selectedDate!);
      if (intervals.isEmpty) return false;

      for (final iv in intervals) {
        if (iv.length < 2) continue;
        final int ivStart = iv[0];
        final int ivEnd = iv[1];
        if (startSel >= ivStart && endSel <= ivEnd) return true;
      }
      return false;
    } catch (e, st) {
      debugPrint('ERROR en _isSelectionValid: $e\n$st');
      return false;
    }
  }

  // Opción A: delega en _isSelectionValid y añade comprobaciones "ya cerró hoy" y no reservar franjas pasadas hoy.
  bool _canBookSelectedDateTime() {
    if (_selectedService == null || _selectedDate == null || _selectedTime == null) return false;

    // primer filtro reutilizando la lógica básica
    if (!_isSelectionValid()) return false;

    final now = DateTime.now().toLocal();
    final nowMinutes = now.hour * 60 + now.minute;
    final isToday = now.year == _selectedDate!.year && now.month == _selectedDate!.month && now.day == _selectedDate!.day;

    final intervals = _effectiveIntervalsForDate(_selectedDate!);
    if (intervals.isEmpty) return false;

    // Si es hoy y ya cerró en tiempo real, bloquear
    if (isToday) {
      final lastEnd = intervals.map((iv) => iv[1]).fold<int>(0, (prev, e) => e > prev ? e : prev);
      if (nowMinutes >= lastEnd) return false;
      final startSel = _timeOfDayToMinutes(_selectedTime!);
      if (startSel < nowMinutes) return false; // no permitir franjas pasadas hoy
    }

    return true;
  }

  // ---------- selectors ----------
  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now().toLocal();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      builder: (context, child) => Theme(data: Theme.of(context), child: child!),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
      });
    }
  }

  // Genera opciones de horas válidas estrictamente dentro de intervalos efectivos y que permiten terminar el servicio.
  Future<void> _selectTime(BuildContext context) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona primero la fecha.')));
      return;
    }
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona primero un servicio.')));
      return;
    }

    final intervals = _effectiveIntervalsForDate(_selectedDate!);
    if (intervals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El negocio está cerrado ese día.')));
      return;
    }

    final now = DateTime.now().toLocal();
    final isToday = DateTime(now.year, now.month, now.day) ==
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);

    const stepMinutes = 30;
    final duration = (_selectedService?['duration'] as int?) ?? 0;
    final options = <TimeOfDay>[];

    for (final iv in intervals) {
      final ivStart = iv[0];
      final ivEnd = iv[1];
      final lastStartAllowed = ivEnd - duration;
      for (int m = ivStart; m <= lastStartAllowed; m += stepMinutes) {
        if (isToday) {
          final nowMinutes = now.hour * 60 + now.minute;
          final nextSlot = ((nowMinutes + stepMinutes - 1) ~/ stepMinutes) * stepMinutes;
          if (m < nextSlot) continue; // no ofrecer franjas pasadas
        }
        if (m >= 0 && m < 24 * 60) {
          final h = m ~/ 60;
          final mm = m % 60;
          options.add(TimeOfDay(hour: h, minute: mm));
        }
      }
    }

    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay servicio disponible para la fecha elegida.')));
      return;
    }

    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text('Selecciona hora', style: theme.textTheme.titleMedium),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 360,
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final t = options[i];
                    final label = t.format(ctx);
                    return ListTile(title: Text(label), onTap: () => Navigator.of(ctx).pop(t));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      // comprobación defensiva adicional (vuelve a validar antes de setState)
      final candidateStart = picked.hour * 60 + picked.minute;
      final dur = (_selectedService?['duration'] as int?) ?? 0;
      final candidateEnd = candidateStart + dur;
      final valid = _effectiveIntervalsForDate(_selectedDate!).any((iv) => candidateStart >= iv[0] && candidateEnd <= iv[1]);
      if (!valid) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hora inválida: fuera del horario de servicio.')));
        return;
      }
      setState(() => _selectedTime = picked);
    }
  }

  // Comprueba si para la fecha seleccionada quedan slots válidos considerando la duración y la hora actual.
  bool _noAvailableSlotsForSelectedDate() {
    if (_selectedDate == null || _selectedService == null) return false;
    final intervals = _effectiveIntervalsForDate(_selectedDate!);
    final now = DateTime.now().toLocal();
    final isToday = DateTime(now.year, now.month, now.day) ==
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    const stepMinutes = 30;
    final duration = (_selectedService?['duration'] as int?) ?? 0;
    for (final iv in intervals) {
      final ivStart = iv[0];
      final ivEnd = iv[1];
      final lastStartAllowed = ivEnd - duration;
      for (int m = ivStart; m <= lastStartAllowed; m += stepMinutes) {
        if (isToday) {
          final nowMinutes = now.hour * 60 + now.minute;
          final nextSlot = ((nowMinutes + stepMinutes - 1) ~/ stepMinutes) * stepMinutes;
          if (m < nextSlot) continue;
        }
        if (m >= 0 && m < 24 * 60) return false;
      }
    }
    return true;
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final appBarBg = theme.appBarTheme.backgroundColor ?? scaffoldBg;
    final cardColor = theme.cardColor;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    final nowOpen = _isNowOpen();
    final currentEnd = _currentIntervalEndIfOpen();
    final currentEndText = currentEnd != null ? _minutesToHHmm(currentEnd) : null;
    final selectedDateOpen = _selectedDate != null ? _isDayOpen(_selectedDate!) : false;
    final selectedDateNoSlots = _noAvailableSlotsForSelectedDate();

    // botón sólo habilitado si la selección es estrictamente válida
    final bool isReadyToConfirm = _canBookSelectedDateTime();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color), onPressed: () => Navigator.pop(context)),
        title: Text('Detalles Del Servicio', style: theme.textTheme.titleLarge?.copyWith(color: primary, fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 220),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildHeader(theme, primary, onSurface, nowOpen, currentEndText),
              _buildBusinessDetails(theme, cardColor),
              _buildBusinessDescriptionAndSchedule(theme, cardColor, primary),
              _buildServiceSelection(theme, cardColor, primary),
              _buildDateTimeSelection(theme, cardColor, primary, selectedDateOpen, selectedDateNoSlots),
            ]),
          ),
          _buildSummaryFooter(theme, primary, surface, isReadyToConfirm),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color primary, Color onSurface, bool nowOpen, String? currentEndText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.business.name, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: onSurface)),
        const SizedBox(height: 6),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: primary.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
            child: Text(widget.business.category, style: theme.textTheme.bodySmall?.copyWith(color: primary, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Icon(Icons.star, color: Colors.amber.shade700, size: 16),
          const SizedBox(width: 6),
          Text('${widget.business.rating.toStringAsFixed(1)} (${widget.business.services.length * 50} reseñas)', style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.location_on_outlined, color: theme.dividerColor.withOpacity(0.9), size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(widget.business.address, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color))),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: nowOpen ? Colors.green.shade600 : Colors.red.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Text(nowOpen ? 'ABIERTO' : 'CERRADO', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              if (nowOpen && currentEndText != null) ...[
                const SizedBox(width: 8),
                Text('hasta $currentEndText', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
              ],
            ]),
          ),
        ]),
        const SizedBox(height: 10),
      ]),
    );
  }

  Widget _buildBusinessDetails(ThemeData theme, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sobre el negocio', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(widget.business.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('Servicios destacados', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.business.services.take(3).map((s) {
              final name = s['name'] ?? '';
              return Chip(label: Text(name));
            }).toList(),
          ),
        ]),
      ),
    );
  }

  Widget _buildBusinessDescriptionAndSchedule(ThemeData theme, Color cardColor, Color primary) {
    final schedule = widget.business.schedule;
    String compactSummary() {
      final days = ['lun', 'mar', 'mie', 'jue', 'vie', 'sab', 'dom'];
      final first = schedule[days[0]];
      if (first == null) return '';
      final allSame = days.every((d) => schedule[d] != null && schedule[d]!['start'] == first['start'] && schedule[d]!['end'] == first['end']);
      if (allSame) return '${first['start']}–${first['end']}';
      return '';
    }

    final summary = compactSummary();
    final todayKey = _keyFromWeekday(DateTime.now().toLocal().weekday);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Horario de Trabajo', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (summary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Horario: $summary', style: theme.textTheme.bodySmall),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: schedule.entries.map((e) {
            final dayKey = e.key;
            final slot = e.value;
            final openDeclared = slot != null && _parseToMinutes(slot['start']!) != _parseToMinutes(slot['end']!);

            // Si es hoy, determinamos estado con base en hora actual y en intervalos efectivos
            if (dayKey == todayKey) {
              final todayIntervals = _effectiveIntervalsForDate(DateTime.now().toLocal());
              final now = DateTime.now().toLocal();
              final nowM = now.hour * 60 + now.minute;
              final isOpenNow = todayIntervals.any((iv) => nowM >= iv[0] && nowM < iv[1]);
              final hasIntervals = todayIntervals.isNotEmpty;
              final text = isOpenNow ? '${slot?['start']}–${slot?['end']}' : (hasIntervals ? 'CERRADO' : 'CERRADO');
              final bg = isOpenNow ? primary.withOpacity(0.08) : Colors.red.withOpacity(0.12);
              final fg = isOpenNow ? theme.textTheme.bodySmall?.color : Colors.red.shade700;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_labelFromKey(dayKey), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text(text, style: theme.textTheme.bodySmall?.copyWith(color: fg, fontWeight: FontWeight.w600)),
                ]),
              );
            }

            // Para otros días mostrar horario declarado o 'Cerrado'
            final display = (slot != null && slot['start'] != null && slot['end'] != null)
                ? '${slot['start']}–${slot['end']}'
                : 'Cerrado';
            final colorBg = openDeclared ? primary.withOpacity(0.08) : theme.dividerColor.withOpacity(0.04);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: colorBg, borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_labelFromKey(dayKey), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text(display, style: theme.textTheme.bodySmall),
              ]),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }

  Widget _buildServiceSelection(ThemeData theme, Color cardColor, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Elige tu Servicio', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...List.generate(widget.business.services.length, (index) {
          final service = widget.business.services[index];
          final isSelected = _selectedServiceIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedServiceIndex = index;
                _selectedTime = null;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: primary, width: 2) : null,
              ),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(service['name'], style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text(service['description'], style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.access_time, color: theme.textTheme.bodySmall?.color, size: 16),
                      const SizedBox(width: 6),
                      Text('${service['duration']} min', style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color)),
                    ]),
                  ]),
                ),
                const SizedBox(width: 8),
                Text('${service['price']}\$', style: theme.textTheme.titleLarge?.copyWith(color: primary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? primary : theme.dividerColor.withOpacity(0.5)),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
                ),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildDateTimeSelection(ThemeData theme, Color cardColor, Color primary, bool selectedDateOpen, bool selectedDateNoSlots) {
    final dayLabel = _selectedDate == null ? 'Seleccionar Fecha' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    final timeLabel = _selectedTime == null ? 'Seleccionar Hora' : _selectedTime!.format(context);
    final isDateChosen = _selectedDate != null;

    Widget statusBadge() {
      if (!isDateChosen) return const SizedBox.shrink();
      if (!selectedDateOpen) {
        return Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(20)),
          child: const Text('CERRADO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        );
      }
      if (selectedDateNoSlots) {
        return Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color.fromARGB(255, 238, 117, 10), borderRadius: BorderRadius.circular(20)),
          child: const Text('Negocio Cerrado 🚫', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        );
      }
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Fecha y Hora del Turno', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.calendar_today_outlined, color: primary),
              const SizedBox(width: 10),
              Expanded(child: Text(dayLabel, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16))),
              statusBadge(),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: theme.textTheme.bodySmall?.color, size: 18),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: (_selectedDate != null && selectedDateOpen) ? () => _selectTime(context) : null,
          child: Opacity(
            opacity: (_selectedDate != null) ? 1.0 : 0.6,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Icon(Icons.access_time_outlined, color: (_selectedDate != null && selectedDateOpen) ? primary : theme.dividerColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Selecciona una fecha primero'
                        : (!selectedDateOpen ? 'Cerrado ese día' : (_selectedService == null ? 'Selecciona un servicio primero' : timeLabel)),
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: theme.textTheme.bodySmall?.color, size: 18),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildSummaryFooter(ThemeData theme, Color primary, Color surface, bool isReadyToConfirm) {
    final priceText = _selectedService != null ? '${_selectedService!['price']}\$' : '0\$';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('🗓️ Resumen de tu Selección', style: theme.textTheme.bodyMedium?.copyWith(color: primary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 10),
          _buildSummaryDetail(theme, label: 'Servicio', value: _selectedService?['name'] ?? 'Pendiente', ready: _selectedService != null),
          _buildSummaryDetail(theme, label: 'Duración', value: _selectedService != null ? '${_selectedService!['duration']} min' : 'Pendiente', ready: _selectedService != null),
          _buildSummaryDetail(theme, label: 'Fecha', value: _selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}' : 'Pendiente', ready: _selectedDate != null),
          _buildSummaryDetail(theme, label: 'Hora', value: _selectedTime != null ? _selectedTime!.format(context) : 'Pendiente', ready: _selectedTime != null),
          const Divider(height: 20),
          if (!isReadyToConfirm && _selectedDate != null && _selectedTime != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'El negocio está cerrado en la fecha/hora seleccionada. Intenta reservar durante el horario de servicio.',
                style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
              ),
            ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total a pagar:', style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color, fontSize: 14)),
              Text(priceText, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
            ]),
            ElevatedButton(
              onPressed: isReadyToConfirm
                ? () {
                    // Validación final (defensiva)
                    if (_selectedDate == null || _selectedTime == null || _selectedService == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para confirmar.')));
                      return;
                    }
                    if (!_canBookSelectedDateTime()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se puede agendar: el negocio está cerrado o la hora no es válida. Intenta más tarde.')),
                      );
                      return;
                    }
                    // Persistir/agendar (integrar backend)
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turno confirmado.')));
                  }
                : null,

              style: ElevatedButton.styleFrom(
                backgroundColor: isReadyToConfirm ? primary : theme.disabledColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isReadyToConfirm ? 'Confirmar Turno' : 'Faltan datos o no disponible', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 16)),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildSummaryDetail(ThemeData theme, {required String label, required String value, required bool ready}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$label:', style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color, fontSize: 15)),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(color: ready ? theme.textTheme.bodyLarge?.color : theme.dividerColor, fontSize: 15, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
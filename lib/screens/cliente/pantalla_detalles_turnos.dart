// lib/screens/pantalla_detalles_turnos.dart
import 'package:flutter/material.dart';

class BusinessData {
  final String name;
  final String category;
  final double rating;
  final String address;
  final String description;
  final List<Map<String, dynamic>> services;

  /// Schedule opcional: mapa por día corto -> { 'start': 'HH:mm', 'end': 'HH:mm' } o null si cerrado
  /// claves: 'lun','mar','mie','jue','vie','sab','dom'
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
              'lun': {'start': '08:00 AM', 'end': '7:00 PM'},
              'mar': {'start': '08:00 AM', 'end': '7:00 PM'},
              'mie': {'start': '08:00 AM', 'end': '7:00 PM'},
              'jue': {'start': '08:00 AM', 'end': '7:00 PM'},
              'vie': {'start': '08:00 AM', 'end': '7:00 PM'},
              'sab': {'start': '08:00 AM', 'end': '4:00 PM'}, 
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

  // --------------------
  // Helpers para schedule
  // --------------------
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

  Map<String, String>? _slotForDate(DateTime d) {
    final key = _keyFromWeekday(d.weekday);
    return widget.business.schedule[key];
  }

  int _parseToMinutes(String hhmm) {
    final p = hhmm.split(':');
    final h = int.tryParse(p[0]) ?? 0;
    final m = int.tryParse(p[1]) ?? 0;
    return h * 60 + m;
  }

  int _timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  bool _isSelectionValid() {
    if (_selectedService == null || _selectedDate == null || _selectedTime == null) return false;
    final slot = _slotForDate(_selectedDate!);
    if (slot == null) return false;
    final start = _parseToMinutes(slot['start']!);
    final end = _parseToMinutes(slot['end']!);
    final selected = _timeOfDayToMinutes(_selectedTime!);
    final duration = (_selectedService?['duration'] as int?) ?? 0;
    return selected >= start && (selected + duration) <= end;
  }

  // --------------------
  // Select Date (solo días abiertos)
  // --------------------
  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
      selectableDayPredicate: (date) {
        final slot = _slotForDate(date);
        if (slot == null) return false;
        final s = slot['start'] ?? '00:00';
        final e = slot['end'] ?? '00:00';
        return _parseToMinutes(s) < _parseToMinutes(e);
      },
      builder: (context, child) => Theme(data: Theme.of(context), child: child!),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // limpiar hora al cambiar fecha
      });
    }
  }

  // --------------------
  // Select Time (muestra solo franjas válidas)
  // --------------------
  Future<void> _selectTime(BuildContext context) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona primero la fecha.')));
      return;
    }
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona primero un servicio.')));
      return;
    }

    final slot = _slotForDate(_selectedDate!);
    if (slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El negocio está cerrado ese día.')));
      return;
    }

    final startM = _parseToMinutes(slot['start']!);
    final endM = _parseToMinutes(slot['end']!);
    if (startM >= endM) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horario no disponible para la fecha seleccionada.')));
      return;
    }

    final stepMinutes = 30;
    final options = <TimeOfDay>[];
    for (int m = startM; m + 0 <= endM - 1; m += stepMinutes) {
      final h = m ~/ 60;
      final mm = m % 60;
      options.add(TimeOfDay(hour: h, minute: mm));
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
                    final duration = (_selectedService?['duration'] as int?) ?? 0;
                    final endIfStart = _timeOfDayToMinutes(t) + duration;
                    final fits = endIfStart <= endM;
                    return ListTile(
                      enabled: fits,
                      title: Text(label),
                      subtitle: fits ? null : Text('No disponible para este servicio', style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor)),
                      onTap: fits ? () => Navigator.of(ctx).pop(t) : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // --------------------
  // UI
  // --------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = theme.primaryColor;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final appBarBg = theme.appBarTheme.backgroundColor ?? scaffoldBg;
    final cardColor = theme.cardColor;
    final surface = colorScheme.surface;
    final onSurface = colorScheme.onSurface;
    final brightness = theme.brightness;

    // ignore: avoid_print
    print('PantallaDetallesTurno build -> brightness: $brightness, scaffoldBg: $scaffoldBg, cardColor: $cardColor');

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color), onPressed: () => Navigator.pop(context)),
        title: Text('Detalles De Tu Turno', style: theme.textTheme.titleLarge?.copyWith(color: primary, fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 220),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildHeader(theme, primary, onSurface),
              _buildBusinessDescriptionAndSchedule(theme, cardColor, primary),
              _buildServiceSelection(theme, cardColor, primary),
              _buildDateTimeSelection(theme, cardColor, primary),
            ]),
          ),
          _buildSummaryFooter(theme, primary, surface),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color primary, Color onSurface) {
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
        ]),
        const SizedBox(height: 10),
      ]),
    );
  }

  Widget _buildBusinessDescriptionAndSchedule(ThemeData theme, Color cardColor, Color primary) {
    final schedule = widget.business.schedule;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.business.description, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        Text('Horario de Trabajo', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: schedule.entries.map((e) {
            final dayKey = e.key;
            final slot = e.value;
            final open = slot != null && _parseToMinutes(slot['start']!) < _parseToMinutes(slot['end']!);
            final startEndText = open ? '${slot['start']}-${slot['end']}' : 'Cerrado';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: open ? theme.primaryColor.withOpacity(0.08) : theme.dividerColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_labelFromKey(dayKey), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text(startEndText, style: theme.textTheme.bodySmall),
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

  Widget _buildDateTimeSelection(ThemeData theme, Color cardColor, Color primary) {
    final dayLabel = _selectedDate == null ? 'Seleccionar Fecha' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    final timeLabel = _selectedTime == null ? 'Seleccionar Hora' : _selectedTime!.format(context);
    final slot = _selectedDate != null ? _slotForDate(_selectedDate!) : null;
    final open = slot != null && _parseToMinutes(slot['start']!) < _parseToMinutes(slot['end']!);

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
              Text(dayLabel, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: theme.textTheme.bodySmall?.color, size: 18),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: (_selectedDate != null && open) ? () => _selectTime(context) : null,
          child: Opacity(
            opacity: (_selectedDate != null && open) ? 1.0 : 0.6,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Icon(Icons.access_time_outlined, color: (_selectedDate != null && open) ? primary : theme.dividerColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Selecciona una fecha primero'
                        : (!open ? 'Cerrado ese día' : (_selectedService == null ? 'Selecciona un servicio primero' : timeLabel)),
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

  Widget _buildSummaryFooter(ThemeData theme, Color primary, Color surface) {
    final bool isReady = _isSelectionValid();
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total a pagar:', style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color, fontSize: 14)),
              Text(priceText, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
            ]),
            ElevatedButton(
              onPressed: isReady
                  ? () {
                      if (!_isSelectionValid()) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horario seleccionado no válido.')));
                        return;
                      }
                      // ignore: avoid_print
                      print('Turno Agendado: ${_selectedService!['name']}, Fecha: $_selectedDate, Hora: $_selectedTime');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turno confirmado.')));
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isReady ? 'Confirmar Turno' : 'Faltan datos', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 16)),
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

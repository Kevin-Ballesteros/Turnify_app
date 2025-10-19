// lib/screens/pantalla_notificaciones_negocio.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tokens de color Turnify
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color cardBackground = Color(0xFFF5F5F5);
}

/// Modelo de notificación simple
class NegocioNotificacion {
  String id;
  String title;
  String body;
  DateTime date;
  bool read;

  NegocioNotificacion({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.read = false,
  });

  factory NegocioNotificacion.fromMap(Map<String, dynamic> m) => NegocioNotificacion(
        id: m['id']?.toString() ?? '',
        title: m['title']?.toString() ?? '',
        body: m['body']?.toString() ?? '',
        date: DateTime.tryParse(m['date']?.toString() ?? '') ?? DateTime.now(),
        read: m['read'] == true,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'date': date.toIso8601String(),
        'read': read,
      };
}

/// Pantalla funcional de notificaciones con persistencia local (SharedPreferences)
class PantallaNotificacionesNegocio extends StatefulWidget {
  const PantallaNotificacionesNegocio({super.key});

  @override
  State<PantallaNotificacionesNegocio> createState() => _PantallaNotificacionesNegocioState();
}

class _PantallaNotificacionesNegocioState extends State<PantallaNotificacionesNegocio> {
  static const String _prefsKey = 'turnify_notificaciones_v1';
  final List<NegocioNotificacion> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _items.clear();
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          if (e is Map<String, dynamic>) {
            _items.add(NegocioNotificacion.fromMap(e));
          } else if (e is Map) {
            _items.add(NegocioNotificacion.fromMap(Map<String, dynamic>.from(e)));
          }
        }
      } catch (_) {
        // ignore parse errors and start empty
      }
    } else {
      // seed with sample notifications for first run
      _items.addAll([
        NegocioNotificacion(
            id: '1',
            title: 'Nuevo turno reservado',
            body: 'Tienes un nuevo turno para María López a las 09:00.',
            date: DateTime.now().subtract(const Duration(hours: 2)),
            read: false),
        NegocioNotificacion(
            id: '2',
            title: 'Reseña recibida',
            body: 'Carlos dejó una reseña positiva para tu servicio Corte de cabello.',
            date: DateTime.now().subtract(const Duration(days: 1)),
            read: true),
        NegocioNotificacion(
            id: '3',
            title: 'Recordatorio',
            body: 'Revisa tu agenda para el fin de semana.',
            date: DateTime.now().subtract(const Duration(days: 2)),
            read: false),
      ]);
      await _saveToPrefs(); // persist initial seed
    }
    setState(() => _loading = false);
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(_items.map((e) => e.toMap()).toList());
    await prefs.setString(_prefsKey, payload);
  }

  Future<void> _toggleRead(int index) async {
    setState(() => _items[index].read = !_items[index].read);
    await _saveToPrefs();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_items[index].read ? 'Marcada como leída' : 'Marcada como no leída'),
        backgroundColor: TurnifyColors.primaryTeal,
      ),
    );
  }

  Future<void> _deleteNotification(int index) async {
    final removed = _items.removeAt(index);
    await _saveToPrefs();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notificación eliminada: ${removed.title}')),
    );
  }

  Future<void> _clearAll() async {
    if (_items.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar todas las notificaciones'),
        content: const Text('¿Estás seguro de que quieres eliminar todas las notificaciones?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Borrar')),
        ],
      ),
    );
    if (confirm != true) return;
    _items.clear();
    await _saveToPrefs();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todas las notificaciones han sido eliminadas')));
  }

  // Añade una notificación de ejemplo (útil para testing)
  Future<void> _addSample() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _items.insert(
      0,
      NegocioNotificacion(
        id: id,
        title: 'Notificación de prueba',
        body: 'Esta es una notificación de prueba creada localmente.',
        date: DateTime.now(),
        read: false,
      ),
    );
    await _saveToPrefs();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notificación añadida')));
  }

  String _formattedDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) {
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else {
      return '${d.day}/${d.month}/${d.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: isDark ? cs.surface : TurnifyColors.primaryTeal,
        foregroundColor: isDark ? cs.onSurface : Colors.white,
        actions: [
          IconButton(
            onPressed: _addSample,
            icon: const Icon(Icons.add),
            tooltip: 'Añadir notificación de prueba',
          ),
          IconButton(
            onPressed: _clearAll,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Borrar todas',
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.notifications_off, size: 72, color: cs.onSurface.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text('No hay notificaciones', style: tt.titleMedium?.copyWith(color: cs.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 8),
                      Text('Cuando recibas notificaciones aparecerán aquí', style: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.5))),
                    ]),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final n = _items[index];
                      final bg = n.read ? (isDark ? cs.surfaceVariant : Colors.white) : (isDark ? cs.surface : Color(0xFFF0FFFE));
                      final border = n.read ? Colors.transparent : TurnifyColors.lightTeal.withOpacity(0.3);

                      return Dismissible(
                        key: ValueKey(n.id),
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Row(children: const [Icon(Icons.delete, color: Colors.redAccent), SizedBox(width: 8), Text('Eliminar')]),
                        ),
                        secondaryBackground: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(color: TurnifyColors.primaryTeal.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: const [Icon(Icons.mark_email_read, color: TurnifyColors.primaryTeal), SizedBox(width: 8), Text('Marcar leída')]),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            // delete
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar notificación'),
                                content: const Text('¿Deseas eliminar esta notificación?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _deleteNotification(index);
                            }
                            return confirm == true;
                          } else {
                            // mark read
                            await _toggleRead(index);
                            return false;
                          }
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              if (!n.read) {
                                await _toggleRead(index);
                              } else {
                                // show details
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: cs.surface,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                                  builder: (_) => Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(n.title, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 8),
                                      Text(_formattedDate(n.date), style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.6))),
                                      const SizedBox(height: 12),
                                      Text(n.body, style: tt.bodyMedium),
                                      const SizedBox(height: 20),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
                                      ),
                                    ]),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bg == Colors.white ? bg : bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: border),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.02 : 0.03), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Row(children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: n.read ? TurnifyColors.cardBackground : TurnifyColors.primaryTeal,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(n.read ? Icons.notifications : Icons.notifications_active, color: n.read ? TurnifyColors.textGray : Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(n.title, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: cs.onBackground)),
                                    const SizedBox(height: 6),
                                    Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.8))),
                                  ]),
                                ),
                                const SizedBox(width: 8),
                                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Text(_formattedDate(n.date), style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.6))),
                                  const SizedBox(height: 8),
                                  PopupMenuButton<String>(
                                    onSelected: (v) async {
                                      if (v == 'toggle') {
                                        await _toggleRead(index);
                                      } else if (v == 'delete') {
                                        await _deleteNotification(index);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(value: 'toggle', child: Text(n.read ? 'Marcar no leída' : 'Marcar leída')),
                                      const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                                    ],
                                  ),
                                ]),
                              ]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

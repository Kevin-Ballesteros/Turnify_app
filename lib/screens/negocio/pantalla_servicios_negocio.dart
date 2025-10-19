// lib/screens/negocio/pantalla_servicios_negocio.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color cardBackground = Color(0xFFF5F5F5);
}

/// Modelos
class Servicio {
  String id;
  String nombre;
  String precio; // string for easy input
  String duracion; // minutes
  List<Resena> resenas;

  Servicio({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.duracion,
    List<Resena>? resenas,
  }) : resenas = resenas ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'precio': precio,
        'duracion': duracion,
        'resenas': resenas.map((r) => r.toMap()).toList(),
      };

  factory Servicio.fromMap(Map<String, dynamic> m) => Servicio(
        id: m['id']?.toString() ?? UniqueKey().toString(),
        nombre: m['nombre']?.toString() ?? '',
        precio: m['precio']?.toString() ?? '',
        duracion: m['duracion']?.toString() ?? '',
        resenas: (m['resenas'] is List) ? List<dynamic>.from(m['resenas']).map((e) => Resena.fromMap(Map<String, dynamic>.from(e))).toList() : [],
      );
}

class Resena {
  String id;
  String autor;
  String texto;
  int rating; // 1-5
  DateTime fecha;

  Resena({required this.id, required this.autor, required this.texto, required this.rating, DateTime? fecha})
      : fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'autor': autor,
        'texto': texto,
        'rating': rating,
        'fecha': fecha.toIso8601String(),
      };

  factory Resena.fromMap(Map<String, dynamic> m) => Resena(
        id: m['id']?.toString() ?? UniqueKey().toString(),
        autor: m['autor']?.toString() ?? 'Anónimo',
        texto: m['texto']?.toString() ?? '',
        rating: int.tryParse(m['rating']?.toString() ?? '') ?? (m['rating'] is int ? m['rating'] : 5),
        fecha: DateTime.tryParse(m['fecha']?.toString() ?? '') ?? DateTime.now(),
      );
}

/// Pantalla servicios funcional (persistencia local con SharedPreferences)
class PantallaServiciosNegocio extends StatefulWidget {
  const PantallaServiciosNegocio({super.key});

  @override
  State<PantallaServiciosNegocio> createState() => _PantallaServiciosNegocioState();
}

class _PantallaServiciosNegocioState extends State<PantallaServiciosNegocio> {
  static const String _prefsKey = 'turnify_negocio_data_v1';

  final List<Servicio> _servicios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadServicios();
  }

  Future<void> _loadServicios() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _servicios.clear();
    if (raw != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(raw);
        final list = List<dynamic>.from(data['servicios'] ?? []);
        for (final s in list) {
          if (s is Map) {
            _servicios.add(Servicio.fromMap(Map<String, dynamic>.from(s)));
          } else if (s is Map<String, dynamic>) {
            _servicios.add(Servicio.fromMap(s));
          }
        }
      } catch (_) {
        // ignore parse errors
      }
    }
    // if empty, seed with examples
    if (_servicios.isEmpty) {
      _servicios.addAll([
        Servicio(id: 's1', nombre: 'Corte de cabello', precio: '20', duracion: '30', resenas: [
          Resena(id: 'r1', autor: 'María', texto: 'Buen servicio, rápido.', rating: 5),
          Resena(id: 'r2', autor: 'Juan', texto: 'Me gustó el corte.', rating: 4),
        ]),
        Servicio(id: 's2', nombre: 'Corte de cabello y barba', precio: '25', duracion: '35', resenas: [
          Resena(id: 'r3', autor: 'Carlos', texto: 'Excelente atención.', rating: 5),
        ]),
      ]);
      await _saveAll();
    }
    setState(() => _loading = false);
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    // load existing data and replace servicios key
    final raw = prefs.getString(_prefsKey);
    Map<String, dynamic> current = {};
    if (raw != null) {
      try {
        current = Map<String, dynamic>.from(jsonDecode(raw));
      } catch (_) {
        current = {};
      }
    }
    current['servicios'] = _servicios.map((s) => s.toMap()).toList();
    await prefs.setString(_prefsKey, jsonEncode(current));
  }

  Future<void> _addServicio() async {
    final nuevo = Servicio(id: UniqueKey().toString(), nombre: '', precio: '', duracion: '');
    // show editor
    final result = await showDialog<Servicio>(
      context: context,
      builder: (_) => _ServicioEditorDialog(servicio: nuevo),
    );
    if (result != null) {
      setState(() => _servicios.insert(0, result));
      await _saveAll();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicio añadido')));
    }
  }

  Future<void> _editServicio(int index) async {
    final servicio = _servicios[index];
    final result = await showDialog<Servicio>(
      context: context,
      builder: (_) => _ServicioEditorDialog(servicio: Servicio.fromMap(servicio.toMap())),
    );
    if (result != null) {
      setState(() => _servicios[index] = result);
      await _saveAll();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicio actualizado')));
    }
  }

  Future<void> _deleteServicio(int index) async {
    _servicios.removeAt(index);
    await _saveAll();
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicio eliminado')));
  }

  Future<void> _addResena(int servicioIndex) async {
    final servicio = _servicios[servicioIndex];
    final result = await showDialog<Resena>(
      context: context,
      builder: (_) => _ResenaEditorDialog(),
    );
    if (result != null) {
      setState(() => servicio.resenas.insert(0, result));
      await _saveAll();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reseña añadida')));
    }
  }

  Future<void> _deleteResena(int servicioIndex, int resenaIndex) async {
    final servicio = _servicios[servicioIndex];
    servicio.resenas.removeAt(resenaIndex);
    await _saveAll();
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reseña eliminada')));
  }

  double _averageRating(Servicio s) {
    if (s.resenas.isEmpty) return 0.0;
    return s.resenas.map((r) => r.rating).reduce((a, b) => a + b) / s.resenas.length;
  }

  Widget _buildServicioCard(int index, ColorScheme cs, TextTheme tt, bool isDark) {
    final s = _servicios[index];
    final cardBg = isDark ? cs.surface : TurnifyColors.white;
    final border = isDark ? cs.onSurface.withOpacity(0.06) : const Color(0xFFA2B2B1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.02 : 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.nombre.isEmpty ? 'Sin nombre' : s.nombre, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Row(children: [
                Text('${s.duracion} min', style: tt.bodySmall?.copyWith(color: TurnifyColors.textGray)),
                const SizedBox(width: 12),
                Text('\$${s.precio}', style: tt.bodySmall?.copyWith(color: TurnifyColors.textGray)),
                const SizedBox(width: 12),
                Row(children: [
                  Icon(Icons.star, size: 14, color: TurnifyColors.primaryTeal),
                  const SizedBox(width: 4),
                  Text(_averageRating(s).toStringAsFixed(1), style: tt.bodySmall),
                  const SizedBox(width: 6),
                  Text('(${s.resenas.length})', style: tt.bodySmall?.copyWith(color: TurnifyColors.textGray)),
                ]),
              ]),
            ]),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') return _editServicio(index);
              if (v == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar servicio'),
                    content: const Text('¿Deseas eliminar este servicio?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
                    ],
                  ),
                );
                if (confirm == true) await _deleteServicio(index);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        ]),
        if (s.resenas.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Aún no hay reseñas para este servicio', style: tt.bodySmall?.copyWith(color: TurnifyColors.textGray)),
          )
        else
          Column(
            children: List.generate(s.resenas.length, (ri) {
              final r = s.resenas[ri];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(r.autor.isNotEmpty ? r.autor[0].toUpperCase() : 'A')),
                title: Row(children: [
                  Expanded(child: Text(r.autor, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                  Row(children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 14, color: TurnifyColors.primaryTeal))),
                ]),
                subtitle: Text(r.texto),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteResena(index, ri),
                ),
              );
            }),
          ),
        const SizedBox(height: 8),
        Row(children: [
          OutlinedButton.icon(
            onPressed: () => _addResena(index),
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Añadir reseña'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _editServicio(index),
            icon: const Icon(Icons.edit),
            label: const Text('Editar servicio'),
            style: ElevatedButton.styleFrom(backgroundColor: TurnifyColors.primaryTeal),
          ),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Servicios'),
          backgroundColor: isDark ? cs.surface : TurnifyColors.primaryTeal,
          foregroundColor: isDark ? cs.onSurface : Colors.white,
          actions: [
            IconButton(
              onPressed: _loadServicios,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refrescar',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addServicio,
          backgroundColor: TurnifyColors.primaryTeal,
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _servicios.isEmpty
                      ? Center(child: Text('No hay servicios', style: tt.titleMedium))
                      : ListView.separated(
                          itemCount: _servicios.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _buildServicioCard(index, cs, tt, isDark),
                        ),
                ),
        ),
      );
    }
  }

/// Dialog para crear/editar servicio
class _ServicioEditorDialog extends StatefulWidget {
  final Servicio servicio;
  const _ServicioEditorDialog({required this.servicio});

  @override
  State<_ServicioEditorDialog> createState() => _ServicioEditorDialogState();
}

class _ServicioEditorDialogState extends State<_ServicioEditorDialog> {
  late final TextEditingController _nombre = TextEditingController();
  late final TextEditingController _precio = TextEditingController();
  late final TextEditingController _duracion = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nombre.text = widget.servicio.nombre;
    _precio.text = widget.servicio.precio;
    _duracion.text = widget.servicio.duracion;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _duracion.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final updated = Servicio(
      id: widget.servicio.id,
      nombre: _nombre.text.trim(),
      precio: _precio.text.trim(),
      duracion: _duracion.text.trim(),
      resenas: widget.servicio.resenas,
    );
    Navigator.of(context).pop(updated);
  }

  @override
Widget build(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final isDark = cs.brightness == Brightness.dark;

  final backgroundColor = isDark ? cs.surface : Colors.white;
  final titleColor = isDark ? cs.onSurface : TurnifyColors.primaryTeal;
  final textColor = isDark ? cs.onSurface : Colors.black;

  return AlertDialog(
    backgroundColor: backgroundColor,
    title: Text(
      widget.servicio.nombre.isEmpty ? 'Nuevo servicio' : 'Editar servicio',
      style: TextStyle(color: titleColor),
    ),
    content: Form(
      key: _formKey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
          controller: _nombre,
          decoration: const InputDecoration(labelText: 'Nombre'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese nombre' : null,
          style: TextStyle(color: textColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _precio,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Precio'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese precio' : null,
          style: TextStyle(color: textColor),
        ),
        // ...
      ]),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
      ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: TurnifyColors.primaryTeal), child: const Text('Guardar')),
    ],
  );
}
}

/// Dialog para añadir reseña
class _ResenaEditorDialog extends StatefulWidget {
  const _ResenaEditorDialog();

  @override
  State<_ResenaEditorDialog> createState() => _ResenaEditorDialogState();
}

class _ResenaEditorDialogState extends State<_ResenaEditorDialog> {
  final _autor = TextEditingController();
  final _texto = TextEditingController();
  int _rating = 5;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _autor.dispose();
    _texto.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final r = Resena(id: UniqueKey().toString(), autor: _autor.text.trim().isEmpty ? 'Anónimo' : _autor.text.trim(), texto: _texto.text.trim(), rating: _rating);
    Navigator.of(context).pop(r);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Añadir reseña'),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: _autor, decoration: const InputDecoration(labelText: 'Nombre (opcional)')),
          const SizedBox(height: 8),
          TextFormField(controller: _texto, decoration: const InputDecoration(labelText: 'Reseña'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese texto' : null),
          const SizedBox(height: 12),
          Row(children: [
            Text('Valoración', style: tt.bodyMedium),
            const SizedBox(width: 12),
            Row(children: List.generate(5, (i) {
              final idx = i + 1;
              return IconButton(
                icon: Icon(idx <= _rating ? Icons.star : Icons.star_border, color: TurnifyColors.primaryTeal),
                onPressed: () => setState(() => _rating = idx),
              );
            })),
          ]),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: TurnifyColors.primaryTeal), child: const Text('Añadir')),
      ],
    );
  }
}

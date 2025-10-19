// lib/screens/pantalla_perfil_negocio.dart
import 'dart:convert';
import 'package:flutter/material.dart';
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

/// Pantalla Perfil del negocio — carga desde SharedPreferences (misma clave usada anteriormente)
class PantallaPerfilNegocio extends StatefulWidget {
  const PantallaPerfilNegocio({super.key});

  @override
  State<PantallaPerfilNegocio> createState() => _PantallaPerfilNegocioState();
}

class _PantallaPerfilNegocioState extends State<PantallaPerfilNegocio> {
  static const String _prefsKey = 'turnify_negocio_data_v1';

  bool _loading = true;
  String _nombre = '';
  String _direccion = '';
  Map<String, String> _horarios = {};
  List<Map<String, String>> _servicios = [];

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(raw);
        _nombre = data['nombre']?.toString() ?? '';
        _direccion = data['direccion']?.toString() ?? '';
        final horarios = Map<String, dynamic>.from(data['horarios'] ?? {});
        _horarios = {for (var e in horarios.entries) e.key: e.value?.toString() ?? ''};
        final list = List<dynamic>.from(data['servicios'] ?? []);
        _servicios = list.map<Map<String, String>>((s) {
          final m = Map<String, dynamic>.from(s ?? {});
          return {
            'nombre': m['nombre']?.toString() ?? '',
            'precio': m['precio']?.toString() ?? '',
            'duracion': m['duracion']?.toString() ?? '',
          };
        }).toList();
      } catch (_) {
        _setEmpty();
      }
    } else {
      _setEmpty();
    }
    setState(() => _loading = false);
  }

  void _setEmpty() {
    _nombre = 'Barbería Los Santos';
    _direccion = 'Fusagasugá, Cundinamarca';
    _horarios = {
      'Lunes a Viernes': '8:00 - 21:00',
      'Sábado': '8:00 - 21:00',
      'Domingo': '8:00 - 17:00',
    };
    _servicios = [
      {'nombre': 'Corte de cabello', 'precio': '20', 'duracion': '30'},
      {'nombre': 'Corte de cabello y barba', 'precio': '25', 'duracion': '35'},
    ];
  }

  Future<void> _refresh() async => _loadFromPrefs();

  void _openEditar() {
    Navigator.pushNamed(context, '/configuracion').then((_) => _refresh());
  }

  Widget _buildHeader(TextTheme tt, Color label, bool isDark) {
    return Row(children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(color: TurnifyColors.primaryTeal, borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.center,
        child: Icon(Icons.storefront_outlined, color: Colors.white, size: 36),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_nombre, style: tt.titleMedium?.copyWith(color: label, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 16, color: TurnifyColors.textGray),
            const SizedBox(width: 6),
            Expanded(child: Text(_direccion, style: tt.bodyMedium?.copyWith(color: TurnifyColors.textGray))),
          ]),
        ]),
      ),
      IconButton(
        onPressed: _openEditar,
        icon: Icon(Icons.settings, color: isDark ? Colors.white : TurnifyColors.primaryTeal),
        tooltip: 'Editar',
      ),
    ]);
  }

  Widget _buildHorariosSection(TextTheme tt, Color label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Horarios', style: tt.titleSmall?.copyWith(color: label, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ..._horarios.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Expanded(child: Text(e.key, style: tt.bodyMedium?.copyWith(color: TurnifyColors.textGray))),
            const SizedBox(width: 8),
            Text(e.value, style: tt.bodyMedium?.copyWith(color: label, fontWeight: FontWeight.w600)),
          ]),
        );
      }).toList(),
    ]);
  }

  Widget _buildServiciosSection(TextTheme tt, Color label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Servicios', style: tt.titleSmall?.copyWith(color: label, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ..._servicios.map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TurnifyColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s['nombre'] ?? '', style: tt.bodyLarge?.copyWith(color: label, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('${s['duracion'] ?? ''} min • \$${s['precio'] ?? ''}', style: tt.bodySmall?.copyWith(color: TurnifyColors.textGray)),
              ]),
            ),
            Icon(Icons.chevron_right, color: TurnifyColors.lightGray),
          ]),
        );
      }).toList(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final bg = theme.scaffoldBackgroundColor;
    final label = tt.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        automaticallyImplyLeading: false, // <-- quita la flecha de regreso
        title: Text('Perfil del negocio', style: tt.titleLarge?.copyWith(color: TurnifyColors.primaryTeal)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _refresh, icon: Icon(Icons.refresh, color: isDark ? Colors.white : TurnifyColors.primaryTeal)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildHeader(tt, label, isDark),
                  const SizedBox(height: 20),
                  _buildHorariosSection(tt, label),
                  const SizedBox(height: 20),
                  _buildServiciosSection(tt, label),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openEditar,
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar datos'),
                        style: ElevatedButton.styleFrom(backgroundColor: TurnifyColors.primaryTeal),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove(_prefsKey);
                        await _loadFromPrefs();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos restaurados a valores por defecto')));
                        }
                      },
                      child: const Text('Restaurar'),
                    ),
                  ]),
                ]),
              ),
            ),
    );
  }
}

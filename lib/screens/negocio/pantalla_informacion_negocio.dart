// lib/screens/pantalla_informacion_negocio.dart
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

/// Modelo simple de servicio con conversión a/from Map para persistencia
class Servicio {
  String nombre;
  String precio; // string para input; parsear si hace falta
  String duracion;

  Servicio({required this.nombre, required this.precio, required this.duracion});

  Map<String, dynamic> toMap() => {'nombre': nombre, 'precio': precio, 'duracion': duracion};
  factory Servicio.fromMap(Map<String, dynamic> m) => Servicio(
        nombre: m['nombre']?.toString() ?? '',
        precio: m['precio']?.toString() ?? '',
        duracion: m['duracion']?.toString() ?? '',
      );
}

class PantallaInformacionNegocio extends StatefulWidget {
  const PantallaInformacionNegocio({super.key});

  @override
  State<PantallaInformacionNegocio> createState() => _PantallaInformacionNegocioState();
}

class _PantallaInformacionNegocioState extends State<PantallaInformacionNegocio> {
  static const String _prefsKey = 'turnify_negocio_data_v1';

  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  final Map<String, TextEditingController> _horarioCtrls = {};
  final List<Servicio> _servicios = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    for (final c in _horarioCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFromPrefs() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(raw);
        _nombreCtrl.text = data['nombre']?.toString() ?? '';
        _direccionCtrl.text = data['direccion']?.toString() ?? '';

        final Map<String, dynamic> horarios = Map<String, dynamic>.from(data['horarios'] ?? {});
        _horarioCtrls.clear();
        if (horarios.isNotEmpty) {
          horarios.forEach((k, v) {
            _horarioCtrls[k] = TextEditingController(text: v?.toString() ?? '');
          });
        } else {
          _createDefaultHorarios();
        }

        _servicios.clear();
        final sList = List<dynamic>.from(data['servicios'] ?? []);
        for (final s in sList) {
          if (s is Map<String, dynamic>) _servicios.add(Servicio.fromMap(s));
        }
      } catch (_) {
        _setDefaults();
      }
    } else {
      _setDefaults();
    }
    setState(() => _loading = false);
  }

  void _setDefaults() {
    _nombreCtrl.text = 'Barbería Los Santos';
    _direccionCtrl.text = 'Fusagasugá, Cundinamarca';
    _createDefaultHorarios();
    _servicios
      ..clear()
      ..addAll([
        Servicio(nombre: 'Corte de cabello', precio: '20', duracion: '30'),
        Servicio(nombre: 'Corte de cabello y barba', precio: '25', duracion: '35'),
        Servicio(nombre: '', precio: '30', duracion: '45'),
      ]);
  }

  void _createDefaultHorarios() {
    _horarioCtrls.clear();
    _horarioCtrls['Lunes a Viernes'] = TextEditingController(text: '8:00 - 21:00');
    _horarioCtrls['Sábado'] = TextEditingController(text: '8:00 - 21:00');
    _horarioCtrls['Domingo'] = TextEditingController(text: '8:00 - 17:00');
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> payload = {
      'nombre': _nombreCtrl.text.trim(),
      'direccion': _direccionCtrl.text.trim(),
      'horarios': {for (var e in _horarioCtrls.entries) e.key: e.value.text.trim()},
      'servicios': _servicios.map((s) => s.toMap()).toList(),
    };
    await prefs.setString(_prefsKey, jsonEncode(payload));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cambios guardados exitosamente'),
        backgroundColor: TurnifyColors.primaryTeal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _agregarServicio() {
    setState(() {
      _servicios.add(Servicio(nombre: '', precio: '', duracion: ''));
    });
  }

  void _eliminarServicio(int index) {
    setState(() {
      if (index >= 0 && index < _servicios.length) {
        _servicios.removeAt(index);
      }
    });
  }

  InputDecoration _inputDecoration({required String hint, required Color fill}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;
    final primary = TurnifyColors.primaryTeal;
    final labelColor = tt.bodyLarge?.color ?? cs.onBackground;
    final inputFill = isDark ? cs.surfaceVariant : TurnifyColors.cardBackground;
    final subtitleColor = cs.onSurface.withOpacity(0.7);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 1,
        leading: BackButton(color: primary),
        title: Text('Datos del Negocio', style: tt.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Nombre del negocio
                    Text('Nombre del negocio', style: tt.bodyLarge?.copyWith(color: labelColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nombreCtrl,
                      style: tt.bodyLarge?.copyWith(color: labelColor),
                      decoration: _inputDecoration(hint: 'Ej. Barbería Los Santos', fill: inputFill),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el nombre del negocio' : null,
                    ),
                    const SizedBox(height: 16),

                    // Dirección
                    Text('Dirección', style: tt.bodyLarge?.copyWith(color: labelColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _direccionCtrl,
                      style: tt.bodyLarge?.copyWith(color: labelColor),
                      decoration: _inputDecoration(hint: 'Ej. Fusagasugá, Cundinamarca', fill: inputFill),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese la dirección' : null,
                    ),
                    const SizedBox(height: 20),

                    // Horarios
                    Text('Horarios', style: tt.bodyLarge?.copyWith(color: labelColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ..._horarioCtrls.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: e.value,
                              style: tt.bodyMedium?.copyWith(color: labelColor),
                              decoration: _inputDecoration(hint: 'Horario', fill: inputFill),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese horario' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 100,
                            child: Text(e.key, textAlign: TextAlign.center, style: tt.bodySmall?.copyWith(color: subtitleColor)),
                          ),
                        ]),
                      );
                    }).toList(),

                    const SizedBox(height: 20),

                    // Servicios
                    Text('Servicios', style: tt.bodyLarge?.copyWith(color: labelColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    ListView.builder(
                      itemCount: _servicios.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, idx) {
                        final s = _servicios[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? cs.surface : TurnifyColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? cs.onSurface.withOpacity(0.06) : const Color(0xFFA2B2B1)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.02 : 0.03), blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                          child: Column(children: [
                            Row(children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: s.nombre,
                                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Nombre del servicio'),
                                  style: tt.bodyLarge?.copyWith(color: labelColor),
                                  onChanged: (val) => s.nombre = val,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese nombre del servicio' : null,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _eliminarServicio(idx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Servicio eliminado')),
                                  );
                                },
                                icon: Icon(Icons.delete_outline, color: cs.error),
                                tooltip: 'Eliminar servicio',
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              // Precio
                              Expanded(
                                child: TextFormField(
                                  initialValue: s.precio,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    hintText: 'Precio (\$)',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  onChanged: (val) => s.precio = val,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese precio' : null,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Duración
                              SizedBox(
                                width: 140,
                                child: TextFormField(
                                  initialValue: s.duracion,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    hintText: 'Duración (min)',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  onChanged: (val) => s.duracion = val,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese duración' : null,
                                ),
                              ),
                            ]),
                          ]),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Añadir servicio
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          _agregarServicio();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicio añadido')));
                        },
                        icon: Icon(Icons.add, color: primary),
                        label: Text('+ Añadir Servicio', style: tt.bodyMedium?.copyWith(color: primary, fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: isDark ? cs.surfaceVariant : Colors.transparent,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Guardar cambios
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await _guardarCambios();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Corrige los errores antes de guardar')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text('Guardar Cambios', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ]),
                ),
              ),
      ),

      // Bottom navigation (4 items: Inicio, Datos, Perfil, Soporte) — mantiene look adaptativo
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        currentIndex: 1, // por ejemplo: Datos
        onTap: (i) {
          // Implementa navegación local o push según arquitectura
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Datos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_outlined), activeIcon: Icon(Icons.support_agent), label: 'Soporte'),
        ],
      ),
    );
  }
}

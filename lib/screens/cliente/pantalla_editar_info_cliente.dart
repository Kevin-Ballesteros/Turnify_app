// lib/screens/pantalla_editar_info_cliente.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaEditarInfoCliente extends StatefulWidget {
  const PantallaEditarInfoCliente({super.key});

  @override
  State<PantallaEditarInfoCliente> createState() => _PantallaEditarInfoClienteState();
}

class _PantallaEditarInfoClienteState extends State<PantallaEditarInfoCliente> {
  final _formkey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController(text: 'José Fernando Campos');
  final _telefonoCtrl = TextEditingController(text: '+57 313 455 4666');
  final _correoCtrl = TextEditingController(text: 'josecampos@example.com');
  String generoSeleccionado = 'Masculino';

  // Mantengo la propiedad por si en el futuro quieres soportar imagenes
  File? _avatarFile;
  bool _picking = false;

  // Persistencia de color del avatar
  static const _kAvatarColorKey = 'avatar_color';
  int? _avatarColorValue;

  // Paleta de colores para el avatar
  final List<Color> _avatarPalette = [
    const Color(0xFFEF5350), // rojo
    const Color(0xFFFFA726), // naranja
    const Color(0xFFFFEB3B), // amarillo
    const Color(0xFF66BB6A), // verde
    const Color(0xFF29B6F6), // azul claro
    const Color(0xFF5C6BC0), // índigo
    const Color(0xFFAB47BC), // morado
    const Color(0xFF8D6E63), // marrón suave
    const Color(0xFF90A4AE), // gris azulado
  ];

  @override
  void initState() {
    super.initState();
    _loadAvatarColor();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAvatarColor() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_kAvatarColorKey);
    setState(() {
      _avatarColorValue = v ?? _avatarPalette.first.value;
    });
  }

  Future<void> _saveAvatarColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAvatarColorKey, color.value);
    setState(() => _avatarColorValue = color.value);
  }

  bool useWhiteForeground(Color backgroundColor, {double bias = 0.0}) {
    return backgroundColor.computeLuminance() < 0.5 + bias;
  }

  // Abre la paleta horizontal; llamada desde el icono lápiz
  void _mostrarSelectorDeColores() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Color del avatar', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _avatarPalette.map((c) {
                      final isSelected = _avatarColorValue == c.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            _saveAvatarColor(c);
                            Navigator.of(context).pop();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            width: isSelected ? 56 : 46,
                            height: isSelected ? 56 : 46,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: theme.colorScheme.onSurface.withOpacity(0.9), width: 3) : null,
                              boxShadow: isSelected ? [BoxShadow(color: c.withOpacity(0.22), blurRadius: 10, offset: const Offset(0, 4))] : null,
                            ),
                            child: isSelected
                                ? Icon(Icons.check, color: useWhiteForeground(c) ? Colors.white : Colors.black, size: 20)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar', style: TextStyle(color: theme.colorScheme.primary)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoEliminarCuenta() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            '¿Eliminar cuenta?',
            style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Esta acción es permanente. Se eliminará toda tu información y no podrás recuperar tu cuenta.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancelar', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cuenta eliminada exitosamente'),
                    backgroundColor: colorScheme.error,
                  ),
                );
              },
              child: Text('Eliminar', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFieldWithLabel({
    required String label,
    required Widget child,
    required ThemeData theme,
  }) {
    final  isDarkMode = theme.brightness == Brightness.dark; // Esto es para Verificar si el tema es oscuro, para asi mismo darle un color diferente
    final fieldColor = isDarkMode                         
        ? const Color.fromARGB(255, 56, 56, 56) 
        : const Color(0xFFF5F5F5);
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: fieldColor, 
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }

  Future<void> _onActualizar() async {
    if (!_formkey.currentState!.validate()) return;

    // Placeholder para sincronizar con backend: aquí enviarías nombre, telefono, correo, genero y avatar_color.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Perfil actualizado exitosamente'), backgroundColor: Theme.of(context).colorScheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final avatarBg = _avatarColorValue != null ? Color(_avatarColorValue!) : colorScheme.primary.withOpacity(0.12);
    final isDarkMode = theme.brightness == Brightness.dark; // Esto es lo mismo que la linea 147, para verificar si el tema es oscuro y pues asi mismo darle un color diferente a diferente tema 
    final fieldStyle = textTheme.bodyLarge?.copyWith(
      color: isDarkMode ? Colors.white : Colors.black,
      fontSize: 16,
    );
    final buttonTextStyle = textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 16);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Editar perfil', style: textTheme.titleLarge?.copyWith(color: const Color.fromARGB(255, 24, 186, 207), fontSize: 22, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Avatar
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: avatarBg,
                        backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
                        child: _avatarFile == null
                            ? Icon(Icons.person, size: 60, color: useWhiteForeground(avatarBg) ? Colors.white : Colors.black)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: const Color.fromARGB(255, 41, 193, 204),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _mostrarSelectorDeColores,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_picking) ...[
                  const SizedBox(height: 12),
                  const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)),
                ],
                const SizedBox(height: 40),

                // Nombre Completo
                _buildFieldWithLabel(
                  label: 'Nombre Completo',
                  theme: theme,
                  child: TextFormField(
                    controller: _nombreCtrl,
                    style: fieldStyle,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el nombre completo' : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Número Móvil
                _buildFieldWithLabel(
                  label: 'Número Móvil',
                  theme: theme,
                  child: TextFormField(
                    controller: _telefonoCtrl,
                    style: fieldStyle,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el número móvil' : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Correo
                _buildFieldWithLabel(
                  label: 'Correo',
                  theme: theme,
                  child: TextFormField(
                    controller: _correoCtrl,
                    style: fieldStyle,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el correo' : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Género
                _buildFieldWithLabel(
                  label: 'Género',
                  theme: theme,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: generoSeleccionado,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.black),
                      style: fieldStyle,
                      isDense: true,
                      items: ['Masculino', 'Femenino'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue == null) return;
                        setState(() => generoSeleccionado = newValue);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                // Botón Actualizar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onActualizar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 43, 188, 204),
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: Text('Actualizar', style: buttonTextStyle?.copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 30),
                // Botón Eliminar Cuenta
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _mostrarDialogoEliminarCuenta,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: Text('Eliminar Cuenta', style: buttonTextStyle?.copyWith(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
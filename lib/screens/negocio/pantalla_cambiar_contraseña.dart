// lib/screens/pantalla_cambiar_contrasena.dart
import 'package:flutter/material.dart';
import '/screens/pantalla_recuperar_password.dart';

// Colores de Turnify (fallback / tokens)
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color inputGray = Color(0xFFF0F0F0);
  static const Color lightTealBg = Color(0xFFD4F1EE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
}

class PantallaCambiarContrasena extends StatefulWidget {
  const PantallaCambiarContrasena({super.key});

  @override
  State<PantallaCambiarContrasena> createState() => _PantallaCambiarContrasenaState();
}

class _PantallaCambiarContrasenaState extends State<PantallaCambiarContrasena> {
  final _formkey = GlobalKey<FormState>();
  final _contrasenaActualCtrl = TextEditingController();
  final _nuevaContrasenaCtrl = TextEditingController();
  final _confirmarContrasenaCtrl = TextEditingController();

  bool _obscureActual = true;
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;

  // Estados de validación para los requisitos
  bool _longitudMinima = false;
  bool _letraMayuscula = false;
  bool _letraMinuscula = false;
  bool _numero = false;
  bool _caracterEspecial = false;
  bool _contrasenasCoinciden = false;

  @override
  void dispose() {
    _contrasenaActualCtrl.dispose();
    _nuevaContrasenaCtrl.dispose();
    _confirmarContrasenaCtrl.dispose();
    super.dispose();
  }

  void _validarNuevaContrasena(String password) {
    setState(() {
      _longitudMinima = password.length >= 8;
      _letraMayuscula = password.contains(RegExp(r'[A-Z]'));
      _letraMinuscula = password.contains(RegExp(r'[a-z]'));
      _numero = password.contains(RegExp(r'[0-9]'));
      _caracterEspecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _validarCoincidencia() {
    setState(() {
      _contrasenasCoinciden = _nuevaContrasenaCtrl.text.isNotEmpty &&
          _nuevaContrasenaCtrl.text == _confirmarContrasenaCtrl.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    // Colores adaptativos según el tema
    final bg = isDark ? colorScheme.background : Colors.white;
    final primary = const Color.fromARGB(255, 69, 227, 222);
    final onPrimary = Colors.white;
    final labelColor = isDark ? colorScheme.onBackground : Colors.black87;
    final hintColor = isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.black54;
    
    // Casillas: azul claro en modo claro, color adaptativo en modo oscuro
    final inputFill = isDark 
        ? colorScheme.surfaceVariant.withOpacity(0.5)
        : const Color.fromARGB(255, 221, 221, 221);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Cambiar Contraseña',
          style: textTheme.titleLarge?.copyWith(
            color: primary, 
            fontSize: 20, 
            fontWeight: FontWeight.w600
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo Contraseña Actual
                Text(
                  'Contraseña Actual',
                  style: textTheme.bodyLarge?.copyWith(
                    color: labelColor, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contrasenaActualCtrl,
                  obscureText: _obscureActual,
                  style: textTheme.bodyLarge?.copyWith(color: labelColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureActual ? Icons.visibility_off : Icons.visibility,
                        color: hintColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureActual = !_obscureActual;
                        });
                      },
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) 
                      ? 'Ingrese la contraseña actual' 
                      : null,
                ),

                const SizedBox(height: 12),

                // Link "Olvidó Su Contraseña?"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const PantallaRecuperarPassword()
                        )
                      );
                    },
                    child: Text(
                      'Olvidó Su Contraseña?',
                      style: textTheme.bodyMedium?.copyWith(
                        color: primary, 
                        fontSize: 13
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Campo Nueva Contraseña
                Text(
                  'Nueva Contraseña',
                  style: textTheme.bodyLarge?.copyWith(
                    color: labelColor, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nuevaContrasenaCtrl,
                  obscureText: _obscureNueva,
                  style: textTheme.bodyLarge?.copyWith(color: labelColor),
                  onChanged: (value) {
                    _validarNuevaContrasena(value);
                    _validarCoincidencia();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNueva ? Icons.visibility_off : Icons.visibility, 
                        color: hintColor
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNueva = !_obscureNueva;
                        });
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingrese la nueva contraseña';
                    }
                    if (!_longitudMinima || !_letraMayuscula || !_letraMinuscula || 
                        !_numero || !_caracterEspecial) {
                      return 'La contraseña no cumple los requisitos';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Requisitos de Contraseña
                Text(
                  'Requisitos de Contraseña:',
                  style: textTheme.bodyLarge?.copyWith(
                    color: labelColor, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 12),

                _buildRequisito(
                  'Al menos 8 caracteres', 
                  _longitudMinima, 
                  primary, 
                  labelColor
                ),
                _buildRequisito(
                  'Una letra mayúscula (A-Z)', 
                  _letraMayuscula, 
                  primary, 
                  labelColor
                ),
                _buildRequisito(
                  'Una letra minúscula (a-z)', 
                  _letraMinuscula, 
                  primary, 
                  labelColor
                ),
                _buildRequisito(
                  'Un número (0-9)', 
                  _numero, 
                  primary, 
                  labelColor
                ),
                _buildRequisito(
                  'Un carácter especial (!@#\$%...)', 
                  _caracterEspecial, 
                  primary, 
                  labelColor
                ),

                const SizedBox(height: 30),

                // Campo Confirmar Nueva Contraseña
                Text(
                  'Confirmar Nueva Contraseña',
                  style: textTheme.bodyLarge?.copyWith(
                    color: labelColor, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmarContrasenaCtrl,
                  obscureText: _obscureConfirmar,
                  style: textTheme.bodyLarge?.copyWith(color: labelColor),
                  onChanged: (value) {
                    _validarCoincidencia();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmar ? Icons.visibility_off : Icons.visibility,
                        color: hintColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmar = !_obscureConfirmar;
                        });
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Confirme la nueva contraseña';
                    }
                    if (v != _nuevaContrasenaCtrl.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Indicador de coincidencia
                _buildRequisito(
                  'Las contraseñas coinciden', 
                  _contrasenasCoinciden, 
                  primary, 
                  labelColor
                ),

                const SizedBox(height: 40),

                // Botón Cambiar Contraseña
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        // Mostrar mensaje de éxito
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Contraseña actualizada exitosamente'),
                            backgroundColor: TurnifyColors.primaryTeal,
                            duration: const Duration(seconds: 2),
                          ),
                        );

                        // Regresar a la pantalla anterior después de 1 segundo
                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 57, 189, 196),
                      foregroundColor: onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Cambiar Contraseña',
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600,
                        color: onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper: requisito con icono adaptativo
  Widget _buildRequisito(String texto, bool cumplido, Color primaryColor, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            cumplido ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: cumplido ? primaryColor : labelColor.withOpacity(0.6),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: cumplido ? primaryColor : labelColor.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '/screens/pantalla_recuperar_password.dart';

// Colores de Turnify
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
    return Scaffold(
      backgroundColor: TurnifyColors.white,
      appBar: AppBar(
        backgroundColor: TurnifyColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: TurnifyColors.textGray,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Cambiar Contraseña',
          style: TextStyle(
            color: Color.fromARGB(255, 67, 188, 180),
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
                  style: TextStyle(
                    color: TurnifyColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contrasenaActualCtrl,
                  obscureText: _obscureActual,
                  style: TextStyle(color: TurnifyColors.textGray),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 227, 227, 227),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureActual ? Icons.visibility_off : Icons.visibility,
                        color: TurnifyColors.textGray,
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaRecuperarPassword()));
                    },
                    child: Text(
                      'Olvidó Su Contraseña?',
                      style: TextStyle(
                        color: TurnifyColors.primaryTeal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Campo Nueva Contraseña
                Text(
                  'Nueva Contraseña',
                  style: TextStyle(
                    color: TurnifyColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nuevaContrasenaCtrl,
                  obscureText: _obscureNueva,
                  style: TextStyle(color: TurnifyColors.textGray),
                  onChanged: (value) {
                    _validarNuevaContrasena(value);
                    _validarCoincidencia();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 238, 238, 238),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNueva ? Icons.visibility_off : Icons.visibility,
                        color: TurnifyColors.textGray,
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
                  style: TextStyle(
                    color: TurnifyColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildRequisito('Al menos 8 caracteres', _longitudMinima),
                _buildRequisito('Una letra mayúscula (A-Z)', _letraMayuscula),
                _buildRequisito('Una letra minúscula (a-z)', _letraMinuscula),
                _buildRequisito('Un número (0-9)', _numero),
                _buildRequisito('Un carácter especial (!@#\$%...)', _caracterEspecial),
                
                const SizedBox(height: 30),
                
                // Campo Confirmar Nueva Contraseña
                Text(
                  'Confirmar Nueva Contraseña',
                  style: TextStyle(
                    color: TurnifyColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmarContrasenaCtrl,
                  obscureText: _obscureConfirmar,
                  style: TextStyle(color: TurnifyColors.textGray),
                  onChanged: (value) {
                    _validarCoincidencia();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 230, 230, 230),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmar ? Icons.visibility_off : Icons.visibility,
                        color: TurnifyColors.textGray,
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
                _buildRequisito('Las contraseñas coinciden', _contrasenasCoinciden),
                
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
                            content: Text('Contraseña actualizada exitosamente'),
                            backgroundColor: TurnifyColors.primaryTeal,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        
                        // Regresar a la pantalla anterior después de 1 segundo
                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.pop(context);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TurnifyColors.primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cambiar Contraseña',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  Widget _buildRequisito(String texto, bool cumplido) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            cumplido ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: cumplido ? TurnifyColors.primaryTeal : TurnifyColors.lightGray,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: cumplido ? TurnifyColors.primaryTeal : TurnifyColors.lightGray,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
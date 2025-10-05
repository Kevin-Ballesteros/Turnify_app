import 'package:flutter/material.dart';

// Colores de Turnify
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color inputGray = Color(0xFFF0F0F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color lightGreen = Color(0xFFE8F5E8);
}

class PantallaRecuperarPassword extends StatefulWidget {
  const PantallaRecuperarPassword({super.key});

  @override
  State<PantallaRecuperarPassword> createState() => _PantallaRecuperarPasswordState();
}

class _PantallaRecuperarPasswordState extends State<PantallaRecuperarPassword> {
  final _formkey = GlobalKey<FormState>();
  final _nuevaPasswordCtrl = TextEditingController();
  final _confirmarPasswordCtrl = TextEditingController();
  bool _obscureNuevaPassword = true;
  bool _obscureConfirmarPassword = true;

  // Estados de validación para los requisitos
  bool _mayuscula = false;
  bool _minuscula = false;
  bool _numero = false;
  bool _caracterEspecial = false;
  bool _longitudMinima = false;

  @override
  void dispose() {
    _nuevaPasswordCtrl.dispose();
    _confirmarPasswordCtrl.dispose();
    super.dispose();
  }

  void _validarPassword(String password) {
    setState(() {
      _mayuscula = password.contains(RegExp(r'[A-Z]'));
      _minuscula = password.contains(RegExp(r'[a-z]'));
      _numero = password.contains(RegExp(r'[0-9]'));
      _caracterEspecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _longitudMinima = password.length >= 8;
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
          'Nueva Contraseña',
          style: TextStyle(
            color: TurnifyColors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtítulo
                  Center(
                    child: Text(
                      'Crea una nueva contraseña para poder entrar a tu\ncuenta la próxima vez',
                      style: TextStyle(
                        color: TurnifyColors.lightGray,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Ícono de candado
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: TurnifyColors.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  Center(
                    child: Text(
                      'Tu nueva contraseña debe ser diferente a las\ncontraseñas utilizadas anteriormente.',
                      style: TextStyle(
                        color: TurnifyColors.textGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Campo Nueva contraseña
                  Text(
                    'Nueva contraseña',
                    style: TextStyle(
                      color: TurnifyColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nuevaPasswordCtrl,
                    obscureText: _obscureNuevaPassword,
                    style: TextStyle(color: TurnifyColors.textGray),
                    onChanged: _validarPassword,
                    decoration: InputDecoration(
                      hintText: 'Ingresar la nueva contraseña',
                      hintStyle: TextStyle(
                        color: TurnifyColors.lightGray,
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: TurnifyColors.inputGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNuevaPassword ? Icons.visibility_off : Icons.visibility,
                          color: TurnifyColors.lightGray,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNuevaPassword = !_obscureNuevaPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Campo Confirmar contraseña
                  Text(
                    'Confirmar contraseña',
                    style: TextStyle(
                      color: TurnifyColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmarPasswordCtrl,
                    obscureText: _obscureConfirmarPassword,
                    style: TextStyle(color: TurnifyColors.textGray),
                    decoration: InputDecoration(
                      hintText: 'confirmar la nueva contraseña',
                      hintStyle: TextStyle(
                        color: TurnifyColors.lightGray,
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: TurnifyColors.inputGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmarPassword ? Icons.visibility_off : Icons.visibility,
                          color: TurnifyColors.lightGray,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmarPassword = !_obscureConfirmarPassword;
                          });
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Confirme la contraseña';
                      }
                      if (v != _nuevaPasswordCtrl.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Requisitos de contraseña
                  Text(
                    'Tu contraseña debe tener:',
                    style: TextStyle(
                      color: TurnifyColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Lista de requisitos
                  _buildRequisito('Al menos 8 caracteres', _longitudMinima),
                  _buildRequisito('Una letra minúscula', _minuscula),
                  _buildRequisito('Una letra mayúscula', _mayuscula),
                  _buildRequisito('Un número', _numero),
                  _buildRequisito('Un caracter especial (!@#\$%*)', _caracterEspecial),
                  _buildRequisito('Las contraseñas deben coincidir', _nuevaPasswordCtrl.text.isNotEmpty && _confirmarPasswordCtrl.text.isNotEmpty && _nuevaPasswordCtrl.text == _confirmarPasswordCtrl.text,),
                  
                  const SizedBox(height: 40),
                  
                  // Botón Actualizar Contraseña
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          if (_mayuscula && _minuscula && _numero && _caracterEspecial && _longitudMinima) {
                            print('Actualizando contraseña...');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contraseña actualizada exitosamente')),
                            );
                            
                            // Esperar un poco para mostrar el mensaje y luego navegar
                            Future.delayed(const Duration(seconds: 2), () {
                              // Regresar a la pantalla de login
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('La contraseña no cumple todos los requisitos')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TurnifyColors.primaryTeal,
                        foregroundColor: TurnifyColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Actualizar Contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
            cumplido ? Icons.check_circle : Icons.radio_button_unchecked,
            color: cumplido ? Colors.green : TurnifyColors.lightGray,
            size: 16,
          ),
          const SizedBox(width: 12),
          Text(
            texto,
            style: TextStyle(
              color: cumplido ? Colors.green : TurnifyColors.lightGray,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
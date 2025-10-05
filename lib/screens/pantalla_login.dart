import 'package:flutter/material.dart';
import 'package:turnify/screens/pantalla_registro.dart';
import 'pantalla_recuperar_password.dart';

// Colores de Turnify
class TurnifyColors {
  static const Color primaryTeal = Color(0xFF4ECDC4);
  static const Color lightTeal = Color(0xFF7FE8E2);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color inputGray = Color(0xFFF0F0F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
}

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formkey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _aceptaTerminos = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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
          'Inicio Sesión',
          style: TextStyle(
            color: TurnifyColors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtítulo
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Bienvenido/a inicio sesión',
                        style: TextStyle(
                          color: TurnifyColors.lightGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'con tu cuenta',
                        style: TextStyle(
                          color: TurnifyColors.lightGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              
                const SizedBox(height: 30),
                
                // Campo Nombre registrado
                Text(
                  'Nombre registrado',
                  style: TextStyle(
                    color: TurnifyColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombreCtrl,
                  style: TextStyle(color: TurnifyColors.textGray),
                  decoration: InputDecoration(
                    hintText: 'nombre completo',
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
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingrese el nombre'
                      : null,
                ),
                
                const SizedBox(height: 20),
                
                // Campo Dirección Email
                Text(
                  'Dirección Email',
                  style: TextStyle(
                    color: TurnifyColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  style: TextStyle(color: TurnifyColors.textGray),
                  decoration: InputDecoration(
                    hintText: 'correo electrónico',
                    hintStyle: TextStyle(
                      color: TurnifyColors.lightGray,
                      fontSize: 14,
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
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingrese el email'
                      : null,
                ),
                
                const SizedBox(height: 20),
                
                // Campo Contraseña
                Text(
                  'Contraseña',
                  style: TextStyle(
                    color: TurnifyColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: TurnifyColors.textGray),
                  decoration: InputDecoration(
                    hintText: '• • • • • • • • • • • • •',
                    hintStyle: TextStyle(
                      color: TurnifyColors.lightGray,
                      fontSize: 14,
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
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: TurnifyColors.lightGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingrese la contraseña'
                      : null,
                ),
                
                const SizedBox(height: 16),
                
                // Olvidé mi contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PantallaRecuperarPassword()),
                      );
                    },
                    child: Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(
                        color: TurnifyColors.primaryTeal,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Botón Iniciar sesión
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_aceptaTerminos) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Debe aceptar los términos y condiciones')),
                        );
                        return;
                      }
                      
                      if (_formkey.currentState!.validate()) {
                        print('Iniciando sesión...');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Iniciando sesión...')),
                        );
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
                      'iniciar sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Link de "¿No tienes cuenta? Crear cuenta."
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PantallaRegistro()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: TurnifyColors.textGray,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: 'Ya tienes una cuenta? '),
                          TextSpan(
                            text: 'Crear cuenta',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                   const SizedBox(height: 40),
                
                // Checkbox Términos y condiciones
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _aceptaTerminos,
                      onChanged: (value) {
                        setState(() {
                          _aceptaTerminos = value ?? false;
                        });
                      },
                      activeColor: TurnifyColors.primaryTeal,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: TurnifyColors.textGray,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(text: 'He leído y acepto los '),
                              TextSpan(
                                text: 'Términos de uso',
                                style: TextStyle(
                                  color: TurnifyColors.primaryTeal,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: ' y la '),
                              TextSpan(
                                text: 'Política de privacidad',
                                style: TextStyle(
                                  color: TurnifyColors.primaryTeal,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
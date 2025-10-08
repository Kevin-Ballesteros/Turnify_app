import 'package:flutter/material.dart';
import 'pantalla_login.dart';
import 'cliente/pantalla_dashboard_cliente.dart';
import 'negocio/pantalla_dashboard_negocio.dart';

// Colores de Turnify
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color inputGray = Color(0xFFF0F0F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
}

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formkey = GlobalKey<FormState>();
  bool esCliente = true; // true = Cliente, false = Negocio

  // Controladores comunes
  final _nombreCompletoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmarPasswordCtrl = TextEditingController();

  // Controladores solo para Negocio
  final _nombreNegocioCtrl = TextEditingController();
  final _descripcionNegocioCtrl = TextEditingController();
  final _otroTipoNegocioCtrl = TextEditingController();
  String tipoNegocioSeleccionado = 'Restaurante';

  bool _obscurePassword = true;
  bool _obscureConfirmarPassword = true;
  bool _aceptaTerminos = false;

  // Variables para validación de contraseña (Mantenidas para los checks)
  bool _tieneMayuscula = false;
  bool _tieneMinuscula = false;
  bool _tieneNumero = false;
  bool _tieneCaracterEspecial = false;
  bool _tieneLongitudMinima = false;
  // ELIMINADAS: _fortalezaPassword y _colorFortaleza

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_validarFortalezaPassword);
  }

  @override
  void dispose() {
    _nombreCompletoCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmarPasswordCtrl.dispose();
    _nombreNegocioCtrl.dispose();
    _descripcionNegocioCtrl.dispose();
    _otroTipoNegocioCtrl.dispose();
    super.dispose();
  }

  void _validarFortalezaPassword() {
    final password = _passwordCtrl.text;
    setState(() {
      _tieneMayuscula = password.contains(RegExp(r'[A-Z]'));
      _tieneMinuscula = password.contains(RegExp(r'[a-z]'));
      _tieneNumero = password.contains(RegExp(r'[0-9]'));
      _tieneCaracterEspecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _tieneLongitudMinima = password.length >= 8;

    });
  }

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese la contraseña';
    }
    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe contener al menos una minúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Debe contener al menos un carácter especial (!@#\$%^&*...)';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un email válido';
    }
    return null;
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
          'únete a turnify',
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
                  child: Text(
                    esCliente ? 'Crea tu cuenta de cliente' : 'Crea tu cuenta de\nnegocio',
                    style: TextStyle(
                      color: TurnifyColors.lightGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Toggle Cliente / Negocio
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            esCliente = true;
                          });
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: esCliente ? TurnifyColors.primaryTeal : Colors.grey[200],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: esCliente ? Colors.white : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cliente',
                                style: TextStyle(
                                  color: esCliente ? Colors.white : Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            esCliente = false;
                          });
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: !esCliente ? TurnifyColors.primaryTeal : Colors.grey[200],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.business_outlined,
                                color: !esCliente ? Colors.white : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Negocio',
                                style: TextStyle(
                                  color: !esCliente ? Colors.white : Colors.grey[600],
                                  fontSize: 16,
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

                const SizedBox(height: 30),

                // Campo Nombre completo / Nombre del propietario
                Text(
                  esCliente ? 'Nombre completo' : 'Nombre completo del propietario',
                  style: TextStyle(
                    color: TurnifyColors.textGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombreCompletoCtrl,
                  style: TextStyle(color: TurnifyColors.textGray),
                  decoration: InputDecoration(
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
                      ? 'Ingrese el nombre completo'
                      : null,
                ),

                const SizedBox(height: 20),

                // Campo Dirección Email
                Text(
                  'Dirección email',
                  style: TextStyle(
                    color: TurnifyColors.textGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  style: TextStyle(color: TurnifyColors.textGray),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
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
                  validator: _validarEmail,
                ),

                const SizedBox(height: 20),

                // Campo Contraseña
                Text(
                  'Contraseña',
                  style: TextStyle(
                    color: TurnifyColors.textGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: TurnifyColors.textGray),
                  decoration: InputDecoration(
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
                  validator: _validarPassword,
                ),

                // Lista de requisitos de contraseña (SIEMPRE VISIBLE)
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequisitoItem('Al menos 8 caracteres', _tieneLongitudMinima),
                    _buildRequisitoItem('Una letra mayúscula (A-Z)', _tieneMayuscula),
                    _buildRequisitoItem('Una letra minúscula (a-z)', _tieneMinuscula),
                    _buildRequisitoItem('Un número (0-9)', _tieneNumero),
                    _buildRequisitoItem('Un carácter especial (!@#\$%...)', _tieneCaracterEspecial),
                  ],
                ),


                const SizedBox(height: 20),

                // Campo Confirmar Contraseña
                Text(
                  'Confirmar contraseña',
                  style: TextStyle(
                    color: TurnifyColors.textGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmarPasswordCtrl,
                  obscureText: _obscureConfirmarPassword,
                  style: TextStyle(color: TurnifyColors.textGray),
                  decoration: InputDecoration(
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
                    if (v != _passwordCtrl.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),

                // Campos específicos para Negocio
                if (!esCliente) ...[
                  const SizedBox(height: 30),

                  // Título sección negocio
                  Text(
                    'Información del negocio',
                    style: TextStyle(
                      color: TurnifyColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Campo Nombre del negocio
                  Text(
                    'Nombre del negocio',
                    style: TextStyle(
                      color: TurnifyColors.textGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nombreNegocioCtrl,
                    style: TextStyle(color: TurnifyColors.textGray),
                    decoration: InputDecoration(
                      hintText: 'Ej: La Pizzería de Jhon',
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
                        ? 'Ingrese el nombre del negocio'
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // Dropdown Tipo de negocio
                  Text(
                    'Seleccionar tipo de negocio',
                    style: TextStyle(
                      color: TurnifyColors.textGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: TurnifyColors.inputGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tipoNegocioSeleccionado,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: TurnifyColors.lightGray),
                        items: [
                          'Restaurante',
                          'Peluquería',
                          'Consultorio médico',
                          'Gimnasio',
                          'Spa',
                          'Taller mecánico',
                          'Otro'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: TurnifyColors.textGray),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            tipoNegocioSeleccionado = newValue!;
                            if (tipoNegocioSeleccionado != 'Otro') {
                              _otroTipoNegocioCtrl.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ),

                  // Campo de texto para "Otro" tipo de negocio
                  if (tipoNegocioSeleccionado == 'Otro') ...[
                    const SizedBox(height: 20),
                    Text(
                      'Especificar tipo de negocio',
                      style: TextStyle(
                        color: TurnifyColors.textGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _otroTipoNegocioCtrl,
                      style: TextStyle(color: TurnifyColors.textGray),
                      decoration: InputDecoration(
                        hintText: 'Ej: Barbería, Salón de belleza, etc.',
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
                          ? 'Especifique el tipo de negocio'
                          : null,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Campo Descripción del negocio
                  Text(
                    'Descripción breve del negocio',
                    style: TextStyle(
                      color: TurnifyColors.textGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descripcionNegocioCtrl,
                    maxLines: 3,
                    style: TextStyle(color: TurnifyColors.textGray),
                    decoration: InputDecoration(
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
                        ? 'Ingrese una descripción'
                        : null,
                  ),
                ],

                const SizedBox(height: 30),

                // Checkbox Términos
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
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(text: 'Al crear una cuenta, acepta nuestros '),
                              TextSpan(
                                text: 'Términos de servicio',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Política de privacidad',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Botón Crear cuenta
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
                        print('Creando cuenta ${esCliente ? "Cliente" : "Negocio"}...');

                        // Navegar según el tipo de cuenta
                        if (esCliente) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardCliente()),
                          );
                        } else {
                          // Navegar al dashboard de negocio
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardNegocio()),
                          );
                        }
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
                    child: Text(
                      esCliente ? 'Crear cuenta cliente' : 'Crear cuenta negocio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Link "Ya tienes cuenta"
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PantallaLogin()),
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
                            text: 'Inicia sesión',
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequisitoItem(String texto, bool cumplido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            cumplido ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: cumplido ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: cumplido ? Colors.green : TurnifyColors.lightGray,
              fontSize: 12,
              fontWeight: cumplido ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
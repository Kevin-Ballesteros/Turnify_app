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
}

class PantallaEditarInfoCliente extends StatefulWidget {
  const PantallaEditarInfoCliente({super.key});

  @override
  State<PantallaEditarInfoCliente> createState() => _PantallaPerfilClienteState();
}

class _PantallaPerfilClienteState extends State<PantallaEditarInfoCliente> {
  final _formkey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController(text: 'José Fernando Campos');
  final _telefonoCtrl = TextEditingController(text: '+57 313 455 4666');
  final _correoCtrl = TextEditingController(text: 'josecampos@example.com');
  String generoSeleccionado = 'Masculino';

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
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
          'Perfil',
          style: TextStyle(
            color: TurnifyColors.primaryTeal,
            fontSize: 22,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Avatar con icono de editar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: TurnifyColors.lightTeal,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: TurnifyColors.white,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TurnifyColors.primaryTeal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Campo Nombre Completo
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nombre Completo',
                    style: TextStyle(
                      color: TurnifyColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombreCtrl,
                  style: TextStyle(color: TurnifyColors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: TurnifyColors.inputGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                
                const SizedBox(height: 24),
                
                // Campo Número Móvil
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Número Móvil',
                    style: TextStyle(
                      color: TurnifyColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _telefonoCtrl,
                  style: TextStyle(color: TurnifyColors.black),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: TurnifyColors.inputGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingrese el número móvil'
                      : null,
                ),
                
                const SizedBox(height: 24),
                
                // Campo Correo
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Correo',
                    style: TextStyle(
                      color: TurnifyColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _correoCtrl,
                  style: TextStyle(color: TurnifyColors.black),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: TurnifyColors.inputGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingrese el correo'
                      : null,
                ),
                
                const SizedBox(height: 24),
                
                // Campo Género
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Género',
                    style: TextStyle(
                      color: TurnifyColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: TurnifyColors.inputGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: generoSeleccionado,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: TurnifyColors.lightGray),
                      style: TextStyle(color: TurnifyColors.black, fontSize: 16),
                      items: ['Masculino', 'Femenino', 'Otro'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          generoSeleccionado = newValue!;
                        });
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
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        print('Actualizando perfil...');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perfil actualizado exitosamente'),
                            backgroundColor: TurnifyColors.primaryTeal,
                          ),
                        );
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
                      'Actualizar',
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
}
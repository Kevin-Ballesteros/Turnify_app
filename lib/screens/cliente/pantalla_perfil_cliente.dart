import 'package:flutter/material.dart';
import 'pantalla_configuracion_cliente.dart';
import 'pantalla_editar_info_cliente.dart';

class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color cardBackground = Color(0xFFF5F5F5);
}

class PantallaPerfilCliente extends StatefulWidget {
  const PantallaPerfilCliente({super.key});

  @override
  State<PantallaPerfilCliente> createState() => _PantallaPerfilClienteState();
}

class _PantallaPerfilClienteState extends State<PantallaPerfilCliente> {

  void _mostrarDialogoSalir() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres salir de Turnify?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text(
                'Aceptar',
                style: TextStyle(color: TurnifyColors.primaryTeal),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                print('Cerrando sesión...');
                // Aquí puedes agregar la lógica para cerrar sesión
                // Por ejemplo: Navigator.pushAndRemoveUntil(...) para ir a login
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: TurnifyColors.primaryTeal),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TurnifyColors.white,
      appBar: AppBar(
        backgroundColor: TurnifyColors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Quita la flecha de regreso
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Color.fromARGB(255, 54, 54, 54),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Círculo de perfil grande
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: TurnifyColors.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nombre del usuario
              Text(
                'José Fernando Campos',
                style: TextStyle(
                  color: TurnifyColors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),

              // Opciones de perfil en cards
              
              _buildProfileOption(
                icon: Icons.person_outline,
                title: 'Perfil',
                onTap: () {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const PantallaEditarInfoCliente()),
                  );
                },
              ),
              const SizedBox(height: 15),

              _buildProfileOption(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                onTap: () {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const PantallaConfiguracionCliente()),
                  );
                },
              ),
              const SizedBox(height: 15),

              _buildProfileOption(
                icon: Icons.logout,
                title: 'Salir',
                onTap: _mostrarDialogoSalir,
              ),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    }) {
    return Material(
      color: Colors.transparent, // permite usar InkWell ripple sobre cualquier fondo
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color.fromARGB(255, 160, 160, 160).withOpacity(0.16),
        highlightColor: const Color.fromARGB(255, 90, 90, 90).withOpacity(0.08),
        child: Ink(
          decoration: BoxDecoration(
            color: TurnifyColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: TurnifyColors.primaryTeal, size: 28),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: TurnifyColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: TurnifyColors.lightGray, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
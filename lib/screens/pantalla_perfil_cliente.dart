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
            color: TurnifyColors.black,
          ),
          onPressed: () {
            // Esto solo es funcional si se navega a la pantalla (Navigator.push)
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Mi Perfil',
          style: TextStyle(
            color: TurnifyColors.black,
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

              // Opciones de perfil
              _buildProfileOption(
                icon: Icons.person_outline,
                title: 'Perfil',
                onTap: () {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const PantallaEditarInfoCliente()),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildProfileOption(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                onTap: () {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const PantallaConfiguracionCliente()),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildProfileOption(
                icon: Icons.logout,
                title: 'Salir',
                onTap: () {
                  print('Cerrar Sesión');
                },
              ),
            ],
          ),
        ),
      ),
      // Aquí iba el BottomNavigationBar que eliminamos
    );
  }

  // Widget auxiliar para crear las opciones de perfil
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: TurnifyColors.lightGray.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
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
    );
  }
}
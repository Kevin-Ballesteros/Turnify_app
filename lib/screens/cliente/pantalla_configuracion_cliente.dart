import 'package:flutter/material.dart';
import 'package:turnify/screens/cliente/pantalla_configuracion_notificaciones.dart';
import "pantalla_cambiar_contraseña.dart";

class TurnifyColors {
 static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
 static const Color textGray = Color(0xFF666666);
 static const Color white = Color(0xFFFFFFFF);
}

class PantallaConfiguracionCliente extends StatelessWidget {
  const PantallaConfiguracionCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TurnifyColors.white,
      appBar: AppBar(
        // Estilo del AppBar (fondo blanco, sin sombra)
        backgroundColor: const Color.fromARGB(255, 244, 244, 244),
        elevation: 0,
        // Botón de regreso
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: TurnifyColors.primaryTeal),
          onPressed: () {
            // Navegación para volver a la pantalla anterior
            Navigator.pop(context);
          },
        ),
        // Título centralizado
        title: const Text(
          'Configuración',
          style: TextStyle(
            color: TurnifyColors.primaryTeal,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Opción 1: Contraseña
          _buildConfigurationTile(
            icon: Icons.vpn_key_outlined,
            title: 'Actualizar Contraseña',
            onTap: () {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => const PantallaCambiarContrasena()),
              );
            },
          ),

          // Opción 2: Modo Oscuro
          _buildConfigurationTile(
            icon: Icons.dark_mode_outlined,
            title: 'Modo Oscuro',
            onTap: () {
              print('Alternar Modo Oscuro (Implementar lógica de tema)');
            },
          ),

          // Opción 3: Información Personal
          _buildConfigurationTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            onTap: () {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => const PantallaConfiguracionNotificaciones()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Método auxiliar para construir cada fila de configuración
  Widget _buildConfigurationTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: TurnifyColors.primaryTeal,
        size: 28,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: TurnifyColors.textGray,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
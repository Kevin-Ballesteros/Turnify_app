import 'package:flutter/material.dart';
import 'pantalla_editar_info_cliente.dart';
import 'pantalla_cambiar_contraseña.dart';

// Colores de Turnify
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color cardBackground = Color(0xFFF5F5F5);
  static const Color subtitleGray = Color(0xFF9CA3AF);
}

class PantallaConfiguracionCliente extends StatelessWidget {
  const PantallaConfiguracionCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TurnifyColors.cardBackground,
      appBar: AppBar(
        backgroundColor: TurnifyColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: TurnifyColors.primaryTeal,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configuración',
          style: TextStyle(
            color: TurnifyColors.primaryTeal,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          // Sección: Cuenta
          _buildSectionHeader('Cuenta'),
          const SizedBox(height: 12),
          
          _buildConfigCard(
            icon: Icons.person_outline,
            title: 'Perfil',
            subtitle: 'Ver y editar tu información',
            iconColor: TurnifyColors.primaryTeal,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaEditarInfoCliente()));
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildConfigCard(
            icon: Icons.vpn_key_outlined,
            title: 'Actualizar Contraseña',
            subtitle: 'Cambia tu contraseña periódicamente',
            iconColor: Colors.orange,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaCambiarContrasena()));
            },
          ),

          const SizedBox(height: 24),

          // Sección: Preferencias
          _buildSectionHeader('Preferencias'),
          const SizedBox(height: 12),
          
          _buildConfigCard(
            icon: Icons.dark_mode_outlined,
            title: 'Modo Oscuro',
            subtitle: 'Elegir tema de la aplicación',
            iconColor: Colors.indigo,
            onTap: () {
              print('Ir a Modo Oscuro');
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildConfigCard(
            icon: Icons.notifications_none_outlined,
            title: 'Notificaciones',
            subtitle: 'Configurar alertas y recordatorios',
            iconColor: Colors.amber,
            onTap: () {
              print('Ir a Notificaciones');
            },
          ),
          
          const SizedBox(height: 12),

          // Sección: Soporte y ayuda
          _buildSectionHeader('Soporte y ayuda'),
          const SizedBox(height: 12),
          
          _buildConfigCard(
            icon: Icons.question_answer_outlined,
            title: 'Preguntas frecuentes',
            subtitle: 'Respuestas a dudas comunes',
            iconColor: Colors.purple,
            onTap: () {
              print('Ir a Preguntas frecuentes');
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildConfigCard(
            icon: Icons.build_outlined,
            title: 'Soporte Técnico',
            subtitle: 'Reporta problemas técnicos',
            iconColor: Colors.red,
            onTap: () {
              print('Ir a Soporte Técnico');
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildConfigCard(
            icon: Icons.info_outline,
            title: 'Acerca de Turnify',
            subtitle: 'Versión 1.0 - Términos y más',
            iconColor: Colors.teal,
            onTap: () {
              print('Ir a Acerca de Turnify');
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildConfigCard(
            icon: Icons.mail_outline,
            title: 'Contáctanos',
            subtitle: 'Envíanos tus comentarios',
            iconColor: Colors.green,
            onTap: () {
              print('Ir a Contáctanos');
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildConfigCard(
            icon: Icons.star_outline,
            title: 'Califica la App',
            subtitle: 'Ayúdanos a mejorar',
            iconColor: Colors.yellow[700]!,
            onTap: () {
              print('Ir a Calificar App');
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildConfigCard(
            icon: Icons.share_outlined,
            title: 'Compartir App',
            subtitle: 'Invita a tus amigos',
            iconColor: Colors.blueAccent,
            onTap: () {
              print('Compartir App');
            },
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: TurnifyColors.textGray,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildConfigCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color.fromARGB(255, 167, 167, 167).withOpacity(0.3),
        highlightColor: const Color.fromARGB(255, 215, 215, 215).withOpacity(0.1),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TurnifyColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Ícono con fondo de color
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: TurnifyColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: TurnifyColors.subtitleGray,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                color: TurnifyColors.lightGray,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
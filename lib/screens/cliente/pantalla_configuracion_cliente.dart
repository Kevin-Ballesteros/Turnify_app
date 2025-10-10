import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pantalla_editar_info_cliente.dart';
import 'pantalla_cambiar_contraseña.dart';
import 'pantalla_configuracion_notificaciones.dart';
import 'package:turnify/screens/pantalla_modo_oscuro.dart';

class PantallaConfiguracionCliente extends StatelessWidget {
  const PantallaConfiguracionCliente({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configuración',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.primaryColor,
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
          _buildSectionHeader(context, 'Cuenta'),
          const SizedBox(height: 12),

          _buildConfigCard(
            context: context,
            icon: Icons.person_outline,
            title: 'Perfil',
            subtitle: 'Ver y editar tu información',
            iconColor: theme.primaryColor,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaEditarInfoCliente()));
            },
          ),

          const SizedBox(height: 12),

          _buildConfigCard(
            context: context,
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
          _buildSectionHeader(context, 'Preferencias'),
          const SizedBox(height: 12),

          _buildConfigCard(
            context: context,
            icon: Icons.dark_mode_outlined,
            title: 'Modo Oscuro',
            subtitle: 'Elegir tema de la aplicación',
            iconColor: Colors.indigo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaModoOscuro(
                    onTemaChanged: (tema) async {
                      // Callback: el main ya persiste y aplica el tema, aquí solo persiste adicionalmente si quieres
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('tema', tema);
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _buildConfigCard(
            context: context,
            icon: Icons.notifications_none_outlined,
            title: 'Notificaciones',
            subtitle: 'Configurar alertas y recordatorios',
            iconColor: Colors.amber,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaConfiguracionNotificaciones()));
            },
          ),

          const SizedBox(height: 12),

          // Sección: Soporte y ayuda
          _buildSectionHeader(context, 'Soporte y ayuda'),
          const SizedBox(height: 12),

          _buildConfigCard(
            context: context,
            icon: Icons.question_answer_outlined,
            title: 'Preguntas frecuentes',
            subtitle: 'Respuestas a dudas comunes',
            iconColor: Colors.purple,
            onTap: () {
              debugPrint('Ir a Preguntas frecuentes');
            },
          ),

          const SizedBox(height: 12),

          _buildConfigCard(
            context: context,
            icon: Icons.build_outlined,
            title: 'Soporte Técnico',
            subtitle: 'Reporta problemas técnicos',
            iconColor: Colors.red,
            onTap: () {
              debugPrint('Ir a Soporte Técnico');
            },
          ),

          const SizedBox(height: 12),

          _buildConfigCard(
            context: context,
            icon: Icons.info_outline,
            title: 'Acerca de Turnify',
            subtitle: 'Versión 1.0 - Términos y más',
            iconColor: theme.primaryColor,
            onTap: () {
              debugPrint('Ir a Acerca de Turnify');
            },
          ),

          const SizedBox(height: 12),

          _buildConfigCard(
            context: context,
            icon: Icons.mail_outline,
            title: 'Contáctanos',
            subtitle: 'Envíanos tus comentarios',
            iconColor: Colors.green,
            onTap: () {
              debugPrint('Ir a Contáctanos');
            },
          ),

          const SizedBox(height: 12),

          _buildConfigCard(
            context:context,
            icon: Icons.star_outline,
            title: 'Califica la App',
            subtitle: 'Ayúdanos a mejorar',
            iconColor: Colors.yellow[700]!,
            onTap: () {
              debugPrint('Ir a Calificar App');
            },
          ),

          const SizedBox(height: 12),

          _buildConfigCard(
            context: context,
            icon: Icons.share_outlined,
            title: 'Compartir App',
            subtitle: 'Invita a tus amigos',
            iconColor: Colors.blueAccent,
            onTap: () {
              debugPrint('Compartir App');
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.textTheme.bodyLarge?.color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildConfigCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: theme.primaryColor.withOpacity(0.12),
        highlightColor: theme.primaryColor.withOpacity(0.06),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.08 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Ícono con fondo de color (acento)
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
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
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
                color: theme.iconTheme.color ?? Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/screens/pantalla_perfil_cliente.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/user_provider.dart';
import 'pantalla_configuracion_cliente.dart';
import 'pantalla_editar_info_cliente.dart';
import 'package:turnify/screens/pantalla_bienvenida.dart';

class PantallaPerfilCliente extends StatefulWidget {
  const PantallaPerfilCliente({super.key});

  @override
  State<PantallaPerfilCliente> createState() => _PantallaPerfilClienteState();
}

class _PantallaPerfilClienteState extends State<PantallaPerfilCliente> {
  void _mostrarDialogoSalir() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text('Cerrar Sesión', style: theme.textTheme.titleLarge),
          content: Text('¿Estás seguro de que quieres salir de Turnify?', style: theme.textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar', style: TextStyle(color: colorScheme.primary)),
            ),
            TextButton(
              onPressed: () {
                // Aquí deberías llamar a userProvider.clearUser() si tienes lógica de cierre de sesión
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const Pantalla1()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Aceptar', style: TextStyle(color: colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Acceder al UserProvider para obtener los datos dinámicos
    final userProvider = context.watch<UserProvider>(); 
    final String userName = userProvider.customerName; 
    final Color avatarColor = userProvider.avatarColor;
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final surface = theme.cardColor;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final splash = colorScheme.onSurface.withOpacity(0.06);
    final highlight = colorScheme.onSurface.withOpacity(0.03);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Mi Perfil',
          style: textTheme.titleLarge?.copyWith(color: const Color.fromARGB(244, 30, 184, 171), fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 2. CircleAvatar con color dinámico
              CircleAvatar(
                radius: 70,
                // Fondo con el color del avatar + opacidad
                backgroundColor: avatarColor.withOpacity(0.12),
                child: Icon(
                  Icons.person,
                  // Color del icono es el color del avatar
                  color: avatarColor,
                  size: 85,
                ),
              ),
              const SizedBox(height: 20),
              // 3. Nombre del cliente dinámico
              Text(
                userName.isNotEmpty ? userName : 'Cliente Turnify', 
                style: textTheme.headlineSmall?.copyWith(color: textTheme.titleLarge?.color, fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              // 4. Opciones con color de ícono dinámico
              _buildProfileOption(
                icon: Icons.person_outline,
                title: 'Perfil',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaEditarInfoCliente())),
                surface: surface,
                iconColor: avatarColor, // Usar el color del avatar
                titleStyle: textTheme.titleMedium,
                splashColor: splash,
                highlightColor: highlight,
              ),
              const SizedBox(height: 15),
              _buildProfileOption(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaConfiguracionCliente())),
                surface: surface,
                iconColor: avatarColor, // Usar el color del avatar
                titleStyle: textTheme.titleMedium,
                splashColor: splash,
                highlightColor: highlight,
              ),
              const SizedBox(height: 15),
              _buildProfileOption(
                icon: Icons.logout,
                title: 'Salir',
                onTap: _mostrarDialogoSalir,
                surface: surface,
                iconColor: avatarColor, // Usar el color del avatar
                titleStyle: textTheme.titleMedium,
                splashColor: splash,
                highlightColor: highlight,
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
    required Color surface,
    required Color iconColor,
    required TextStyle? titleStyle,
    required Color splashColor,
    required Color highlightColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: Ink(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: titleStyle?.copyWith(color: titleStyle.color ?? Theme.of(context).textTheme.titleLarge?.color, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Theme.of(context).dividerColor, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
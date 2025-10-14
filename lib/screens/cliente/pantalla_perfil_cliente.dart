// lib/screens/pantalla_perfil_cliente.dart
import 'package:flutter/material.dart';
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
          style: textTheme.titleLarge?.copyWith(color: Color.fromARGB(244, 30, 184, 171), fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundColor: Color.fromARGB(244, 30, 184, 171).withOpacity(0.12),
                child: Icon(
                  Icons.person,
                  color: Color.fromARGB(244, 165, 224, 218),
                  size: 85,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'José Fernando Campos',
                style: textTheme.headlineSmall?.copyWith(color: textTheme.titleLarge?.color, fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              _buildProfileOption(
                icon: Icons.person_outline,
                title: 'Perfil',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaEditarInfoCliente())),
                surface: surface,
                iconColor: Color.fromARGB(244, 30, 184, 171),
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
                iconColor: Color.fromARGB(244, 30, 184, 171),
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
                iconColor: Color.fromARGB(244, 30, 184, 171),
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
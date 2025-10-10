import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_manager.dart';

class PantallaModoOscuro extends StatefulWidget {
  final Function(String) onTemaChanged;

  const PantallaModoOscuro({
    super.key,
    required this.onTemaChanged,
  });

  @override
  State<PantallaModoOscuro> createState() => _PantallaModoOscuroState();
}

class _PantallaModoOscuroState extends State<PantallaModoOscuro> {
  String temaSeleccionado = 'light';

  @override
  void initState() {
    super.initState();
    _cargarTemaInicial();
  }

  void _cargarTemaInicial() {
    final tm = Provider.of<ThemeManager>(context, listen: false);
    final mode = tm.themeMode;
    setState(() {
      temaSeleccionado = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system';
    });
  }

  void _cambiarTema(String nuevoTema) async {
    setState(() {
      temaSeleccionado = nuevoTema;
    });

    // Usar ThemeManager para persistir y notificar a la app completa
    Provider.of<ThemeManager>(context, listen: false).cambiarTema(nuevoTema);

    // Mantener callback opcional externo si se usa en otras partes
    try {
      widget.onTemaChanged(nuevoTema);
    } catch (_) {}

    final mensajeTema = nuevoTema == 'light'
        ? 'Tema Claro activado'
        : nuevoTema == 'dark'
            ? 'Tema Oscuro activado'
            : 'Tema del Sistema activado';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(mensajeTema),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textSecondary = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final cardColor = theme.cardColor;
    final primary = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Modo Oscuro',
          style: theme.textTheme.titleLarge?.copyWith(
            color: primary,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
            'Elige el tema de la aplicación',
            style: theme.textTheme.titleMedium?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Personaliza la apariencia de Turnify según tu preferencia',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 30),
          _buildTemaOption(
            context,
            cardColor: cardColor,
            primary: primary,
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            title: 'Tema Claro',
            subtitle: 'Interfaz con colores brillantes',
            value: 'light',
            isSelected: temaSeleccionado == 'light',
            onTap: () => _cambiarTema('light'),
          ),
          const SizedBox(height: 16),
          _buildTemaOption(
            context,
            cardColor: cardColor,
            primary: primary,
            icon: Icons.dark_mode,
            iconColor: Colors.indigo,
            title: 'Tema Oscuro',
            subtitle: 'Interfaz oscura para menos brillo',
            value: 'dark',
            isSelected: temaSeleccionado == 'dark',
            onTap: () => _cambiarTema('dark'),
          ),
          const SizedBox(height: 16),
          _buildTemaOption(
            context,
            cardColor: cardColor,
            primary: primary,
            icon: Icons.brightness_auto,
            iconColor: primary,
            title: 'Automático',
            subtitle: 'Sigue la configuración del sistema',
            value: 'system',
            isSelected: temaSeleccionado == 'system',
            onTap: () => _cambiarTema('system'),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primary.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'El tema se aplicará en toda la aplicación, elije el que mas te guste.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: textPrimary, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTemaOption(
    BuildContext context, {
    required Color cardColor,
    required Color primary,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: iconColor.withOpacity(0.18),
      highlightColor: iconColor.withOpacity(0.08),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 2,
          ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Radio<String>(
                value: value,
                groupValue: temaSeleccionado,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _cambiarTema(newValue);
                  }
                },
                activeColor: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

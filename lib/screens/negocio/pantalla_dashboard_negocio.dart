// lib/screens/negocio/pantalla_dashboard_negocio.dart
import 'package:flutter/material.dart';
import 'package:turnify/screens/negocio/pantalla_informacion_negocio.dart';
import 'package:turnify/screens/negocio/pantalla_notificaciones_negocio.dart';
import 'package:turnify/screens/negocio/pantalla_servicios_negocio.dart';
import 'package:turnify/screens/pantalla_ayuda.dart';
import 'package:turnify/screens/negocio/pantalla_configuraciones.dart';
import 'package:turnify/screens/negocio/pantalla_perfil_negocio.dart';

/// Tokens de color Turnify (mantengo tus valores originales)
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color cardBackground = Color(0xFFF5F5F5);
}

/// Pantalla principal (expuesta)
class DashboardNegocio extends StatefulWidget {
  const DashboardNegocio({super.key});

  @override
  State<DashboardNegocio> createState() => _DashboardNegocioState();
}

class _DashboardNegocioState extends State<DashboardNegocio> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions = <Widget>[
    DashboardHomeContent(
      key: const ValueKey('home'),
      onOpenProfileTab: () => _onItemTapped(1),
    ),
    const PantallaPerfilNegocio(),
    const PantallaAyuda(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = TurnifyColors.primaryTeal;
    final background = theme.scaffoldBackgroundColor;
    final bottomContainerColor = isDark ? theme.colorScheme.surface : TurnifyColors.white;

    return Scaffold(
      backgroundColor: background,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bottomContainerColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.08 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: primary,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
              BottomNavigationBarItem(icon: Icon(Icons.help_outline), activeIcon: Icon(Icons.help), label: 'Ayuda'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Home content: versión adaptada y fiel a tu diseño original.
/// Recibe callback onOpenProfileTab para abrir la pestaña Perfil (índice 1).
class DashboardHomeContent extends StatelessWidget {
  final VoidCallback onOpenProfileTab;
  const DashboardHomeContent({super.key, required this.onOpenProfileTab});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    final primary = TurnifyColors.primaryTeal;
    final onPrimary = Colors.white;
    final label = tt.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final subtitle = cs.onBackground.withOpacity(0.6);
    final hint = cs.onBackground.withOpacity(0.55);

    final cardBg = isDark ? cs.surface : TurnifyColors.white;
    final lightCardBg = isDark ? cs.surfaceVariant : TurnifyColors.cardBackground;
    final borderColor = isDark ? cs.onSurface.withOpacity(0.06) : const Color(0xFFA2B2B1);
    final shadowOpacity = isDark ? 0.02 : 0.04;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AnimatedTap(
              onTap: () => debugPrint('Abrir perfil del negocio (desde logo)'),
              borderRadius: BorderRadius.circular(12),
              color: primary,
              pressedColor: primary.withOpacity(0.88),
              padding: const EdgeInsets.all(0),
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.storefront_outlined, color: onPrimary, size: 32),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hola, Bienvenido', style: tt.bodyMedium?.copyWith(color: subtitle, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Barbería Los Santos', style: tt.titleMedium?.copyWith(color: label, fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
            ),

            AnimatedTap(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaNotificacionesNegocio())),
              borderRadius: BorderRadius.circular(999),
              color: primary,
              pressedColor: primary.withOpacity(0.88),
              padding: const EdgeInsets.all(0),
              child: Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Icon(Icons.notifications, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 10),

            AnimatedTap(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaConfiguracion())),
              borderRadius: BorderRadius.circular(999),
              color: isDark ? cs.surfaceVariant : Colors.grey[200],
              pressedColor: isDark ? cs.surface : Colors.grey[300],
              padding: const EdgeInsets.all(0),
              child: Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                child: Icon(Icons.settings, color: label, size: 24),
              ),
            ),
          ]),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(color: lightCardBg, borderRadius: BorderRadius.circular(25)),
            child: Row(children: [
              Icon(Icons.search, color: hint, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar',
                    hintStyle: tt.bodyMedium?.copyWith(color: subtitle, fontSize: 14),
                    border: InputBorder.none,
                  ),
                  style: tt.bodyMedium?.copyWith(color: label),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 30),

          Text('Servicios', style: tt.headlineSmall?.copyWith(color: label, fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          AnimatedTap(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaServiciosNegocio())),
            borderRadius: BorderRadius.circular(12),
            color: cardBg,
            pressedColor: isDark ? cs.surface : TurnifyColors.lightTeal.withOpacity(0.18),
            padding: const EdgeInsets.all(0),
            child: _serviceCard(
              icon: Icons.receipt_long,
              title: 'Servicios Del Negocio',
              subtitle: 'Gestiona servicios, precios y duraciones',
              primary: TurnifyColors.primaryTeal,
              labelColor: label,
              cardBg: cardBg,
              borderColor: borderColor,
              shadowOpacity: shadowOpacity,
            ),
          ),

          const SizedBox(height: 16),

          AnimatedTap(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaInformacionNegocio())),
            borderRadius: BorderRadius.circular(12),
            color: cardBg,
            pressedColor: isDark ? cs.surface : TurnifyColors.lightTeal.withOpacity(0.18),
            padding: const EdgeInsets.all(0),
            child: _serviceCard(
              icon: Icons.info_outline,
              title: 'Información Del Negocio',
              subtitle: 'Editar datos, horarios y ubicación',
              primary: TurnifyColors.primaryTeal,
              labelColor: label,
              cardBg: cardBg,
              borderColor: borderColor,
              shadowOpacity: shadowOpacity,
            ),
          ),

          const SizedBox(height: 30),

          Text('Resumen', style: tt.headlineSmall?.copyWith(color: label, fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          Row(children: [
            Expanded(
              child: AnimatedTap(
                onTap: () => debugPrint('Turnos hoy'),
                borderRadius: BorderRadius.circular(14),
                color: isDark ? cs.surface : const Color.fromARGB(255, 212, 237, 234),
                pressedColor: isDark ? cs.surfaceVariant : TurnifyColors.lightTeal.withOpacity(0.22),
                padding: const EdgeInsets.all(0),
                child: _summaryCard(title: 'Turnos hoy', value: '12', primary: TurnifyColors.primaryTeal, labelColor: label, cardBg: cardBg, shadowOpacity: shadowOpacity),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedTap(
                onTap: () => debugPrint('Clientes'),
                borderRadius: BorderRadius.circular(14),
                color: isDark ? cs.surface : const Color.fromARGB(255, 212, 237, 234),
                pressedColor: isDark ? cs.surfaceVariant : TurnifyColors.lightTeal.withOpacity(0.22),
                padding: const EdgeInsets.all(0),
                child: _summaryCard(title: 'Clientes', value: '240', primary: TurnifyColors.primaryTeal, labelColor: label, cardBg: cardBg, shadowOpacity: shadowOpacity),
              ),
            ),
          ]),

          const SizedBox(height: 30),

          Text('Próximos Turnos', style: tt.titleMedium?.copyWith(color: label, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          AnimatedTap(
            onTap: () => debugPrint('Abrir turno 09:00'),
            borderRadius: BorderRadius.circular(12),
            color: cardBg,
            pressedColor: isDark ? cs.surfaceVariant : TurnifyColors.cardBackground.withOpacity(0.9),
            padding: const EdgeInsets.all(0),
            child: _turnoTile(context, time: '09:00', name: 'María López', service: 'Corte', primary: TurnifyColors.primaryTeal, cardBg: cardBg, borderColor: borderColor, shadowOpacity: shadowOpacity),
          ),
          const SizedBox(height: 8),
          AnimatedTap(
            onTap: () => debugPrint('Abrir turno 09:30'),
            borderRadius: BorderRadius.circular(12),
            color: cardBg,
            pressedColor: isDark ? cs.surfaceVariant : TurnifyColors.cardBackground.withOpacity(0.9),
            padding: const EdgeInsets.all(0),
            child: _turnoTile(context, time: '09:30', name: 'Carlos Pérez', service: 'Afeitado', primary: TurnifyColors.primaryTeal, cardBg: cardBg, borderColor: borderColor, shadowOpacity: shadowOpacity),
          ),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primary,
    required Color labelColor,
    required Color cardBg,
    required Color borderColor,
    required double shadowOpacity,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(shadowOpacity), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: TurnifyColors.lightTeal.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: labelColor, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: TurnifyColors.lightGray, fontSize: 13)),
          ]),
        ),
        Icon(Icons.arrow_forward_ios, color: TurnifyColors.lightGray, size: 18),
      ]),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color primary,
    required Color labelColor,
    required Color cardBg,
    required double shadowOpacity,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg == TurnifyColors.white ? const Color.fromARGB(255, 212, 237, 234) : cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(shadowOpacity), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: TurnifyColors.lightGray, fontSize: 14)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: TurnifyColors.black, fontSize: 32, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _turnoTile(BuildContext context, {
    required String time,
    required String name,
    required String service,
    required Color primary,
    required Color cardBg,
    required Color borderColor,
    required double shadowOpacity,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(shadowOpacity), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        CircleAvatar(backgroundColor: primary.withOpacity(0.14), child: Text(time.split(':')[0], style: TextStyle(color: primary, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onBackground)),
            const SizedBox(height: 4),
            Text(service, style: const TextStyle(color: TurnifyColors.textGray)),
          ]),
        ),
        Text(time, style: const TextStyle(color: TurnifyColors.textGray, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

/// AnimatedTap mejorado: escala + animación de color de fondo + ripple
class AnimatedTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double pressedScale;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? pressedColor;
  final EdgeInsets? padding;

  const AnimatedTap({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 120),
    this.pressedScale = 0.96,
    this.borderRadius,
    this.color,
    this.pressedColor,
    this.padding,
  });

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap> {
  double _scale = 1.0;
  bool _pressed = false;

  void _onTapDown(_) => setState(() {
        _scale = widget.pressedScale;
        _pressed = true;
      });

  void _onTapUp(_) => _restore();
  void _onTapCancel() => _restore();

  void _restore() => setState(() {
        _scale = 1.0;
        _pressed = false;
      });

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);
    final Color? normal = widget.color;
    final Color? pressed = widget.pressedColor;

    Widget content = widget.child;
    if (widget.padding != null) {
      content = Padding(padding: widget.padding!, child: widget.child);
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (details) {
        _onTapUp(details);
        widget.onTap?.call();
      },
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.translucent,
      child: AnimatedScale(
        scale: _scale,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _pressed ? (pressed ?? normal) : normal,
            borderRadius: borderRadius,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: widget.onTap,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

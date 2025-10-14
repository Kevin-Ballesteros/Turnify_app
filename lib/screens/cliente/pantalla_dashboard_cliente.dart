import 'package:flutter/material.dart';
import 'package:turnify/screens/pantalla_ayuda.dart';
import 'pantalla_notificaciones.dart';
import 'pantalla_perfil_cliente.dart';
import 'pantalla_configuracion_cliente.dart';
import 'pantalla_agendar_turnos.dart';
import 'pantalla_mis_turnos.dart';


// Colores de Turnify (se mantiene primario por compatibilidad; no se usa para fondos principales)
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color cardBackground = Color(0xFFF5F5F5);
}

class DashboardCliente extends StatefulWidget {
  const DashboardCliente({super.key});

  @override
  State<DashboardCliente> createState() => _DashboardClienteState();
}

class _DashboardClienteState extends State<DashboardCliente> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions = <Widget>[
    const _DashboardContent(), // 0: Inicio
    const PantallaMisTurnos(), // 1: Mis Turnos
    const PantallaPerfilCliente(), // 2: Perfil
    const PantallaAyuda()// 3: Ayuda
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.08 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.primaryColor,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.7),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Mis Turnos'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Ayuda'),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final iconAccent = theme.primaryColor;
    final border = Border.all(color: theme.dividerColor);

    return _AnimatedPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconAccent, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color?.withOpacity(0.7), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, {required String title, required String value}) {
    final theme = Theme.of(context);
    final bg = theme.primaryColor.withOpacity(0.12);
    final titleStyle = theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color, fontSize: 14);
    final valueStyle = theme.textTheme.headlineSmall?.copyWith(fontSize: 32, fontWeight: FontWeight.bold);

    return _AnimatedPressable(
      onTap: () {
        // placeholder: acción opcional al tocar un resumen
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 8),
          Text(value, style: valueStyle),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    final primary = theme.primaryColor;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header con avatar, nombre y iconos
          Row(children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: primary.withOpacity(0.18),
              child: Icon(Icons.person, color: Colors.white, size: 35),
            ),
            const SizedBox(width: 12),

            // Saludo y nombre
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hola, bienvenido a Turnify',
                    style: theme.textTheme.bodyMedium?.copyWith(color: textSecondary, fontSize: 14)),
                Text('José Fernando Campos',
                    style: theme.textTheme.bodyLarge?.copyWith(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
            ),

            // Iconos (notificaciones y configuración)
            Row(children: [
              // Icono de notificación
              _AnimatedPressable(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaNotificaciones()));
                },
                shape: BoxShape.circle,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(color: primary.withOpacity(0.18), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 10),

              // Icono de configuración
              _AnimatedPressable(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaConfiguracionCliente()));
                },
                shape: BoxShape.circle,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.6), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(Icons.settings_outlined, color: Colors.white, size: 24),
                ),
              ),
            ]),
          ]),

          const SizedBox(height: 25),

          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25)),
            child: Row(children: [
              Icon(Icons.menu, color: theme.iconTheme.color?.withOpacity(0.85), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Icon(Icons.search, color: theme.iconTheme.color?.withOpacity(0.85), size: 24),
            ]),
          ),

          const SizedBox(height: 30),

          // Título "Servicios"
          Text('Servicios', style: theme.textTheme.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          // Card "Agendar Turnos"
          _buildServiceCard(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Agendar Turnos',
            subtitle: 'Reserva tu turno en tus negocios favoritos',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaAgendarTurnos()));
            },
          ),

          const SizedBox(height: 16),

          // Card "Consultar Negocios"
          _buildServiceCard(
            context,
            icon: Icons.store_outlined,
            title: 'Consultar Negocios',
            subtitle: 'Explora y encuentra negocios cerca de ti',
            onTap: () {
              // acción placeholder
            },
          ),

          const SizedBox(height: 30),

          // Título "Resumen"
          Text('Resumen', style: theme.textTheme.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          // Cards de resumen
          Row(children: [
            Expanded(child: _buildSummaryCard(context, title: 'Turnos pendientes', value: '3')),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard(context, title: 'Negocios favoritos', value: '8')),
          ]),
        ]),
      ),
    );
  }
}

/// Helper widget: ripple + small scale press animation.
/// Soporta borderRadius y circulo (shape: BoxShape.circle).
class _AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;
  final BoxShape? shape;

  const _AnimatedPressable({
    required this.child,
    required this.onTap,
    this.borderRadius,
    this.shape,
    Key? key,
  }) : super(key: key);

  @override
  State<_AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<_AnimatedPressable> with SingleTickerProviderStateMixin {
  static const double _pressedScale = 0.97;
  static const Duration _duration = Duration(milliseconds: 110);

  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: _duration, lowerBound: _pressedScale, upperBound: 1.0, value: 1.0);

  void _onTapDown(TapDownDetails _) {
    _ctrl.animateTo(_pressedScale, duration: _duration, curve: Curves.easeOut);
  }

  void _onTapUp(TapUpDetails _) async {
    await _ctrl.animateTo(1.0, duration: _duration, curve: Curves.easeIn);
  }

  void _onTapCancel() {
    _ctrl.animateTo(1.0, duration: _duration, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return ScaleTransition(
      scale: _ctrl,
      child: Material(
        color: Colors.transparent,
        shape: widget.shape == BoxShape.circle ? const CircleBorder() : RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          borderRadius: widget.shape == BoxShape.circle ? null : radius,
          customBorder: widget.shape == BoxShape.circle ? const CircleBorder() : null,
          splashColor: Theme.of(context).primaryColor.withOpacity(0.14),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.06),
          child: widget.child,
        ),
      ),
    );
  }
}

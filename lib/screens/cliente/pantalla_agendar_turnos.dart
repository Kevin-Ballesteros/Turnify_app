import 'package:flutter/material.dart';
import 'pantalla_detalles_turnos.dart';

// Colores de Turnify (se mantiene para compatibilidad; UI usa Theme.of(context))
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color cardBackground = Color(0xFFF5F5F5);
  static const Color starYellow = Color.fromARGB(255, 255, 193, 7);
}


class PantallaAgendarTurnos extends StatelessWidget {
  const PantallaAgendarTurnos({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Definición de la data de la Barbería
    final barberiaData = BusinessData(
      name: 'Barbería El Estilo',
      category: 'Barbería',
      rating: 4.8,
      address: 'Calle Principal 123',
      description:
          'Barbería tradicional con más de 20 años de experiencia. Especialistas en cortes clásicos y modernos.',
      services: [
        {
          'name': 'Corte de Pelo',
          'duration': 30,
          'price': 25,
          'description': 'Corte personalizado según tu estilo y preferencias. Incluye lavado y peinado.'
        },
        {'name': 'Afeitado Clásico', 'duration': 25, 'price': 15, 'description': 'Afeitado tradicional con navaja.'},
        {
          'name': 'Corte y Afeitado',
          'duration': 55,
          'price': 35,
          'description': 'Servicio completo que incluye corte de pelo y afeitado clásico.'
        },
      ],
    );

    // Definición de la data del Consultorio
    final consultorioData = BusinessData(
      name: 'Consultorio Odontologico',
      category: 'Consultorio',
      rating: 4.9,
      address: 'Avenida Central 456',
      description: 'Clínica dental moderna con enfoque en ortodoncia, cirugía y odontología preventiva.',
      services: [
        {'name': 'Valoración Brackets', 'duration': 25, 'price': 40, 'description': 'Evaluación inicial para ortodoncia.'},
        {'name': 'Cirugías Orales', 'duration': 45, 'price': 80, 'description': 'Extracciones e implantes dentales.'},
        {'name': 'Profilaxis (Limpieza bucal)', 'duration': 20, 'price': 50, 'description': 'Limpieza profunda.'},
      ],
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección 1: Barbería
              _buildBusinessSection(
                context,
                business: barberiaData,
                onTapService: (serviceIndex) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaDetallesTurno(business: barberiaData),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // Sección 2: Consultorio Odontológico
              _buildBusinessSection(
                context,
                business: consultorioData,
                onTapService: (serviceIndex) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaDetallesTurno(business: consultorioData),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // Sección 3: Veterinaria San Martín (demo)
              _buildBusinessSection(
                context,
                business: BusinessData(
                  name: 'Veterinaria San Martín',
                  category: 'Veterinaria',
                  rating: 4.7,
                  address: 'Plaza Mayor 789',
                  description: 'Cuidado integral para tus mascotas. Servicio de emergencia 24h.',
                  services: [
                    {'name': 'Consulta General', 'duration': 30, 'price': 45, 'description': 'Chequeo completo.'},
                    {'name': 'Vacunación', 'duration': 15, 'price': 25, 'description': 'Aplicación de vacunas.'},
                    {'name': 'Cirugía Menor', 'duration': 90, 'price': 120, 'description': 'Procedimientos básicos.'},
                  ],
                ),
                onTapService: (serviceIndex) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaDetallesTurno(business: barberiaData),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Turnos',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          Text(
            'Encuentra y agenda tu cita',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color, fontSize: 13),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, color: theme.primaryColor),
          onPressed: () {
            // acción de ayuda
          },
        ),
        IconButton(
          icon: Icon(Icons.favorite_border, color: theme.primaryColor),
          onPressed: () {
            // favoritos
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBusinessSection(
    BuildContext context, {
    required BusinessData business,
    required Function(int serviceIndex) onTapService,
  }) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del Negocio
        Text(
          business.name,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        ),
        const SizedBox(height: 8),

        // Información del Negocio (Categoría, Rating, Dirección)
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                business.category,
                style: theme.textTheme.bodySmall?.copyWith(color: primary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.star, color: TurnifyColors.starYellow, size: 16),
            const SizedBox(width: 4),
            Text(
              business.rating.toStringAsFixed(1),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color, fontSize: 13),
            ),
            const SizedBox(width: 8),
            Icon(Icons.location_on_outlined, color: theme.dividerColor.withOpacity(0.9), size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                business.address,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Servicios disponibles:',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color, fontSize: 13),
        ),
        const SizedBox(height: 10),

        // Lista de Servicios
        ...List.generate(business.services.length, (index) {
          final service = business.services[index];
          return _buildServiceItem(
            context,
            serviceName: service['name'] as String,
            duration: '${service['duration']} min',
            price: '${service['price']}\$',
            onTap: () => onTapService(index),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildServiceItem(
    BuildContext context, {
    required String serviceName,
    required String duration,
    required String price,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final primary = theme.primaryColor;

    return _AnimatedPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  serviceName,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, color: theme.textTheme.bodySmall?.color, size: 16),
                    const SizedBox(width: 4),
                    Text(duration, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color)),
                    const SizedBox(width: 16),
                    Icon(Icons.payments_outlined, color: theme.textTheme.bodySmall?.color, size: 16),
                    const SizedBox(width: 4),
                    Text(price, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color)),
                  ],
                ),
              ]),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              child: Row(children: [
                Text('Agendar', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 14)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;

  _AnimatedPressable({
    required this.child,
    required this.onTap,
    this.borderRadius,
    Key? key,
  }) : super(key: key);

  @override
  State<_AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<_AnimatedPressable> with SingleTickerProviderStateMixin {
  static const double _pressedScale = 0.97;
  static const Duration _duration = Duration(milliseconds: 110);

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: _duration,
    lowerBound: _pressedScale,
    upperBound: 1.0,
    value: 1.0,
  );

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
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          borderRadius: radius,
          splashColor: Theme.of(context).primaryColor.withOpacity(0.14),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.06),
          child: widget.child,
        ),
      ),
    );
  }
}
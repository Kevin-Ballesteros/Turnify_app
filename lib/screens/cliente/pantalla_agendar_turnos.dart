import 'package:flutter/material.dart';
import 'pantalla_detalles_turnos.dart'; 

// Colores de Turnify
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

    // Definición de la data de la Barbería
    final barberiaData = BusinessData(
      name: 'Barbería El Estilo',
      category: 'Barbería',
      rating: 4.8,
      address: 'Calle Principal 123',
      description: 'Barbería tradicional con más de 20 años de experiencia. Especialistas en cortes clásicos y modernos.',
      services: [
        {'name': 'Corte de Pelo', 'duration': 30, 'price': 25, 'description': 'Corte personalizado según tu estilo y preferencias. Incluye lavado y peinado.'},
        {'name': 'Afeitado Clásico', 'duration': 25, 'price': 15, 'description': 'Afeitado tradicional con navaja, toalla caliente y productos premium.'},
        {'name': 'Corte y Afeitado', 'duration': 55, 'price': 35, 'description': 'Servicio completo que incluye corte de pelo y afeitado clásico.'},
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
        {'name': 'Valoración Brackets', 'duration': 25, 'price': 40, 'description': 'Evaluación inicial para tratamiento de ortodoncia.'},
        {'name': 'Cirugías Orales', 'duration': 45, 'price': 80, 'description': 'Extracciones complejas e implantes dentales.'},
        {'name': 'Profilaxis (Limpieza bucal)', 'duration': 20, 'price': 50, 'description': 'Limpieza profunda para prevenir caries y enfermedades de las encías.'},
      ],
    );


    return Scaffold(
      backgroundColor: TurnifyColors.white,
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
                // Lógica de navegación unificada
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
                // Lógica de navegación unificada
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

              // Sección 3: Veterinaria San Martín (usando solo la data de demostración)
              _buildBusinessSection(
                context,
                business: BusinessData(
                  name: 'Veterinaria San Martín',
                  category: 'Veterinaria',
                  rating: 4.7,
                  address: 'Plaza Mayor 789',
                  description: 'Cuidado integral para tus mascotas. Contamos con farmacia y servicio de emergencia 24h.',
                  services: [
                    {'name': 'Consulta General', 'duration': 30, 'price': 45, 'description': 'Chequeo completo y diagnóstico.'},
                    {'name': 'Vacunación', 'duration': 15, 'price': 25, 'description': 'Aplicación de vacunas requeridas.'},
                    {'name': 'Cirugía Menor', 'duration': 90, 'price': 120, 'description': 'Procedimientos quirúrgicos básicos.'},
                  ],
                ),
                onTapService: (serviceIndex) {
                  // Se puede usar la misma lógica
                  // (Aquí se usaría la data de la Veterinaria, simplificando para el ejemplo)
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

  // --- MÉTODOS AUXILIARES ---

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: TurnifyColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: TurnifyColors.textGray),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Turnos',
            style: TextStyle(
              color: TurnifyColors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Encuentra y agenda tu cita',
            style: TextStyle(
              color: TurnifyColors.lightGray,
              fontSize: 13,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, color: TurnifyColors.primaryTeal),
          onPressed: () { print('Ayuda de Turnos'); },
        ),
        IconButton(
          icon: Icon(Icons.favorite_border, color: TurnifyColors.primaryTeal),
          onPressed: () { print('Favoritos de Turnos'); },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBusinessSection(
    BuildContext context, {
    required BusinessData business, // Ahora recibimos el objeto de datos
    required Function(int serviceIndex) onTapService, // Callback para el botón
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del Negocio
        Text(
          business.name,
          style: const TextStyle(
            color: TurnifyColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Información del Negocio (Categoría, Rating, Dirección)
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: TurnifyColors.lightTeal.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                business.category,
                style: const TextStyle(
                  color: TurnifyColors.primaryTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.star, color: TurnifyColors.starYellow, size: 16),
            Text(
              business.rating.toString(),
              style: const TextStyle(
                color: TurnifyColors.textGray,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.location_on_outlined, color: TurnifyColors.lightGray, size: 16),
            Expanded(
              child: Text(
                business.address,
                style: const TextStyle(
                  color: TurnifyColors.textGray,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Servicios disponibles:',
          style: TextStyle(
            color: TurnifyColors.lightGray,
            fontSize: 13,
          ),
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
            onTap: () => onTapService(index), // Llama al callback de navegación
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TurnifyColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    color: TurnifyColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: TurnifyColors.lightGray, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: const TextStyle(
                        color: TurnifyColors.lightGray,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.payments_outlined, color: TurnifyColors.lightGray, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        color: TurnifyColors.lightGray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap, // Usa el callback de navegación
            style: ElevatedButton.styleFrom(
              backgroundColor: TurnifyColors.primaryTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Row(
              children: const [
                Text(
                  'Agendar',
                  style: TextStyle(color: TurnifyColors.white, fontSize: 14),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, color: TurnifyColors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
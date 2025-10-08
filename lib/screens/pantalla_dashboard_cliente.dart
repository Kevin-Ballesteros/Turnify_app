import 'package:flutter/material.dart';
import 'pantalla_notificaciones.dart';
import 'pantalla_perfil_cliente.dart'; 
import 'pantalla_configuracion_cliente.dart'; 


// Colores de Turnify
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

  // 1. LISTA DE WIDGETS PARA EL NAVEGADOR INFERIOR
  late final List<Widget> _widgetOptions = <Widget>[
    const _DashboardContent(), // 0: Inicio (El contenido que ya tenías)
    const Center(child: Text('Mis Turnos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: TurnifyColors.black))), // 1: Mis Turnos
    const PantallaPerfilCliente(), // 2: Perfil (La pantalla que queremos mostrar)
    const Center(child: Text('Ayuda', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: TurnifyColors.black))), // 3: Ayuda
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TurnifyColors.white,
      
      // 2. BODY DINÁMICO
      // Muestra el widget correspondiente al índice seleccionado
      body: _widgetOptions.elementAt(_selectedIndex),
      
      // Bottom Navigation Bar (Se queda igual)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: TurnifyColors.primaryTeal,
            selectedItemColor: TurnifyColors.white,
            unselectedItemColor: TurnifyColors.white.withOpacity(0.6),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Mis Turnos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Ayuda'
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// WIDGET PARA EL CONTENIDO DEL DASHBOARD (Extraído de la función build original)
// --------------------------------------------------------------------------

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  // Helper methods (movidos aquí para que este widget sea autónomo)
  Widget _buildServiceCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TurnifyColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromARGB(255, 162, 178, 177)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: TurnifyColors.lightTeal.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: TurnifyColors.primaryTeal,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: TurnifyColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: TurnifyColors.lightGray,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: TurnifyColors.lightGray,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 212, 237, 234),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: TurnifyColors.lightGray,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: TurnifyColors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con avatar, nombre y iconos
            Row(
              children: [
                // Avatar
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: TurnifyColors.lightTeal,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Saludo y nombre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Hola, bienvenido José',
                        style: TextStyle(
                          color: TurnifyColors.lightGray,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'José Fernando Campos',
                        style: TextStyle(
                          color: TurnifyColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Icono de notificación
                GestureDetector(
                  onTap: () {
                    // Esta navegación debe ser a la pantalla de notificaciones
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaNotificaciones(),
                      ),
                    );
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: TurnifyColors.lightTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: TurnifyColors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Icono de configuración
                GestureDetector( // <--- Ya es interactivo
                  onTap: () {
                    // Navegación a la pantalla de configuración
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaConfiguracionCliente(),
                      ),
                    );
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: TurnifyColors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 25),
            
            // Barra de búsqueda
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: TurnifyColors.cardBackground,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu,
                    color: TurnifyColors.textGray,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: const TextStyle(
                          color: TurnifyColors.lightGray,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.search,
                    color: TurnifyColors.textGray,
                    size: 24,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Título "Servicios"
            const Text(
              'Servicios',
              style: TextStyle(
                color: TurnifyColors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Card "Agendar Turnos"
            _buildServiceCard(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Agendar Turnos',
              subtitle: 'Reserva tu turno en tus negocios favoritos',
              onTap: () {
               // Navigator.push(
                 // context,
                 // MaterialPageRoute(
                  //  builder: (context) => const PantallaAgendarTurnos(),
                 // ),
              //  );
                // print('Ir a Agendar Turnos');
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
                print('Ir a Consultar Negocios');
              },
            ),
            
            const SizedBox(height: 30),
            
            // Título "Resumen"
            const Text(
              'Resumen',
              style: TextStyle(
                color: TurnifyColors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Cards de resumen
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Turnos pendientes',
                    value: '3',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Negocios favoritos',
                    value: '8',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
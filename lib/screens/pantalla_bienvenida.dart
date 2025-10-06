import 'package:flutter/material.dart';
import 'pantalla_login.dart';
import 'pantalla_registro.dart';

// Colores de Turnify
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
}

class Pantalla1 extends StatelessWidget {
  const Pantalla1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TurnifyColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Espaciado flexible superior - más grande para empujar el logo hacia abajo
              const Spacer(flex: 4),
              
              // Logo de Turnify - Centrado
              Center(
                child: Container(
                  width: 250,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/images/Logo_Turnify.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Slogan
              Text(
                'Tu turno, más fácil que nunca',
                style: TextStyle(
                  fontSize: 16,
                  color: TurnifyColors.textGray,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Versión
              Text(
                'Versión 1.0',
                style: TextStyle(
                  fontSize: 14,
                  color: TurnifyColors.lightGray,
                  fontWeight: FontWeight.w300,
                ),
              ),
              
              // Espaciado flexible - más pequeño para mantener logo, eslogan y versión juntos
              const Spacer(flex: 2),
              
              // Botón Iniciar Sesión
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navegación a login
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PantallaLogin()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TurnifyColors.primaryTeal,
                    foregroundColor: TurnifyColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Separador decorativo con líneas y círculo
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: TurnifyColors.lightGray.withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TurnifyColors.lightGray.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: TurnifyColors.lightGray.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Botón de Crear cuenta
              SizedBox(
                width: 350,
                height: 50,
                
                child: ElevatedButton(
                  onPressed: () {
                    // Navegación a registro
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PantallaRegistro()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TurnifyColors.lightTeal,
                    foregroundColor: TurnifyColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Enlaces inferiores
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      print('Términos de licencias y el usuario');
                    },
                    child: Text(
                      'Términos de licencias y el usuario',
                      style: TextStyle(
                        color: TurnifyColors.primaryTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Espaciado flexible inferior
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
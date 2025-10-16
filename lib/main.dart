import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/pantalla_bienvenida.dart';
import 'screens/pantalla_modo_oscuro.dart';
import 'theme_manager.dart';
import 'providers/turnos_provider.dart';
import 'services/notification_service.dart';

void main() async {
  // Asegura que Flutter esté inicializado antes de ejecutar código asíncrono
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa el servicio de notificaciones
  await NotificationService().initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => TurnosProvider()),
      ],
      child: const TurnifyApp(),
    ),
  );
}

class TurnifyApp extends StatelessWidget {
  const TurnifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    return MaterialApp(
      title: 'Turnify',
      debugShowCheckedModeBanner: false,
      themeMode: themeManager.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF4ECDC4),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.black87),
          bodyLarge: TextStyle(color: Colors.black87),
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, iconTheme: IconThemeData(color: Colors.black)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4ECDC4),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white70),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white70),
          bodyLarge: TextStyle(color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E), foregroundColor: Colors.white, iconTheme: IconThemeData(color: Colors.white)),
      ),
      home: const Pantalla1(),
      onGenerateRoute: (settings) {
        if (settings.name == '/modo-oscuro') {
          return MaterialPageRoute(
            builder: (_) => PantallaModoOscuro(
              onTemaChanged: (tema) {
                // opcional: mantener compatibilidad; ThemeManager ya persiste
              },
            ),
          );
        }
        return null;
      },
    );
  }
}

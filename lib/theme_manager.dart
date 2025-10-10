import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ThemeManager extends ChangeNotifier {
  static const _prefKey = 'tema';

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final tema = prefs.getString(_prefKey);
    if (tema == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (tema == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    _applySystemUiOverlay();
    notifyListeners();
  }

  Future<void> cambiarTema(String tema) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, tema);

    if (tema == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (tema == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }

    _applySystemUiOverlay();
    notifyListeners();
  }

  // Método auxiliar si prefieres setear pasando ThemeMode directamente
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.system ? 'system' : 'light';
    await cambiarTema(value);
  }

  void _applySystemUiOverlay() {
    // Actualiza status bar y navigation bar según el tema actual
    final bool isDark = _themeMode == ThemeMode.dark || (_themeMode == ThemeMode.system && WidgetsBinding.instance.window.platformBrightness == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? const Color(0xFF121212) : Colors.white,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }
}

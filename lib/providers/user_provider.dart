// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Clave de SharedPreferences para el color ---
const _kAvatarColorKey = 'avatar_color';

class UserProvider with ChangeNotifier {
// --- DATOS DEL PERFIL ---
String _customerName = 'Cliente';
String _customerEmail = '';
String _customerPhone = '';
// Color del avatar, por defecto un valor inicial.
int _avatarColorValue = const Color(0xFF5C6BC0).value; 

String get customerName => _customerName;
String get customerEmail => _customerEmail;
String get customerPhone => _customerPhone;
Color get avatarColor => Color(_avatarColorValue);

UserProvider() {
 _loadInitialData();
}

// Carga el color guardado en SharedPreferences al iniciar
Future<void> _loadInitialData() async {
  final prefs = await SharedPreferences.getInstance();
  // NOTA: Para un sistema real, cargarías también el nombre/email/phone aquí
  _avatarColorValue = prefs.getInt(_kAvatarColorKey) ?? _avatarColorValue;
  notifyListeners();
}

// 🚀 MÉTODO AJUSTADO PARA INCLUIR EL CELULAR EN EL REGISTRO
/// Método para inicializar o actualizar el nombre, email y celular del cliente
void setCustomerData(String name, String email, String phone) {
  // Usamos este método para el registro/login inicial del cliente.
  _customerName = name;
  _customerEmail = email;
  _customerPhone = phone; // ¡NUEVO CAMPO DE CELULAR AÑADIDO Y GUARDADO!
  notifyListeners();
}

// Método usado en la pantalla de EDICIÓN (tu _onActualizar)
Future<void> updateProfile({
  required String name, 
  required String email, 
  required String phone,
}) async {
  _customerName = name;
  _customerEmail = email;
  _customerPhone = phone;
  // Aquí iría la lógica para enviar al backend

  notifyListeners(); // ¡Esto refresca el Dashboard y Perfil!
}

// Método para el cambio de color de avatar
Future<void> setAvatarColor(Color color) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_kAvatarColorKey, color.value);
  _avatarColorValue = color.value;
  notifyListeners(); // ¡Esto refresca el Dashboard y Perfil!
}

// Opcional: para cerrar sesión
void clearUser() {
  _customerName = 'Cliente';
  _customerEmail = '';
  _customerPhone = '';
  // No reseteamos el color del avatar
  notifyListeners();
  }
}
// providers/business_provider.dart
import 'package:flutter/material.dart';

class BusinessProvider with ChangeNotifier {
  String _ownerName = 'Propietario Invitado';
  String _businessName = '';
  String _businessType = '';
  String _businessDescription = '';
  String _ownerEmail = '';

  String get ownerName => _ownerName;
  String get businessName => _businessName;
  String get businessType => _businessType;
  String get businessDescription => _businessDescription;
  String get ownerEmail => _ownerEmail;

  /// Método para inicializar o actualizar los datos del negocio
  void setBusinessData({
    required String ownerName,
    required String ownerEmail,
    required String businessName,
    required String businessType,
    required String businessDescription,
  }) {
    _ownerName = ownerName;
    _ownerEmail = ownerEmail;
    _businessName = businessName;
    _businessType = businessType;
    _businessDescription = businessDescription;
    notifyListeners();
  }

  /// Método para cerrar sesión (restaurar valores por defecto)
  void logout() {
    _ownerName = 'Propietario Invitado';
    _ownerEmail = '';
    _businessName = '';
    _businessType = '';
    _businessDescription = '';
    notifyListeners();
  }
}
// lib/providers/favoritos_provider.dart
import 'package:flutter/foundation.dart';

class Negocio {
  final int id;
  final String nombre;
  final String categoria;
  final String direccion;

  Negocio({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.direccion,
  });
}

class FavoritosProvider with ChangeNotifier {
  final List<Negocio> _favoritos = [];

  List<Negocio> get favoritos => List.unmodifiable(_favoritos);
  
  int get cantidadFavoritos => _favoritos.length;

  // Agrega un negocio a favoritos
  void agregarFavorito(Negocio negocio) {
    if (!_favoritos.any((n) => n.id == negocio.id)) {
      _favoritos.add(negocio);
      notifyListeners();
    }
  }

  // Elimina un negocio de favoritos
  void eliminarFavorito(int negocioId) {
    _favoritos.removeWhere((n) => n.id == negocioId);
    notifyListeners();
  }

  // Verifica si un negocio está en favoritos
  bool esFavorito(int negocioId) {
    return _favoritos.any((n) => n.id == negocioId);
  }

  // Toggle favorito (agregar/quitar)
  void toggleFavorito(Negocio negocio) {
    if (esFavorito(negocio.id)) {
      eliminarFavorito(negocio.id);
    } else {
      agregarFavorito(negocio);
    }
  }

  // Limpia todos los favoritos
  void limpiarFavoritos() {
    _favoritos.clear();
    notifyListeners();
  }
}
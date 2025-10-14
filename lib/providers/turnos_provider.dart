// lib/providers/turnos_provider.dart
import 'package:flutter/material.dart';

class TurnosProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> activos = [];
  final List<Map<String, dynamic>> cancelados = [];

  void setTurnos(List<Map<String, dynamic>> lista) {
    activos
      ..clear()
      ..addAll(lista);
    notifyListeners();
  }

  void actualizarTurno(Map<String, dynamic> turno) {
    final id = turno['id'];
    if (id != null) {
      final idx = activos.indexWhere((t) => t['id'] == id);
      if (idx != -1) {
        activos[idx] = turno;
        notifyListeners();
        return;
      }
      final cidx = cancelados.indexWhere((t) => t['id'] == id);
      if (cidx != -1) {
        cancelados[cidx] = turno;
        notifyListeners();
        return;
      }
      activos.insert(0, turno);
      notifyListeners();
      return;
    }

    final key = _compositeKey(turno);
    final idx2 = activos.indexWhere((t) => _compositeKey(t) == key);
    if (idx2 != -1) {
      activos[idx2] = turno;
      notifyListeners();
      return;
    }
    activos.insert(0, turno);
    notifyListeners();
  }

  void moverACancelados(Map<String, dynamic> turno) {
    final id = turno['id'];
    if (id != null) {
      activos.removeWhere((t) => t['id'] == id);
    } else {
      final key = _compositeKey(turno);
      activos.removeWhere((t) => _compositeKey(t) == key);
    }
    if (!_existsInList(cancelados, turno)) {
      cancelados.insert(0, turno);
    }
    notifyListeners();
  }

  bool _existsInList(List<Map<String, dynamic>> list, Map<String, dynamic> turno) {
    final id = turno['id'];
    if (id != null) return list.any((t) => t['id'] == id);
    final key = _compositeKey(turno);
    return list.any((t) => _compositeKey(t) == key);
  }

  String _compositeKey(Map<String, dynamic> t) {
    final s = (t['startAt'] ?? t['fecha'] ?? '').toString();
    final n = (t['negocio'] ?? '').toString();
    return '$s|$n';
  }

  // <-- Implementa esta función para evitar el error
  void restaurarTurnoDesdeCancelados(Map<String, dynamic> turno) {
    cancelados.removeWhere((t) => t['id'] == turno['id']);
    // evita duplicados en activos
    activos.removeWhere((t) => t['id'] == turno['id']);
    activos.add(turno);
    notifyListeners();
  }
}

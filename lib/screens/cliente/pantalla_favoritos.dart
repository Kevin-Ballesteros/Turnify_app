// lib/screens/negocio/pantalla_favoritos_negocios.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pantalla_consultar_negocios.dart'; // ajusta la ruta si tu archivo está en otra ubicación

/// Nota: Este archivo reutiliza las clases Business, Service y Review definidas
/// en pantalla_consultar_negocios.dart. Ajusta las importaciones si las tienes en otro archivo.

class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF5F5F5);
}

class PantallaFavoritosNegocios extends StatefulWidget {
  /// Si [pickMode] es true, la pantalla devuelve el Business seleccionado con Navigator.pop(context, Business)
  /// y puede usarse desde el flujo de agendamiento.
  final bool pickMode;
  const PantallaFavoritosNegocios({super.key, this.pickMode = false});

  @override
  State<PantallaFavoritosNegocios> createState() => _PantallaFavoritosNegociosState();
}

class _PantallaFavoritosNegociosState extends State<PantallaFavoritosNegocios> {
  static const String _businessesKey = 'turnify_businesses_v1';
  static const String _favoritesKey = 'turnify_favorites_v1';

  final List<Business> _all = [];
  final Set<String> _favorites = {};
  final TextEditingController _search = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    _all.clear();
    _favorites.clear();

    final rawBusinesses = prefs.getString(_businessesKey);
    if (rawBusinesses != null) {
      try {
        final list = jsonDecode(rawBusinesses) as List<dynamic>;
        for (final e in list) {
          _all.add(Business.fromMap(Map<String, dynamic>.from(e)));
        }
      } catch (_) {}
    }

    final rawFav = prefs.getStringList(_favoritesKey);
    if (rawFav != null) _favorites.addAll(rawFav);

    setState(() => _loading = false);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favorites.toList());
  }

  List<Business> get _favoriteBusinesses {
    final q = _search.text.trim().toLowerCase();
    final list = _all.where((b) => _favorites.contains(b.id)).toList();
    if (q.isEmpty) return list;
    return list.where((b) => b.name.toLowerCase().contains(q) || b.address.toLowerCase().contains(q)).toList();
  }

  void _toggleFavorite(String id) async {
    setState(() {
      if (_favorites.contains(id)) _favorites.remove(id);
      else _favorites.add(id);
    });
    await _saveFavorites();
  }

  void _openBusinessDetail(Business b) async {
    // Si tienes BusinessDetailPage en pantalla_consultar_negocios.dart, úsalo aquí.
    final updated = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => BusinessDetailPage(business: b, onChanged: (newB) {
      // cuando detalle notifique, actualizamos lista y persistimos en storage principal
      final idx = _all.indexWhere((x) => x.id == newB.id);
      if (idx >= 0) {
        _all[idx] = newB;
        _persistAllBusinesses();
      }
    })));
    if (updated is Business) {
      // no hacemos nada adicional por ahora; BusinessDetailPage ya persiste via callback en la otra pantalla
      setState(() {});
    }
  }

  Future<void> _persistAllBusinesses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessesKey, jsonEncode(_all.map((b) => b.toMap()).toList()));
  }

  Future<void> _clearFavorites() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar favoritos'),
        content: const Text('¿Eliminar todos los negocios favoritos?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _favorites.clear());
      await _saveFavorites();
    }
  }

  Widget _buildItem(Business b) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = cs.brightness == Brightness.dark;
    final cardBg = isDark ? cs.surface : TurnifyColors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (widget.pickMode) {
            Navigator.of(context).pop(b); // devuelve negocio seleccionado para agendar
            return;
          }
          _openBusinessDetail(b);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.onSurface.withOpacity(0.06)),
          ),
          child: Row(children: [
            CircleAvatar(backgroundColor: TurnifyColors.lightTeal.withOpacity(0.3), child: Icon(Icons.storefront, color: TurnifyColors.primaryTeal)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.name, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(b.address, style: tt.bodySmall?.copyWith(color: TurnifyColors.textGray)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.star, size: 14, color: TurnifyColors.primaryTeal),
                  const SizedBox(width: 6),
                  Text(b.averageRating().toStringAsFixed(1), style: tt.bodySmall),
                  const SizedBox(width: 8),
                  Text('(${b.reviews.length})', style: tt.bodySmall?.copyWith(color: TurnifyColors.textGray)),
                ]),
              ]),
            ),
            IconButton(
              icon: Icon(_favorites.contains(b.id) ? Icons.favorite : Icons.favorite_border, color: _favorites.contains(b.id) ? TurnifyColors.primaryTeal : TurnifyColors.lightGray),
              onPressed: () => _toggleFavorite(b.id),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = cs.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pickMode ? 'Elegir negocio' : 'Favoritos'),
        backgroundColor: isDark ? cs.surface : TurnifyColors.primaryTeal,
        foregroundColor: isDark ? cs.onSurface : Colors.white,
        actions: [
          IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _clearFavorites, icon: const Icon(Icons.delete_sweep)),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: isDark ? cs.surfaceVariant : TurnifyColors.cardBackground, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Buscar en favoritos'),
                          style: tt.bodyMedium,
                        ),
                      ),
                      if (_search.text.isNotEmpty)
                        IconButton(onPressed: () => setState(() => _search.clear()), icon: const Icon(Icons.close)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _favoriteBusinesses.isEmpty
                        ? Center(
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.favorite_border, size: 72, color: cs.onBackground.withOpacity(0.2)),
                              const SizedBox(height: 12),
                              Text(widget.pickMode ? 'No hay negocios favoritos para elegir' : 'Aún no tienes favoritos', style: tt.bodyLarge),
                              const SizedBox(height: 8),
                              if (!widget.pickMode)
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    // abrir pantalla de consulta para añadir favoritos
                                    final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaConsultarNegocios()));
                                    if (res != null) await _loadAll();
                                  },
                                  icon: const Icon(Icons.search),
                                  label: const Text('Buscar negocios'),
                                ),
                            ]),
                          )
                        : ListView.separated(
                            itemCount: _favoriteBusinesses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) => _buildItem(_favoriteBusinesses[i]),
                          ),
                  ),
                ]),
              ),
      ),
    );
  }
}

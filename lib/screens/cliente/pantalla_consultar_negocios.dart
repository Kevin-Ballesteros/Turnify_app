// lib/screens/negocio/pantalla_consultar_negocios.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color cardBackground = Color(0xFFF5F5F5);
}

/// Modelos
class Business {
  String id;
  String name;
  String address;
  Map<String, String> hours; // e.g. {'Lunes': '8:00-20:00'}
  List<Service> services;
  List<Review> reviews;

  Business({
    required this.id,
    required this.name,
    required this.address,
    Map<String, String>? hours,
    List<Service>? services,
    List<Review>? reviews,
  })  : hours = hours ?? {},
        services = services ?? [],
        reviews = reviews ?? [];

  double averageRating() {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'hours': hours,
        'services': services.map((s) => s.toMap()).toList(),
        'reviews': reviews.map((r) => r.toMap()).toList(),
      };

  factory Business.fromMap(Map<String, dynamic> m) => Business(
        id: m['id']?.toString() ?? UniqueKey().toString(),
        name: m['name']?.toString() ?? '',
        address: m['address']?.toString() ?? '',
        hours: Map<String, String>.from(m['hours'] ?? {}),
        services: (m['services'] is List)
            ? List<dynamic>.from(m['services']).map((e) => Service.fromMap(Map<String, dynamic>.from(e))).toList()
            : [],
        reviews: (m['reviews'] is List)
            ? List<dynamic>.from(m['reviews']).map((e) => Review.fromMap(Map<String, dynamic>.from(e))).toList()
            : [],
      );
}

class Service {
  String id;
  String name;
  String price;
  String duration;

  Service({required this.id, required this.name, required this.price, required this.duration});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'price': price, 'duration': duration};
  factory Service.fromMap(Map<String, dynamic> m) => Service(
        id: m['id']?.toString() ?? UniqueKey().toString(),
        name: m['name']?.toString() ?? '',
        price: m['price']?.toString() ?? '',
        duration: m['duration']?.toString() ?? '',
      );
}

class Review {
  String id;
  String author;
  String text;
  int rating;
  String dateIso;

  Review({required this.id, required this.author, required this.text, required this.rating, String? date})
      : dateIso = date ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {'id': id, 'author': author, 'text': text, 'rating': rating, 'date': dateIso};
  factory Review.fromMap(Map<String, dynamic> m) => Review(
        id: m['id']?.toString() ?? UniqueKey().toString(),
        author: m['author']?.toString() ?? 'Anónimo',
        text: m['text']?.toString() ?? '',
        rating: int.tryParse(m['rating']?.toString() ?? '') ?? (m['rating'] is int ? m['rating'] : 5),
        date: m['date']?.toString(),
      );
}

/// Pantalla principal de consulta
class PantallaConsultarNegocios extends StatefulWidget {
  const PantallaConsultarNegocios({super.key});

  @override
  State<PantallaConsultarNegocios> createState() => _PantallaConsultarNegociosState();
}

class _PantallaConsultarNegociosState extends State<PantallaConsultarNegocios> {
  static const String _prefsKey = 'turnify_businesses_v1';
  final List<Business> _businesses = [];
  final TextEditingController _searchCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    _businesses.clear();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          _businesses.add(Business.fromMap(Map<String, dynamic>.from(e)));
        }
      } catch (_) {
        // ignore
      }
    }
    if (_businesses.isEmpty) {
      _seedSample();
    }
    setState(() => _loading = false);
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_businesses.map((b) => b.toMap()).toList()));
  }

  Future<void> _seedSample() async {
    _businesses.add(
      Business(
        id: 'b1',
        name: 'Barbería Los Santos',
        address: 'Cll 10 #5-20, Fusagasugá',
        hours: {'Lunes a Viernes': '8:00 - 20:00', 'Sábado': '8:00 - 17:00', 'Domingo': 'Cerrado'},
        services: [
          Service(id: 's1', name: 'Corte de cabello', price: '20', duration: '30'),
          Service(id: 's2', name: 'Corte y barba', price: '30', duration: '40'),
        ],
        reviews: [
          Review(id: 'r1', author: 'María', text: 'Buen servicio y rápido', rating: 5),
          Review(id: 'r2', author: 'Juan', text: 'Precio justo', rating: 4),
        ],
      ),
    );
    _businesses.add(
      Business(
        id: 'b2',
        name: 'Salon Estilo',
        address: 'Av. Principal 123, Bogotá',
        hours: {'Lunes a Viernes': '9:00 - 19:00', 'Sábado': '9:00 - 15:00', 'Domingo': 'Cerrado'},
        services: [Service(id: 's3', name: 'Alisado', price: '50', duration: '90')],
        reviews: [Review(id: 'r3', author: 'Catalina', text: 'Excelente resultado', rating: 5)],
      ),
    );
    await _saveAll();
  }

  List<Business> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _businesses;
    return _businesses.where((b) => b.name.toLowerCase().contains(q) || b.address.toLowerCase().contains(q)).toList();
  }

  void _openBusinessDetail(Business b) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BusinessDetailPage(business: b, onChanged: _onBusinessChanged)));
  }

  Future<void> _onBusinessChanged(Business updated) async {
    final idx = _businesses.indexWhere((b) => b.id == updated.id);
    if (idx >= 0) {
      setState(() => _businesses[idx] = updated);
      await _saveAll();
    }
  }

  Future<void> _addBusinessQuick() async {
    final id = UniqueKey().toString();
    final b = Business(id: id, name: 'Nuevo Negocio', address: '');
    _businesses.insert(0, b);
    await _saveAll();
    setState(() {});
    _openBusinessDetail(b);
  }

  Future<void> _deleteBusiness(int idx) async {
    final removed = _businesses.removeAt(idx);
    await _saveAll();
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Negocio eliminado: ${removed.name}')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = cs.brightness == Brightness.dark;
    final cardBg = isDark ? cs.surface : TurnifyColors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultar Negocios'),
        backgroundColor: isDark ? cs.surface : TurnifyColors.primaryTeal,
        foregroundColor: isDark ? cs.onSurface : Colors.white,
        actions: [
          IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _addBusinessQuick, icon: const Icon(Icons.add)),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: isDark ? cs.surfaceVariant : TurnifyColors.cardBackground, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(border: InputBorder.none, hintText: 'Buscar negocio o dirección'),
                          style: tt.bodyMedium,
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        IconButton(onPressed: () => setState(() => _searchCtrl.clear()), icon: const Icon(Icons.close)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(child: Text('No se encontraron negocios', style: tt.bodyLarge))
                        : ListView.separated(
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final b = _filtered[idx];
                              return Dismissible(
                                key: ValueKey(b.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.delete, color: Colors.red),
                                ),
                                confirmDismiss: (_) async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Eliminar negocio'),
                                      content: Text('¿Eliminar ${b.name}?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) await _deleteBusiness(_businesses.indexWhere((x) => x.id == b.id));
                                  return confirm == true;
                                },
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _openBusinessDetail(b),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.onSurface.withOpacity(0.06))),
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
                                        const Icon(Icons.chevron_right, color: Colors.grey),
                                      ]),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ]),
              ),
      ),
    );
  }
}

/// Página de detalle de negocio (servicios, horarios, reseñas)
class BusinessDetailPage extends StatefulWidget {
  final Business business;
  final ValueChanged<Business> onChanged;
  const BusinessDetailPage({super.key, required this.business, required this.onChanged});

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  late Business b;

  @override
  void initState() {
    super.initState();
    b = Business.fromMap(widget.business.toMap());
  }

  Future<void> _saveAndNotify() async {
    widget.onChanged(b);
  }

  Future<void> _addReview() async {
    final r = await showDialog<Review>(
      context: context,
      builder: (_) => const _AddReviewDialog(),
    );
    if (r != null) {
      setState(() => b.reviews.insert(0, r));
      await _saveAndNotify();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reseña añadida')));
    }
  }

  Future<void> _addService() async {
    final s = await showDialog<Service>(
      context: context,
      builder: (_) => const _AddServiceDialog(),
    );
    if (s != null) {
      setState(() => b.services.insert(0, s));
      await _saveAndNotify();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicio añadido')));
    }
  }

  Future<void> _editService(int idx) async {
    final s = await showDialog<Service>(context: context, builder: (_) => _AddServiceDialog(existing: b.services[idx]));
    if (s != null) {
      setState(() => b.services[idx] = s);
      await _saveAndNotify();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicio actualizado')));
    }
  }

  Future<void> _deleteService(int idx) async {
    final removed = b.services.removeAt(idx);
    await _saveAndNotify();
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Servicio eliminado: ${removed.name}')));
  }

  Future<void> _deleteReview(int idx) async {
    b.reviews.removeAt(idx);
    await _saveAndNotify();
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reseña eliminada')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = cs.brightness == Brightness.dark;
    final cardBg = isDark ? cs.surface : TurnifyColors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(b.name),
        backgroundColor: isDark ? cs.surface : TurnifyColors.primaryTeal,
        foregroundColor: isDark ? cs.onSurface : Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              // editar nombre/dirección simple inline
              final res = await showDialog<Business>(
                context: context,
                builder: (_) => _EditBusinessDialog(business: b),
              );
              if (res != null) {
                setState(() => b = res);
                await _saveAndNotify();
              }
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      floatingActionButton: Column(mainAxisSize: MainAxisSize.min, children: [
        FloatingActionButton(heroTag: 'addReview', onPressed: _addReview, backgroundColor: TurnifyColors.primaryTeal, child: const Icon(Icons.rate_review)),
        const SizedBox(height: 10),
        FloatingActionButton(heroTag: 'addService', onPressed: _addService, backgroundColor: TurnifyColors.lightTeal, child: const Icon(Icons.add)),
      ]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(shrinkWrap: true, children: [
            // Address + hours
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.onSurface.withOpacity(0.06))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(backgroundColor: TurnifyColors.lightTeal.withOpacity(0.3), child: Icon(Icons.location_on, color: TurnifyColors.primaryTeal)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(b.address.isEmpty ? 'Sin dirección' : b.address, style: tt.bodyLarge)),
                ]),
                const SizedBox(height: 12),
                Text('Horarios', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...b.hours.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [Expanded(child: Text(e.key, style: tt.bodyMedium)), Text(e.value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600))]),
                    )),
              ]),
            ),
            const SizedBox(height: 12),

            // Servicios
            Text('Servicios', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (b.services.isEmpty) Text('No hay servicios', style: tt.bodyMedium),
            ...List.generate(b.services.length, (i) {
              final s = b.services[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.onSurface.withOpacity(0.06))),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.name, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 6), Text('${s.duration} min • \$${s.price}', style: tt.bodySmall?.copyWith(color: TurnifyColors.textGray))])),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _editService(i);
                      if (v == 'delete') _deleteService(i);
                    },
                    itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Eliminar'))],
                  ),
                ]),
              );
            }),

            const SizedBox(height: 12),

            // Reseñas
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Reseñas', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Row(children: [Icon(Icons.star, color: TurnifyColors.primaryTeal), const SizedBox(width: 6), Text(b.averageRating().toStringAsFixed(1))]),
            ]),
            const SizedBox(height: 8),
            if (b.reviews.isEmpty) Text('Aún no hay reseñas', style: tt.bodyMedium),
            ...List.generate(b.reviews.length, (ri) {
              final r = b.reviews[ri];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(r.author.isNotEmpty ? r.author[0].toUpperCase() : 'A')),
                title: Row(children: [Expanded(child: Text(r.author, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600))), Row(children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 14, color: TurnifyColors.primaryTeal)))]),
                subtitle: Text(r.text),
                trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteReview(ri)),
              );
            }),
            const SizedBox(height: 60),
          ]),
        ),
      ),
    );
  }
}

/// Dialogs: añadir reseña
class _AddReviewDialog extends StatefulWidget {
  const _AddReviewDialog();
  @override
  State<_AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<_AddReviewDialog> {
  final _author = TextEditingController();
  final _text = TextEditingController();
  int _rating = 5;
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _author.dispose();
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final r = Review(id: UniqueKey().toString(), author: _author.text.trim().isEmpty ? 'Anónimo' : _author.text.trim(), text: _text.text.trim(), rating: _rating);
    Navigator.of(context).pop(r);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir reseña'),
      content: Form(
        key: _form,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: _author, decoration: const InputDecoration(labelText: 'Nombre (opcional)')),
          const SizedBox(height: 8),
          TextFormField(controller: _text, decoration: const InputDecoration(labelText: 'Reseña'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese reseña' : null),
          const SizedBox(height: 8),
          Row(children: List.generate(5, (i) => IconButton(icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: TurnifyColors.primaryTeal), onPressed: () => setState(() => _rating = i + 1)))),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')), ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: TurnifyColors.primaryTeal), child: const Text('Añadir'))],
    );
  }
}

/// Dialog añadir/editar servicio
class _AddServiceDialog extends StatefulWidget {
  final Service? existing;
  const _AddServiceDialog({this.existing});
  @override
  State<_AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<_AddServiceDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _name.text = widget.existing!.name;
      _price.text = widget.existing!.price;
      _duration.text = widget.existing!.duration;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final s = Service(id: widget.existing?.id ?? UniqueKey().toString(), name: _name.text.trim(), price: _price.text.trim(), duration: _duration.text.trim());
    Navigator.of(context).pop(s);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Nuevo servicio' : 'Editar servicio'),
      content: Form(
        key: _form,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese nombre' : null),
          const SizedBox(height: 8),
          TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese precio' : null),
          const SizedBox(height: 8),
          TextFormField(controller: _duration, decoration: const InputDecoration(labelText: 'Duración (min)'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese duración' : null),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')), ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: TurnifyColors.primaryTeal), child: const Text('Guardar'))],
    );
  }
}

/// Dialog editar business basic
class _EditBusinessDialog extends StatefulWidget {
  final Business business;
  const _EditBusinessDialog({required this.business});
  @override
  State<_EditBusinessDialog> createState() => _EditBusinessDialogState();
}

class _EditBusinessDialogState extends State<_EditBusinessDialog> {
  late final TextEditingController _name = TextEditingController();
  late final TextEditingController _address = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _name.text = widget.business.name;
    _address.text = widget.business.address;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final updated = Business(
      id: widget.business.id,
      name: _name.text.trim(),
      address: _address.text.trim(),
      hours: widget.business.hours,
      services: widget.business.services,
      reviews: widget.business.reviews,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar negocio'),
      content: Form(
        key: _form,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese nombre' : null),
          const SizedBox(height: 8),
          TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Dirección')),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')), ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: TurnifyColors.primaryTeal), child: const Text('Guardar'))],
    );
  }
}

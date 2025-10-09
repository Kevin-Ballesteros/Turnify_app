import 'package:flutter/material.dart';

// Definición simplificada de colores (debe coincidir con la de tu app)
class TurnifyColors {
  static const Color primaryTeal = Color.fromARGB(255, 67, 188, 180);
  static const Color lightTeal = Color.fromARGB(255, 149, 214, 211);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF333333);
  static const Color starYellow = Color.fromARGB(255, 255, 193, 7);
  static const Color cardBackground = Color(0xFFF5F5F5); 
}

// -----------------------------------------------------------------------
// MODELO DE DATOS SIMPLIFICADO para pasar la info del negocio
// (Necesario para que el archivo compile)
// -----------------------------------------------------------------------
class BusinessData {
  final String name;
  final String category;
  final double rating;
  final String address;
  final String description;
  final List<Map<String, dynamic>> services;

  BusinessData({
    required this.name,
    required this.category,
    required this.rating,
    required this.address,
    required this.description,
    required this.services,
  });
}

// -----------------------------------------------------------------------
// PANTALLA PRINCIPAL: Stateful para manejar la selección
// -----------------------------------------------------------------------
class PantallaDetallesTurno extends StatefulWidget {
  final BusinessData business;

  const PantallaDetallesTurno({super.key, required this.business});

  @override
  State<PantallaDetallesTurno> createState() => _PantallaDetallesTurnoState();
}

class _PantallaDetallesTurnoState extends State<PantallaDetallesTurno> {
  // Estado para la gestión de la selección
  int? _selectedServiceIndex;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Objeto de servicio actualmente seleccionado
  Map<String, dynamic>? get _selectedService {
    if (_selectedServiceIndex == null) return null;
    return widget.business.services[_selectedServiceIndex!];
  }
  
  // Lógica para mostrar el DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Lógica para mostrar el TimePicker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TurnifyColors.white,
      appBar: AppBar(
        backgroundColor: TurnifyColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: TurnifyColors.textGray),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalles De Tu Turno',
          style: TextStyle(
            color: TurnifyColors.primaryTeal,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      
      // El Stack permite fijar el resumen en la parte inferior
      body: Stack(
        children: [
          // Cuerpo principal desplazable
          SingleChildScrollView(
            // --- CORRECCIÓN IMPLEMENTADA AQUÍ ---
            padding: const EdgeInsets.only(bottom: 200), // Suficiente espacio para que el footer no tape el contenido
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBusinessInfoCard(), // Detalles del negocio
                _buildServiceSelection(),  // Selección de servicios
                _buildDateTimeSelection(), // Selección de fecha y hora
              ],
            ),
          ),
          
          // Resumen de la selección (Fijo en la parte inferior)
          _buildSummaryFooter(),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // WIDGETS AUXILIARES
  // -----------------------------------------------------------------------

  Widget _buildBusinessInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.business.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TurnifyColors.black),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TurnifyColors.lightTeal.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  widget.business.category,
                  style: const TextStyle(color: TurnifyColors.primaryTeal, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: TurnifyColors.starYellow, size: 16),
              Text(
                '${widget.business.rating} (${widget.business.services.length * 50} reseñas)',
                style: const TextStyle(color: TurnifyColors.textGray, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: TurnifyColors.lightGray, size: 16),
              const SizedBox(width: 5),
              Text(widget.business.address, style: const TextStyle(color: TurnifyColors.textGray)),
            ],
          ),
          Row(
            children: const [
              Icon(Icons.access_time, color: TurnifyColors.lightGray, size: 16),
              SizedBox(width: 5),
              Text('Disponible hoy (Horario: 9:00 - 18:00)', style: TextStyle(color: TurnifyColors.textGray)),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.business.description, style: const TextStyle(color: TurnifyColors.textGray)),
        ],
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elige tu Servicio',
            style: TextStyle(
              color: TurnifyColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(widget.business.services.length, (index) {
            final service = widget.business.services[index];
            final isSelected = _selectedServiceIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedServiceIndex = index;
                  // Si selecciona un servicio, borramos la hora para forzar a re-seleccionar
                  _selectedTime = null; 
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TurnifyColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected 
                      ? Border.all(color: TurnifyColors.primaryTeal, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Text(service['description'], style: const TextStyle(color: TurnifyColors.textGray, fontSize: 13)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: TurnifyColors.lightGray, size: 16),
                              const SizedBox(width: 4),
                              Text('${service['duration']} min', style: const TextStyle(color: TurnifyColors.lightGray, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${service['price']}\$',
                      style: const TextStyle(
                        color: TurnifyColors.primaryTeal,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? TurnifyColors.primaryTeal : TurnifyColors.lightGray.withOpacity(0.5),
                      ),
                      child: isSelected 
                          ? const Icon(Icons.check, color: TurnifyColors.white, size: 12) 
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fecha y Hora del Turno',
            style: TextStyle(
              color: TurnifyColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          // Selector de Fecha
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: TurnifyColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: TurnifyColors.primaryTeal),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate == null
                        ? 'Seleccionar Fecha'
                        : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: const TextStyle(fontSize: 16, color: TurnifyColors.black),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, color: TurnifyColors.lightGray, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Selector de Hora
          GestureDetector(
            // Solo permitir seleccionar hora si se ha seleccionado un servicio primero
            onTap: _selectedService != null 
                ? () => _selectTime(context)
                : null,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: TurnifyColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_outlined, 
                    color: _selectedService != null ? TurnifyColors.primaryTeal : TurnifyColors.lightGray
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _selectedTime == null
                        ? (_selectedService != null ? 'Seleccionar Hora' : 'Selecciona un servicio primero')
                        : 'Hora: ${_selectedTime!.format(context)}',
                    style: TextStyle(
                      fontSize: 16, 
                      color: _selectedService != null ? TurnifyColors.black : TurnifyColors.lightGray
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, color: TurnifyColors.lightGray, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20), // Espacio final antes del resumen
        ],
      ),
    );
  }


  Widget _buildSummaryFooter() {
    final bool isReady = _selectedService != null && _selectedDate != null && _selectedTime != null;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TurnifyColors.white,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resumen
            Text(
              '🗓️ Resumen de tu Selección',
              style: TextStyle(
                color: TurnifyColors.primaryTeal,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            
            // Detalles del Servicio
            _buildSummaryDetail(
              label: 'Servicio', 
              value: _selectedService?['name'] ?? 'Pendiente', 
              color: _selectedService == null ? TurnifyColors.lightGray : TurnifyColors.black
            ),
            _buildSummaryDetail(
              label: 'Duración', 
              value: _selectedService != null ? '${_selectedService!['duration']} min' : 'Pendiente',
              color: _selectedService == null ? TurnifyColors.lightGray : TurnifyColors.black
            ),
            _buildSummaryDetail(
              label: 'Fecha', 
              value: _selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}' : 'Pendiente',
              color: _selectedDate == null ? TurnifyColors.lightGray : TurnifyColors.black
            ),
            _buildSummaryDetail(
              label: 'Hora', 
              value: _selectedTime != null ? _selectedTime!.format(context) : 'Pendiente',
              color: _selectedTime == null ? TurnifyColors.lightGray : TurnifyColors.black
            ),

            const Divider(height: 20),
            
            // Total y Botón
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total a pagar:', style: TextStyle(color: TurnifyColors.textGray, fontSize: 14)),
                    Text(
                      _selectedService != null ? '${_selectedService!['price']}\$' : '0\$',
                      style: const TextStyle(
                        color: TurnifyColors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: isReady ? () {
                    print('Turno Agendado: ${_selectedService!['name']}, Fecha: $_selectedDate, Hora: $_selectedTime');
                    // TODO: Aquí iría la lógica final de confirmación
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TurnifyColors.primaryTeal,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    isReady ? 'Confirmar Turno' : 'Faltan datos',
                    style: const TextStyle(color: TurnifyColors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDetail({required String label, required String value, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(color: TurnifyColors.textGray, fontSize: 15)),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
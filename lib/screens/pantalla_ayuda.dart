// lib/screens/pantalla_ayuda.dart
import 'package:flutter/material.dart';

class PantallaAyuda extends StatefulWidget {
  const PantallaAyuda({super.key});

  @override
  State<PantallaAyuda> createState() => _PantallaAyudaState();
}

class _PantallaAyudaState extends State<PantallaAyuda> {
  final Set<int> _expandidas = {};

  final List<Map<String, String>> preguntas = [
      {
        'pregunta': '¿Cómo agendo una cita?',
        'respuesta': 'Ve a Agendar Turnos desde el menú, selecciona negocio y servicio, elige fecha y hora disponible y confirma. Recibirás confirmación por la app.'
      },
      {
        'pregunta': '¿Puedo cancelar o reagendar una cita?',
        'respuesta': 'Sí. En Mis Turnos selecciona la cita y elige Reprogramar o Cancelar. Recomendamos hacerlo con 24 horas de antelación para respetar políticas del negocio.'
      },
      {
        'pregunta': '¿Cómo recupero mi cuenta si olvido la contraseña?',
        'respuesta': 'En la pantalla de inicio de sesión usa "¿Olvidaste tu contraseña?" para recibir un enlace o código por correo. Sigue las instrucciones para restablecerla de forma segura.'
      },
      {
        'pregunta': '¿La app sincroniza mis turnos entre varios dispositivos?',
        'respuesta': 'Sí. Mientras uses la misma cuenta, tus turnos se sincronizan en todos tus dispositivos mediante nuestro backend. Asegúrate de iniciar sesión con la misma cuenta y conexión estable.'
      },
      {
        'pregunta': '¿Qué datos personales guarda Turnify y cómo se usan?',
        'respuesta': 'Guardamos nombre, email, teléfono y datos de reservas para gestionar turnos y comunicaciones. Tratamos los datos según la política de privacidad y solo con tu consentimiento; puedes solicitar eliminación desde Perfil.'
      },
      {
        'pregunta': '¿Cómo activo o desactivo notificaciones?',
        'respuesta': 'Ve a Perfil > Notificaciones para configurar alertas de recordatorios, cambios de turno y promociones. También puedes administrar permisos desde los ajustes del sistema operativo.'
      },
      {
        'pregunta': '¿Puedo recibir recordatorios antes de mi turno?',
        'respuesta': 'Sí. La app envía recordatorios configurables (ej. 24h y 1h antes). Ajusta las preferencias en Perfil > Notificaciones.'
      },
      {
        'pregunta': '¿Qué hago si no encuentro mi turno en la lista?',
        'respuesta': 'Verifica que hayas iniciado sesión con la cuenta correcta. Si sigue sin aparecer, actualiza la lista (pull-to-refresh) o contacta soporte con detalles del turno para que lo validemos.'
      },
      {
        'pregunta': '¿Cómo puedo añadir mi negocio a Turnify?',
        'respuesta': 'Regístrate como Negocio desde la pantalla de inicio, completa el formulario y nuestro equipo revisará la solicitud para activarlo en 24–48 horas.'
      },
      {
        'pregunta': '¿Qué hago si la app tiene un error o falla al cargar?',
        'respuesta': 'Intenta: 1) actualizar la lista con pull-to-refresh; 2) cerrar y volver a abrir la app; 3) verificar conexión; 4) reiniciar el dispositivo. Si persiste, contacta soporte con capturas y pasos para reproducir.'
      },
      {
        'pregunta': '¿Turnify ofrece accesibilidad (tamaños de fuente, lector de pantalla)?',
        'respuesta': 'Sí. La app respeta los ajustes de accesibilidad del sistema y escala tipografías según las preferencias. Si necesitas ayuda adicional, contacta soporte para alternativas personalizadas.'
      },
      {
        'pregunta': '¿Cómo protegen mi cuenta contra accesos no autorizados?',
        'respuesta': 'Recomendamos usar una contraseña fuerte y mantener tu correo seguro. Implementamos medidas de seguridad en el backend; si detectas actividad sospechosa contacta soporte inmediatamente.'
      },
      {
        'pregunta': '¿Puedo compartir mi turno con otra persona?',
        'respuesta': 'Sí, puedes compartir los detalles del turno (fecha, hora, dirección) desde la pantalla de detalles usando la opción de compartir del sistema operativo.'
      },
      {
        'pregunta': '¿Cómo gestionan los negocios sus horarios y disponibilidades?',
        'respuesta': 'Los negocios administran sus horarios desde su panel. Los cambios se sincronizan y pueden afectar la disponibilidad mostrada en la app; si un turno cambia por parte del negocio recibirás una notificación.'
      },
      {
        'pregunta': '¿Qué hago si llego tarde al turno?',
        'respuesta': 'Contacta al negocio lo antes posible usando la información de contacto en los detalles del turno. Las políticas sobre tolerancia y reprogramaciones dependen de cada negocio.'
      },
    ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final iconColor = theme.iconTheme.color ?? colorScheme.onSurface.withOpacity(0.8);
    final surfaceColor = theme.cardColor;
    final headerBg = colorScheme.surfaceVariant.withOpacity(0.06); // gentle background for header block
    final accentColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Ayuda & Soporte', style: textTheme.titleLarge?.copyWith(color: Color.fromARGB(244, 36, 222, 207), fontSize: 20, fontWeight: FontWeight.w600)),
        leading: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con ícono y título
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Ícono de interrogación
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colorScheme.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromARGB(244, 36, 222, 207),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      color: Color.fromARGB(244, 36, 222, 207),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Título
                  Text(
                    'Preguntas Frecuentes',
                    style: textTheme.headlineSmall?.copyWith(color: textTheme.titleLarge?.color, fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo
                  Text(
                    'Encuentra respuestas a tus dudas sobre Turnify.',
                    style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyLarge?.color?.withOpacity(0.9), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección de Temas Comunes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Temas Comunes',
                  style: textTheme.titleLarge?.copyWith(color: textTheme.titleLarge?.color, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Lista de preguntas expandibles
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: preguntas.length,
              itemBuilder: (context, index) {
                final item = preguntas[index];
                final isExpanded = _expandidas.contains(index);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        item['pregunta']!,
                        style: textTheme.bodyLarge?.copyWith(color: textTheme.titleLarge?.color, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: iconColor,
                      ),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          if (expanded) {
                            _expandidas.add(index);
                          } else {
                            _expandidas.remove(index);
                          }
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            item['respuesta']!,
                            style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyLarge?.color?.withOpacity(0.8), fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Sección "¿Necesitas más ayuda?"
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '¿Necesitas más ayuda?',
                    style: textTheme.titleLarge?.copyWith(color: textTheme.titleLarge?.color, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Si no encuentras lo que buscas, no dudes en contactar a nuestro equipo de soporte.',
                    style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyLarge?.color?.withOpacity(0.9), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Botón Contactar Soporte
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _mostrarOpcionesSoporte(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Contactar Soporte',
                        style: textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcionesSoporte(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          color: theme.scaffoldBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contactar Soporte',
                style: textTheme.headlineSmall?.copyWith(color: textTheme.titleLarge?.color, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Elige cómo deseas contactarnos',
                style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyLarge?.color?.withOpacity(0.9), fontSize: 14),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.email_outlined, color: colorScheme.primary),
                ),
                title: Text('Enviar Email', style: textTheme.titleMedium),
                subtitle: Text('soporte@turnify.com', style: textTheme.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  // implementar apertura de email client si corresponde
                },
              ),
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone, color: Colors.green),
                ),
                title: Text('Llamar', style: textTheme.titleMedium),
                subtitle: Text('+57 300 123 4567', style: textTheme.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  // implementar llamada si corresponde
                },
              ),
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chat_bubble_outline, color: Colors.orange),
                ),
                title: Text('Tienes una pregunta', style: textTheme.titleMedium),
                subtitle: Text('No dudes en contactarnos', style: textTheme.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  // implementar chat si corresponde
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

# INNPO Battery Support Panel

## Alcance

`INNPO Battery Support Panel` sera el panel web tecnico de INNPO para atender sesiones de diagnostico remoto autorizadas desde la app movil `INNPO Smart Battery`.

No se implementa dentro de Flutter. El panel sera una aplicacion web independiente conectada al backend seguro INNPO.

```text
BMS/Bateria -> BLE -> App movil cliente -> Backend seguro INNPO -> INNPO Battery Support Panel
```

## Funciones

1. Login de tecnico autorizado.
2. Introducir codigo de sesion.
3. Ver sesiones activas.
4. Ver datos en tiempo real: SOC, voltaje, corriente, potencia, temperatura, ciclos, celdas, delta de celdas, alarmas, MOSFET y diagnostico.
5. Ver grafico en vivo.
6. Descargar informe PDF.
7. Anadir notas internas.
8. Cerrar sesion.
9. Registrar resultado: sin incidencia, mal uso, posible garantia, requiere recogida o requiere mas informacion.

## Seguridad

- Login obligatorio para personal autorizado.
- Codigo de sesion unico, temporal y no reutilizable.
- Acceso vinculado a una bateria y a un consentimiento explicito del cliente.
- Trafico por HTTPS/WSS.
- Auditoria de accesos, notas, informes y cierre de sesion.
- Solo lectura en MVP: sin escritura remota sobre el BMS.
- Cierre automatico si el cliente revoca consentimiento, la app se desconecta o caduca el tiempo.
- El panel solo recibe datos mientras el movil del cliente mantenga conexion Bluetooth con la bateria y la app siga activa.
- El panel debe mostrar que INNPO solo ve datos tecnicos de la bateria durante la sesion autorizada.
- No implementar control remoto de parametros del BMS hasta validar protocolo del fabricante, seguridad, responsabilidad legal, consentimiento reforzado y pruebas internas.

## Comunicacion en tiempo real

### Opcion A: WebSocket

- La app abre conexion WSS con backend.
- Envia telemetria cada 2-5 segundos.
- El panel tecnico recibe datos en vivo.
- Recomendado para control propio, auditoria fina e integraciones internas.

### Opcion B: Firebase/Supabase Realtime

- Mas rapido para MVP.
- La app escribe en una coleccion/canal de sesion.
- El panel escucha cambios en tiempo real.
- Requiere reglas de seguridad estrictas por sesion, tecnico y expiracion.

### Opcion C: MQTT

- Interesante para IoT industrial.
- Util si en el futuro se conectan gateways permanentes.
- Para MVP movil puede ser mas complejo por autenticacion, broker y permisos por sesion.

### Recomendacion inicial

Preparar abstraccion para WebSocket y mantener mock local en Flutter.

```text
MVP local: mock://innpo-remote-diagnostics
MVP backend: wss://api.innpo.es/remote-diagnostics/realtime
REST base: https://api.innpo.es
Frecuencia telemetria: 2-5 segundos
Duracion sesion: 30 minutos
TTL codigo sesion: 10 minutos
```

## Endpoints backend sugeridos

```text
POST /technicians/login
POST /remote-diagnostics/sessions
GET  /remote-diagnostics/sessions/active
GET  /remote-diagnostics/sessions/{code}
GET  /remote-diagnostics/sessions/{sessionId}
POST /remote-diagnostics/sessions/{sessionId}/telemetry
GET  /remote-diagnostics/sessions/{sessionId}/events
POST /remote-diagnostics/sessions/{sessionId}/heartbeat
POST /remote-diagnostics/sessions/{sessionId}/notes
POST /remote-diagnostics/sessions/{sessionId}/report
POST /remote-diagnostics/sessions/{sessionId}/outcome
POST /remote-diagnostics/sessions/{sessionId}/close
```

## Canales WebSocket sugeridos

```text
wss://api.innpo.es/remote-diagnostics/realtime/mobile/{sessionId}
wss://api.innpo.es/remote-diagnostics/realtime/panel/{sessionId}
```

Eventos:

```text
session.created
session.technician_joined
session.telemetry
session.diagnostic_updated
session.note_added
session.report_generated
session.closed_by_customer
session.closed_by_technician
session.expired
session.connection_lost
```

## Modelos preparados

Los modelos de dominio preparados para backend/panel estan en:

```text
lib/features/remote_diagnostics/domain/support_panel_models.dart
```

No implementan el panel web, solo preparan el contrato de datos.

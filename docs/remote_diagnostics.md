# Diagnóstico Remoto INNPO

## Objetivo

Permitir que un cliente autorice temporalmente a soporte técnico INNPO a visualizar datos de lectura de su batería conectada por Bluetooth BLE.

La app no controla el móvil del cliente y no modifica parámetros del BMS. Actúa como puente seguro y revocable:

```text
BMS/Batería -> Bluetooth BLE -> App móvil cliente -> Backend seguro INNPO -> Panel web técnico INNPO
```

## Seguridad y privacidad

- Consentimiento explícito antes de iniciar.
- Sesión temporal de 30 minutos por defecto.
- Ampliación solo con autorización expresa del cliente.
- Código de sesión único, no reutilizable y asociado a una única batería/sesión.
- Código con caducidad si no se usa.
- Modo solo lectura en el MVP.
- Sin modificación remota de parámetros BMS.
- Sin acceso remoto oculto, permanente ni automático.
- El cliente puede detener la sesión en cualquier momento.
- Telemetría futura siempre por HTTPS/WSS.
- No guardar tokens sensibles en texto plano.
- Minimización: solo datos técnicos necesarios para diagnóstico.
- Transparencia: la app muestra cuándo está compartiendo datos.

## Finalización de sesión

La sesión termina si:

- El cliente pulsa detener.
- La app se cierra o queda pausada.
- Se pierde conexión Bluetooth.
- Caduca el tiempo.
- El técnico cierra la sesión desde backend/panel.
- Hay error de conexión.

## Logs mínimos

Guardar solo lo necesario:

- Fecha de inicio.
- Fecha de fin.
- Técnico que accedió, cuando el backend real lo informe.
- Código de sesión.
- Batería consultada.
- Si se generó informe.

No guardar datos no relacionados con la batería.

## 1. App móvil Flutter

Responsabilidades:

- Leer datos del BMS por Bluetooth BLE.
- Mostrar los datos al cliente.
- Solicitar autorización expresa antes de iniciar una sesión remota.
- Crear una sesión temporal contra el backend.
- Enviar telemetría de solo lectura mientras la sesión esté activa.
- Detener el envío según las reglas de finalización.

Módulos implementados:

- `RemoteDiagnosticSession`: estado de sesión, código, caducidad, técnico, permisos y contador de muestras.
- `RemoteDiagnosticTelemetry`: payload de lectura enviado al backend.
- `RemoteDiagnosticsRepository`: contrato para backend seguro.
- `MockRemoteDiagnosticsRepository`: backend mock para MVP.
- `RemoteDiagnosticService`: orquesta sesión y telemetría.
- `RemoteDiagnosticsController`: conecta Riverpod, BLE y UI.
- `RemoteDiagnosticsScreen`: autorización, estado de sesión, ampliación y parada manual.

Datos enviados:

- Identificación de batería.
- SOC, voltaje, corriente, potencia.
- Temperaturas.
- Celdas, delta y balanceo.
- Estado MOSFET.
- Alarmas activas.
- Estado operativo.
- RSSI y estado de conexión.

## 2. Backend seguro INNPO

Responsabilidades previstas:

- Crear sesiones temporales.
- Generar códigos de sesión.
- Validar caducidad, revocación y no reutilización.
- Recibir telemetría desde la app móvil.
- Autenticar técnicos INNPO.
- Autorizar acceso de técnicos a sesiones.
- Exponer datos en tiempo real al panel web.
- Guardar logs de acceso y acciones.
- Permitir cierre manual de sesión.
- Permitir generación de informe técnico.

Endpoints sugeridos:

```text
POST /remote-diagnostics/sessions
POST /remote-diagnostics/sessions/{sessionId}/telemetry
POST /remote-diagnostics/sessions/{sessionId}/stop
GET  /remote-diagnostics/sessions/{code}
GET  /remote-diagnostics/sessions/{sessionId}/events
POST /remote-diagnostics/sessions/{sessionId}/report
```

## 3. Panel web técnico INNPO

Responsabilidades previstas:

- Login obligatorio para personal autorizado.
- Introducción de código de sesión.
- Visualización en tiempo real de datos de batería.
- Visualización de alarmas, celdas e histórico reciente.
- Generación de informe PDF.
- Cierre manual de sesión.
- Logs de acceso técnico.
- Registro de resultado: sin incidencia, mal uso, posible garantía, requiere recogida o requiere más información.

Especificación funcional completa:

```text
docs/innpo_battery_support_panel.md
```

## Tecnologías recomendadas

- Backend: NestJS, Express, Supabase o Firebase.
- Tiempo real recomendado: WebSocket/WSS con mock local en MVP.
- Alternativas: Supabase/Firebase Realtime para acelerar MVP, o MQTT para escenarios IoT industriales futuros.
- Base de datos: PostgreSQL, Supabase o Firestore.
- Autenticación técnicos: email/password, SSO o sistema interno.
- Hosting: servidor propio, Supabase, Firebase, AWS o Google Cloud.

## Estado MVP actual

La app ya tiene arquitectura preparada sin backend desplegado:

- Interfaces creadas.
- Servicio remoto creado.
- Repositorio mock creado.
- Modelo de sesión creado.
- Modelo de telemetría creado.
- Pantalla de autorización creada.
- TODOs claros para backend real.

## Limitaciones importantes

- La app solo puede enviar datos remotos mientras el movil del cliente este conectado por Bluetooth a la bateria.
- Si el cliente cierra la app, pierde cobertura o se aleja de la bateria, la sesion se detendra o quedara pausada/interrumpida.
- En la primera version, el diagnostico remoto es solo lectura.
- La app debe mostrar claramente: "El equipo tecnico de INNPO solo vera los datos tecnicos de la bateria durante esta sesion autorizada."
- No se debe implementar control remoto de parametros del BMS hasta validar:
  - Protocolo del fabricante.
  - Seguridad.
  - Responsabilidad legal.
  - Consentimiento reforzado.
  - Pruebas internas.

## Como conectar un backend real

El MVP usa `MockRemoteDiagnosticsRepository` y `RemoteDiagnosticsConfig.mock`.
Para conectar backend real:

1. Implementar `RemoteDiagnosticRepository` usando `RemoteDiagnosticApiClient`.
2. Configurar `RemoteDiagnosticsConfig.websocketMvp` o una configuracion equivalente con URL WSS real.
3. Sustituir el provider `remoteDiagnosticsRepositoryProvider` para devolver el repositorio real.
4. Implementar en backend:
   - Creacion de sesion temporal.
   - Generacion de codigo unico.
   - Validacion de consentimiento.
   - Canal WSS para app movil.
   - Canal WSS para panel tecnico.
   - Heartbeat.
   - Recepcion de telemetria cada 2-5 segundos.
   - Cierre por cliente, tecnico, expiracion o perdida de conexion.
5. Mantener el MVP en modo solo lectura. No exponer comandos de escritura al BMS.
6. Verificar reglas de seguridad antes de pasar de mock a produccion:
   - HTTPS/WSS obligatorio.
   - Autenticacion de tecnicos.
   - Codigo de sesion no reutilizable.
   - Expiracion de sesion.
   - Logs de acceso.
   - Minimizacion de datos.

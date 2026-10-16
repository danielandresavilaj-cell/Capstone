# Guion breve - Terreno Conectado

Duración sugerida: 6 a 8 minutos. Hablen con la aplicación o las capturas abiertas, sin leer el texto de las láminas.

## Raúl - diapositivas 1 a 5

### 1. Portada

“Buenos días. Somos Daniel Ávila y Raúl González. Presentamos Terreno Conectado, una PWA para registrar inspecciones y evidencia en terreno, incluso cuando no hay conexión.”

### 2. Problema y propósito

“En faenas y obras remotas la señal puede fallar en medio de una inspección. Por eso nuestra aplicación guarda la información primero en el dispositivo y la envía cuando la conexión vuelve.”

### 3. Alcance funcional

“El avance incluye captura offline, fotos, formularios importados desde Excel, plantillas versionadas y asignaciones por faena y rol. El trabajador sólo ve los formularios que realmente tiene asignados.”

### 4. Flujo offline

“Al completar el formulario, las respuestas quedan en Dexie e IndexedDB. La cola local conserva el envío con un identificador único. Cuando vuelve la señal, la sincronización es idempotente, así que no duplica el registro. También verificamos que la pausa manual de envíos se conserve al recargar.”

### 5. Catálogo del trabajador

“Esta captura muestra el catálogo del trabajador. El filtro combina su faena y su rol. Desde Plantillas, el administrador puede crear o eliminar asignaciones, y el trabajador no recibe formularios ajenos.”

## Daniel - diapositivas 6 a 11

### 6. Administración de plantillas

“El administrador carga un Excel, revisa su propuesta, publica una versión y luego la asigna. La asignación puede ser para una faena específica o para toda la empresa. El original también queda disponible para exportar con las respuestas.”

### 7. Arquitectura técnica

“Usamos TypeScript de punta a punta. React y Vite forman la PWA; Dexie e IndexedDB manejan el almacenamiento local. NestJS concentra la API y PostgreSQL con RLS protege el aislamiento entre empresas. Publicamos la demo con Docker Compose, Caddy HTTPS y Oracle Always Free.”

### 8. Pruebas y validación

“La validación más reciente del release aprobó 401 pruebas en CI. Además hicimos dos E2E dirigidos: uno para detectar la recuperación física de la conexión y otro para comprobar que el modo manual persiste al recargar y sincroniza una sola vez. También verificamos backup cifrado, restauración aislada y reinicio del servidor.”

### 9. Mejoras incorporadas

“Las pruebas y el uso de la aplicación nos llevaron a corregir el catálogo de formularios, la validación numérica y la persistencia del switch de señal. Sumamos revisión de respuestas por trabajador, descarga Excel y publicación HTTPS con respaldos.”

### 10. Relación con la pauta

“La pauta pide ajustes justificados, metodología y evidencias. Mostramos correcciones conectadas a pruebas, trabajamos con Spec Driven Development y dejamos trazabilidad en specs, ADR, tareas, issues, commits y pull requests. El informe complementa la evidencia formal solicitada.”

### 11. Cierre

“Terreno Conectado ya funciona como demo HTTPS y mantiene su lógica offline: captura local, cola persistente y sincronización idempotente. Para la demostración final mostraremos importar un formulario, asignarlo, responder sin señal y revisarlo desde supervisión. Muchas gracias.”

## Recomendación para la exposición

No digan que las 17 pruebas E2E y los 7 escenarios de caos corresponden al release actual. Son evidencia histórica de Fase 2. Para el estado publicado, usen las cifras de la diapositiva 8: 401 pruebas en CI y 2 E2E dirigidos.

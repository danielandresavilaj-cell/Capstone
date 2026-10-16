# Terreno Conectado — publicación y validación

Fecha: 16 de octubre de 2026. Entorno: demostración pública, no producción con SLA.

## Acceso

https://terreno-conectado-demo.duckdns.org/

La pantalla de inicio ofrece las siete cuentas compartidas y rellena sus credenciales
al seleccionarlas. Para Constructora Andes: Camila administra/importa/asigna, Bárbara
captura y Bruno supervisa/revisa. Minera El Cobre tiene Andrés, Pedro y Sofía.
Operación Plataforma corresponde al perfil global. Usar sólo datos y fotos ficticios.
La contraseña pública de demostración no se reutiliza para la infraestructura.

## Infraestructura instalada

Una VM A1 ARM en la región principal existente de la cuenta, Valparaíso
(`sa-valparaiso-1`): 2 OCPU, 12 GB RAM, Ubuntu 24.04, 50 GB de arranque y 50 GB
de datos. Docker guarda base y adjuntos en el volumen de datos montado por UUID;
su servicio depende de ese montaje. Caddy publica HTTPS y redirige HTTP. NestJS,
nginx y PostgreSQL 16 permanecen en la red interna de Compose.

Puertos públicos: 80/443 y SSH 22 autenticado únicamente por llave dedicada, sin
password ni acceso root. SSH permite IP variables para los runners de GitHub.
La identidad del host se contrastó con el registro de consola obtenido de OCI.

Objetivo de costo: US$0, utilizando las cuotas Always Free y sin activar pago por uso.
No garantiza continuidad: Oracle puede recuperar instancias inactivas y la capacidad
gratuita no está garantizada. No se contrataron servicios alternativos pagados.

Límites y riesgos del proveedor: [Oracle Always Free](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
y [preguntas frecuentes](https://www.oracle.com/cloud/free/faq/).

## Datos

Se copiaron 2 empresas, 7 usuarios, 2 faenas, 7 formularios, 8 revisiones,
4 asignaciones iniciales y los 6 archivos originales asociados a los imports.
Se conservaron los identificadores y se generaron nuevos hashes con la contraseña demo.
No se importaron inspecciones, respuestas, hallazgos, bitácoras, fotos operacionales,
sesiones ni bloqueos. No se ejecutó una semilla adicional. La base local no se modificó.

Los cambios que realicen los usuarios después de abrir la demo son datos nuevos:
no se borran ni se sustituyen al desplegar otra versión. Durante la validación se
probó una asignación temporal y se eliminó únicamente esa asignación.

## Resultados comprobados

| Comprobación | Resultado |
|---|---|
| HTTPS y `/health` con PostgreSQL disponible | Correcto |
| Login y perfil de las siete cuentas | Correcto |
| Cookie de renovación Secure/HttpOnly/SameSite=Strict y renovación por API | Correcto |
| Rutas privadas sin autenticación | Rechazan el acceso |
| Trabajador intentando administrar asignaciones | Rechazado por rol |
| Empresa distinta intentando leer revisión/original o borrar asignación | Rechazado |
| Crear, consultar y quitar una asignación por faena | Correcto; catálogo inicial conservado |
| Descargar Excel original por HTTPS | Checksum idéntico al origen |
| Catálogo del trabajador y fecha/hora automáticas | Observados en la interfaz pública |
| Escritura de temperaturas -10 y 45 | Admitida en la interfaz pública |
| Enviar formulario incompleto | Bloqueado antes de encolar |
| Respaldo cifrado en bucket privado de OCI | Correcto; acceso mediante identidad limitada de la VM |
| Restauración del respaldo real en stack vacío | Correcto: filas y 6 originales verificados por checksum |
| Rol de aplicación restaurado sin BYPASSRLS | Correcto |
| Reinicio completo del servidor | Volumen, archivos, usuarios y formularios persistieron; HTTPS volvió |
| Retorno de versión sin cambios de esquema, en stack aislado | Versión restaurada → actual → restaurada → actual, con health correcto y filas conservadas |
| Pruebas de código, lint, tipos, build y comprobación PWA | 401 pruebas: 78 shared + 130 frontend + 190 backend + 3 infra; validación aprobada en Actions |
| Corte real y recuperación de conexión | E2E dirigido aprobado en Chromium móvil |
| Switch manual y recarga con pendientes | E2E dirigido aprobado: 1 pendiente local, 0 filas remotas hasta encender; luego 1 fila, sin duplicados |
| Tipo MIME del manifiesto PWA publicado | `application/manifest+json`, comprobado por HTTPS |
| Revisión de un envío reciente de Pedro | HTTP 200, autor y 19 respuestas; otra empresa recibe 404 |
| Descarga de esa inspección | XLSX HTTP 200, 128.668 bytes y contenedor ZIP válido |
| Foto de ese envío en el servidor | 1 adjunto, 117.422 bytes, conservado tras actualizar |
| Restauración del backup reciente con esa foto | 19 respuestas y foto recuperadas en stack aislado; bytes y SHA256 idénticos al servidor |

El ensayo de restauración se hizo con contenedores y volúmenes independientes,
que se eliminaron después. No se restauró encima de la demo ni se borraron sus datos.
El envío reciente se creó después de abrir la demo y se conservó intacto: no es una
respuesta antigua importada. La evidencia E2E corresponde a dos recorridos dirigidos,
no a una reejecución completa de toda la matriz manual histórica.

E2E: https://github.com/danielandresavilaj-cell/terreno-conectado/actions/runs/38870622764

Release publicado: `8185fd75c143a8d414c179a051e75d1e7b348e32`.
Publicación validada: https://github.com/danielandresavilaj-cell/terreno-conectado/actions/runs/38870126308

## Hallazgos corregidos durante la publicación

El efecto de conexión dependía de una función que cambiaba con el estado online:
al apagar manualmente el switch, volvía a inicializarlo con `navigator.onLine`.
Se separó la red física de la preferencia manual, que ahora se conserva al recargar.
Sin apagado manual, la recuperación real de conexión sigue siendo automática.
La skill de buenas prácticas de React orientó esta separación de estados y efectos.

El cliente pedía `/auth/me`, pero el backend expone `/me`. Esa discrepancia cerraba
la sesión al recargar. Se corrigió la ruta y se agregó una prueba de contrato.
También se impide que un error de edición numérica quede oculto por el último
valor válido guardado al intentar enviar.

La hidratación de sesión quedó separada de los cambios de señal; no vuelve a
inicializar al trabajador cada vez que cambia la red. La prueba de desconexión
espera la instalación inicial del service worker antes de cortar la conexión:
la primera descarga de la app requiere red, como indicaba el plan.

Se corrigió el tipo MIME del manifiesto PWA. El bootstrap instala rclone oficial
con checksum porque el paquete de Ubuntu no incluye el backend de Oracle.

## Respaldos y seguridad

Backup diario a las 03:00 UTC, con dispersión de hasta 5 minutos. Pausa brevemente
las escrituras de la API, captura PostgreSQL y adjuntos, reinicia la API y cifra con
age antes de subir a Object Storage privado. Hasta 7 conjuntos y máximo 10 GiB.
La VM sólo tiene permisos sobre el bucket de respaldos; no guarda una clave de
administrador de Oracle. La llave de descifrado y las credenciales de recuperación
también tienen una copia local privada fuera de Oracle y del control de versiones.

La clave API administrativa temporal fue eliminada de Oracle; su lista de claves
quedó vacía. Se eliminaron también su clave privada y configuración temporales locales.
Las llaves de SSH y recuperación permanecen privadas y excluidas de Git.

Los fallos de backup quedan en systemd/journal. La auditoría externa de HTTPS,
antigüedad y retención está implementada en GitHub Actions, pero requiere que su
workflow nuevo se incorpore a `main` para registrarse y ejecutarse diariamente.
Las notificaciones de fallos dependen de las preferencias de GitHub del titular;
no se configuró un destinatario externo de correo/webhook sin que se proporcione.

## Pendientes explícitos

- El navegador denegó la subida del Excel durante la prueba. No se intentó por otra
  vía: importación/publicación de un nuevo Excel y el recorrido controlado completo
  de captura con foto offline en la URL pública quedan pendientes de autorización.
  Se verificó un envío existente con foto, pero no se declara ejecutado ese recorrido
  controlado de principio a fin por el agente.
- Instalación real de la PWA en Android/iOS y renovación tras expirar el token en
  una sesión larga: pendientes de validación en dispositivo.
- La revisión cruzada del PR #160 sigue el proceso del repositorio; no se presume
  aprobación del otro integrante ni se hace merge sin ella.

## Actualización y recuperación

### Recorrido para probar como usuario

1. Con internet, abre la URL y entra como **Camila Administradora**. En **Importar**,
   elige un Excel de prueba: Subir → Preview → Editar → Borrador → Publicar.
   Revisa los campos obligatorios antes de publicar; no cargues información real.
2. En **Plantillas**, asigna la revisión publicada a **Obra Costanera** y al rol
   **Trabajador**. Asignarla a **Supervisor** es una decisión independiente.
   Si marcas **Todas**, la asignación cubre todas las faenas de esa empresa.
3. Sal y entra como **Bárbara Trabajadora**. En **Formularios**, elige el formulario
   concreto. Espera a que cargue con red; en el primer uso, recarga una vez antes
   de probar modo avión para que la PWA instalada controle la página.
4. Abre el formulario. Fecha y hora se completan automáticamente. Responde todos
   los obligatorios y añade una foto ficticia. Para la plantilla con rango mostrado
   de temperatura -10 a 45, prueba los extremos y un decimal con coma o punto.
5. Apaga el switch para simular pausa de envíos, o corta realmente internet después
   de la descarga inicial. El apagado manual es una pausa persistente: no apaga el
   Wi-Fi del equipo. Pulsa **Enviar inspección** y revisa **Cola → En cola**.
6. Recarga o cierra y abre la app. El pendiente debe seguir allí. No uses
   **Limpiar datos de prueba** mientras quieras conservar capturas pendientes.
   Si el switch se apagó manualmente, debe seguir apagado tras recargar.
7. Recupera internet. Si habías apagado manualmente el switch, enciéndelo también.
   Espera a que desaparezcan los pendientes; no vuelvas a enviar el mismo formulario.
8. Entra como **Bruno Supervisor**, abre **Gerencia** y pulsa **Revisar** en ese
   envío: comprueba autor Bárbara, respuestas y fecha. Usa **Descargar** para el Excel
   rellenado. Sofía, de la otra empresa, no debe ver esa inspección.
9. Vuelve con Camila a **Plantillas** y quita la asignación de prueba. Si **Todas**
   sigue marcada, el formulario continuará habilitado: hay que quitar también esa
   asignación global. En el trabajador, recarga con conexión para actualizar el
   catálogo. Un borrador ya iniciado conserva su revisión y no se cambia por otra
   plantilla automáticamente.

**Cómo leer la cola:** una inspección produce varias filas técnicas —inspección,
respuestas y fotos—; no son múltiples formularios enviados. Usa **En cola** para
los pendientes y **Gerencia** para contar y revisar los envíos completos.

### Operación del servidor

Procedimiento completo: `guia-publicacion-oracle.md`, entregada junto con este informe.
Los despliegues son manuales desde Actions, por SHA completo validado, sin `latest`.
Se respalda antes de actualizar y se conserva la versión anterior. El rollback de
imágenes sólo es automático si no cambió el esquema; en otro caso se requiere
restauración del conjunto respaldado en un destino vacío.

Código y seguimiento:

- PR: https://github.com/danielandresavilaj-cell/terreno-conectado/pull/160
- Tarea: https://github.com/danielandresavilaj-cell/terreno-conectado/issues/159

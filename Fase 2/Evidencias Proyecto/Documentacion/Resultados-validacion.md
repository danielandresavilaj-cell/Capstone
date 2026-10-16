# Resultados de validación al 16 de octubre de 2026

Release publicado: `8185fd75c143a8d414c179a051e75d1e7b348e32`. Health HTTPS observado: status ok, db up. No constituye certificación productiva ni un porcentaje de cobertura.

| Ejecución | Resultado | Alcance |
|---|---|---|
| [CI y publicación](https://github.com/danielandresavilaj-cell/terreno-conectado/actions/runs/38870126308) | success | 78 shared + 130 frontend + 190 backend + 3 infraestructura = 401; lint, tipos, build y check PWA |
| [E2E dirigidos](https://github.com/danielandresavilaj-cell/terreno-conectado/actions/runs/38870622764) | 2 aprobados | Red física; pausa manual persistente al recargar y sincronización única |
| Informe histórico 13-10-2026 | 17 E2E y 7 caos documentados | Evidencia previa; no se repitió íntegramente sobre el release público |
| API pública | Verificaciones realizadas | Login de 7 perfiles, permisos, aislamiento, alta/baja temporal de asignación y descargas |
| Revisión y exportación | Verificadas | Lectura de una inspección nueva con 19 respuestas y una foto; empresa distinta rechazada |
| Recuperación | Verificada en stack aislado | Restore DB y originales; restore reciente con foto y checksum idéntico; retorno compatible de versión |
| Reinicio de VM | Verificado | Persistencia de DB/archivos y retorno de HTTPS |

El E2E dirigido usa el commit `4adef7658e71bbbdeae31e7b79e366b8a1bce1cf`; cambia preparación de prueba respecto del runtime publicado, no el comportamiento del producto. No se afirma una ejecución actual completa de la matriz manual ni de todos los escenarios de caos.

## Pendientes

Quedan pendientes el recorrido público controlado de importación Excel y foto offline, la instalación en Android/iOS, la sesión prolongada y la revisión cruzada del PR #160. La auditoría diaria de Actions requiere incorporar su workflow a main. El respaldo diario del servidor sí está activo.

La primera carga de la PWA requiere red. Una vez instalado su service worker y descargadas las plantillas, se prueban los cortes de conectividad. El switch manual pausa el transporte y no apaga el Wi-Fi.

## Ajustes encontrados y resueltos

Catálogo por sesión/faena, envío incompleto, entrada numérica inválida, preferencia manual de señal, rehidratación de sesión y ruta /me. La revisión del detalle y exportación relacionan el envío con su autor. Las filas técnicas de cola (inspección, respuestas, fotos) no son múltiples formularios enviados.

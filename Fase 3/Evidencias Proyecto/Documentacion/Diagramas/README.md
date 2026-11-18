# Diagramas actualizados de Terreno Conectado

**Revisión:** Fase 3 · 18 de noviembre de 2026  
**Fuente funcional:** [repositorio de producto](https://github.com/danielandresavilaj-cell/terreno-conectado), spec maestro y modelo de datos vigentes.

Estos cinco diagramas revisan los SVG de la evidencia de Fase 2 y los actualizan al producto documentado en Fase 3. Los originales de Fase 2 se conservan como registro del corte anterior.

- `casos-uso.svg`: actores y flujos actuales, incluidas captura offline, QR, firma y seguimiento de hallazgos.
- `clases.svg`: objetos de dominio y servicios de captura, sync y supervisión.
- `componentes.svg`: PWA, almacenamiento local, entrada HTTPS, API, PostgreSQL, adjuntos y respaldo.
- `modelo-er.svg`: relaciones principales con activos QR, firmas y hallazgos de bitácora.
- `secuencia.svg`: captura offline, sincronización idempotente, RLS y gestión posterior.

El modelo ER es una vista resumida; el esquema completo está en `data-model.md`. Avisos push y programación recurrente no se muestran como funciones disponibles.

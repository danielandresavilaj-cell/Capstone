# Evidencia de base de datos

PostgreSQL 16, esquema público del release `8185fd75c143a8d414c179a051e75d1e7b348e32`. El archivo SQL contiene sólo estructura: tablas, índices, restricciones y políticas RLS. No contiene respuestas, fotos, usuarios, sesiones ni hashes de contraseña.

- `esquema-publicado.sql`: exportación de sólo esquema, para inspección. No es un backup operacional ni incluye la provisión del rol tc_app.
- `Diccionario.md`: columnas y restricciones extraídas del mismo esquema.
- `migraciones/`: 12 migraciones versionadas que construyen y evolucionan el modelo.
- Modelo conceptual y ER completo: `../../Documentacion/snapshot-2026-10-16/data-model.md`.

Para reproducir una base nueva, seguir la guía de aplicación y los scripts del repositorio técnico: crear roles, migrar y sembrar exclusivamente el entorno local. No ejecutar una semilla sobre la demo pública. El restore operacional recupera DB y adjuntos juntos según `infra/ORACLE-FREE.md`.

Conteo extraído: 19 tablas en public, incluida la tabla de control de migraciones cuando corresponde. Las fotos viven en volumen; la tabla attachment conserva sus metadatos y relación con el registro.

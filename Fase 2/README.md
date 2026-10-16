# Fase 2 de Terreno Conectado

Corte: 16 de octubre de 2026. Equipo: Daniel Ávila y Raúl González. Capstone PTY4614, Ingeniería en Informática, sede Alameda. Docente consignado en Fase 1: Carlos Herrera.

Demo: https://terreno-conectado-demo.duckdns.org/

## Entrega organizada según el correo y la pauta

- **Evidencias Grupales:** 2.4 en español e inglés, 2.6 en español e inglés e informe de avance corregido.
- **Evidencias Individuales:** diario 2.1 identificado por apellido/nombre de cada estudiante.
- **Evidencias Proyecto (version Agil):** Product Vision, Product Backlog, Definition of Done y Diseño. Se mantiene la numeración del modelo; no existe Documento 03 en la referencia.
- **Evidencias Proyecto:** Presentación Proyecto.pptx, guion, documentación y Sistema (Aplicacion / Base de datos).

Se conserva únicamente la versión ágil, acorde con el desarrollo iterativo e incremental, el backlog y los criterios de aceptación utilizados por el equipo.

Las guías 2.6 documentan los resultados alcanzados al corte y sus limitaciones. No certifican finalización de todas las pruebas físicas. Diarios y conclusiones personales requieren lectura y validación de su respectivo integrante antes de la entrega académica.

## Mapeo de la pauta sumativa

| Criterio | Archivos o evidencia | Qué permite comprobar |
|---|---|---|
| 1 Ajustes (10%) | Guía 2.4, informe §6 | Dificultad, corrección y evidencia de resultado. |
| 2 Metodología (10%) | 2.4, Product Backlog y DoD | SDD iterativo, requisitos y aceptación. |
| 3 Evidencias técnicas (25%) | Diseño, Documentacion y Sistema | Documentación, código, pruebas, esquema y demo. |
| 4 Lenguaje técnico (5%) | Informe y documento de diseño | Offline-first, RLS, outbox e idempotencia definidos con precisión. |
| 5 Redacción y referencias (5%) | Informe, guías y bibliografía | Idiomas requeridos y enlaces verificables. |
| 6 Estructura y Git (20%) | Índice de Fase 2 y commit de entrega | Archivos por categoría, esquema y snapshots identificados. |
| 7 Aportes individuales (15%) | Contribuciones-equipo y diarios | Enlaces reales por integrante; no se deduce equidad de conteos. |
| 8 Trabajo de equipo (10%) | Presentación, guion y ensayo | Participación de ambos y dominio del tema; requiere exposición. |

## Estado técnico

Release `8185fd75c143a8d414c179a051e75d1e7b348e32`. La publicación y validación CI tienen [ejecución identificada](https://github.com/danielandresavilaj-cell/terreno-conectado/actions/runs/38870126308), al igual que los [2 E2E dirigidos](https://github.com/danielandresavilaj-cell/terreno-conectado/actions/runs/38870622764). Los 17 E2E y siete caos de la evidencia histórica conservan su fecha, sin atribuirlos al release actual. No se reporta porcentaje de cobertura actual no recalculado.

Quedan pendientes el recorrido público controlado de importación Excel y foto offline, la instalación en Android/iOS, la sesión prolongada y la revisión cruzada del PR #160. La auditoría diaria de Actions requiere incorporar su workflow a main. El respaldo diario del servidor sí está activo.

## Índice de evidencia técnica

- [Resultados y límites](Evidencias%20Proyecto/Documentacion/Resultados-validacion.md)
- [Aportes del equipo](Evidencias%20Proyecto/Documentacion/Contribuciones-equipo.md)
- [Aplicación y recorrido](Evidencias%20Proyecto/Sistema/Aplicacion/README.md)
- [Base de datos](Evidencias%20Proyecto/Sistema/Base%20de%20datos/README.md)
- [Registro del snapshot](Evidencias%20Proyecto/Documentacion/manifest-snapshot.json)

Las fuentes oficiales del profesor se tomaron de https://github.com/FelipeKraussDOUC/capstone_2026_duoc_alameda. Las respuestas del equipo y la actualización técnica pertenecen a esta entrega. La Fase 1 se conserva como antecedente. El código fuente continúa en https://github.com/danielandresavilaj-cell/terreno-conectado.

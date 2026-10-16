# Aplicación demostrativa

Demo HTTPS: https://terreno-conectado-demo.duckdns.org/

Código fuente del release: https://github.com/danielandresavilaj-cell/terreno-conectado/tree/8185fd75c143a8d414c179a051e75d1e7b348e32

Descarga del código de esa versión: https://github.com/danielandresavilaj-cell/terreno-conectado/archive/8185fd75c143a8d414c179a051e75d1e7b348e32.zip

El repositorio Capstone conserva la entrega documental. La aplicación se ejecuta desde el repositorio técnico. La primera descarga y autenticación requieren red. La captura posterior utiliza caché e IndexedDB del dispositivo.

## Ejecución local

Requisitos: Node.js >=22.12, npm y Docker activo. En una copia del repositorio técnico:

```sh
npm ci
cp .env.example .env
```

Completar localmente las variables de `.env` según su plantilla, incluyendo claves nuevas y las variables de demo y conexión. No publicar ese archivo.

```sh
docker compose -f infra/docker-compose.yml up -d
npm run db:migrate --workspace @terreno/backend
npm run db:seed --workspace @terreno/backend
npm run dev:backend
```

En otra terminal:

```sh
npm run dev:frontend
```

Frontend local: http://localhost:5173. Health local: http://localhost:3000/health.
`npm test` ejecuta unitarias e integración, con Docker requerido. Para E2E, construir primero con la URL del harness:

```sh
npm run build --workspace @terreno/shared
npm run build --workspace @terreno/backend
npx cross-env VITE_API_URL=http://127.0.0.1:3310/api/v1 npm run build --workspace @terreno/frontend
npm run e2e
```

El modo Vite de desarrollo no sirve para demostrar recarga offline. Usar build PWA o la demo HTTPS.

## Recorrido de demostración

1. Entrar como Camila Administradora (Constructora Andes) mediante el acceso demo.
2. Importar un Excel ficticio, revisar propuesta, confirmar borrador y publicar.
3. Asignar por Obra Costanera y rol Trabajador. Considerar también asignaciones globales.
4. Entrar como Bárbara, esperar la descarga inicial y elegir el formulario asignado.
5. Responder campos obligatorios y foto ficticia. Fecha/hora se autocompletan al abrir.
6. Cortar la red o apagar el switch manual y enviar. Comprobar pendiente local y recarga.
7. Recuperar conexión y reactivar el switch si se apagó manualmente. Verificar un solo envío.
8. Entrar como Bruno, revisar autor/respuestas en Gerencia y descargar el Excel.
9. Quitar asignación desde Camila. Si existe asignación a Todas, quitarla también para retirar el formulario.

Este recorrido es la pauta del próximo ensayo controlado; no se registra como una prueba pública completa ya ejecutada. No borrar pendientes para realizarlo.

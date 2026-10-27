import { app } from './app.js';
import { env } from './config/env.js';
import { db } from './db/connection.js';

const server = app.listen(env.port, '0.0.0.0', () => {
  console.log('');
  console.log('  API de Inventario escuchando');
  console.log(`  Local:   http://localhost:${env.port}`);
  console.log(`  API:     http://localhost:${env.port}/api/productos`);
  console.log(`  Entorno: ${env.nodeEnv}`);
  console.log(`  Base:    ${env.dbPath}`);
  console.log('');
});

const cerrar = (senal) => {
  console.log(`\n[server] Cerrando por ${senal}...`);
  server.close(() => {
    db.close();
    process.exit(0);
  });
};

process.on('SIGINT', () => cerrar('SIGINT'));
process.on('SIGTERM', () => cerrar('SIGTERM'));

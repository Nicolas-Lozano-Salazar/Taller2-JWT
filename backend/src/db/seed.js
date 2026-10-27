import { db, recargarSemilla } from './connection.js';

const total = recargarSemilla();
console.log(`[seed] Base de datos reiniciada con ${total} productos de prueba.`);
db.close();

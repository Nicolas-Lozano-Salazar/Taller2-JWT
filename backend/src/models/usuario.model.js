import { db } from '../db/connection.js';

const columnas = 'id, nombre, email, creado_en';

export const usuarioModel = {
  obtenerPorEmail(email) {
    return db.prepare(`SELECT id, nombre, email, password_hash FROM usuarios WHERE email = ? COLLATE NOCASE`).get(email);
  },

  obtenerPorId(id) {
    return db.prepare(`SELECT ${columnas} FROM usuarios WHERE id = ?`).get(id);
  },
};
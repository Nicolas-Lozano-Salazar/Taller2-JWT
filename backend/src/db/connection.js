import fs from 'node:fs';
import path from 'node:path';
import { DatabaseSync } from 'node:sqlite';
import { env } from '../config/env.js';
import { productosSemilla } from './seed-data.js';

fs.mkdirSync(path.dirname(env.dbPath), { recursive: true });

/**
 * Base de datos SQLite real, almacenada en disco (backend/data/inventario.db).
 * Se usa el modulo nativo node:sqlite incluido en Node.js 24, sin dependencias nativas.
 */
export const db = new DatabaseSync(env.dbPath);

db.exec(`
  PRAGMA journal_mode = WAL;
  PRAGMA foreign_keys = ON;

  CREATE TABLE IF NOT EXISTS productos (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre         TEXT    NOT NULL,
    codigo         TEXT    NOT NULL COLLATE NOCASE UNIQUE,
    descripcion    TEXT    NOT NULL DEFAULT '',
    precio         REAL    NOT NULL CHECK (precio >= 0),
    cantidad       INTEGER NOT NULL CHECK (cantidad >= 0),
    categoria      TEXT    NOT NULL,
    creado_en      TEXT    NOT NULL DEFAULT (datetime('now')),
    actualizado_en TEXT    NOT NULL DEFAULT (datetime('now'))
  );

  CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos (categoria);
  CREATE INDEX IF NOT EXISTS idx_productos_nombre ON productos (nombre);
`);

const insertarSemilla = db.prepare(`
  INSERT INTO productos (nombre, codigo, descripcion, precio, cantidad, categoria)
  VALUES (:nombre, :codigo, :descripcion, :precio, :cantidad, :categoria)
`);

const insertarVarios = (productos) => {
  db.exec('BEGIN');
  try {
    for (const producto of productos) {
      insertarSemilla.run(producto);
    }
    db.exec('COMMIT');
  } catch (error) {
    db.exec('ROLLBACK');
    throw error;
  }
};

/** Carga los productos de prueba solo si la tabla esta vacia. */
export function cargarSemillaSiEstaVacia() {
  const { total } = db.prepare('SELECT COUNT(*) AS total FROM productos').get();
  if (total > 0) return 0;
  insertarVarios(productosSemilla);
  return productosSemilla.length;
}

/** Borra los productos existentes y vuelve a cargar los de prueba. */
export function recargarSemilla() {
  db.exec("DELETE FROM productos; DELETE FROM sqlite_sequence WHERE name = 'productos';");
  insertarVarios(productosSemilla);
  return productosSemilla.length;
}

if (env.seed) {
  const insertados = cargarSemillaSiEstaVacia();
  if (insertados > 0) {
    console.log(`[db] Base de datos inicializada con ${insertados} productos de prueba.`);
  }
}

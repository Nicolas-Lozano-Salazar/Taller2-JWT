import { db } from '../db/connection.js';

const columnas = 'id, nombre, codigo, descripcion, precio, cantidad, categoria';

/**
 * Capa de acceso a datos. Toda la interaccion con SQLite vive aqui,
 * de modo que los controladores solo se encargan del HTTP.
 */
export const productoModel = {
  listar({ buscar = '', categoria = '' } = {}) {
    const condiciones = [];
    const parametros = {};

    if (buscar) {
      condiciones.push('(nombre LIKE :buscar OR codigo LIKE :buscar OR categoria LIKE :buscar)');
      parametros.buscar = `%${buscar}%`;
    }

    if (categoria) {
      condiciones.push('categoria = :categoria');
      parametros.categoria = categoria;
    }

    const where = condiciones.length ? `WHERE ${condiciones.join(' AND ')}` : '';
    return db
      .prepare(`SELECT ${columnas} FROM productos ${where} ORDER BY nombre COLLATE NOCASE ASC`)
      .all(parametros);
  },

  obtenerPorId(id) {
    return db.prepare(`SELECT ${columnas} FROM productos WHERE id = ?`).get(id);
  },

  obtenerPorCodigo(codigo) {
    return db.prepare(`SELECT ${columnas} FROM productos WHERE codigo = ? COLLATE NOCASE`).get(codigo);
  },

  crear(producto) {
    const resultado = db
      .prepare(
        `INSERT INTO productos (nombre, codigo, descripcion, precio, cantidad, categoria)
         VALUES (:nombre, :codigo, :descripcion, :precio, :cantidad, :categoria)`,
      )
      .run(producto);

    return this.obtenerPorId(Number(resultado.lastInsertRowid));
  },

  actualizar(id, producto) {
    db.prepare(
      `UPDATE productos
          SET nombre = :nombre,
              codigo = :codigo,
              descripcion = :descripcion,
              precio = :precio,
              cantidad = :cantidad,
              categoria = :categoria,
              actualizado_en = datetime('now')
        WHERE id = :id`,
    ).run({ ...producto, id });

    return this.obtenerPorId(id);
  },

  eliminar(id) {
    const resultado = db.prepare('DELETE FROM productos WHERE id = ?').run(id);
    return resultado.changes > 0;
  },

  estadisticas() {
    const fila = db
      .prepare(
        `SELECT
           COUNT(*)                                   AS totalProductos,
           COALESCE(SUM(cantidad), 0)                 AS totalUnidades,
           COALESCE(SUM(precio * cantidad), 0)        AS valorInventario,
           COALESCE(SUM(CASE WHEN cantidad < 5 THEN 1 ELSE 0 END), 0) AS productosStockBajo,
           COUNT(DISTINCT categoria)                  AS totalCategorias
         FROM productos`,
      )
      .get();

    return {
      totalProductos: Number(fila.totalProductos),
      totalUnidades: Number(fila.totalUnidades),
      valorInventario: Number(Number(fila.valorInventario).toFixed(2)),
      productosStockBajo: Number(fila.productosStockBajo),
      totalCategorias: Number(fila.totalCategorias),
    };
  },
};

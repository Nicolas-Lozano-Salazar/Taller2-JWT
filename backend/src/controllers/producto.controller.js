import { productoModel } from '../models/producto.model.js';
import { validarId, validarProducto } from '../validators/producto.validator.js';
import { ApiError } from '../utils/ApiError.js';

const verificarCodigoUnico = (codigo, idExcluir = null) => {
  const existente = productoModel.obtenerPorCodigo(codigo);
  if (existente && existente.id !== idExcluir) {
    throw ApiError.unprocessable('Ya existe un producto con ese codigo.', [
      { field: 'codigo', message: `El codigo ${codigo} ya esta registrado.` },
    ]);
  }
};

export const productoController = {
  listar(req, res) {
    const buscar = typeof req.query.buscar === 'string' ? req.query.buscar.trim() : '';
    const categoria = typeof req.query.categoria === 'string' ? req.query.categoria.trim() : '';
    const productos = productoModel.listar({ buscar, categoria });

    res.json({
      data: productos,
      meta: { total: productos.length, filtros: { buscar, categoria } },
    });
  },

  obtener(req, res) {
    const id = validarId(req.params.id);
    if (!id) throw ApiError.badRequest('El identificador del producto no es valido.');

    const producto = productoModel.obtenerPorId(id);
    if (!producto) throw ApiError.notFound(`No existe un producto con id ${id}.`);

    res.json({ data: producto });
  },

  crear(req, res) {
    const { valido, datos, errores } = validarProducto(req.body);
    if (!valido) throw ApiError.unprocessable('Los datos del producto no son validos.', errores);

    verificarCodigoUnico(datos.codigo);
    const producto = productoModel.crear(datos);

    res.status(201).json({
      message: 'Producto registrado correctamente.',
      data: producto,
    });
  },

  actualizar(req, res) {
    const id = validarId(req.params.id);
    if (!id) throw ApiError.badRequest('El identificador del producto no es valido.');

    const existente = productoModel.obtenerPorId(id);
    if (!existente) throw ApiError.notFound(`No existe un producto con id ${id}.`);

    const { valido, datos, errores } = validarProducto(req.body);
    if (!valido) throw ApiError.unprocessable('Los datos del producto no son validos.', errores);

    verificarCodigoUnico(datos.codigo, id);
    const producto = productoModel.actualizar(id, datos);

    res.json({
      message: 'Producto actualizado correctamente.',
      data: producto,
    });
  },

  eliminar(req, res) {
    const id = validarId(req.params.id);
    if (!id) throw ApiError.badRequest('El identificador del producto no es valido.');

    const eliminado = productoModel.eliminar(id);
    if (!eliminado) throw ApiError.notFound(`No existe un producto con id ${id}.`);

    res.json({
      message: 'Producto eliminado correctamente.',
      data: { id },
    });
  },

  estadisticas(_req, res) {
    res.json({ data: productoModel.estadisticas() });
  },
};

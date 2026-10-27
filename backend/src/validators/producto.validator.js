const LIMITE_PRECIO = 1_000_000_000;
const LIMITE_CANTIDAD = 1_000_000_000;

const aTexto = (valor) => (typeof valor === 'string' ? valor.trim() : '');

const aNumero = (valor) => {
  if (typeof valor === 'number') return valor;
  if (typeof valor === 'string' && valor.trim() !== '') return Number(valor.replace(',', '.'));
  return Number.NaN;
};

/**
 * Valida y normaliza el cuerpo recibido para crear o actualizar un producto.
 * Devuelve { valido, datos, errores }.
 */
export function validarProducto(cuerpo = {}) {
  const errores = [];

  const nombre = aTexto(cuerpo.nombre);
  if (!nombre) {
    errores.push({ field: 'nombre', message: 'El nombre es obligatorio.' });
  } else if (nombre.length < 2 || nombre.length > 120) {
    errores.push({ field: 'nombre', message: 'El nombre debe tener entre 2 y 120 caracteres.' });
  }

  const codigoOriginal = aTexto(cuerpo.codigo);
  const codigo = codigoOriginal.toUpperCase();
  if (!codigo) {
    errores.push({ field: 'codigo', message: 'El codigo es obligatorio.' });
  } else if (codigo.length < 2 || codigo.length > 40) {
    errores.push({ field: 'codigo', message: 'El codigo debe tener entre 2 y 40 caracteres.' });
  } else if (!/^[A-Z0-9._-]+$/.test(codigo)) {
    errores.push({
      field: 'codigo',
      message: 'El codigo solo admite letras, numeros, punto, guion y guion bajo.',
    });
  }

  const descripcion = aTexto(cuerpo.descripcion);
  if (descripcion.length > 500) {
    errores.push({ field: 'descripcion', message: 'La descripcion no puede superar 500 caracteres.' });
  }

  const categoria = aTexto(cuerpo.categoria);
  if (!categoria) {
    errores.push({ field: 'categoria', message: 'La categoria es obligatoria.' });
  } else if (categoria.length < 2 || categoria.length > 60) {
    errores.push({ field: 'categoria', message: 'La categoria debe tener entre 2 y 60 caracteres.' });
  }

  const precio = aNumero(cuerpo.precio);
  if (!Number.isFinite(precio)) {
    errores.push({ field: 'precio', message: 'El precio es obligatorio y debe ser numerico.' });
  } else if (precio < 0 || precio > LIMITE_PRECIO) {
    errores.push({ field: 'precio', message: 'El precio debe ser mayor o igual a 0.' });
  }

  const cantidad = aNumero(cuerpo.cantidad);
  if (!Number.isFinite(cantidad)) {
    errores.push({ field: 'cantidad', message: 'La cantidad es obligatoria y debe ser numerica.' });
  } else if (!Number.isInteger(cantidad)) {
    errores.push({ field: 'cantidad', message: 'La cantidad debe ser un numero entero.' });
  } else if (cantidad < 0 || cantidad > LIMITE_CANTIDAD) {
    errores.push({ field: 'cantidad', message: 'La cantidad debe ser mayor o igual a 0.' });
  }

  if (errores.length > 0) {
    return { valido: false, datos: null, errores };
  }

  return {
    valido: true,
    errores: [],
    datos: {
      nombre,
      codigo,
      descripcion,
      precio: Number(precio.toFixed(2)),
      cantidad,
      categoria,
    },
  };
}

/** Valida que el identificador de la ruta sea un entero positivo. */
export function validarId(valor) {
  const id = Number(valor);
  return Number.isInteger(id) && id > 0 ? id : null;
}

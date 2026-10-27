import { ApiError } from '../utils/ApiError.js';

export function notFoundHandler(req, _res, next) {
  next(ApiError.notFound(`La ruta ${req.method} ${req.originalUrl} no existe.`));
}

// eslint-disable-next-line no-unused-vars
export function errorHandler(error, _req, res, _next) {
  if (error instanceof ApiError) {
    return res.status(error.status).json({
      error: {
        message: error.message,
        ...(error.details ? { details: error.details } : {}),
      },
    });
  }

  if (error?.type === 'entity.parse.failed') {
    return res.status(400).json({
      error: { message: 'El cuerpo de la peticion no contiene un JSON valido.' },
    });
  }

  console.error('[error]', error);
  return res.status(500).json({
    error: { message: 'Ocurrio un error interno en el servidor.' },
  });
}

import jwt from 'jsonwebtoken';

import { env } from '../config/env.js';
import { ApiError } from '../utils/ApiError.js';

export function authMiddleware(req, _res, next) {
  const encabezado = req.headers.authorization ?? '';
  const [esquema, token] = encabezado.split(' ');

  if (esquema !== 'Bearer' || !token) {
    return next(ApiError.unauthorized('Se requiere un token Bearer valido.'));
  }

  try {
    const payload = jwt.verify(token, env.jwtSecret);
    req.user = {
      id: payload.sub,
      email: payload.email,
      nombre: payload.nombre,
    };
    next();
  } catch (error) {
    next(ApiError.unauthorized('Token invalido o expirado.'));
  }
}
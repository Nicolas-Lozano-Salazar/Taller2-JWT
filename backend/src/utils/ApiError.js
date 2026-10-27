/**
 * Error controlado que viaja hasta el middleware global de errores.
 */
export class ApiError extends Error {
  constructor(status, message, details = undefined) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.details = details;
  }

  static badRequest(message = 'Solicitud invalida.', details) {
    return new ApiError(400, message, details);
  }

  static notFound(message = 'Recurso no encontrado.') {
    return new ApiError(404, message);
  }

  static unprocessable(message = 'Los datos enviados no son validos.', details) {
    return new ApiError(422, message, details);
  }
}

import 'package:dio/dio.dart';

/// Excepcion propia de la aplicacion. Traduce los errores de Dio
/// a mensajes claros para mostrarlos en la interfaz.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.details = const [],
  });

  final String message;
  final int? statusCode;
  final List<String> details;

  factory ApiException.fromDio(DioException error) {
    final respuesta = error.response;
    final datos = respuesta?.data;

    if (datos is Map<String, dynamic>) {
      final cuerpoError = datos['error'];
      if (cuerpoError is Map<String, dynamic>) {
        final detalles = <String>[];
        final listaDetalles = cuerpoError['details'];
        if (listaDetalles is List) {
          for (final detalle in listaDetalles) {
            if (detalle is Map && detalle['message'] != null) {
              detalles.add(detalle['message'].toString());
            } else if (detalle != null) {
              detalles.add(detalle.toString());
            }
          }
        }

        return ApiException(
          message: cuerpoError['message']?.toString() ?? 'La operacion no se pudo completar.',
          statusCode: respuesta?.statusCode,
          details: detalles,
        );
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'La conexion con el servidor tardo demasiado. Intente de nuevo.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No se pudo conectar con la API. Verifique que el backend este en ejecucion y la URL configurada.',
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'La solicitud fue cancelada.');
      default:
        final mensaje = respuesta?.statusMessage?.trim();
        return ApiException(
          message: mensaje == null || mensaje.isEmpty
              ? 'Ocurrio un error al comunicarse con el servidor.'
              : 'Error del servidor: $mensaje',
          statusCode: respuesta?.statusCode,
        );
    }
  }

  /// Mensaje corto listo para un SnackBar o una tarjeta de error.
  String get mensajeCompleto {
    if (details.isEmpty) return message;
    return '$message\n${details.map((detalle) => '- $detalle').join('\n')}';
  }

  @override
  String toString() => message;
}

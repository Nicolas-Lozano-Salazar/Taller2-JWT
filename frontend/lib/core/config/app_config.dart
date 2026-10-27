import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuracion central de la aplicacion.
///
/// La URL de la API se obtiene del archivo .env mediante flutter_dotenv,
/// tal como exige el enunciado del parcial.
class AppConfig {
  AppConfig._();

  static const String _urlPorDefecto = 'http://10.0.2.2:3000/api';
  static const String _urlCompilacion = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    final urlCompilada = _urlCompilacion.trim();
    final url = urlCompilada.isNotEmpty ? urlCompilada : dotenv.env['API_BASE_URL']?.trim();
    if (url == null || url.isEmpty) return _urlPorDefecto;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static const Duration tiempoConexion = Duration(seconds: 15);
  static const Duration tiempoRespuesta = Duration(seconds: 20);
}

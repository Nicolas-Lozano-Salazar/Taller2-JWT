import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Cliente HTTP unico de la aplicacion, construido sobre Dio.
/// Los widgets nunca usan Dio directamente: lo hacen a traves del repositorio.
class ApiClient {
  ApiClient._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: AppConfig.tiempoConexion,
            receiveTimeout: AppConfig.tiempoRespuesta,
            sendTimeout: AppConfig.tiempoRespuesta,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (objeto) => debugPrint('[Dio] $objeto'),
        ),
      );
    }
  }

  static final ApiClient instance = ApiClient._internal();

  final Dio _dio;

  Dio get dio => _dio;
}

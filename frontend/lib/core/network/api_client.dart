import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_controller.dart';
import '../config/app_config.dart';
import '../storage/session_storage.dart';
import '../storage/token_storage.dart';

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
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.leer();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final esLogin = error.requestOptions.path.contains('/auth/login');
          if (error.response?.statusCode == 401 && !esLogin) {
            await TokenStorage.instance.eliminar();
            await SessionStorage.instance.limpiar();
            AuthController.alExpirarSesion?.call();
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
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

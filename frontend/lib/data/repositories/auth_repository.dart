import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/session_storage.dart';
import '../../core/storage/token_storage.dart';
import '../models/usuario.dart';

/// Repositorio de autenticacion: unico punto que conoce el endpoint de login.
class AuthRepository {
  AuthRepository({
    Dio? dio,
    TokenStorage? tokenStorage,
    SessionStorage? sessionStorage,
  })  : _dio = dio ?? ApiClient.instance.dio,
        _tokenStorage = tokenStorage ?? TokenStorage.instance,
        _sessionStorage = sessionStorage ?? SessionStorage.instance;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final SessionStorage _sessionStorage;

  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    try {
      final respuesta = await _dio.post<dynamic>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final cuerpo = _comoMapa(respuesta.data);
      final datos = _comoMapa(cuerpo['data']);
      final token = datos['accessToken']?.toString();
      if (token == null || token.isEmpty) {
        throw const ApiException(message: 'La API no devolvio un token valido.');
      }

      final usuario = Usuario.fromJson(_comoMapa(datos['usuario']));
      await _tokenStorage.guardar(token);
      await _sessionStorage.guardar(usuario);
      return usuario;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Usuario> obtenerSesion() async {
    try {
      final respuesta = await _dio.get<dynamic>('/auth/me');
      final cuerpo = _comoMapa(respuesta.data);
      final datos = _comoMapa(cuerpo['data']);
      final usuarioJson = datos['usuario'];
      if (usuarioJson is Map) {
        return Usuario.fromJson(_comoMapa(usuarioJson));
      }
      // Fallback a datos locales si el backend no devuelve usuario.
      final local = await _sessionStorage.leer();
      if (local != null) return local;
      throw const ApiException(message: 'No se pudo obtener la informacion de la sesion.');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> cerrarSesion() async {
    await _tokenStorage.eliminar();
    await _sessionStorage.limpiar();
  }

  Map<String, dynamic> _comoMapa(dynamic valor) {
    if (valor is Map<String, dynamic>) return valor;
    if (valor is Map) {
      return valor.map((clave, contenido) => MapEntry(clave.toString(), contenido));
    }
    throw const ApiException(message: 'La respuesta de la API no tiene el formato esperado.');
  }
}
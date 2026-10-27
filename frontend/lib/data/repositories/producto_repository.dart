import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/estadisticas.dart';
import '../models/producto.dart';

/// Repositorio de productos: unico punto de la app que conoce los endpoints
/// de la API. Las pantallas solo invocan estos metodos (nunca Dio directo).
class ProductoRepository {
  ProductoRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<List<Producto>> listar({String buscar = ''}) async {
    try {
      final filtro = buscar.trim();
      final respuesta = await _dio.get<dynamic>(
        '/productos',
        queryParameters: filtro.isEmpty ? null : {'buscar': filtro},
      );

      final cuerpo = _comoMapa(respuesta.data);
      final lista = cuerpo['data'];
      if (lista is! List) {
        throw const ApiException(message: 'La API no devolvio un listado de productos valido.');
      }

      return lista
          .whereType<Map>()
          .map((item) => Producto.fromJson(_comoMapa(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Producto> obtener(int id) async {
    try {
      final respuesta = await _dio.get<dynamic>('/productos/$id');
      return Producto.fromJson(_comoMapa(_comoMapa(respuesta.data)['data']));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Producto> crear(Producto producto) async {
    try {
      final respuesta = await _dio.post<dynamic>('/productos', data: producto.toJson());
      return Producto.fromJson(_comoMapa(_comoMapa(respuesta.data)['data']));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Producto> actualizar(int id, Producto producto) async {
    try {
      final respuesta = await _dio.put<dynamic>('/productos/$id', data: producto.toJson());
      return Producto.fromJson(_comoMapa(_comoMapa(respuesta.data)['data']));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _dio.delete<dynamic>('/productos/$id');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Estadisticas> obtenerEstadisticas() async {
    try {
      final respuesta = await _dio.get<dynamic>('/estadisticas');
      return Estadisticas.fromJson(_comoMapa(_comoMapa(respuesta.data)['data']));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic> _comoMapa(dynamic valor) {
    if (valor is Map<String, dynamic>) return valor;
    if (valor is Map) {
      return valor.map((clave, contenido) => MapEntry(clave.toString(), contenido));
    }
    throw const ApiException(message: 'La respuesta de la API no tiene el formato esperado.');
  }
}

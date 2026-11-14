import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento seguro del access token (flutter_secure_storage).
class TokenStorage {
  TokenStorage._internal();
  static final TokenStorage instance = TokenStorage._internal();

  static const String _claveToken = 'access_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> guardar(String token) =>
      _storage.write(key: _claveToken, value: token);

  Future<String?> leer() => _storage.read(key: _claveToken);

  Future<void> eliminar() => _storage.delete(key: _claveToken);

  Future<bool> existe() async => (await leer()) != null;
}
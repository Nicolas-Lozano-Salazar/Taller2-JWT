import 'package:flutter/foundation.dart';

import '../../data/models/usuario.dart';
import '../../data/repositories/auth_repository.dart';
import '../storage/token_storage.dart';

enum AuthStatus { desconocido, noAutenticado, autenticado }

class AuthState {
  const AuthState({
    required this.status,
    this.usuario,
    this.cargando = false,
    this.error,
  });

  final AuthStatus status;
  final Usuario? usuario;
  final bool cargando;
  final String? error;

  bool get estaAutenticado => status == AuthStatus.autenticado;

  static const AuthState inicial = AuthState(status: AuthStatus.desconocido);
}

/// Controlador de sesion. Se expone como singleton y como ValueNotifier para
/// que GoRouter se refresque cuando cambie el estado de autenticacion.
class AuthController extends ValueNotifier<AuthState> {
  AuthController._internal()
      : _repositorio = AuthRepository(),
        super(AuthState.inicial);

  static AuthController? _instancia;
  static AuthController get instance =>
      _instancia ??= AuthController._internal();

  final AuthRepository _repositorio;

  /// Callback que ApiClient puede invocar cuando recibe un 401.
  static void Function()? alExpirarSesion;

  Future<void> inicializar() async {
    alExpirarSesion = () => cerrarSesion();

    String? token;
    try {
      token = await TokenStorage.instance.leer();
    } catch (error) {
      debugPrint('No se pudo leer el token almacenado: $error');
    }

    if (token == null || token.isEmpty) {
      value = const AuthState(status: AuthStatus.noAutenticado);
      return;
    }

    // Intentar recuperar la sesion desde el backend.
    try {
      final usuario = await _repositorio.obtenerSesion();
      value = AuthState(status: AuthStatus.autenticado, usuario: usuario);
    } catch (_) {
      await cerrarSesion();
    }
  }

  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    value = AuthState(
      status: value.status,
      usuario: value.usuario,
      cargando: true,
    );

    try {
      final usuario = await _repositorio.login(email: email, password: password);
      value = AuthState(status: AuthStatus.autenticado, usuario: usuario);
      return true;
    } catch (error) {
      value = AuthState(
        status: AuthStatus.noAutenticado,
        cargando: false,
        error: error.toString(),
      );
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _repositorio.cerrarSesion();
    } catch (error) {
      debugPrint('No se pudieron borrar los datos de sesion: $error');
    } finally {
      value = const AuthState(status: AuthStatus.noAutenticado);
    }
  }

  void limpiarError() {
    if (value.error != null) {
      value = AuthState(status: value.status, usuario: value.usuario);
    }
  }
}
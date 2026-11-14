import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_app/core/auth/auth_controller.dart';
import 'package:inventario_app/data/models/usuario.dart';

void main() {
  group('Usuario', () {
    test('fromJson interpreta los datos del login', () {
      final usuario = Usuario.fromJson({
        'id': 7,
        'nombre': 'Administrador',
        'email': 'admin@inventario.com',
      });

      expect(usuario.id, 7);
      expect(usuario.nombre, 'Administrador');
      expect(usuario.email, 'admin@inventario.com');
    });

    test('fromJson tolera campos ausentes', () {
      final usuario = Usuario.fromJson({});

      expect(usuario.id, 0);
      expect(usuario.nombre, isEmpty);
      expect(usuario.email, isEmpty);
    });
  });

  group('AuthState', () {
    test('estaAutenticado solo es true con estado autenticado', () {
      const activo = AuthState(status: AuthStatus.autenticado);
      const inactivo = AuthState(status: AuthStatus.noAutenticado);
      const desconocido = AuthState(status: AuthStatus.desconocido);

      expect(activo.estaAutenticado, isTrue);
      expect(inactivo.estaAutenticado, isFalse);
      expect(desconocido.estaAutenticado, isFalse);
    });
  });
}
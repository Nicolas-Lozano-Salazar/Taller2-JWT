import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/productos/producto_detalle_screen.dart';
import '../presentation/screens/productos/producto_form_screen.dart';
import '../presentation/screens/productos/productos_screen.dart';
import '../presentation/screens/sesion/sesion_screen.dart';
import '../presentation/screens/shell/app_shell.dart';

/// Navegacion declarativa con go_router.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _navegadorRaiz =
      GlobalKey<NavigatorState>(debugLabel: 'raiz');

  static GoRouter create() {
    final auth = AuthController.instance;
    return GoRouter(
      navigatorKey: _navegadorRaiz,
      initialLocation: '/',
      refreshListenable: auth,
      redirect: (context, state) {
        final autenticado = auth.value.estaAutenticado;
        final enLogin = state.matchedLocation == '/login';

        if (!autenticado && !enLogin) return '/login';
        if (autenticado && enLogin) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(
            ubicacion: state.uri.path,
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/',
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/productos',
              name: 'productos',
              builder: (context, state) => const ProductosScreen(),
              routes: [
                GoRoute(
                  path: 'nuevo',
                  name: 'producto-nuevo',
                  parentNavigatorKey: _navegadorRaiz,
                  builder: (context, state) => const ProductoFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'producto-detalle',
                  parentNavigatorKey: _navegadorRaiz,
                  builder: (context, state) {
                    final id = int.tryParse(state.pathParameters['id'] ?? '');
                    return ProductoDetalleScreen(productoId: id ?? 0);
                  },
                  routes: [
                    GoRoute(
                      path: 'editar',
                      name: 'producto-editar',
                      parentNavigatorKey: _navegadorRaiz,
                      builder: (context, state) {
                        final id = int.tryParse(state.pathParameters['id'] ?? '');
                        return ProductoFormScreen(productoId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/sesion',
              name: 'sesion',
              builder: (context, state) => const SesionScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => const RutaNoEncontrada(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/productos/producto_detalle_screen.dart';
import '../presentation/screens/productos/producto_form_screen.dart';
import '../presentation/screens/productos/productos_screen.dart';
import '../presentation/screens/shell/app_shell.dart';

/// Navegacion declarativa con go_router.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _navegadorRaiz =
      GlobalKey<NavigatorState>(debugLabel: 'raiz');

  static GoRouter create() {
    return GoRouter(
      navigatorKey: _navegadorRaiz,
      initialLocation: '/',
      routes: [
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
          ],
        ),
      ],
      errorBuilder: (context, state) => const RutaNoEncontrada(),
    );
  }
}

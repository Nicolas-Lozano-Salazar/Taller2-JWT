import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

/// Contenedor con el menu inferior para las secciones principales.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.ubicacion,
    required this.child,
  });

  final String ubicacion;
  final Widget child;

  int get _indice {
    if (ubicacion.startsWith('/productos')) return 1;
    if (ubicacion.startsWith('/sesion')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        height: 68,
        onDestinationSelected: (indice) {
          if (indice == _indice) return;
          if (indice == 0) context.go('/');
          if (indice == 1) context.go('/productos');
          if (indice == 2) context.go('/sesion');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Sesion',
          ),
        ],
      ),
    );
  }
}

/// Pagina mostrada cuando la ruta no existe.
class RutaNoEncontrada extends StatelessWidget {
  const RutaNoEncontrada({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagina no encontrada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_outlined, size: 64, color: AppTheme.textoSuave),
              const SizedBox(height: 16),
              const Text(
                'La pantalla que busca no existe.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppTheme.textoSuave),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

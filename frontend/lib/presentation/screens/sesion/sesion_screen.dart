import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/storage/token_storage.dart';
import '../../theme/app_theme.dart';

/// Vista de informacion de la sesion activa.
class SesionScreen extends StatelessWidget {
  const SesionScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    await AuthController.instance.cerrarSesion();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: AuthController.instance,
      builder: (context, estado, _) {
        final usuario = estado.usuario;
        return Scaffold(
          appBar: AppBar(title: const Text('Sesion')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: AppTheme.primario.withValues(alpha: 0.12),
                        child: const Icon(Icons.person, size: 36, color: AppTheme.primario),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        usuario?.nombre ?? 'Sin sesion',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        usuario?.email ?? 'No hay un usuario autenticado',
                        style: const TextStyle(color: AppTheme.textoSuave),
                      ),
                      const SizedBox(height: 16),
                      _FilaInfo(
                        icono: Icons.verified_user_outlined,
                        etiqueta: 'Estado de autenticacion',
                        valor: estado.estaAutenticado ? 'Sesion activa' : 'Sin sesion',
                        color: estado.estaAutenticado ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<bool>(
                        future: TokenStorage.instance.existe(),
                        builder: (context, snapshot) {
                          final existe = snapshot.data ?? false;
                          return _FilaInfo(
                            icono: Icons.key_outlined,
                            etiqueta: 'Token JWT almacenado',
                            valor: existe ? 'Si (contenido oculto)' : 'No',
                            color: existe ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _cerrarSesion(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesion'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Al cerrar sesion se eliminan el token seguro y los datos locales del usuario.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.textoSuave),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilaInfo extends StatelessWidget {
  const _FilaInfo({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 20, color: AppTheme.textoSuave),
        const SizedBox(width: 10),
        Expanded(child: Text(etiqueta, style: const TextStyle(fontSize: 13))),
        Text(
          valor,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
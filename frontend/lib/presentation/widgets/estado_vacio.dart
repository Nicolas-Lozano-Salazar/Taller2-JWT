import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Mensaje para listados sin resultados o inventarios vacios.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoAccion,
    this.onAccion,
    this.icono = Icons.inventory_2_outlined,
  });

  final String titulo;
  final String mensaje;
  final String? textoAccion;
  final VoidCallback? onAccion;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primario.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icono, size: 44, color: AppTheme.primario),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primario,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textoSuave, height: 1.5),
            ),
            if (textoAccion != null && onAccion != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAccion,
                style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
                icon: const Icon(Icons.add),
                label: Text(textoAccion!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

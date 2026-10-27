import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Vista reutilizable para estados de error de red o de la API.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.mensaje,
    required this.onReintentar,
  });

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 40, color: Color(0xFFC62828)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar la informacion',
              textAlign: TextAlign.center,
              style: TextStyle(
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
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onReintentar,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(180, 46),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/utils/formato.dart';
import '../../data/models/producto.dart';
import '../theme/app_theme.dart';

/// Tarjeta del listado de productos: nombre, precio y cantidad disponible.
class ProductoCard extends StatelessWidget {
  const ProductoCard({
    super.key,
    required this.producto,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  final Producto producto;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  IconData get _iconoCategoria {
    switch (producto.categoria.toLowerCase()) {
      case 'alimentos':
        return Icons.restaurant_outlined;
      case 'aseo':
        return Icons.cleaning_services_outlined;
      case 'bebidas':
        return Icons.local_drink_outlined;
      case 'papeleria':
      case 'papelería':
        return Icons.edit_note_outlined;
      case 'tecnologia':
      case 'tecnología':
        return Icons.devices_other_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockBajo = producto.stockBajo;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primario.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconoCategoria, color: AppTheme.primario, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primario,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${producto.codigo} · ${producto.categoria}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Etiqueta(
                          icono: Icons.payments_outlined,
                          texto: Formato.precio(producto.precio),
                          color: AppTheme.secundario,
                        ),
                        _Etiqueta(
                          icono: Icons.inventory_2_outlined,
                          texto: '${producto.cantidad} und',
                          color: stockBajo ? const Color(0xFFC62828) : AppTheme.textoSuave,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opciones',
                icon: const Icon(Icons.more_vert, color: AppTheme.textoSuave),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (opcion) {
                  if (opcion == 'editar') onEditar();
                  if (opcion == 'eliminar') onEliminar();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Color(0xFFC62828)),
                        SizedBox(width: 10),
                        Text('Eliminar', style: TextStyle(color: Color(0xFFC62828))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.icono,
    required this.texto,
    required this.color,
  });

  final IconData icono;
  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

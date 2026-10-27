import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/formato.dart';
import '../../../data/models/producto.dart';
import '../../../data/repositories/producto_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_view.dart';

/// Consulta del detalle completo de un producto (GET /api/productos/{id}).
class ProductoDetalleScreen extends StatefulWidget {
  const ProductoDetalleScreen({super.key, required this.productoId});

  final int productoId;

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  final ProductoRepository _repositorio = ProductoRepository();
  late Future<Producto> _producto;

  @override
  void initState() {
    super.initState();
    _producto = _consultar();
  }

  Future<Producto> _consultar() {
    if (widget.productoId <= 0) {
      return Future<Producto>.error(
        const ApiException(message: 'El identificador del producto no es valido.'),
      );
    }
    return _repositorio.obtener(widget.productoId);
  }

  void _recargar() {
    setState(() {
      _producto = _consultar();
    });
  }

  String _mensajeError(Object error) {
    return error is ApiException ? error.mensajeCompleto : error.toString();
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? const Color(0xFFC62828) : AppTheme.secundario,
      ),
    );
  }

  Future<void> _editar(Producto producto) async {
    final actualizado = await context.push<bool>('/productos/${producto.id}/editar');
    if (actualizado == true && mounted) {
      _recargar();
      _mostrarMensaje('Producto actualizado correctamente.');
    }
  }

  Future<void> _confirmarEliminacion(Producto producto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contextDialogo) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Seguro que desea eliminar "${producto.nombre}"?\n\nEsta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contextDialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contextDialogo).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      await _repositorio.eliminar(producto.id);
      if (!mounted) return;
      _mostrarMensaje('Producto eliminado correctamente.');
      context.pop(true);
    } catch (error) {
      _mostrarMensaje(_mensajeError(error), esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: FutureBuilder<Producto>(
        future: _producto,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorView(
              mensaje: snapshot.hasError
                  ? _mensajeError(snapshot.error!)
                  : 'No se encontro informacion del producto.',
              onReintentar: _recargar,
            );
          }

          return _ContenidoDetalle(
            producto: snapshot.data!,
            onEditar: _editar,
            onEliminar: _confirmarEliminacion,
          );
        },
      ),
    );
  }
}

class _ContenidoDetalle extends StatelessWidget {
  const _ContenidoDetalle({
    required this.producto,
    required this.onEditar,
    required this.onEliminar,
  });

  final Producto producto;
  final Future<void> Function(Producto) onEditar;
  final Future<void> Function(Producto) onEliminar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borde),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primario.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primario, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primario,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Codigo: ${producto.codigo}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textoSuave),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Chip(texto: producto.categoria),
                        _Chip(
                          texto: producto.stockBajo ? 'Stock bajo' : 'Disponible',
                          color: producto.stockBajo
                              ? const Color(0xFFC62828)
                              : AppTheme.secundario,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Informacion del producto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.primario,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borde),
          ),
          child: Column(
            children: [
              _FilaInfo(
                icono: Icons.payments_outlined,
                etiqueta: 'Precio unitario',
                valor: Formato.precio(producto.precio),
              ),
              const Divider(height: 1),
              _FilaInfo(
                icono: Icons.inventory_2_outlined,
                etiqueta: 'Cantidad disponible',
                valor: '${Formato.entero(producto.cantidad)} unidades',
              ),
              const Divider(height: 1),
              _FilaInfo(
                icono: Icons.payments_outlined,
                etiqueta: 'Valor en inventario',
                valor: Formato.moneda(producto.valorInventario),
              ),
              const Divider(height: 1),
              _FilaInfo(
                icono: Icons.category_outlined,
                etiqueta: 'Categoria',
                valor: producto.categoria,
              ),
              const Divider(height: 1),
              _FilaInfo(
                icono: Icons.qr_code_2_outlined,
                etiqueta: 'Codigo',
                valor: producto.codigo,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Descripcion',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.primario,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borde),
          ),
          child: Text(
            producto.descripcion.isEmpty ? 'Sin descripcion registrada.' : producto.descripcion,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: producto.descripcion.isEmpty ? AppTheme.textoSuave : const Color(0xFF334155),
              fontStyle: producto.descripcion.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => onEditar(producto),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar producto'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => onEliminar(producto),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFC62828),
            side: const BorderSide(color: Color(0xFFE7B5B5)),
          ),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Eliminar producto'),
        ),
      ],
    );
  }
}

class _FilaInfo extends StatelessWidget {
  const _FilaInfo({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icono, size: 20, color: AppTheme.textoSuave),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(fontSize: 13, color: AppTheme.textoSuave),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primario,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.texto, this.color = AppTheme.primario});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/producto.dart';
import '../../../data/repositories/producto_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_view.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/producto_card.dart';

/// Listado de productos con busqueda, edicion y eliminacion.
class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoRepository _repositorio = ProductoRepository();
  final TextEditingController _buscador = TextEditingController();

  List<Producto>? _productos;
  Object? _error;
  bool _cargando = true;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final productos = await _repositorio.listar();
      if (!mounted) return;
      setState(() {
        _productos = productos;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _cargando = false;
      });
      if (_productos != null) {
        _mostrarMensaje(_mensajeError(error), esError: true);
      }
    }
  }

  List<Producto> get _filtrados {
    final productos = _productos ?? const <Producto>[];
    final consulta = _filtro.trim().toLowerCase();
    if (consulta.isEmpty) return productos;

    return productos.where((producto) {
      return producto.nombre.toLowerCase().contains(consulta) ||
          producto.codigo.toLowerCase().contains(consulta) ||
          producto.categoria.toLowerCase().contains(consulta);
    }).toList(growable: false);
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

  Future<void> _abrirNuevo() async {
    await context.push<bool>('/productos/nuevo');
    if (mounted) _cargar();
  }

  Future<void> _abrirDetalle(Producto producto) async {
    await context.push<bool>('/productos/${producto.id}');
    if (mounted) _cargar();
  }

  Future<void> _abrirEdicion(Producto producto) async {
    await context.push<bool>('/productos/${producto.id}/editar');
    if (mounted) _cargar();
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
      _mostrarMensaje('Producto eliminado correctamente.');
      await _cargar();
    } catch (error) {
      _mostrarMensaje(_mensajeError(error), esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            tooltip: 'Recargar listado',
            onPressed: _cargando ? null : _cargar,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _buscador,
              textInputAction: TextInputAction.search,
              onChanged: (valor) => setState(() => _filtro = valor),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, codigo o categoria',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _filtro.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar busqueda',
                        onPressed: () {
                          _buscador.clear();
                          setState(() => _filtro = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  _cargando
                      ? 'Consultando la API...'
                      : '${filtrados.length} producto${filtrados.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textoSuave,
                  ),
                ),
                const Spacer(),
                if (_cargando && _productos != null)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(child: _construirContenido(filtrados)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNuevo,
        backgroundColor: AppTheme.primario,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _construirContenido(List<Producto> filtrados) {
    if (_cargando && _productos == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _productos == null) {
      return ErrorView(
        mensaje: _mensajeError(_error!),
        onReintentar: _cargar,
      );
    }

    if ((_productos ?? const []).isEmpty) {
      return EstadoVacio(
        titulo: 'Sin productos registrados',
        mensaje: 'Aun no hay productos en el inventario. Registre el primero para comenzar.',
        textoAccion: 'Registrar producto',
        onAccion: _abrirNuevo,
      );
    }

    if (filtrados.isEmpty) {
      return const EstadoVacio(
        icono: Icons.search_off,
        titulo: 'Sin resultados',
        mensaje: 'Ningun producto coincide con la busqueda realizada.',
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: filtrados.length,
        itemBuilder: (context, indice) {
          final producto = filtrados[indice];
          return ProductoCard(
            producto: producto,
            onTap: () => _abrirDetalle(producto),
            onEditar: () => _abrirEdicion(producto),
            onEliminar: () => _confirmarEliminacion(producto),
          );
        },
      ),
    );
  }
}

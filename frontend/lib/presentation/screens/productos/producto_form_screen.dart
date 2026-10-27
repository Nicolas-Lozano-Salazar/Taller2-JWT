import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/producto.dart';
import '../../../data/repositories/producto_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_view.dart';

/// Formulario para registrar (POST) o editar (PUT) un producto.
class ProductoFormScreen extends StatefulWidget {
  const ProductoFormScreen({super.key, this.productoId});

  final int? productoId;

  bool get esEdicion => productoId != null;

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final ProductoRepository _repositorio = ProductoRepository();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _codigo;
  late final TextEditingController _categoria;
  late final TextEditingController _precio;
  late final TextEditingController _cantidad;
  late final TextEditingController _descripcion;

  bool _cargando = false;
  bool _guardando = false;
  Object? _errorCarga;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController();
    _codigo = TextEditingController();
    _categoria = TextEditingController();
    _precio = TextEditingController();
    _cantidad = TextEditingController();
    _descripcion = TextEditingController();

    if (widget.esEdicion) {
      _cargarProducto();
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _codigo.dispose();
    _categoria.dispose();
    _precio.dispose();
    _cantidad.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _cargarProducto() async {
    final id = widget.productoId;
    if (id == null) return;

    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final producto = await _repositorio.obtener(id);
      if (!mounted) return;

      _nombre.text = producto.nombre;
      _codigo.text = producto.codigo;
      _categoria.text = producto.categoria;
      _precio.text = producto.precio % 1 == 0
          ? producto.precio.toStringAsFixed(0)
          : producto.precio.toStringAsFixed(2);
      _cantidad.text = producto.cantidad.toString();
      _descripcion.text = producto.descripcion;

      setState(() => _cargando = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorCarga = error;
        _cargando = false;
      });
    }
  }

  String _mensajeError(Object error) {
    return error is ApiException ? error.mensajeCompleto : error.toString();
  }

  void _mostrarError(Object error) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(_mensajeError(error)),
        backgroundColor: const Color(0xFFC62828),
      ),
    );
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    final precio = double.parse(_precio.text.trim().replaceAll(',', '.'));
    final cantidad = int.parse(_cantidad.text.trim());
    final producto = Producto(
      id: widget.productoId ?? 0,
      nombre: _nombre.text.trim(),
      codigo: _codigo.text.trim().toUpperCase(),
      descripcion: _descripcion.text.trim(),
      precio: precio,
      cantidad: cantidad,
      categoria: _categoria.text.trim(),
    );

    setState(() => _guardando = true);

    try {
      if (widget.productoId == null) {
        await _repositorio.crear(producto);
      } else {
        await _repositorio.actualizar(widget.productoId!, producto);
      }

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.esEdicion
                ? 'Producto actualizado correctamente.'
                : 'Producto registrado correctamente.',
          ),
          backgroundColor: AppTheme.secundario,
        ),
      );

      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _mostrarError(error);
    }
  }

  String? _validarNombre(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'El nombre es obligatorio.';
    if (texto.length < 2) return 'Ingrese al menos 2 caracteres.';
    if (texto.length > 120) return 'Maximo 120 caracteres.';
    return null;
  }

  String? _validarCodigo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'El codigo es obligatorio.';
    if (texto.length < 2) return 'Ingrese al menos 2 caracteres.';
    if (texto.length > 40) return 'Maximo 40 caracteres.';
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(texto)) {
      return 'Solo letras, numeros, punto, guion y guion bajo.';
    }
    return null;
  }

  String? _validarCategoria(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'La categoria es obligatoria.';
    if (texto.length < 2) return 'Ingrese al menos 2 caracteres.';
    if (texto.length > 60) return 'Maximo 60 caracteres.';
    return null;
  }

  String? _validarPrecio(String? valor) {
    final texto = valor?.trim().replaceAll(',', '.') ?? '';
    if (texto.isEmpty) return 'El precio es obligatorio.';
    final numero = double.tryParse(texto);
    if (numero == null) return 'Ingrese un precio valido.';
    if (numero < 0) return 'El precio no puede ser negativo.';
    return null;
  }

  String? _validarCantidad(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'La cantidad es obligatoria.';
    final numero = int.tryParse(texto);
    if (numero == null) return 'Ingrese un numero entero.';
    if (numero < 0) return 'La cantidad no puede ser negativa.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.esEdicion ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorCarga != null) {
      return ErrorView(
        mensaje: _mensajeError(_errorCarga!),
        onReintentar: _cargarProducto,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primario.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borde),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: AppTheme.primario),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.esEdicion
                          ? 'Modifica los datos del producto y guarda los cambios.'
                          : 'Completa la informacion para registrar un nuevo producto en la base de datos.',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textoSuave, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _Etiqueta(texto: 'Informacion basica'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: _validarNombre,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto *',
                hintText: 'Ej: Arroz Diana 1 kg',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _codigo,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9._-]')),
                LengthLimitingTextInputFormatter(40),
              ],
              validator: _validarCodigo,
              decoration: const InputDecoration(
                labelText: 'Codigo unico *',
                hintText: 'Ej: ALI-001',
                prefixIcon: Icon(Icons.qr_code_2_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _categoria,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: _validarCategoria,
              decoration: const InputDecoration(
                labelText: 'Categoria *',
                hintText: 'Ej: Alimentos, Aseo, Bebidas',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 18),
            const _Etiqueta(texto: 'Precio y existencias'),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precio,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: _validarPrecio,
                    decoration: const InputDecoration(
                      labelText: 'Precio unitario *',
                      hintText: 'Ej: 12500.50',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cantidad,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validarCantidad,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad *',
                      hintText: 'Ej: 25',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _Etiqueta(texto: 'Descripcion'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descripcion,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Descripcion (opcional)',
                hintText: 'Detalles adicionales del producto...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _guardando
                    ? 'Guardando...'
                    : widget.esEdicion
                        ? 'Guardar cambios'
                        : 'Registrar producto',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _guardando ? null : () => context.pop(false),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.primario,
      ),
    );
  }
}

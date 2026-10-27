import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/formato.dart';
import '../../../data/models/estadisticas.dart';
import '../../../data/repositories/producto_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_view.dart';
import '../../widgets/indicador_card.dart';

/// Pantalla principal con los indicadores reales del inventario.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ProductoRepository _repositorio = ProductoRepository();
  late Future<Estadisticas> _estadisticas;

  @override
  void initState() {
    super.initState();
    _estadisticas = _repositorio.obtenerEstadisticas();
  }

  void _cargar() {
    setState(() {
      _estadisticas = _repositorio.obtenerEstadisticas();
    });
  }

  Future<void> _recargar() async {
    final consulta = _repositorio.obtenerEstadisticas();
    setState(() {
      _estadisticas = consulta;
    });
    try {
      await consulta;
    } catch (_) {
      // El FutureBuilder muestra el error; se evita una excepcion sin manejar.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primario,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inventario Pro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text(
                  'Gestion de productos',
                  style: TextStyle(fontSize: 11, color: AppTheme.textoSuave, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar indicadores',
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: FutureBuilder<Estadisticas>(
        future: _estadisticas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error!;
            return ErrorView(
              mensaje: error is ApiException ? error.mensajeCompleto : error.toString(),
              onReintentar: _cargar,
            );
          }

          final datos = snapshot.data ?? Estadisticas.vacias;
          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                const _BannerBienvenida(),
                const SizedBox(height: 20),
                const Text(
                  'Resumen del inventario',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primario,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: IndicadorCard(
                        titulo: 'Productos registrados',
                        valor: Formato.entero(datos.totalProductos),
                        icono: Icons.inventory_2_outlined,
                        color: AppTheme.primario,
                        detalle: '${datos.totalCategorias} categorias',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IndicadorCard(
                        titulo: 'Unidades disponibles',
                        valor: Formato.entero(datos.totalUnidades),
                        icono: Icons.warehouse_outlined,
                        color: AppTheme.secundario,
                        detalle: 'En todo el inventario',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                IndicadorCard(
                  titulo: 'Valor economico total',
                  valor: Formato.moneda(datos.valorInventario),
                  icono: Icons.payments_outlined,
                  color: const Color(0xFFB26A00),
                  detalle: 'Calculado como precio x cantidad de cada producto',
                ),
                if (datos.productosStockBajo > 0) ...[
                  const SizedBox(height: 12),
                  _AvisoStock(cantidad: datos.productosStockBajo),
                ],
                const SizedBox(height: 22),
                const Text(
                  'Accesos rapidos',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primario,
                  ),
                ),
                const SizedBox(height: 12),
                _AccesoGestion(onTap: () => context.go('/productos')),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Indicadores calculados en tiempo real por la API REST',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppTheme.textoSuave),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BannerBienvenida extends StatelessWidget {
  const _BannerBienvenida();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primario, Color(0xFF2C5A96)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, bienvenido',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Controla tu inventario\nde forma sencilla',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Electiva Profesional I · API REST + Flutter',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.insights_rounded,
            size: 74,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ],
      ),
    );
  }
}

class _AvisoStock extends StatelessWidget {
  const _AvisoStock({required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0D9A8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB26A00)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cantidad == 1
                  ? '1 producto tiene stock bajo (menos de 5 unidades).'
                  : '$cantidad productos tienen stock bajo (menos de 5 unidades).',
              style: const TextStyle(fontSize: 13, color: Color(0xFF7A4A00), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccesoGestion extends StatelessWidget {
  const _AccesoGestion({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borde),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secundario.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppTheme.secundario, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestion de productos',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primario,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Consultar, registrar, editar y eliminar',
                      style: TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textoSuave),
            ],
          ),
        ),
      ),
    );
  }
}

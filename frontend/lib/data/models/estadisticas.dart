/// Indicadores del inventario calculados por la API para el dashboard.
class Estadisticas {
  const Estadisticas({
    required this.totalProductos,
    required this.totalUnidades,
    required this.valorInventario,
    required this.productosStockBajo,
    required this.totalCategorias,
  });

  final int totalProductos;
  final int totalUnidades;
  final double valorInventario;
  final int productosStockBajo;
  final int totalCategorias;

  factory Estadisticas.fromJson(Map<String, dynamic> json) {
    return Estadisticas(
      totalProductos: (json['totalProductos'] as num?)?.toInt() ?? 0,
      totalUnidades: (json['totalUnidades'] as num?)?.toInt() ?? 0,
      valorInventario: (json['valorInventario'] as num?)?.toDouble() ?? 0,
      productosStockBajo: (json['productosStockBajo'] as num?)?.toInt() ?? 0,
      totalCategorias: (json['totalCategorias'] as num?)?.toInt() ?? 0,
    );
  }

  static const Estadisticas vacias = Estadisticas(
    totalProductos: 0,
    totalUnidades: 0,
    valorInventario: 0,
    productosStockBajo: 0,
    totalCategorias: 0,
  );
}

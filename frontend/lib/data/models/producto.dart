/// Modelo de dominio de un producto del inventario.
/// Sus campos coinciden con los de la entidad almacenada en la base de datos.
class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.descripcion,
    required this.precio,
    required this.cantidad,
    required this.categoria,
  });

  final int id;
  final String nombre;
  final String codigo;
  final String descripcion;
  final double precio;
  final int cantidad;
  final String categoria;

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      codigo: json['codigo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0,
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      categoria: json['categoria']?.toString() ?? '',
    );
  }

  /// Cuerpo JSON que se envia a la API en POST y PUT.
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'precio': precio,
      'cantidad': cantidad,
      'categoria': categoria,
    };
  }

  double get valorInventario => precio * cantidad;

  bool get stockBajo => cantidad < 5;

  Producto copyWith({
    int? id,
    String? nombre,
    String? codigo,
    String? descripcion,
    double? precio,
    int? cantidad,
    String? categoria,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      categoria: categoria ?? this.categoria,
    );
  }
}

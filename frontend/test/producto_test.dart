import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_app/data/models/estadisticas.dart';
import 'package:inventario_app/data/models/producto.dart';

void main() {
  group('Producto', () {
    test('fromJson interpreta numeros enteros y decimales', () {
      final producto = Producto.fromJson({
        'id': 3,
        'nombre': 'Cafe Molido',
        'codigo': 'ALI-004',
        'descripcion': 'Empaque de 500 gramos',
        'precio': 18500,
        'cantidad': 18,
        'categoria': 'Alimentos',
      });

      expect(producto.id, 3);
      expect(producto.nombre, 'Cafe Molido');
      expect(producto.precio, 18500);
      expect(producto.cantidad, 18);
      expect(producto.stockBajo, isFalse);
    });

    test('fromJson tolera campos ausentes sin lanzar excepciones', () {
      final producto = Producto.fromJson({'id': 1});

      expect(producto.nombre, isEmpty);
      expect(producto.precio, 0);
      expect(producto.cantidad, 0);
    });

    test('toJson no incluye el id porque lo genera la base de datos', () {
      const producto = Producto(
        id: 9,
        nombre: 'Leche Entera',
        codigo: 'ALI-003',
        descripcion: '',
        precio: 4200,
        cantidad: 60,
        categoria: 'Alimentos',
      );

      final json = producto.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['codigo'], 'ALI-003');
      expect(json['precio'], 4200);
    });

    test('valorInventario multiplica precio por cantidad', () {
      const producto = Producto(
        id: 1,
        nombre: 'Audifonos',
        codigo: 'TEC-001',
        descripcion: '',
        precio: 85000,
        cantidad: 8,
        categoria: 'Tecnologia',
      );

      expect(producto.valorInventario, 680000);
    });

    test('stockBajo se activa con menos de cinco unidades', () {
      const producto = Producto(
        id: 1,
        nombre: 'Agua',
        codigo: 'BEB-002',
        descripcion: '',
        precio: 2500,
        cantidad: 4,
        categoria: 'Bebidas',
      );

      expect(producto.stockBajo, isTrue);
    });
  });

  group('Estadisticas', () {
    test('fromJson convierte los indicadores del dashboard', () {
      final estadisticas = Estadisticas.fromJson({
        'totalProductos': 12,
        'totalUnidades': 398,
        'valorInventario': 1234567.89,
        'productosStockBajo': 2,
        'totalCategorias': 5,
      });

      expect(estadisticas.totalProductos, 12);
      expect(estadisticas.totalUnidades, 398);
      expect(estadisticas.valorInventario, closeTo(1234567.89, 0.01));
      expect(estadisticas.productosStockBajo, 2);
    });

    test('valores por defecto en cero', () {
      final estadisticas = Estadisticas.fromJson({});

      expect(estadisticas.totalProductos, 0);
      expect(estadisticas.valorInventario, 0);
    });
  });
}

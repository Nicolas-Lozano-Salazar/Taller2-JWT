import 'package:intl/intl.dart';

/// Utilidades de formato para mostrar valores en la interfaz.
class Formato {
  Formato._();

  static final NumberFormat _entero = NumberFormat.decimalPattern('es_CO');
  static final NumberFormat _decimales = NumberFormat('#,##0.00', 'es_CO');

  /// Valores grandes del dashboard: $ 1.234.500
  static String moneda(num valor) => '\$ ${_entero.format(valor)}';

  /// Precio unitario: $ 4.800,00
  static String precio(num valor) => '\$ ${_decimales.format(valor)}';

  /// Cantidades y contadores: 1.234
  static String entero(num valor) => _entero.format(valor);
}

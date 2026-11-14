import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/usuario.dart';

/// Almacenamiento no sensible del usuario (shared_preferences).
class SessionStorage {
  SessionStorage._internal();
  static final SessionStorage instance = SessionStorage._internal();

  static const String _claveId = 'user_id';
  static const String _claveNombre = 'user_nombre';
  static const String _claveEmail = 'user_email';

  Future<void> guardar(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_claveId, usuario.id);
    await prefs.setString(_claveNombre, usuario.nombre);
    await prefs.setString(_claveEmail, usuario.email);
  }

  Future<Usuario?> leer() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_claveId);
    final nombre = prefs.getString(_claveNombre);
    final email = prefs.getString(_claveEmail);
    if (id == null || nombre == null || email == null) return null;
    return Usuario(id: id, nombre: nombre, email: email);
  }

  Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveId);
    await prefs.remove(_claveNombre);
    await prefs.remove(_claveEmail);
  }
}
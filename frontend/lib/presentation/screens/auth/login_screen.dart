import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@inventario.com');
  final _passwordController = TextEditingController(text: 'Admin123!');
  bool _ocultarPassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _error = null);
    final futuro = AuthController.instance.iniciarSesion(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (mounted) setState(() {});
    final ok = await futuro;

    if (!mounted) return;
    if (ok) {
      context.go('/');
    } else {
      setState(() => _error = AuthController.instance.value.error?.replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = AuthController.instance.value.cargando;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primario,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.lock_outline, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Inventario Pro',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Inicie sesion para acceder a los servicios protegidos',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textoSuave),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo electronico',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return 'Ingrese el correo electronico.';
                              }
                              if (!valor.contains('@')) {
                                return 'Correo no valido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _ocultarPassword,
                            decoration: InputDecoration(
                              labelText: 'Contrasena',
                              prefixIcon: const Icon(Icons.key_outlined),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                                icon: Icon(_ocultarPassword ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.isEmpty) {
                                return 'Ingrese la contrasena.';
                              }
                              return null;
                            },
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: const TextStyle(color: Color(0xFFC62828)),
                            ),
                          ],
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: cargando ? null : _iniciarSesion,
                            icon: cargando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.login),
                            label: Text(cargando ? 'Ingresando...' : 'Iniciar sesion'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Usuario de prueba: admin@inventario.com / Admin123!',
                  style: TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

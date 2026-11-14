import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import 'core/auth/auth_controller.dart';
import 'presentation/theme/app_theme.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // flutter_dotenv carga la URL base de la API desde el archivo .env.
  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint('No se pudo cargar .env, se usara la URL por defecto: $error');
  }

  await AuthController.instance.inicializar();

  runApp(const InventarioApp());
}

class InventarioApp extends StatefulWidget {
  const InventarioApp({super.key});

  @override
  State<InventarioApp> createState() => _InventarioAppState();
}

class _InventarioAppState extends State<InventarioApp> {
  late final GoRouter _router = AppRouter.create();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Inventario Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}

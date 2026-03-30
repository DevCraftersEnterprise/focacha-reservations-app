import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extract_error_message_util.dart';
import '../../../../core/widgets/custom_loading_overlay.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _obscurePassword = true;
  String? _errorMessage;
  OverlayEntry? _loadingOverlay;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'admin@restaurant.com');
    _passwordController = TextEditingController(text: 'Admin123*');

    // Precargar el GIF del loader para que aparezca inmediatamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/loading.gif'), context);
    });
  }

  @override
  void dispose() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
    });

    // Mostrar el overlay de loading
    final startTime = DateTime.now();

    _loadingOverlay = CustomLoadingOverlay.show(
      context,
      message: 'Iniciando sesión...',
      assetPath: 'assets/images/loading.gif',
      imageSize: 280.0,
    );

    // Dar tiempo al overlay para renderizarse completamente
    await Future.delayed(const Duration(milliseconds: 200));

    final notifier = ref.read(authProvider.notifier);
    const minimumDisplayTime = Duration(
      milliseconds: 3000,
    ); // 3 segundos mínimo

    try {
      // Ejecutar el login
      await notifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Calcular cuánto tiempo ha pasado
      final elapsed = DateTime.now().difference(startTime);

      // Si no han pasado los 3 segundos mínimos, esperar el resto
      if (elapsed < minimumDisplayTime) {
        final remaining = minimumDisplayTime - elapsed;
        await Future.delayed(remaining);
      }
    } catch (error) {
      setState(() {
        _errorMessage = extractErrorMessage(
          error,
          fallback: 'No se pudo iniciar sesión',
        );
      });

      // También esperar el tiempo mínimo en caso de error
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < minimumDisplayTime) {
        await Future.delayed(minimumDisplayTime - elapsed);
      }
    } finally {
      // Ocultar el overlay siempre al finalizar
      _loadingOverlay?.remove();
      _loadingOverlay = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Accede al sistema de reservaciones',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Iniciar sesión',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !isLoading,
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return 'Ingresa tu correo';
                                if (!text.contains('@')) {
                                  return 'Correo inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              enabled: !isLoading,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return 'Ingresa tu contraseña';
                                }
                                if (text.length < 6) {
                                  return 'Mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.errorBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 1),
                                      child: Icon(
                                        Icons.error_outline,
                                        size: 18,
                                        color: AppColors.errorText,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: AppColors.errorText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: isLoading ? null : _submit,
                              icon: Icon(
                                isLoading ? Icons.hourglass_top : Icons.login,
                              ),
                              label: Text(isLoading ? 'Entrando...' : 'Entrar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Usa tus credenciales del sistema web.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

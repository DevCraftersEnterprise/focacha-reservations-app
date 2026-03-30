import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Overlay de loading personalizado que muestra una imagen/GIF animado
///
/// Diseñado para mostrar un loading atractivo durante operaciones asíncronas
/// como el inicio de sesión.
class CustomLoadingOverlay extends StatelessWidget {
  const CustomLoadingOverlay({
    super.key,
    this.message = 'Cargando...',
    this.assetPath = 'assets/images/loading.gif',
    this.backgroundColor,
    this.imageSize = 200.0,
  });

  /// Mensaje que se muestra debajo del loader
  final String message;

  /// Ruta del asset (imagen o GIF) a mostrar
  final String assetPath;

  /// Color de fondo del overlay (por defecto semi-transparente)
  final Color? backgroundColor;

  /// Tamaño de la imagen/GIF
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              AppColors.primary.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen/GIF del loader con diseño mejorado
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Pulse(
                  duration: const Duration(milliseconds: 1500),
                  infinite: true,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            assetPath,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            frameBuilder:
                                (
                                  context,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  if (wasSynchronouslyLoaded) {
                                    return child;
                                  }

                                  if (frame == null) {
                                    // Loader temporal mejorado
                                    return Container(
                                      width: imageSize,
                                      height: imageSize,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            AppColors.primary.withValues(
                                              alpha: 0.05,
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: SpinPerfect(
                                          infinite: true,
                                          duration: const Duration(seconds: 2),
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.primary.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.restaurant_menu,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return child;
                                },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: imageSize,
                                height: imageSize,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.shade50,
                                      Colors.red.shade100,
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 56,
                                        color: Colors.red,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Error cargando',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Mensaje de carga mejorado
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.grey.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flash(
                        infinite: true,
                        duration: const Duration(seconds: 2),
                        child: Icon(
                          Icons.hourglass_bottom,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Indicador de progreso adicional
              FadeIn(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: Pulse(
                  infinite: true,
                  duration: const Duration(milliseconds: 1500),
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra el overlay de loading
  ///
  /// Retorna un [OverlayEntry] que puede ser removido llamando a `.remove()`
  static OverlayEntry show(
    BuildContext context, {
    String message = 'Cargando...',
    String assetPath = 'assets/images/loading.gif',
    double imageSize = 200.0,
  }) {
    final overlay = OverlayEntry(
      builder: (context) => CustomLoadingOverlay(
        message: message,
        assetPath: assetPath,
        imageSize: imageSize,
      ),
    );

    Overlay.of(context).insert(overlay);
    return overlay;
  }
}

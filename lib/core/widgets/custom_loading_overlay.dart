import 'package:flutter/material.dart';

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
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.9),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen/GIF del loader con fondo blanco
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    assetPath,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          }

                          if (frame == null) {
                            // Mientras está cargando, mostrar un loader visible
                            return Container(
                              width: imageSize,
                              height: imageSize,
                              color: Colors.orange.shade50,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 6,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Cargando...',
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
                        color: Colors.red.shade100,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error, size: 48, color: Colors.red),
                              SizedBox(height: 8),
                              Text('Error cargando GIF'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Mensaje de carga
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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

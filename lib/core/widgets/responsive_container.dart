import 'package:flutter/material.dart';

/// Widget reutilizable para contenedores responsive con ancho máximo
/// Aplica DRY: evita repetir el patrón Align + ConstrainedBox
/// Aplica SRP: solo se encarga de centrar y limitar el ancho
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1024,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

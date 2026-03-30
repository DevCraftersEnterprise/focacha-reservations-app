import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Widget reutilizable para badges de estado (activo/cancelado)
/// Aplica DRY: centraliza la lógica de renderizado de badges de estado
/// Aplica OCP: extensible mediante configuración de colores
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.activeLabel = 'Activa',
    this.cancelledLabel = 'Cancelada',
  });

  final String status;
  final String activeLabel;
  final String cancelledLabel;

  bool get _isActive => status == 'ACTIVE';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _isActive ? AppColors.successBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _isActive ? activeLabel : cancelledLabel,
        style: TextStyle(
          color: _isActive ? AppColors.successText : AppColors.errorText,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Widget reutilizable para badges genéricos con icono
/// Aplica SRP: responsabilidad única de renderizar un badge
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.label,
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.border,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

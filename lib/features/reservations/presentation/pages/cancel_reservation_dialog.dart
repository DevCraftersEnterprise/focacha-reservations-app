import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extract_error_message_util.dart';
import '../../data/models/reservation_model.dart';
import '../providers/reservations_provider.dart';

class CancelReservationDialog extends ConsumerStatefulWidget {
  const CancelReservationDialog({super.key, required this.reservation});

  final ReservationModel reservation;

  @override
  ConsumerState<CancelReservationDialog> createState() =>
      _CancelReservationDialogState();
}

class _CancelReservationDialogState
    extends ConsumerState<CancelReservationDialog> {
  final _reasonController = TextEditingController();

  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final notifier = ref.read(reservationsProvider.notifier);

    try {
      await notifier.cancelReservation(
        id: widget.reservation.id,
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      setState(() {
        _errorMessage = extractErrorMessage(
          error,
          fallback: 'No se pudo cancelar la reservación',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservation = widget.reservation;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.event_busy_outlined,
                      color: AppColors.errorText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancelar reservación',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Esta acción no elimina el registro, solo cambia su estatus.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.customerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DialogInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha',
                      value: reservation.reservationDate,
                    ),
                    const SizedBox(height: 8),
                    _DialogInfoRow(
                      icon: Icons.schedule_outlined,
                      label: 'Hora',
                      value: _formatTime(reservation.reservationTime),
                    ),
                    const SizedBox(height: 8),
                    _DialogInfoRow(
                      icon: Icons.place_outlined,
                      label: 'Zona',
                      value: reservation.zone?.name ?? reservation.zoneId,
                    ),
                    const SizedBox(height: 8),
                    _DialogInfoRow(
                      icon: Icons.groups_2_outlined,
                      label: 'Personas',
                      value: reservation.guestCount.toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _reasonController,
                minLines: 3,
                maxLines: 5,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Motivo (opcional)',
                  prefixIcon: Icon(Icons.edit_note_outlined),
                  alignLabelWithHint: true,
                ),
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
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.errorText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      icon: Icon(
                        _saving ? Icons.hourglass_top : Icons.cancel_outlined,
                      ),
                      label: Text(_saving ? 'Cancelando...' : 'Confirmar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(String value) {
    try {
      final normalized = value.length >= 5 ? value.substring(0, 5) : value;
      final parts = normalized.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2000, 1, 1, hour, minute);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final hour12 = dt.hour == 0
          ? 12
          : dt.hour > 12
          ? dt.hour - 12
          : dt.hour;

      return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return value;
    }
  }
}

class _DialogInfoRow extends StatelessWidget {
  const _DialogInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

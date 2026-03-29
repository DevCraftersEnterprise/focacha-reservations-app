import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return AlertDialog(
      title: const Text('Cancelar reservación'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.reservation.customerName),
          const SizedBox(height: 8),
          Text(
            '${widget.reservation.reservationDate} · ${widget.reservation.reservationTime.substring(0, 5)}',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Motivo (opcional)'),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Cancelando...' : 'Confirmar'),
        ),
      ],
    );
  }
}

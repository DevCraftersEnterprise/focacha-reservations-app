import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/reservation_model.dart';

class CancelReservationDialog extends ConsumerStatefulWidget {
  const CancelReservationDialog({super.key, required this.reservation});

  final ReservationModel reservation;

  @override
  ConsumerState<CancelReservationDialog> createState() =>
      _CancelReservationDialogState();
}

class _CancelReservationDialogState
    extends ConsumerState<CancelReservationDialog> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

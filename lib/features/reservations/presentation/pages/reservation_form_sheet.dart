import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/reservation_model.dart';

class ReservationFormSheet extends ConsumerStatefulWidget {
  const ReservationFormSheet({
    super.key,
    required this.branchId,
    this.reservation,
  });

  final String branchId;
  final ReservationModel? reservation;

  @override
  ConsumerState<ReservationFormSheet> createState() =>
      _ReservationFormSheetState();
}

class _ReservationFormSheetState extends ConsumerState<ReservationFormSheet> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

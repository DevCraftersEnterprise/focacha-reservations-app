import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/reservation_model.dart';
import '../../data/models/zone_model.dart';
import '../../data/service/reservations_service.dart';

final reservationsServiceProvider = Provider<ReservationsService>((ref) {
  final client = ref.read(dioClientProvider);
  return ReservationsService(client);
});

class ReservationFilters {
  final String? branchId;
  final String? reservationDate;
  final String? status;

  const ReservationFilters({this.branchId, this.reservationDate, this.status});
}

final reservationFiltersProvider = Provider<ReservationFilters>((ref) {
  final session = ref.watch(authProvider).value;
  final branchId = session?.isCashier == true ? session?.user.branchId : null;

  return ReservationFilters(branchId: branchId);
});

class ReservationsNotifier extends AsyncNotifier<List<ReservationModel>> {
  @override
  Future<List<ReservationModel>> build() async {
    return _load();
  }

  Future<List<ReservationModel>> _load() async {
    final filters = ref.read(reservationFiltersProvider);
    final service = ref.read(reservationsServiceProvider);

    return service.findAll(
      branchId: filters.branchId,
      reservationDate: filters.reservationDate,
      status: filters.status,
    );
  }

  Future<void> refreshData() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> create({
    required String reservationDate,
    required String reservationTime,
    required int guestCount,
    required String branchId,
    required String zoneId,
    required String eventType,
    required String customerName,
    required String phonePrimary,
    String? phoneSecondary,
    String? notes,
  }) async {
    final service = ref.read(reservationsServiceProvider);

    await service.create(
      reservationDate: reservationDate,
      reservationTime: reservationTime,
      guestCount: guestCount,
      branchId: branchId,
      zoneId: zoneId,
      eventType: eventType,
      customerName: customerName,
      phonePrimary: phonePrimary,
      phoneSecondary: phoneSecondary,
      notes: notes,
    );

    await refreshData();
  }

  Future<void> updateReservation({
    required String id,
    required String reservationDate,
    required String reservationTime,
    required int guestCount,
    required String branchId,
    required String zoneId,
    required String eventType,
    required String customerName,
    required String phonePrimary,
    String? phoneSecondary,
    String? notes,
  }) async {
    final service = ref.read(reservationsServiceProvider);

    await service.update(
      id: id,
      reservationDate: reservationDate,
      reservationTime: reservationTime,
      guestCount: guestCount,
      branchId: branchId,
      zoneId: zoneId,
      eventType: eventType,
      customerName: customerName,
      phonePrimary: phonePrimary,
      phoneSecondary: phoneSecondary,
      notes: notes,
    );

    await refreshData();
  }

  Future<void> cancelReservation({required String id, String? reason}) async {
    final service = ref.read(reservationsServiceProvider);

    await service.cancel(id: id, reason: reason);
    await refreshData();
  }
}

final reservationsProvider =
    AsyncNotifierProvider<ReservationsNotifier, List<ReservationModel>>(
      ReservationsNotifier.new,
    );

final branchZonesProvider = FutureProvider.family<List<ZoneModel>, String>((
  ref,
  branchId,
) async {
  final service = ref.read(reservationsServiceProvider);
  final zones = await service.getZonesByBranch(branchId);
  return zones.where((zone) => zone.isActive).toList();
});

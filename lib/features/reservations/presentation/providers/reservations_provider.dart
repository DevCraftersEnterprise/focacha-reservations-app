import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/reservation_model.dart';
import '../../data/models/zone_model.dart';
import '../../data/service/branches_service.dart';
import '../../data/service/reservations_service.dart';

part 'reservations_provider.g.dart';

@riverpod
ReservationsService reservationsService(ReservationsServiceRef ref) {
  final client = ref.read(dioClientProvider);
  return ReservationsService(client);
}

@riverpod
BranchesService branchesService(BranchesServiceRef ref) {
  final client = ref.read(dioClientProvider);
  return BranchesService(client);
}

@riverpod
Future<List<BranchModel>> branches(BranchesRef ref) async {
  final session = ref.read(authProvider).value;

  if (session?.isCashier == true) {
    final user = session!.user;
    final branchId = user.branchId;
    final branchName = user.branch?.name;

    if (branchId != null && branchName != null) {
      return [
        BranchModel(
          id: branchId,
          name: branchName,
          address: '',
          phone: null,
          isActive: true,
        ),
      ];
    }

    return [];
  }

  final service = ref.read(branchesServiceProvider);
  final branches = await service.findAll();

  return branches.where((branch) => branch.isActive).toList();
}

class ReservationFilters {
  final String? branchId;
  final String? reservationDate;
  final String? status;

  const ReservationFilters({this.branchId, this.reservationDate, this.status});
}

@riverpod
class ReservationFiltersNotifier extends _$ReservationFiltersNotifier {
  @override
  ReservationFilters build() {
    final session = ref.watch(authProvider).value;
    final branchId = session?.isCashier == true ? session?.user.branchId : null;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return ReservationFilters(branchId: branchId, reservationDate: today);
  }

  void updateFilters(ReservationFilters newFilters) {
    state = newFilters;
  }

  void reset() {
    final session = ref.read(authProvider).value;
    final branchId = session?.isCashier == true ? session?.user.branchId : null;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    state = ReservationFilters(branchId: branchId, reservationDate: today);
  }
}

@riverpod
class Reservations extends _$Reservations {
  @override
  Future<List<ReservationModel>> build() async {
    ref.watch(reservationFiltersNotifierProvider);
    return _load();
  }

  Future<List<ReservationModel>> _load() async {
    final filters = ref.read(reservationFiltersNotifierProvider);
    final service = ref.read(reservationsServiceProvider);

    final results = await service.findAll(
      branchId: filters.branchId,
      reservationDate: filters.reservationDate,
      status: filters.status,
    );

    return results;
  }

  Future<void> refreshData() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load());
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

@riverpod
Future<List<ZoneModel>> branchZones(BranchZonesRef ref, String branchId) async {
  final service = ref.read(reservationsServiceProvider);
  final zones = await service.getZonesByBranch(branchId);
  return zones.where((zone) => zone.isActive).toList();
}

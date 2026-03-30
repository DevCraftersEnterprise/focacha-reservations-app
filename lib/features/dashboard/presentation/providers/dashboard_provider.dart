import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reservations/data/models/branch_model.dart';
import '../../../reservations/data/service/branches_service.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final client = ref.read(dioClientProvider);
  return DashboardService(client);
});

final dashboardBranchesServiceProvider = Provider<BranchesService>((ref) {
  final client = ref.read(dioClientProvider);
  return BranchesService(client);
});

class DashboardSelectedDateNotifier extends Notifier<String> {
  @override
  String build() {
    return _todayAsString();
  }

  void updateDate(String newDate) {
    state = newDate;
  }

  void reset() {
    state = _todayAsString();
  }
}

final dashboardSelectedDateProvider =
    NotifierProvider<DashboardSelectedDateNotifier, String>(
      DashboardSelectedDateNotifier.new,
    );

class DashboardSelectedBranchIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final session = ref.read(authProvider).value;

    if (session?.isCashier == true) {
      return session?.user.branchId ?? session?.user.branch?.id;
    }

    return null;
  }

  void updateBranchId(String? branchId) {
    state = branchId;
  }

  void reset() {
    final session = ref.read(authProvider).value;

    if (session?.isCashier == true) {
      state = session?.user.branchId ?? session?.user.branch?.id;
    } else {
      state = null;
    }
  }
}

final dashboardSelectedBranchIdProvider =
    NotifierProvider<DashboardSelectedBranchIdNotifier, String?>(
      DashboardSelectedBranchIdNotifier.new,
    );

final dashboardBranchesProvider = FutureProvider<List<BranchModel>>((
  ref,
) async {
  final session = ref.watch(authProvider).value;

  if (session?.isCashier == true) {
    final branchId = session?.user.branchId ?? session?.user.branch?.id;
    final branchName = session?.user.branch?.name;

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

  final service = ref.read(dashboardBranchesServiceProvider);
  final branches = await service.findAll();
  final activeBranches = branches.where((branch) => branch.isActive).toList();

  final selectedBranchId = ref.read(dashboardSelectedBranchIdProvider);

  if (selectedBranchId == null && activeBranches.isNotEmpty) {
    Future.microtask(() {
      ref
          .read(dashboardSelectedBranchIdProvider.notifier)
          .updateBranchId(activeBranches.first.id);
    });
  }

  return activeBranches;
});

final dashboardSummaryProvider = FutureProvider<List<DashboardCalendarItem>>((
  ref,
) async {
  final selectedDate = ref.watch(dashboardSelectedDateProvider);
  final branchId = ref.watch(dashboardSelectedBranchIdProvider);

  if (branchId == null || branchId.isEmpty) {
    return [];
  }

  final parsed = DateTime.tryParse(selectedDate) ?? DateTime.now();
  final service = ref.read(dashboardServiceProvider);

  return service.getCalendarSummary(
    branchId: branchId,
    month: parsed.month,
    year: parsed.year,
  );
});

final dashboardDayDetailProvider = FutureProvider<DashboardDayDetail?>((
  ref,
) async {
  final selectedDate = ref.watch(dashboardSelectedDateProvider);
  final branchId = ref.watch(dashboardSelectedBranchIdProvider);

  if (branchId == null || branchId.isEmpty) {
    return null;
  }

  final service = ref.read(dashboardServiceProvider);

  return service.getDayDetail(branchId: branchId, date: selectedDate);
});

String _todayAsString() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

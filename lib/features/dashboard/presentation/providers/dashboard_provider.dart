import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final client = ref.read(dioClientProvider);
  return DashboardService(client);
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

final dashboardSummaryProvider = FutureProvider<List<DashboardCalendarItem>>((
  ref,
) async {
  final session = ref.watch(authProvider).value;
  final date = ref.watch(dashboardSelectedDateProvider);

  final branchId = session?.user.branchId ?? session?.user.branch?.id;

  if (branchId == null || branchId.isEmpty) {
    return [];
  }

  final parsed = DateTime.tryParse(date) ?? DateTime.now();

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
  final session = ref.watch(authProvider).value;
  final selectedDate = ref.watch(dashboardSelectedDateProvider);

  final branchId = session?.user.branchId ?? session?.user.branch?.id;

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

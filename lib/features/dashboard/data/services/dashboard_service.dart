import '../../../../core/network/dio_client.dart';
import '../models/dashboard_models.dart';

class DashboardService {
  DashboardService(this._client);

  final DioClient _client;

  Future<List<DashboardCalendarItem>> getCalendarSummary({
    required String branchId,
    required int month,
    required int year,
  }) async {
    final response = await _client.dio.get(
      '/reservations/calendar/summary',
      queryParameters: {'branchId': branchId, 'month': month, 'year': year},
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => DashboardCalendarItem.fromMap(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<DashboardDayDetail> getDayDetail({
    required String branchId,
    required String date,
  }) async {
    final response = await _client.dio.get(
      '/reservations/day-detail',
      queryParameters: {'branchId': branchId, 'date': date},
    );

    return DashboardDayDetail.fromMap(response.data as Map<String, dynamic>);
  }
}

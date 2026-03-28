import '../../../../core/network/dio_client.dart';
import '../models/reservation_model.dart';
import '../models/zone_model.dart';

class ReservationsService {
  ReservationsService(this._client);

  final DioClient _client;

  Future<List<ReservationModel>> findAll({
    String? branchId,
    String? reservationTime,
    String? status,
  }) async {
    final response = await _client.dio.get(
      '/reservations',
      queryParameters: {
        if (branchId != null && branchId.isNotEmpty) 'branchId': branchId,
        if (reservationTime != null && reservationTime.isNotEmpty)
          'reservationTime': reservationTime,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final data = response.data as List<dynamic>;
    return data
        .map((item) => ReservationModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<ReservationModel> create({
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
    final response = await _client.dio.post(
      '/reservations',
      data: {
        'reservationDate': reservationDate,
        'reservationTime': reservationTime,
        'guestCount': guestCount,
        'branchId': branchId,
        'zoneId': zoneId,
        'eventType': eventType,
        'customerName': customerName,
        'phonePrimary': phonePrimary,
        'phoneSecondary': phoneSecondary,
        'notes': notes,
      },
    );

    return ReservationModel.fromMap(response.data as Map<String, dynamic>);
  }

  Future<ReservationModel> update({
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
    final response = await _client.dio.patch(
      '/reservations/$id',
      data: {
        'reservationDate': reservationDate,
        'reservationTime': reservationTime,
        'guestCount': guestCount,
        'branchId': branchId,
        'zoneId': zoneId,
        'eventType': eventType,
        'customerName': customerName,
        'phonePrimary': phonePrimary,
        'phoneSecondary': phoneSecondary,
        'notes': notes,
      },
    );

    return ReservationModel.fromMap(response.data as Map<String, dynamic>);
  }

  Future<ReservationModel> cancel({required String id, String? reason}) async {
    final response = await _client.dio.patch(
      '/reservations/$id/cancel',
      data: {'reason': reason},
    );

    return ReservationModel.fromMap(response.data as Map<String, dynamic>);
  }

  Future<List<ZoneModel>> getZonesByBranch(String branchId) async {
    final response = await _client.dio.get('/zones/branch/$branchId');

    final data = response.data as List<dynamic>;

    return data
        .map((item) => ZoneModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}

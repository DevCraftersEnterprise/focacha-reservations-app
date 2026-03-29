import '../../../../core/network/dio_client.dart';
import '../models/branch_model.dart';

class BranchesService {
  BranchesService(this._client);

  final DioClient _client;

  Future<List<BranchModel>> findAll() async {
    final response = await _client.dio.get('/branches');
    final data = response.data as List<dynamic>;

    return data
        .map((item) => BranchModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}

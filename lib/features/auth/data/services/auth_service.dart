import '../../../../core/network/dio_client.dart';
import '../models/auth_user_model.dart';

class AuthService {
  AuthService(this._client);

  final DioClient _client;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      'auth/login',
      data: {'email': email, 'password': password},
    );

    return LoginResponseModel.fromMap(response.data as Map<String, dynamic>);
  }

  Future<AuthUserModel> me() async {
    final response = await _client.dio.get('/auth/me');
    return AuthUserModel.fromMap(response.data as Map<String, dynamic>);
  }
}

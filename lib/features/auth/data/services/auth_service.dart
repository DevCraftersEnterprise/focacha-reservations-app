import 'package:dio/dio.dart';

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

  String extractErrorMessage(
    Object error, {
    String fallback = 'Ocurrió un error',
  }) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'];

        if (message is String && message.trim().isNotEmpty) {
          return message;
        }

        if (message is List) {
          return message.join(', ');
        }
      }
    }

    return fallback;
  }
}

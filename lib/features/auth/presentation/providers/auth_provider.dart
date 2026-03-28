import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_env.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/services/auth_service.dart';
import '../../domain/auth_session.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.read(secureStorageProvider);

  return DioClient(baseUrl: AppEnv.apiBaseUrl, storage: storage);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.read(dioClientProvider);
  return AuthService(client);
});

class AuthNotifier extends AsyncNotifier<AuthSession?> {
  @override
  FutureOr<AuthSession?> build() {
    return _restoreSession();
  }

  Future<AuthSession?> _restoreSession() async {
    final storage = ref.read(secureStorageProvider);
    final authService = ref.read(authServiceProvider);

    final token = await storage.getToken();
    final userJson = await storage.getUser();

    if (token == null || userJson == null) return null;

    try {
      final remoteUser = await authService.me();

      await storage.saveUser(remoteUser.toJson());

      return AuthSession(token: token, user: remoteUser);
    } catch (e) {
      await storage.clearSession();
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();

    final storage = ref.read(secureStorageProvider);
    final authService = ref.read(authServiceProvider);

    try {
      final response = await authService.login(
        email: email,
        password: password,
      );

      await storage.saveToken(response.accessToken);
      await storage.saveUser(response.user.toJson());

      final session = AuthSession(
        token: response.accessToken,
        user: response.user,
      );

      state = AsyncData(session);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearSession();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthSession?>(
  AuthNotifier.new,
);

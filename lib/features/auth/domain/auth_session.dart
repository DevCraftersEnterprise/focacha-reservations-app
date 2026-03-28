import '../data/models/auth_user_model.dart';

class AuthSession {
  final String token;
  final AuthUserModel user;

  const AuthSession({required this.token, required this.user});

  bool get isAdmin => user.role == 'ADMIN';
  bool get isCashier => user.role == 'CASHIER';
}

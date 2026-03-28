import 'dart:convert';

class AuthUserBranchModel {
  final String id;
  final String name;

  const AuthUserBranchModel({required this.id, required this.name});

  factory AuthUserBranchModel.fromMap(Map<String, dynamic> map) {
    return AuthUserBranchModel(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}

class AuthUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? branchId;
  final AuthUserBranchModel? branch;

  const AuthUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.branchId,
    required this.branch,
  });

  factory AuthUserModel.fromMap(Map<String, dynamic> map) {
    return AuthUserModel(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      branchId: map['branchId'] as String?,
      branch: map['branch'] != null
          ? AuthUserBranchModel.fromMap(map['branch'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'branchId': branchId,
      'branch': branch?.toMap(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory AuthUserModel.fromJson(String source) =>
      AuthUserModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class LoginResponseModel {
  final String accessToken;
  final AuthUserModel user;

  const LoginResponseModel({required this.accessToken, required this.user});

  factory LoginResponseModel.fromMap(Map<String, dynamic> map) {
    return LoginResponseModel(
      accessToken: map['accessToken'] as String,
      user: AuthUserModel.fromMap(map['user'] as Map<String, dynamic>),
    );
  }
}

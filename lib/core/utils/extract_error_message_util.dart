import 'package:dio/dio.dart';

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

import 'package:intl/intl.dart';

/// Utilidad para formatear fechas y horas de manera consistente
/// Aplica DRY: centraliza todo el formateo de fechas en un solo lugar
class DateFormatter {
  DateFormatter._();

  /// Formatea una fecha en formato ISO (yyyy-MM-dd) a dd/MM/yyyy
  static String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  /// Formatea una hora en formato HH:mm:ss o HH:mm a formato legible
  static String formatTime(String time) {
    try {
      final normalized = time.length >= 5 ? time.substring(0, 5) : time;
      final parts = normalized.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time;
    }
  }

  /// Convierte DateTime a formato ISO (yyyy-MM-dd)
  static String toIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Obtiene la fecha actual en formato ISO
  static String todayIsoDate() {
    return toIsoDate(DateTime.now());
  }
}

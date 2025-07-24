import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppDate {
  AppDate._();

  static late DateFormat _dateFormatter;
  static late DateFormat _dayDateFormatter;
  static bool _initialized = false;

  // Initialize Indonesian locale
  static Future<void> initialize() async {
    await initializeDateFormatting('id_ID', null);
    _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');
    _dayDateFormatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    _initialized = true;
  }

  // Format tanggal sederhana (e.g., "25 Juni 2026")
  static String format(dynamic date) {
    if (!_initialized) {
      print('AppDate not initialized. Call AppDate.initialize() first.');
      return '-';
    }
    
    DateTime? dateTime = _parseDate(date);
    if (dateTime == null) return '-';
    
    return _dateFormatter.format(dateTime);
  }

  // Format dengan hari (e.g., "Rabu, 25 Juni 2026")
  static String formatWithDay(dynamic date) {
    if (!_initialized) {
      print('AppDate not initialized. Call AppDate.initialize() first.');
      return '-';
    }
    
    DateTime? dateTime = _parseDate(date);
    if (dateTime == null) return '-';
    
    return _dayDateFormatter.format(dateTime);
  }

  // Helper method untuk parsing date
  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    
    if (date is DateTime) {
      return date;
    } else if (date is String) {
      if (date.isEmpty || date == '-') return null;
      
      try {
        return DateTime.parse(date);
      } catch (e) {
        print('Error parsing date: $date');
        return null;
      }
    }
    
    return null;
  }
}
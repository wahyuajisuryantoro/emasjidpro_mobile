import 'package:intl/intl.dart';

class AppCurrency {
  AppCurrency._();

  // Format dengan simbol Rp (e.g., "Rp 10.000.000")
  static String format(dynamic value) {
    if (value == null) return 'Rp 0';
    
    double amount = 0.0;
    
    if (value is double) {
      amount = value;
    } else if (value is int) {
      amount = value.toDouble();
    } else if (value is String) {
      String cleanValue = value
          .replaceAll('Rp', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      amount = double.tryParse(cleanValue) ?? 0.0;
    }
    
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    return formatter.format(amount);
  }

  // Format tanpa simbol (e.g., "10.000.000")
  static String formatNumber(dynamic value) {
    if (value == null) return '0';
    
    double amount = 0.0;
    
    if (value is double) {
      amount = value;
    } else if (value is int) {
      amount = value.toDouble();
    } else if (value is String) {
      String cleanValue = value
          .replaceAll('Rp', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      amount = double.tryParse(cleanValue) ?? 0.0;
    }
    
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(amount);
  }
}
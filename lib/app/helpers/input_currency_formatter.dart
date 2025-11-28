import 'package:flutter/services.dart';

class CurrencyFormatter {
  /// 1000000 -> "1.000.000"
  static String formatToIndonesia(String input) {
    String digitsOnly = input.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) return '';
    String reversed = digitsOnly.split('').reversed.join('');
    String formatted = '';
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }
    return formatted.split('').reversed.join('');
  }
}
class IndonesiaCurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String formattedText = CurrencyFormatter.formatToIndonesia(newValue.text);
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
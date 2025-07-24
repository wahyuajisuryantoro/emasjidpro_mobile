import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String onlyDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    int value = int.parse(onlyDigits);
    
    final formatter = NumberFormat('#,###', 'id');
    String formattedValue = formatter.format(value);
    
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
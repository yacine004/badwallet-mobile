import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.decimalPattern('fr_FR');

  /// Formate un montant en XOF, ex: 224438.0 -> "224 438 XOF"
  static String currency(double amount) {
    return '${_currencyFormat.format(amount.round())} XOF';
  }

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy à HH:mm', 'fr_FR');

  static String date(DateTime date) => _dateFormat.format(date);
  static String dateTime(DateTime date) => _dateTimeFormat.format(date);
}
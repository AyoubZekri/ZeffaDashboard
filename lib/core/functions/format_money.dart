import 'package:intl/intl.dart';

/// Amounts shown in the app and on printouts: 200,000.00
/// (comma between thousands, dot before the decimals).
final NumberFormat _moneyFormat = NumberFormat('#,##0.00', 'en_US');

String formatMoney(num? value) => _moneyFormat.format(value ?? 0);

/// Same, for values that may come as text (e.g. from the database).
String formatMoneyAny(dynamic value) =>
    formatMoney(value is num ? value : num.tryParse('${value ?? ''}'));

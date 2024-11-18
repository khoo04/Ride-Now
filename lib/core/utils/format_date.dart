import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) {
  final DateFormat formatter =
      DateFormat('dd/MM/yyyy'); // Format as "day/month/year"
  return formatter.format(dateTime);
}

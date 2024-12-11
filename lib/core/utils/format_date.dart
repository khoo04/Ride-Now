import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) {
  final DateFormat formatter =
      DateFormat('dd/MM/yyyy'); // Format as "day/month/year"
  return formatter.format(dateTime);
}

String formatDateWithWeekDay(DateTime dateTime) {
  final DateFormat formatter =
      DateFormat('EEEE, dd/MM/yyyy'); // Format as "Weekday, day/month/year"
  return formatter.format(dateTime);
}

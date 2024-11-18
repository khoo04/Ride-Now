import 'package:intl/intl.dart';

String formatTime(DateTime dateTime) {
  final DateFormat formatter =
      DateFormat.jm(); // jm() gives the format "h:mm a"
  return formatter.format(dateTime);
}

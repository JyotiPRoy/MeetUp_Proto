class UIUtils{
  static String formatTime({required DateTime dateTime}) {
    var difference = dateTime.difference(DateTime.now());
    if ((difference.inDays.toInt()) >= 365) {
      return (difference.inDays / 365).round().toString() + ' Years, ';
    } else if (difference.inDays.toInt() >= 30) {
      return (difference.inDays / 30).round().toString() + ' Months, ';
    } else if (difference.inDays.toInt() >= 1) {
      return difference.inDays.round().toString() + ' days';
    } else if (difference.inHours.toInt() >= 1) {
      return difference.inHours.round().toString() + ' hours';
    } else if (difference.inMinutes.toInt() >= 1) {
      return difference.inMinutes.round().toString() + ' minutes';
    } else
      return difference.inSeconds.round().toString() + ' seconds';
  }
}
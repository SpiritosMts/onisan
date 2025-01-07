
import 'package:intl/intl.dart';
import 'package:get/get.dart';

DateFormat dateFormatHM = DateFormat('dd-MM-yyyy HH:mm');
DateFormat dateFormatHMS = DateFormat('dd-MM-yyyy HH:mm:ss');

//date-time
String extractDate(String dateTimeString) {
  List<String> parts = dateTimeString.split(' '); // Split the string by space
  String datePart = parts[0]; // Get the first part, which is the date
  return datePart;
}
bool isDateToday(String dateString) {
  // Create a DateFormat instance to parse the date string

  // Parse the date string to a DateTime object
  DateTime date = dateFormatHM.parse(dateString);

  // Get the current date
  DateTime currentDate = DateTime.now();

  // Compare the day of the parsed date with the day of the current date
  return date.day == currentDate.day && date.month == currentDate.month && date.year == currentDate.year;
}
String getMonthName(int monthNumber) {
  switch (monthNumber) {
    case 1:
      return "January".tr;
    case 2:
      return "February".tr;
    case 3:
      return "March".tr;
    case 4:
      return "April".tr;
    case 5:
      return "May".tr;
    case 6:
      return "June".tr;
    case 7:
      return "July".tr;
    case 8:
      return "August".tr;
    case 9:
      return "September".tr;
    case 10:
      return "October".tr;
    case 11:
      return "November".tr;
    case 12:
      return "December".tr;
    default:
      return "Unknown".tr;
  }
}
String getWeekdayName(int weekdayIndex) {
  switch (weekdayIndex) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return '';
  }
}
String dateToString(DateTime date,{bool showDay = false, bool showHoursNminutes = false, bool showSeconds = true}) {
  //final formattedStr = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy, ' ', HH, ':' nn]);
  //DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat dateFormat = DateFormat("dd-MM-yyyy");

  if (showDay) {
    dateFormat = DateFormat("dd-MM-yyyy");
  }
  if (showHoursNminutes) {
    dateFormat = DateFormat("dd-MM-yyyy HH:mm");
  }
  if (showSeconds) {
    dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");
  }
  return dateFormat.format(date);
}
String nowToUtc(){
  return DateTime.now().toUtc().toIso8601String();//stored in db

}

String fromUtc(String utcDate, {bool showDay = false, bool showHoursNminutes = true, bool showSeconds = false}) {
  if(utcDate.isEmpty) return "";

  DateTime _fromUtc = DateTime.parse(utcDate).toLocal();
  DateFormat dateFormat;

  if (showDay && showHoursNminutes && showSeconds) {
    dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");
  } else if (showDay && showHoursNminutes) {
    dateFormat = DateFormat("dd-MM-yyyy HH:mm");
  } else if (showDay) {
    dateFormat = DateFormat("dd-MM-yyyy");
  } else if (showHoursNminutes && showSeconds) {
    dateFormat = DateFormat("HH:mm:ss");
  } else if (showHoursNminutes) {
    dateFormat = DateFormat("HH:mm");
  } else if (showSeconds) {
    dateFormat = DateFormat("ss");
  } else {
    dateFormat = DateFormat("yyyy-MM-dd");
  }

  return dateFormat.format(_fromUtc);
}
String fromUtcToLocal(String utcString) {
  // Parse the UTC string to a DateTime object
  DateTime utcDate = DateTime.parse(utcString);

  // Convert the UTC DateTime to local time
  DateTime localDate = utcDate.toLocal();

  // Return the local date and time as a string
  return localDate.toString();
}

String durationSince(String creationTime) {
  DateTime creationDate = DateTime.parse(creationTime).toLocal();
  Duration difference = DateTime.now().difference(creationDate);

  if (difference.inSeconds < 60) {
    return 'now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d';
  } else {
    final weeks = (difference.inDays / 7).floor();
    return '${weeks}w';
  }
}
String durationSince2(String creationTime) {
  DateTime creationDate = DateTime.parse(creationTime).toLocal();
  Duration difference = DateTime.now().difference(creationDate);

  if (difference.inSeconds < 60) {
    return 'now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"} ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} ${difference.inHours == 1 ? "hour" : "hours"} ago';
  } else if (difference.inDays < 30) {
    return '${difference.inDays} ${difference.inDays == 1 ? "day" : "days"} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '${months} ${months == 1 ? "month" : "months"} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '${years} ${years == 1 ? "year" : "years"} ago';
  }
}
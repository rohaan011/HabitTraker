// Return today's date formatted as yyyymmdd
String todaysDateFormatted() {
  // Get today's date and format as yyyymmdd
  return DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
}

// Convert string yyyymmdd to DateTime object
DateTime createDateTimeObject(String yyyymmdd) {
  int yyyy = int.parse(yyyymmdd.substring(0, 4));
  int mm = int.parse(yyyymmdd.substring(4, 6));
  int dd = int.parse(yyyymmdd.substring(6, 8));

  return DateTime(yyyy, mm, dd);
}

// Convert DateTime object to string yyyymmdd
String convertDateTimeToString(DateTime dateTime) {
  // Format year, month, and day with two-digit month and day
  String formattedDate = dateTime.toIso8601String().split('T')[0];
  return formattedDate.replaceAll('-', '');
}

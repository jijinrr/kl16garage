import 'package:intl/intl.dart';

/// Date & time formatting helpers used across the app.
class DateHelpers {
  DateHelpers._();

  static final _dayMonthYear = DateFormat('dd MMM yyyy');
  static final _dayMonthYearTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _time = DateFormat('hh:mm a');
  static final _monthYear = DateFormat('MMM yyyy');
  static final _dayShort = DateFormat('EEE');
  static final _dayNum = DateFormat('d');
  static final _firestoreDate = DateFormat('yyyy-MM-dd');

  /// e.g. "13 May 2026"
  static String formatDate(DateTime date) => _dayMonthYear.format(date);

  /// e.g. "13 May 2026, 09:30 AM"
  static String formatDateTime(DateTime date) =>
      _dayMonthYearTime.format(date);

  /// e.g. "09:30 AM"
  static String formatTime(DateTime date) => _time.format(date);

  /// e.g. "May 2026"
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  /// e.g. "Mon"
  static String formatDayShort(DateTime date) => _dayShort.format(date);

  /// e.g. "13" (day number)
  static String formatDayNum(DateTime date) => _dayNum.format(date);

  /// Firestore key format: "2026-05-13"
  static String toFirestoreKey(DateTime date) => _firestoreDate.format(date);

  /// Returns true if two DateTimes fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns true if [date] is today.
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Returns the start of a day (midnight).
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Returns the end of a day (23:59:59).
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  /// Returns a list of dates for the current week (Mon–Sun).
  static List<DateTime> currentWeekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Relative label: "Today", "Yesterday", or formatted date.
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return 'Today';
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return formatDate(date);
  }

  /// Live clock string updated via Timer.periodic in widgets.
  static String liveClockString() => DateFormat('hh:mm:ss a').format(DateTime.now());

  /// Greeting based on time of day.
  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

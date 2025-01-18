import 'package:habittracker/dateandtime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';

// reference our box
final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  List todaysHabitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  // create initial default data
  void createDefaultData() {
    todaysHabitList = [
      ["Run", false, false], // [habitName, completed, notDone]
      ["Read", false, false],
    ];

    _myBox.put("START_DATE", todaysDateFormatted());
  }

  // load data if it already exists
  void loadData() {
    // if it's a new day, get habit list from the database
    if (_myBox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _myBox.get("CURRENT_HABIT_LIST");
      // reset completed and notDone to false for a new day
      for (int i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false; // completed
        todaysHabitList[i][2] = false; // notDone
      }
    }
    // if it's not a new day, load today's list
    else {
      todaysHabitList = _myBox.get(todaysDateFormatted());
    }
  }

  // update database
  void updateDatabase() {
    // update today's entry in the database
    _myBox.put(todaysDateFormatted(), todaysHabitList);

    // update the universal habit list in case it changed (new habit, edit habit, delete habit)
    _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);

    // calculate habit completion percentages for each day
    calculateHabitPercentages();

    // load heat map
    loadHeatMap();
  }

  void calculateHabitPercentages() {
    int countCompleted = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        countCompleted++;
      }
    }

    String percent = todaysHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todaysHabitList.length).toStringAsFixed(1);

    // key: "PERCENTAGE_SUMMARY_yyyymmdd"
    // value: string of 1dp number between 0.0-1.0 inclusive
    _myBox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(_myBox.get("START_DATE"));
    DateTime currentDate = DateTime.now();

    // Ensure startDate is not after currentDate
    if (startDate.isAfter(currentDate)) {
      print("Error: Start date is after current date.");
      return;
    }

    // Calculate the days in between
    int daysInBetween = currentDate.difference(startDate).inDays;

    for (int i = 0; i <= daysInBetween; i++) {
      DateTime targetDate = startDate.add(Duration(days: i));
      String yyyymmdd = convertDateTimeToString(targetDate);

      // Check if percentage data is available; if not, default to 0.0
      double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      int colorStrength = (10 * strengthAsPercent).toInt();
      // Add only if targetDate is valid and within range
      heatMapDataSet[targetDate] = colorStrength;
    }
  }
}

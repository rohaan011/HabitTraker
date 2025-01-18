import 'package:flutter/material.dart';
import 'package:habittracker/components/habit_tile.dart';
import 'package:habittracker/components/monthly_summary.dart';
import 'package:habittracker/components/my_fab.dart';
import 'package:habittracker/components/my_alert_box.dart';
import 'package:habittracker/data/habit_database.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");

  @override
  void initState() {
    // Check if there's no habit data, then initialize with default data
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    } else {
      db.loadData();
    }

    // Update the database with the loaded data
    db.updateDatabase();
    super.initState();
  }

  // When a checkbox is tapped, update the state accordingly
  void checkBoxTapped(bool? completed, bool? notDone, int index) {
    setState(() {
      if (completed == true) {
        db.todaysHabitList[index][1] = true; // Mark as completed
        db.todaysHabitList[index][2] = false; // Not done becomes false
      } else if (notDone == true) {
        db.todaysHabitList[index][1] = false; // Completed becomes false
        db.todaysHabitList[index][2] = true; // Mark as not done
      }
    });
    db.updateDatabase();
  }

  // Controller for entering new habit names
  final _newHabitNameController = TextEditingController();

  // Function to create a new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          hintText: 'Enter habit name..',
          onSave: saveNewHabit,
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  // Save a new habit to today's habit list
  void saveNewHabit() {
    setState(() {
      db.todaysHabitList.add([
        _newHabitNameController.text,
        false,
        false
      ]); // Both checkboxes unchecked initially
    });

    _newHabitNameController.clear();
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  // Cancel the habit creation dialog
  void cancelDialogBox() {
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  // Open the settings to edit an existing habit
  void openHabitSettings(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          hintText: db.todaysHabitList[index][0],
          onSave: () => saveExistingHabit(index),
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  // Save changes to an existing habit
  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    Navigator.pop(context);
    db.updateDatabase();
  }

  // Delete a habit from the list
  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: MyFloatingActionButton(onPressed: createNewHabit),
      body: ListView(
        children: [
          // Monthly summary section
          MonthlySummary(
            datasets: db.heatMapDataSet,
            startDate: _myBox.get("START_DATE") ?? DateTime.now().toString(),
          ),

          // List of habits with dual checkbox setup
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: db.todaysHabitList.length,
            itemBuilder: (context, index) {
              return HabitTile(
                habitName: db.todaysHabitList[index][0],
                habitCompleted: db.todaysHabitList[index][1],
                habitNotDone: db.todaysHabitList[index][2],
                onCompletedChanged: (value) =>
                    checkBoxTapped(value, false, index),
                onNotDoneChanged: (value) =>
                    checkBoxTapped(false, value, index),
                settingsTapped: (context) => openHabitSettings(index),
                deleteTapped: (context) => deleteHabit(index),
              );
            },
          )
        ],
      ),
    );
  }
}

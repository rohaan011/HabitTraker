import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitCompleted;
  final bool habitNotDone;
  final Function(bool?)? onCompletedChanged;
  final Function(bool?)? onNotDoneChanged;
  final Function(BuildContext)? settingsTapped;
  final Function(BuildContext)? deleteTapped;

  const HabitTile({
    super.key,
    required this.habitName,
    required this.habitCompleted,
    required this.habitNotDone,
    required this.onCompletedChanged,
    required this.onNotDoneChanged,
    required this.settingsTapped,
    required this.deleteTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // Settings option
            SlidableAction(
              onPressed: settingsTapped,
              backgroundColor: Colors.grey.shade800,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(12),
            ),

            // Delete option
            SlidableAction(
              onPressed: deleteTapped,
              backgroundColor: Colors.red.shade400,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Completed checkbox
              Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: habitCompleted,
                        onChanged: (value) {
                          if (value == true) {
                            onCompletedChanged!(true);
                            onNotDoneChanged!(false);
                          }
                        },
                      ),
                      const Icon(Icons.check, color: Colors.green),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: habitNotDone,
                        onChanged: (value) {
                          if (value == true) {
                            onCompletedChanged!(false);
                            onNotDoneChanged!(true);
                          }
                        },
                      ),
                      const Icon(Icons.close, color: Colors.red),
                    ],
                  ),
                ],
              ),

              // Habit name
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(habitName, style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

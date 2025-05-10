

import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_title.dart';
import 'package:habit_tracker/components/month_summary.dart';
import 'package:habit_tracker/components/my_fab.dart';
import 'package:habit_tracker/components/my_alert_box.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:hive_flutter/adapters.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");

  @override
  void initState(){

    // if there's no current habit list
    if(_myBox.get("CURRENT_HABIT_LIST") == null){
      db.createDefaultData();
    } else{
      db.loadData();
    }

    // update the database
    db.updateDatabase();

    super.initState();
  }

  // bool to control habit completed
  bool habitCompleted = false;

  // checkbox was tapped
  void checkboxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value!;
    });
    db.updateDatabase();
  }

  // create a new habit
  final _newHabitNameController = TextEditingController();
  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            controller: _newHabitNameController,
            hintText: "Enter Habit Name...",
            onSave: saveNewHabit,
            onCancel: cancelDialogBox,
          );
        }
    );
  }

  // save new habit
  void saveNewHabit(){
    // add new habit to todays habit list
    setState(() {
      db.todaysHabitList.add([_newHabitNameController.text, false]);
    });

    // clear textfield
    _newHabitNameController.clear();
    // pop dialog box
    Navigator.of(context).pop();

    db.updateDatabase();
  }

  // cancel new habit
  void cancelDialogBox(){
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  // open habit settings to edit
  void openHabitSettings(int index){
    showDialog(context: context, builder: (context) {
      return MyAlertBox(
        controller: _newHabitNameController,
        hintText: db.todaysHabitList[index][0],
        onSave: () => saveExistinghabit(index),
        onCancel: cancelDialogBox,
      );
    });
  }
  
  // save existing habit with a new name
  void saveExistinghabit(int index){
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    Navigator.pop(context);

    db.updateDatabase();
  }

  void deleteHabit(int index){
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: MyFloatingActionButton(
        onPressed: createNewHabit,
      ),
      body: ListView(
        children: [
          // monthly summary
          MonthlySummary(
              datasets: db.heatMapDataSet,
              startDate: _myBox.get("START_DATE")
          ),

          // list of habits
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: db.todaysHabitList.length,
              itemBuilder: (context, index) {
                return HabitTitle(
                  habitName: db.todaysHabitList[index][0],
                  habitCompleted: db.todaysHabitList[index][1],
                  onChanged: (value) => checkboxTapped(value, index),
                  settingsTapped: (context) => openHabitSettings(index),
                  deleteTapped: (context) => deleteHabit(index),
                );
              })
        ],
      )
    );
  }
}
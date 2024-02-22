import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/Database/db_helper.dart';
import 'package:todo/Model/note.dart';
import 'package:todo/Service/notification.dart';

class AddTaskScreen extends StatefulWidget {
  final LocalNotify localNotify;
  AddTaskScreen({required this.localNotify});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? selectedDate = DateTime.now();
  TimeOfDay? selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ToDo'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Enter your title'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Enter your note'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a note';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(selectedDate == null
                    ? 'No date chosen'
                    : DateFormat.yMd().format(selectedDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: Text(selectedTime == null
                    ? 'No end time chosen'
                    : selectedTime!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
              ),
              ElevatedButton(
                child: Text('Create Task'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final note = Note(
                      title: titleController.text,
                      description: descriptionController.text,
                      date: DateFormat('dd-MM-yyyy').format(selectedDate!),
                      endTime:
                          '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                    );
                    widget.localNotify.scheduledNotification(note);
                    DBHelper.instance.insert(note);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:todo/Database/db_helper.dart';
import 'package:todo/Model/note.dart';
import 'package:todo/Service/notification.dart';
import 'package:todo/UI/add.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String dropdownValue = 'All';
  late Future<List<Note>> futureTasks;
  final searchController = TextEditingController();
  final localNotify = LocalNotify();

  @override
  void initState() {
    super.initState();
    refreshTaskList();
    localNotify.initializeNotification();
    localNotify.requestAndroidPermissions();
    localNotify.requestIOSPermissions();
  }

  refreshTaskList([String? query]) {
    setState(() {
      futureTasks = query == null || query.isEmpty
          ? DBHelper.instance.query()
          : DBHelper.instance.find(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
              onSubmitted: (value) {
                refreshTaskList(value);
              },
            ),
          ),
          DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  dropdownValue = newValue;
                  switch (newValue) {
                    case 'All':
                      refreshTaskList();
                      break;
                    case 'Today':
                      futureTasks = DBHelper.instance.queryToday();
                      break;
                    case 'Upcoming':
                      futureTasks = DBHelper.instance.queryUpcoming();
                      break;
                  }
                });
              }
            },
            items: <String>['All', 'Today', 'Upcoming']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          FutureBuilder<List<Note>>(
            future: futureTasks,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Note note = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Choose an option'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text('Complete'),
                                      onTap: () async {
                                        await DBHelper.instance
                                            .delete(note.id!);
                                        refreshTaskList();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: ListTile(
                          title: Text(note.title!),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(note.description!),
                              Text('Due Date: ${note.date}'),
                              Text('Due Time: ${note.endTime}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return CircularProgressIndicator();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddTaskScreen(localNotify: localNotify)),
          );

          setState(() {
            refreshTaskList();
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

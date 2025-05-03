import 'package:classfy/screens/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEventsFromDatabase();
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _loadEventsFromDatabase() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;

    if (!mounted) return; // Ensure the widget is still mounted before updating the state

    final List<Map<String, dynamic>> maps = await db.query('Task');
    final Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (var map in maps) {
      final date = DateTime.parse(map['date']);
      final cleanDate = DateTime(date.year, date.month, date.day);
      events.putIfAbsent(cleanDate, () => <Map<String, dynamic>>[]);
      events[cleanDate]!.add({
        'id': map['id'], // assuming you have an ID for each task
        'titre': map['titre'],
        'note': map['note'],
        'startTime': map['startTime'],
        'endTime': map['endTime'],
      });
    }

    if (!mounted) return; // Ensure widget is still mounted before calling setState
    setState(() {
      _events = events;
    });
  }

  Future<void> _navigateToAddTask() async {
    final newEventTitle = await Navigator.pushNamed(context, '/addTask');
    if (newEventTitle != null) {
      await _loadEventsFromDatabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay!);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5E6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Calendar",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(
              backgroundColor: Colors.brown,
              radius: 18,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                todayDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Événements du ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text("Aucun événement"))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(event['titre'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (event['note'] != null && event['note'].toString().isNotEmpty)
                                Text("Note: ${event['note']}"),
                              Text("De ${event['startTime']} à ${event['endTime']}"),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              // Add logic for "delete" or "edit"
                              if (value == 'delete') {
                                // Implement your delete functionality here
                                _deleteEvent(event['id']);
                              } else if (value == 'edit') {
                                // Implement your edit functionality here
                                _editEvent(event);
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Modify'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ];
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Implement the delete event function
  Future<void> _deleteEvent(int? eventId) async {
    if (eventId == null) return;
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteEvent(eventId); // Assuming a delete method in your DB helper
    await _loadEventsFromDatabase(); // Refresh the event list
  }

  // Implement the edit event function
  void _editEvent(Map<String, dynamic> event) {
    // Navigate to the edit screen with the event data
    Navigator.pushNamed(context, '/editTask', arguments: event);
  }
}

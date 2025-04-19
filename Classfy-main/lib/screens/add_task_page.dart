import 'package:classfy/screens/database_helper.dart';
import 'package:classfy/screens/task_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  final TaskModel? task; // Pour la modification

  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 10, minute: 0);
  String _remind = "5 minutes early";
  String _repeat = "None";
  int _selectedColor = 0;

  final List<String> remindList = [
    "5 minutes early",
    "10 minutes early",
    "15 minutes early",
    "30 minutes early",
  ];

  final List<String> repeatList = ["None", "Daily", "Weekly", "Monthly"];

  final List<Color> colorList = [Colors.blue, Colors.pink, Colors.orange];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.titre;
      _noteController.text = widget.task!.note;
      _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.task!.date);
      _startTime = _parseTimeOfDay(widget.task!.startTime);
      _endTime = _parseTimeOfDay(widget.task!.endTime);
      _remind = widget.task!.remind;
      _repeat = widget.task!.repeat;
      _selectedColor = widget.task!.color;
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final format = DateFormat.jm(); // Ex: 5:08 PM
    final dateTime = format.parse(time);
    return TimeOfDay.fromDateTime(dateTime);
  }

  Future<void> _getDateFromUser() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _getTimeFromUser(bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    final dbHelper = DatabaseHelper.instance;

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    final task = TaskModel(
      id: widget.task?.id, // null si ajout, valeur si modif
      titre: _titleController.text,
      note: _noteController.text,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      startTime: _startTime.format(context),
      endTime: _endTime.format(context),
      remind: _remind,
      repeat: _repeat,
      color: _selectedColor,
      utilisateurId: 1, // à adapter dynamiquement
    );

    if (widget.task == null) {
      await dbHelper.insertTask(task);
    }

    if (!mounted) return;
    Navigator.pop(context, task.titre);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Modifier la tâche" : "Ajouter une tâche"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInputField("Title", _titleController),
              _buildInputField("Note", _noteController),
              _buildDatePicker(),
              _buildTimePicker(),
              _buildDropdown("Remind", remindList, _remind, (value) {
                setState(() => _remind = value!);
              }),
              _buildDropdown("Repeat", repeatList, _repeat, (value) {
                setState(() => _repeat = value!);
              }),
              _buildColorPicker(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(isEditing ? "Update Task" : "Create Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      title: Text("Date"),
      subtitle: Text(DateFormat('MM/dd/yyyy').format(_selectedDate)),
      trailing: IconButton(
        icon: Icon(Icons.calendar_today),
        onPressed: _getDateFromUser,
      ),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text("Start Time"),
            subtitle: Text(_startTime.format(context)),
            trailing: IconButton(
              icon: Icon(Icons.access_time),
              onPressed: () => _getTimeFromUser(true),
            ),
          ),
        ),
        Expanded(
          child: ListTile(
            title: Text("End Time"),
            subtitle: Text(_endTime.format(context)),
            trailing: IconButton(
              icon: Icon(Icons.access_time),
              onPressed: () => _getTimeFromUser(false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String title,
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(),
        ),
        items:
            items.map((String e) {
              return DropdownMenuItem<String>(value: e, child: Text(e));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: List.generate(colorList.length, (index) {
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = index),
          child: Container(
            margin: EdgeInsets.only(right: 8),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorList[index],
              shape: BoxShape.circle,
              border:
                  _selectedColor == index
                      ? Border.all(width: 2, color: Colors.black)
                      : null,
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App with Description, Priority & Time',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoHome(),
    );
  }
}

class TodoHome extends StatefulWidget {
  const TodoHome({super.key});

  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class Task {
  String title;
  String description;
  String priority;
  DateTime time;

  Task({
    required this.title,
    required this.description,
    required this.priority,
    required this.time,
  });
}

class _TodoHomeState extends State<TodoHome> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  final List<Task> _tasks = [];
  String _selectedPriority = 'Easy';

  void _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: _selectedTime.hour, minute: _selectedTime.minute),
    );

    if (time == null) return;

    setState(() {
      _selectedTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _addTask() {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();
    if (title.isNotEmpty) {
      setState(() {
        _tasks.add(Task(
          title: title,
          description: description,
          priority: _selectedPriority,
          time: _selectedTime,
        ));
      });
      _clearInputs();
    }
  }

  void _editTask(int index) {
    _titleController.text = _tasks[index].title;
    _descriptionController.text = _tasks[index].description;
    _selectedPriority = _tasks[index].priority;
    _selectedTime = _tasks[index].time;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Enter task title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(hintText: 'Enter description'),
              ),
              const SizedBox(height: 10),
              _buildPriorityDropdown(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Scheduled: ${_formatDateTime(_selectedTime)}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDateTime,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearInputs();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String updatedTitle = _titleController.text.trim();
              String updatedDesc = _descriptionController.text.trim();
              if (updatedTitle.isNotEmpty) {
                setState(() {
                  _tasks[index] = Task(
                    title: updatedTitle,
                    description: updatedDesc,
                    priority: _selectedPriority,
                    time: _selectedTime,
                  );
                });
              }
              Navigator.pop(context);
              _clearInputs();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _clearInputs() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedPriority = 'Easy';
    _selectedTime = DateTime.now();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      items: ['Easy', 'Medium', 'Hard'].map((String priority) {
        return DropdownMenuItem<String>(
          value: priority,
          child: Text(
            priority,
            style: TextStyle(
              color: _getPriorityColor(priority),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPriority = value!;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Priority Level',
        border: OutlineInputBorder(),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App with Time'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Task Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                _buildPriorityDropdown(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Scheduled: ${_formatDateTime(_selectedTime)}',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDateTime,
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add Task'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks yet.'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(_tasks[index].title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_tasks[index].description),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text('Priority: '),
                                  Text(
                                    _tasks[index].priority,
                                    style: TextStyle(
                                      color: _getPriorityColor(
                                          _tasks[index].priority),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Scheduled at: ${_formatDateTime(_tasks[index].time)}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () => _editTask(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTask(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

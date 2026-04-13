import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class TaskInputScreen extends StatefulWidget {
  const TaskInputScreen({super.key});

  @override
  State<TaskInputScreen> createState() => _TaskInputScreenState();
}

class _TaskInputScreenState extends State<TaskInputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form State
  String _title = '';
  String _category = 'Class';
  final DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();

  // Safe initialization for end time (current time + 1 hour)
  TimeOfDay _endTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1)),
  );

  double _urgency = 3;
  double _importance = 3;
  double _effort = 1.0;
  String _energy = 'Medium';

  final List<String> _cats = ['Class', 'Org Work', 'Study', 'Rest', 'Other'];
  final List<String> _energies = ['Low', 'Medium', 'High'];

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() => isStart ? _startTime = picked : _endTime = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Provider.of<ScheduleProvider>(context, listen: false).addTask(
        title: _title,
        category: _category,
        date: _date,
        startTime: _startTime,
        endTime: _endTime,
        urgency: _urgency.toInt(),
        importance: _importance.toInt(),
        estimatedEffortHours: _effort,
        energyLevel: _energy,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Task Title
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),

              // Time Pickers
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(true),
                      icon: const Icon(Icons.access_time),
                      label: Text("Start: ${_startTime.format(context)}"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(false),
                      icon: const Icon(Icons.access_time_filled),
                      label: Text("End: ${_endTime.format(context)}"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Urgency Slider
              Text('Urgency: ${_urgency.round()}', style: Theme.of(context).textTheme.bodyLarge),
              Slider(
                value: _urgency,
                min: 1,
                max: 5,
                divisions: 4,
                label: _urgency.round().toString(),
                onChanged: (val) => setState(() => _urgency = val),
              ),

              // Importance Slider
              Text('Importance: ${_importance.round()}', style: Theme.of(context).textTheme.bodyLarge),
              Slider(
                value: _importance,
                min: 1,
                max: 5,
                divisions: 4,
                label: _importance.round().toString(),
                onChanged: (val) => setState(() => _importance = val),
              ),

              // Effort Slider (Hours)
              Text('Estimated Effort: ${_effort.toStringAsFixed(1)} hrs', style: Theme.of(context).textTheme.bodyLarge),
              Slider(
                value: _effort,
                min: 0.5,
                max: 8.0,
                divisions: 15,
                label: _effort.toString(),
                onChanged: (val) => setState(() => _effort = val),
              ),
              const SizedBox(height: 16),

              // Energy Level
              DropdownButtonFormField<String>(
                value: _energy,
                decoration: const InputDecoration(
                  labelText: 'Energy Level Required',
                  border: OutlineInputBorder(),
                ),
                items: _energies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _energy = val!),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Add Task to Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
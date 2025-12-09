import 'package:flutter/material.dart';
import 'database/task_repository.dart';
import 'database/task_model.dart';

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        primaryColor: Colors.blue,
        useMaterial3: true,
      ),
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<TaskModel> tasks = [];
  String selectedFilter = "All";
  final TaskRepository repo = TaskRepository();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    tasks = await repo.getAllTasks();
    setState(() {});
  }

  Future<void> _addTask(TaskModel task) async {
    final id = await repo.insertTask(task);
    task.id = id;
    tasks.add(task);
    setState(() {
    });

  }

  Future<void> _updateTask(TaskModel task) async {
    await repo.updateTask(task);
    final index = tasks.indexWhere((t) => t.id== task.id);
    tasks[index] = task;
    setState(() {
    });
  }

  Future<void> _deleteTask(int id) async {
    await repo.deleteTask(id);
    tasks.removeWhere((t) => t.id == id);
    setState(() {
    });
  }

  void _navigateToAddTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditTaskScreen()),
    );

    if (newTask != null) _addTask(newTask);
  }

  void _navigateToEditTask(TaskModel task) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditTaskScreen(task: task)),
    );

    if (updatedTask != null) _updateTask(updatedTask);
  }

  List<TaskModel> get filteredTasks {
    if (selectedFilter == "All") return tasks;
    return tasks.where((t) => t.priority == selectedFilter).toList();
  }

  void _confirmDelete(int id )async{
    final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Task'),
            content: Text('are you sure that you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('cancel'),
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('delete')
              ),
            ],
          );
        },
    );

    if(shouldDelete == true){
      _deleteTask(id);
    }
}

Widget _priorityTag(String priority) {
    Color bg;
    switch (priority) {
      case 'High':
        bg = Colors.red.shade100;
        break;
      case 'Medium':
        bg = Colors.amber.shade100;
        break;
      default:
        bg = Colors.green.shade100;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {

    return GestureDetector(
      onTap: () => _navigateToEditTask(task),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _priorityTag(task.priority),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
              SizedBox(height: 8),
              Text(
                task.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () => _confirmDelete(task.id!),
                  child: Text(
                    "Delete Task",
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade800 : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Tasks",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterButton("All"),
                  _filterButton("High"),
                  _filterButton("Medium"),
                  _filterButton("Low"),
                ],
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: tasks.isEmpty
                  ? Center(child: Text("No tasks found"))
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return _buildTaskCard(task);
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _navigateToAddTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.add),
                label: Text("Create New Task", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  AddEditTaskScreen({this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  String priority = 'High';

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task?.title ?? '');
    descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    priority = widget.task?.priority ?? 'High';
  }

  void _saveTask() {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty)
      return;

    final newTask = TaskModel(
      id: widget.task?.id,
      title: titleController.text,
      description: descriptionController.text,
      priority: priority,
    );

    Navigator.pop(context, newTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(
          widget.task == null ? "Create New Task" : "Edit Task",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Task Title",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "e.g., Design new dashboard",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Description",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Add more details about the task...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Priority Level",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            DropdownButtonFormField<String>(
              value: priority,
              onChanged: (value) => setState(() => priority = value!),
              items: ['High', 'Medium', 'Low']
                  .map(
                    (level) =>
                        DropdownMenuItem(value: level, child: Text(level)),
                  )
                  .toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text(
                  widget.task == null ? "Save Task" : "Update Task",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

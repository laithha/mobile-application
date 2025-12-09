import 'task_db.dart';
import 'task_model.dart';

class TaskRepository {
  Future<List<TaskModel>> getAllTasks() async {
    final db = await TaskDB.instance.database;
    final result = await db.query('tasks');
    return result.map((e) => TaskModel.fromMap(e)).toList();
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await TaskDB.instance.database;
    return db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await TaskDB.instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await TaskDB.instance.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}

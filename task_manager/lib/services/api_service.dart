import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String _baseUrl = 'https://your-api-url.com'; // Substitua pela sua URL

  Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse('$_baseUrl/tasks'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toMap()),
    );
    if (response.statusCode == 201) {
      return Task.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<Task> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/tasks/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toMap()),
    );
    if (response.statusCode == 200) {
      return Task.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/tasks/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }
}
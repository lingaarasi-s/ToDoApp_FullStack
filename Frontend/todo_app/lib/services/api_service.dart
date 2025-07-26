import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart'; // FIXED: Correct import path

class ApiService {
  // Change this IP to your computer's IP address if testing on physical device
  static const String baseUrl = 'http://192.168.1.64:8080/api/todos';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Get all todos
  Future<List<Todo>> getAllTodos() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Todo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create new todo
  Future<Todo> createTodo(Todo todo) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(todo.toJson()),
      );

      if (response.statusCode == 201) {
        return Todo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update todo
  Future<Todo> updateTodo(int id, Todo todo) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
        body: json.encode(todo.toJson()),
      );

      if (response.statusCode == 200) {
        return Todo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Toggle todo completion
  Future<Todo> toggleTodoCompletion(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id/toggle'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Todo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to toggle todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete todo
  Future<void> deleteTodo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get todos by status
  Future<List<Todo>> getTodosByStatus(bool completed) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status/$completed'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Todo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Search todos
  Future<List<Todo>> searchTodos(String title) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?title=$title'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Todo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search todos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get statistics
  Future<TodoStats> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return TodoStats.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

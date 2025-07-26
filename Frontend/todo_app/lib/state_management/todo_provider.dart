import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/task.dart'; // FIXED: Correct import path

enum TodoFilter { all, pending, completed }

class TodoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Todo> _todos = [];
  TodoFilter _currentFilter = TodoFilter.all;
  bool _isLoading = false;
  String _error = '';
  TodoStats? _stats;

  List<Todo> get todos {
    switch (_currentFilter) {
      case TodoFilter.pending:
        return _todos.where((todo) => !todo.completed).toList();
      case TodoFilter.completed:
        return _todos.where((todo) => todo.completed).toList();
      case TodoFilter.all:
      default:
        return _todos;
    }
  }

  TodoFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String get error => _error;
  TodoStats? get stats => _stats;

  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadTodos() async {
    _setLoading(true);
    _clearError();

    try {
      _todos = await _apiService.getAllTodos();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTodo(String title, String? description) async {
    _clearError();

    try {
      final newTodo = Todo(title: title, description: description);
      final createdTodo = await _apiService.createTodo(newTodo);
      _todos.insert(0, createdTodo);
      notifyListeners();
      await loadStats();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateTodo(int id, String title, String? description) async {
    _clearError();

    try {
      final todo = _todos.firstWhere((t) => t.id == id);
      final updatedTodo = todo.copyWith(title: title, description: description);
      final result = await _apiService.updateTodo(id, updatedTodo);

      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = result;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> toggleTodo(int id) async {
    _clearError();

    try {
      final updatedTodo = await _apiService.toggleTodoCompletion(id);
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
        await loadStats();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteTodo(int id) async {
    _clearError();

    try {
      await _apiService.deleteTodo(id);
      _todos.removeWhere((t) => t.id == id);
      notifyListeners();
      await loadStats();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> searchTodos(String query) async {
    _setLoading(true);
    _clearError();

    try {
      if (query.isEmpty) {
        await loadTodos();
      } else {
        _todos = await _apiService.searchTodos(query);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await _apiService.getStats();
      notifyListeners();
    } catch (e) {
      // Don't set error for stats loading failure
      print('Failed to load stats: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
  }

  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((t) => t.completed).length;
  int get pendingTodos => _todos.where((t) => !t.completed).length;
}

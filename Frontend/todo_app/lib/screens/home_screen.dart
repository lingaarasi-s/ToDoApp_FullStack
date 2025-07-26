import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state_management/todo_provider.dart'; // FIXED: Correct import path
import '../models/task.dart'; // FIXED: Correct import path
import 'add_edit_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
      context.read<TodoProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<TodoFilter>(
            onSelected: (filter) {
              context.read<TodoProvider>().setFilter(filter);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TodoFilter.all,
                child: Row(
                  children: [
                    Icon(Icons.list, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text('All'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TodoFilter.pending,
                child: Row(
                  children: [
                    Icon(Icons.radio_button_unchecked, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Pending'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TodoFilter.completed,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Completed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsSection(),
          _buildSearchBar(),
          _buildFilterTabs(),
          Expanded(child: _buildTodoList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTodo(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        if (stats == null) return SizedBox.shrink();

        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.blue[100]!],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', stats.total.toString(), Colors.blue),
              _buildStatItem(
                  'Pending', stats.pending.toString(), Colors.orange),
              _buildStatItem(
                  'Completed', stats.completed.toString(), Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search todos...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<TodoProvider>().loadTodos();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            context.read<TodoProvider>().loadTodos();
          }
        },
        onSubmitted: (value) {
          context.read<TodoProvider>().searchTodos(value);
        },
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('All', TodoFilter.all, provider.currentFilter),
              SizedBox(width: 8),
              _buildFilterChip(
                  'Pending', TodoFilter.pending, provider.currentFilter),
              SizedBox(width: 8),
              _buildFilterChip(
                  'Completed', TodoFilter.completed, provider.currentFilter),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
      String label, TodoFilter filter, TodoFilter currentFilter) {
    final isSelected = filter == currentFilter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => context.read<TodoProvider>().setFilter(filter),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildTodoList() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  style: TextStyle(color: Colors.red[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadTodos(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No todos yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add your first todo!',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadTodos,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: provider.todos.length,
            itemBuilder: (context, index) {
              final todo = provider.todos[index];
              return _buildTodoItem(todo);
            },
          ),
        );
      },
    );
  }

  Widget _buildTodoItem(Todo todo) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: todo.completed,
          onChanged: (_) => context.read<TodoProvider>().toggleTodo(todo.id!),
          activeColor: Colors.green,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            color: todo.completed ? Colors.grey : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description != null && todo.description!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  todo.description!,
                  style: TextStyle(
                    color: todo.completed ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            if (todo.createdAt != null)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Created: ${dateFormat.format(todo.createdAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.edit, size: 20),
                title: Text('Edit'),
                dense: true,
              ),
              onTap: () => _navigateToEditTodo(todo),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.delete, size: 20, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
              onTap: () => _deleteTodo(todo),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddTodo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTodoScreen(),
      ),
    );
  }

  void _navigateToEditTodo(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTodoScreen(todo: todo),
      ),
    );
  }

  void _deleteTodo(Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TodoProvider>().deleteTodo(todo.id!);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

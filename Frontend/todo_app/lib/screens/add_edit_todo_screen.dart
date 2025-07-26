import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state_management/todo_provider.dart'; // FIXED: Correct import path
import '../models/task.dart'; // FIXED: Correct import path

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo;

  const AddEditTodoScreen({Key? key, this.todo}) : super(key: key);

  @override
  _AddEditTodoScreenState createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Todo' : 'Add Todo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            Container(
              margin: EdgeInsets.all(16),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          else
            TextButton(
              onPressed: _saveTodo,
              child: Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          hintText: 'Enter todo title',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.trim().length > 100) {
                            return 'Title must not exceed 100 characters';
                          }
                          return null;
                        },
                        maxLength: 100,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter todo description (optional)',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().length > 500) {
                            return 'Description must not exceed 500 characters';
                          }
                          return null;
                        },
                        maxLines: 3,
                        maxLength: 500,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
              ),
              if (isEditing) ...[
                SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Todo Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          'Status',
                          widget.todo!.completed ? 'Completed' : 'Pending',
                          widget.todo!.completed ? Colors.green : Colors.orange,
                        ),
                        if (widget.todo!.createdAt != null)
                          _buildInfoRow(
                            'Created',
                            _formatDate(widget.todo!.createdAt!),
                            Colors.grey[600]!,
                          ),
                        if (widget.todo!.updatedAt != null)
                          _buildInfoRow(
                            'Last Updated',
                            _formatDate(widget.todo!.updatedAt!),
                            Colors.grey[600]!,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTodo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Saving...'),
                        ],
                      )
                    : Text(
                        isEditing ? 'UPDATE TODO' : 'ADD TODO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _saveTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      if (widget.todo != null) {
        // Update existing todo
        await context.read<TodoProvider>().updateTodo(
              widget.todo!.id!,
              title,
              description.isEmpty ? null : description,
            );
      } else {
        // Add new todo
        await context.read<TodoProvider>().addTodo(
              title,
              description.isEmpty ? null : description,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(widget.todo != null ? 'Todo updated!' : 'Todo added!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

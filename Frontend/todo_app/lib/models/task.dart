class Todo {
  final int? id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Todo({
    this.id,
    required this.title,
    this.description,
    this.completed = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : null,
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TodoStats {
  final int total;
  final int completed;
  final int pending;

  TodoStats({
    required this.total,
    required this.completed,
    required this.pending,
  });

  factory TodoStats.fromJson(Map<String, dynamic> json) {
    return TodoStats(
      total: json['total'],
      completed: json['completed'],
      pending: json['pending'],
    );
  }
}
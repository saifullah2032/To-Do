class Task {
  String id;
  String title;
  String description;
  DateTime dateTime;
  String imageUrl;
  bool isCompleted;
  bool isImportant = false; // NEW

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.imageUrl,
    this.isCompleted = false,
    this.isImportant = false, // NEW
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
      'isImportant': isImportant,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
      imageUrl: map['imageUrl'],
      isCompleted: map['isCompleted'],
      isImportant: map['isImportant'] ?? false, // NEW
    );
  }
}



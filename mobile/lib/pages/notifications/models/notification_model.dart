class AppNotification {
  final int id;
  final String title;
  final String description;
  final String type;
  bool isSeen;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isSeen,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: (j['id'] ?? 0) as int,
        title: (j['title'] ?? j['titre'] ?? '') as String,
        description: (j['description'] ?? j['message'] ?? j['body'] ?? '') as String,
        type: (j['type'] ?? '') as String,
        isSeen: (j['isSeen'] ?? j['seen'] ?? j['lu'] ?? false) as bool,
        createdAt: (j['createdAt'] ?? j['date'] ?? '') as String,
      );
}

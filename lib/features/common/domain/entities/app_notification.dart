enum NotificationCategory { alert, update, system }

enum NotificationSeverity { normal, warning, critical }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.category,
    required this.iconKey,
    this.type = 'SYSTEM',
    this.context = const {},
    this.createdAt,
    this.readAt,
    this.severity = NotificationSeverity.normal,
    this.read = false,
    this.dayLabelOverride,
  });

  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final NotificationCategory category;
  final NotificationSeverity severity;
  final String iconKey;
  final String type;
  final Map<String, Object?> context;
  final DateTime? createdAt;
  final DateTime? readAt;
  final bool read;
  final String? dayLabelOverride;

  String get dayLabel {
    if (dayLabelOverride != null) return dayLabelOverride!;
    final local = createdAt?.toLocal();
    if (local == null) return 'Unknown date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(local.year, local.month, local.day);
    final days = today.difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  AppNotification copyWith({bool? read}) {
    final nextRead = read ?? this.read;
    return AppNotification(
      id: id,
      title: title,
      message: message,
      timeLabel: timeLabel,
      category: category,
      severity: severity,
      iconKey: iconKey,
      type: type,
      context: context,
      createdAt: createdAt,
      readAt: nextRead ? (readAt ?? DateTime.now().toUtc()) : null,
      read: nextRead,
      dayLabelOverride: dayLabelOverride,
    );
  }
}

class HelpArticle {
  const HelpArticle({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.iconKey,
  });

  final String title;
  final String subtitle;
  final String category;
  final String iconKey;
}

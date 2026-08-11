import '../../../../core/network/api_support.dart';
import '../../domain/entities/app_notification.dart';

class NotificationDto {
  const NotificationDto(this.json);
  final Map<String, Object?> json;

  factory NotificationDto.fromJson(Map<String, Object?> json) =>
      NotificationDto(json);

  AppNotification toDomain() {
    final data = json['data'] is Map
        ? ApiData.map(json['data'])
        : const <String, Object?>{};
    final context = data['context'] is Map
        ? ApiData.map(data['context'])
        : const <String, Object?>{};
    final type = ApiData.string(data, 'type', 'SYSTEM').toUpperCase();
    final createdAt = _nullableDate(json, 'createdAt');
    final readAt = _nullableDate(json, 'readAt');
    return AppNotification(
      id: ApiData.string(json, 'id'),
      title: ApiData.string(data, 'title', 'FishTrace update'),
      message: ApiData.string(data, 'message'),
      timeLabel: _timeLabel(createdAt),
      category: _category(type),
      severity: _severity(type),
      iconKey: type.toLowerCase(),
      type: type,
      context: Map.unmodifiable(context),
      createdAt: createdAt,
      readAt: readAt,
      read: readAt != null,
    );
  }
}

const _alertTypes = {
  'HIGH_TEMPERATURE',
  'CRITICAL_TEMPERATURE',
  'DEVICE_OFFLINE',
  'LOW_BATTERY',
  'BATCH_REJECTED',
  'INSPECTION_FAILED',
  'RECALL',
  'HIGH_AI_RISK',
};

NotificationCategory _category(String type) {
  if (_alertTypes.contains(type)) return NotificationCategory.alert;
  if (type.contains('FAILURE') || type.startsWith('REPORT_EXPORT_')) {
    return NotificationCategory.system;
  }
  return NotificationCategory.update;
}

NotificationSeverity _severity(String type) {
  if ({
    'CRITICAL_TEMPERATURE',
    'INSPECTION_FAILED',
    'RECALL',
    'HIGH_AI_RISK',
  }.contains(type)) {
    return NotificationSeverity.critical;
  }
  if (_alertTypes.contains(type) || type.contains('FAILURE')) {
    return NotificationSeverity.warning;
  }
  return NotificationSeverity.normal;
}

DateTime? _nullableDate(Map<String, Object?> json, String key) {
  final value = ApiData.value(json, key);
  return value == null ? null : DateTime.tryParse('$value')?.toUtc();
}

String _timeLabel(DateTime? value) {
  if (value == null) return 'Unknown time';
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
}

/// Produces a user-facing reference without exposing opaque database keys.
abstract final class DisplayIdentifier {
  static String resolve({
    required String id,
    required String noun,
    String? code,
  }) {
    final preferred = code?.trim() ?? '';
    if (preferred.isNotEmpty) return preferred;

    final value = id.trim();
    if (value.isEmpty) return 'Not assigned';
    if (!_isOpaque(value)) return value;

    final compact = value.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
    final token = compact.length <= 8
        ? compact
        : compact.substring(compact.length - 8);
    return '$noun ${token.toUpperCase()}';
  }

  static bool _isOpaque(String value) {
    final uuid = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    final compactOpaque = RegExp(r'^[0-9a-f]{20,}$', caseSensitive: false);
    final numericKey = RegExp(r'^\d+$');
    return uuid.hasMatch(value) ||
        compactOpaque.hasMatch(value) ||
        numericKey.hasMatch(value);
  }
}

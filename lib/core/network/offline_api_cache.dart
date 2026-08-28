import '../database/fishtrace_database.dart';
import '../errors/app_exceptions.dart';

/// Persists successful role-directory responses and serves them only to the
/// same authenticated user when the network is unavailable.
class OfflineApiCache {
  const OfflineApiCache({
    required FishTraceDatabase database,
    required bool Function() isOffline,
    required String? Function() userScope,
  }) : _database = database,
       _isOffline = isOffline,
       _userScope = userScope;

  final FishTraceDatabase _database;
  final bool Function() _isOffline;
  final String? Function() _userScope;

  Future<Object?> readThrough(
    String key,
    Future<Object?> Function() remote,
  ) async {
    final scopedKey = _scopedKey(key);
    if (_isOffline()) return _requiredCached(scopedKey);

    try {
      final response = await remote();
      await _database.cacheApiResponse(scopedKey, response);
      return response;
    } on NetworkException {
      return _requiredCached(scopedKey);
    } on ServerException {
      return _requiredCached(scopedKey);
    }
  }

  String _scopedKey(String key) {
    final scope = _userScope()?.trim();
    if (scope == null || scope.isEmpty) {
      throw const UnauthorizedException(
        'Sign in before accessing offline data.',
      );
    }
    return '$scope:$key';
  }

  Future<Object?> _requiredCached(String scopedKey) async {
    final cached = await _database.readCachedApiResponse(scopedKey);
    if (cached != null) return cached;
    throw const NetworkException(
      'This data has not been downloaded yet. Connect once to make it available offline.',
    );
  }
}

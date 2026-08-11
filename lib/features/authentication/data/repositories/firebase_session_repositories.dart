import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_support.dart';
import '../../domain/repositories/firebase_session_repository.dart';

class MockFirebaseSessionRepository implements FirebaseSessionRepository {
  bool _authenticated = false;
  @override
  bool get isAuthenticated => _authenticated;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> createSession() async => _authenticated = true;
  @override
  Future<void> signOut() async => _authenticated = false;
}

class ApiFirebaseSessionRepository implements FirebaseSessionRepository {
  ApiFirebaseSessionRepository(this._api, {FirebaseAuth? auth})
    : _providedAuth = auth;
  final ApiClient _api;
  final FirebaseAuth? _providedAuth;
  FirebaseAuth get _auth => _providedAuth ?? FirebaseAuth.instance;

  @override
  bool get isAuthenticated {
    try {
      return _auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    } catch (_) {
      throw const ApiException(
        'Firebase is not configured for this build.',
        code: 'firebase_not_configured',
      );
    }
  }

  @override
  Future<void> createSession() async {
    await initialize();
    final response = ApiData.map(await _api.post(ApiEndpoints.firebaseSession));
    final payload = response['data'] is Map
        ? ApiData.map(response['data'])
        : response;
    final token = ApiData.string(
      payload,
      'custom_token',
      ApiData.string(payload, 'customToken'),
    );
    if (token.isEmpty) {
      throw const ApiException(
        'Firebase session token was missing.',
        code: 'invalid_firebase_session',
      );
    }
    try {
      await _auth.signInWithCustomToken(token);
    } on FirebaseAuthException catch (error) {
      throw ApiException(
        'Unable to start live monitoring session.',
        code: error.code,
      );
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

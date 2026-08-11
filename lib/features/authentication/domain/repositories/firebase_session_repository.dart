abstract interface class FirebaseSessionRepository {
  bool get isAuthenticated;
  Future<void> initialize();
  Future<void> createSession();
  Future<void> signOut();
}

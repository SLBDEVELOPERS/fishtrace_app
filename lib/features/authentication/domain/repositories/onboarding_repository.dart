abstract interface class OnboardingRepository {
  Future<bool> isComplete();
  Future<void> markComplete();
}

class HabitValidationException implements Exception {
  final String message;
  HabitValidationException(this.message);

  @override
  String toString() => message;
}

class DataAccessException implements Exception {
  const DataAccessException(this.message);

  final String message;

  @override
  String toString() => 'DataAccessException: $message';
}

/// Exceção lançada em caso de falha de comunicação HTTP com status code >= 400.
class NetworkException implements Exception {
  final int statusCode;
  final String? message;

  NetworkException({required this.statusCode, this.message});

  @override
  String toString() =>
      'NetworkException: status code $statusCode, message: $message';
}
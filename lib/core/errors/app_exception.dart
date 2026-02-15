class AppException implements Exception {
  AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class GraphqlError {
  const GraphqlError({required this.message, this.code});

  final String message;
  final String? code;
}

class GraphqlException extends AppException {
  GraphqlException({required this.errors})
    : super(
        errors.isNotEmpty ? errors.first.message : 'GraphQL request failed',
      );

  final List<GraphqlError> errors;

  bool hasCode(String code) {
    return errors.any((error) => error.code == code);
  }
}

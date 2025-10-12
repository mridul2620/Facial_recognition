class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  ApiException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException({String? message})
      : super(
          message: message ?? 'No internet connection',
          statusCode: null,
        );
}

class TimeoutException extends ApiException {
  TimeoutException({String? message})
      : super(
          message: message ?? 'Request timeout',
          statusCode: 408,
        );
}

class ServerException extends ApiException {
  ServerException({String? message, int? statusCode})
      : super(
          message: message ?? 'Server error occurred',
          statusCode: statusCode ?? 500,
        );
}

class BadRequestException extends ApiException {
  BadRequestException({String? message})
      : super(
          message: message ?? 'Bad request',
          statusCode: 400,
        );
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(
          message: message ?? 'Unauthorized',
          statusCode: 401,
        );
}

class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(
          message: message ?? 'Resource not found',
          statusCode: 404,
        );
}
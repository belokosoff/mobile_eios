class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ForbiddenException extends AppException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 404);
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message, 400);
}

class NoContentException extends AppException {
  NoContentException(String message) : super(message, 204);
}
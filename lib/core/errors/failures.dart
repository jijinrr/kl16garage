import 'package:equatable/equatable.dart';

/// Base class for all application failures.
/// Used in repository return types to represent typed errors.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Firebase Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Firestore / database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Firebase Storage failures
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Network / connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Unknown / unclassified failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// Permission denied failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Validation failures (client-side)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

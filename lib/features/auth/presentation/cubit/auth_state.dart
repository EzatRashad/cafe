part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthNeedsSetup extends AuthState {}
class AuthNeedsLogin extends AuthState {}
class AuthAuthenticated extends AuthState {}
class AuthValidationError extends AuthState {
  final String messageKey;
  AuthValidationError(this.messageKey);
  @override
  List<Object?> get props => [messageKey];
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

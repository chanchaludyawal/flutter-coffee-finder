import 'package:equatable/equatable.dart';



// Inputs: User actions
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoggedOut extends AuthEvent {}

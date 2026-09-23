import 'package:cuproute/domain/entities/user_entity.dart';
import 'package:cuproute/domain/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

// Process : AuthBloc brain of auth flow

//                              Input , Output
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository _repository;
  AuthBloc(this._repository) : super(AuthInitial()) {
    // 1. Check local storage / repository for saved token
    // 2. If valid token exists -> emit(Authenticated());
    // 3. Otherwise           -> emit(Unauthenticated());
    on<AuthCheckRequested>(_onAuthCheckRequested);

    //(event, emit) {}

    on<AuthLoggedOut>((event, emit) {
      // 1. Clear saved token / session from repository
      // 2. emit(Unauthenticated());
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isUserLogin = await _repository.isLoginUser();
    if (isUserLogin) {
      final user = await _repository.getCurrentUser();
      emit(Authenticated(user: user ?? UserEntity()));
    } else {
      emit(Unauthenticated());
    }
  }
}

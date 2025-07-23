import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user.dart';
import '../../repository/firebase_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class SignInAnonymously extends AuthEvent {}

class SignOut extends AuthEvent {}

class UpdateUserProfile extends AuthEvent {
  final AppUser user;

  const UpdateUserProfile(this.user);

  @override
  List<Object> get props => [user];
}

class LoadUserProfile extends AuthEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User firebaseUser;
  final AppUser? appUser;

  const AuthAuthenticated({
    required this.firebaseUser,
    this.appUser,
  });

  @override
  List<Object?> get props => [firebaseUser, appUser];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class UserProfileLoaded extends AuthState {
  final User firebaseUser;
  final AppUser appUser;

  const UserProfileLoaded({
    required this.firebaseUser,
    required this.appUser,
  });

  @override
  List<Object> get props => [firebaseUser, appUser];
}

class UserProfileUpdated extends AuthState {
  final User firebaseUser;
  final AppUser appUser;

  const UserProfileUpdated({
    required this.firebaseUser,
    required this.appUser,
  });

  @override
  List<Object> get props => [firebaseUser, appUser];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<SignInAnonymously>(_onSignInAnonymously);
    on<SignOut>(_onSignOut);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LoadUserProfile>(_onLoadUserProfile);
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      final user = await repository.getCurrentUser();
      
      if (user != null) {
        final appUser = await repository.getUserProfile(user.uid);
        emit(AuthAuthenticated(
          firebaseUser: user,
          appUser: appUser,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Erro ao verificar autenticação: $e'));
    }
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymously event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      final userCredential = await repository.signInAnonymously();
      
      if (userCredential?.user != null) {
        final firebaseUser = userCredential!.user!;
        
        // Create or get user profile
        AppUser? appUser = await repository.getUserProfile(firebaseUser.uid);
        
        if (appUser == null) {
          // Create new user profile
          appUser = AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            preferredLanguage: 'pt',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await repository.createUserProfile(appUser);
        }
        
        emit(AuthAuthenticated(
          firebaseUser: firebaseUser,
          appUser: appUser,
        ));
      } else {
        emit(const AuthError('Falha no login anônimo'));
      }
    } catch (e) {
      emit(AuthError('Erro no login: $e'));
    }
  }

  Future<void> _onSignOut(
    SignOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      await repository.signOut();
      
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Erro ao fazer logout: $e'));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        emit(AuthLoading());
        
        final updatedUser = event.user.copyWith(
          updatedAt: DateTime.now(),
        );
        
        final success = await repository.updateUserProfile(updatedUser);
        
        if (success) {
          emit(UserProfileUpdated(
            firebaseUser: currentState.firebaseUser,
            appUser: updatedUser,
          ));
        } else {
          emit(const AuthError('Erro ao atualizar perfil'));
        }
      }
    } catch (e) {
      emit(AuthError('Erro ao atualizar perfil: $e'));
    }
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        emit(AuthLoading());
        
        final appUser = await repository.getUserProfile(event.userId);
        
        if (appUser != null) {
          emit(UserProfileLoaded(
            firebaseUser: currentState.firebaseUser,
            appUser: appUser,
          ));
        } else {
          emit(const AuthError('Perfil do usuário não encontrado'));
        }
      }
    } catch (e) {
      emit(AuthError('Erro ao carregar perfil: $e'));
    }
  }

  // Helper methods
  bool get isAuthenticated {
    return state is AuthAuthenticated;
  }

  User? get currentFirebaseUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.firebaseUser;
    }
    return null;
  }

  AppUser? get currentAppUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.appUser;
    } else if (currentState is UserProfileLoaded) {
      return currentState.appUser;
    } else if (currentState is UserProfileUpdated) {
      return currentState.appUser;
    }
    return null;
  }
}

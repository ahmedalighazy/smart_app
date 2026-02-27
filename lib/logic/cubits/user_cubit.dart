import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../data/services/calculation_service.dart';
import '../../data/services/auth_service.dart';

// States
abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserCalculated extends UserState {
  final UserModel user;
  final CalculationResult result;

  UserCalculated({required this.user, required this.result});

  @override
  List<Object?> get props => [user, result];
}

class UserError extends UserState {
  final String message;

  UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserAuthenticated extends UserState {
  final Map<String, dynamic>? userData;

  UserAuthenticated([this.userData]);

  @override
  List<Object?> get props => [userData];
}

// Cubit
class UserCubit extends Cubit<UserState> {
  final CalculationService _calculationService = CalculationService();

  UserCubit() : super(UserInitial());

  // Check if user is already logged in
  Future<bool> checkAuth() async {
    try {
      emit(UserLoading());
      final result = await AuthService.autoLogin();
      if (result['success'] == true) {
        emit(UserAuthenticated());
        return true;
      }
      emit(UserInitial());
      return false;
    } catch (e) {
      emit(UserInitial());
      return false;
    }
  }

  void calculateUserData(UserModel user) {
    try {
      emit(UserLoading());

      final result = _calculationService.performCalculation(user);

      emit(UserCalculated(user: user, result: result));
    } catch (e) {
      emit(UserError('خطأ في الحساب: $e'));
    }
  }

  void reset() {
    emit(UserInitial());
  }

  UserModel? get currentUser {
    if (state is UserCalculated) {
      return (state as UserCalculated).user;
    }
    return null;
  }

  CalculationResult? get currentResult {
    if (state is UserCalculated) {
      return (state as UserCalculated).result;
    }
    return null;
  }

  // Login method
  Future<void> login(String email, String password) async {
    try {
      emit(UserLoading());

      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        emit(UserAuthenticated(result['data']));
      } else {
        emit(UserError(result['message'] ?? 'فشل تسجيل الدخول'));
      }
    } catch (e) {
      emit(UserError('خطأ في تسجيل الدخول: $e'));
    }
  }

  // Register method
  Future<void> register(String name, String email, String password) async {
    try {
      emit(UserLoading());

      final result = await AuthService.register(
        username: email.split('@')[0],
        email: email,
        password: password,
        fullName: name,
      );

      if (result['success'] == true) {
        emit(UserAuthenticated(result['data']));
      } else {
        emit(UserError(result['message'] ?? 'فشل التسجيل'));
      }
    } catch (e) {
      emit(UserError('خطأ في التسجيل: $e'));
    }
  }

  // Logout method
  Future<void> logout() async {
    await AuthService.logout();
    emit(UserInitial());
  }
}
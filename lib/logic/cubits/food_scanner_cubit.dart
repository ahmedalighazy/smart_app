import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../data/services/food_vision_service.dart';

// States
abstract class FoodScannerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FoodScannerInitial extends FoodScannerState {}

class FoodScannerImageSelected extends FoodScannerState {
  final File imageFile;

  FoodScannerImageSelected(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class FoodScannerAnalyzing extends FoodScannerState {}

class FoodScannerAnalyzed extends FoodScannerState {
  final File imageFile;
  final FoodAnalysisResult result;

  FoodScannerAnalyzed({required this.imageFile, required this.result});

  @override
  List<Object?> get props => [imageFile, result];
}

class FoodScannerError extends FoodScannerState {
  final String message;

  FoodScannerError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class FoodScannerCubit extends Cubit<FoodScannerState> {
  final FoodVisionService _visionService = FoodVisionService();

  FoodScannerCubit() : super(FoodScannerInitial());

  void selectImage(File imageFile) {
    emit(FoodScannerImageSelected(imageFile));
  }

  Future<void> analyzeFood(File imageFile) async {
    try {
      emit(FoodScannerAnalyzing());

      final result = await _visionService.analyzeFood(imageFile);

      emit(FoodScannerAnalyzed(imageFile: imageFile, result: result));
    } catch (e) {
      emit(FoodScannerError('فشل تحليل الصورة: $e'));
    }
  }

  void reset() {
    emit(FoodScannerInitial());
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/services/tips_service.dart';

part 'tips_state.dart';

class TipsCubit extends Cubit<TipsState> {
  TipsCubit() : super(const TipsInitial());

  void getRandomTip() {
    final tip = TipsService.getRandomTip();
    emit(TipsLoaded(tip: tip));
  }

  void getNutritionTip() {
    final tip = TipsService.getRandomNutritionTip();
    emit(TipsLoaded(tip: tip, type: 'nutrition'));
  }

  void getFitnessTip() {
    final tip = TipsService.getRandomFitnessTip();
    emit(TipsLoaded(tip: tip, type: 'fitness'));
  }

  void getTipsForMeal(String mealType) {
    final tips = TipsService.getTipsForMealType(mealType);
    emit(TipsLoaded(tip: tips.first, type: 'meal'));
  }
}

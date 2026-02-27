import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// States
abstract class FoodSearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FoodSearchInitial extends FoodSearchState {}

class FoodSearchLoading extends FoodSearchState {}

class FoodSearchLoaded extends FoodSearchState {
  final List<Map<String, dynamic>> results;
  final String query;

  FoodSearchLoaded({required this.results, required this.query});

  @override
  List<Object?> get props => [results, query];
}

class FoodSearchEmpty extends FoodSearchState {
  final String query;

  FoodSearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

// Cubit
class FoodSearchCubit extends Cubit<FoodSearchState> {
  final List<Map<String, dynamic>> allFoods;

  FoodSearchCubit({required this.allFoods}) : super(FoodSearchInitial());

  void searchFoods(String query) {
    if (query.isEmpty) {
      emit(FoodSearchInitial());
      return;
    }

    emit(FoodSearchLoading());

    // محاكاة تأخير البحث
    Future.delayed(const Duration(milliseconds: 300), () {
      final results = allFoods.where((food) {
        final name = food['name'].toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery);
      }).toList();

      if (results.isEmpty) {
        emit(FoodSearchEmpty(query));
      } else {
        emit(FoodSearchLoaded(results: results, query: query));
      }
    });
  }

  void clearSearch() {
    emit(FoodSearchInitial());
  }
}

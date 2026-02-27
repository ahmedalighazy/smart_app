import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String? name;
  final int age;
  final String gender; // 'male' or 'female'
  final double height; // in cm
  final double weight; // in kg
  final String activityLevel;
  final String? physiologicalState;

  const UserModel({
    this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    this.physiologicalState,
  });

  @override
  List<Object?> get props => [
    name,
    age,
    gender,
    height,
    weight,
    activityLevel,
    physiologicalState,
  ];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'physiologicalState': physiologicalState,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      activityLevel: json['activityLevel'],
      physiologicalState: json['physiologicalState'],
    );
  }

  UserModel copyWith({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
    String? physiologicalState,
  }) {
    return UserModel(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      physiologicalState: physiologicalState ?? this.physiologicalState,
    );
  }
}

class MacroNutrients extends Equatable {
  final double carbs;
  final double protein;
  final double fats;
  final double carbsCalories;
  final double proteinCalories;
  final double fatsCalories;

  const MacroNutrients({
    required this.carbs,
    required this.protein,
    required this.fats,
    required this.carbsCalories,
    required this.proteinCalories,
    required this.fatsCalories,
  });

  @override
  List<Object> get props => [
    carbs,
    protein,
    fats,
    carbsCalories,
    proteinCalories,
    fatsCalories,
  ];
}

class CalculationResult extends Equatable {
  final double bmi;
  final String bmiCategory;
  final double bmr;
  final double tdee;
  final MacroNutrients macros;

  const CalculationResult({
    required this.bmi,
    required this.bmiCategory,
    required this.bmr,
    required this.tdee,
    required this.macros,
  });

  @override
  List<Object> get props => [bmi, bmiCategory, bmr, tdee, macros];
}

class FoodAnalysisResult extends Equatable {
  final String foodName;
  final String ingredients;
  final String portionSize;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final int fiber;
  final String healthRating;
  final String tips;
  final String detailedAnalysis;

  const FoodAnalysisResult({
    required this.foodName,
    required this.ingredients,
    required this.portionSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.healthRating,
    required this.tips,
    required this.detailedAnalysis,
  });

  @override
  List<Object> get props => [
    foodName,
    ingredients,
    portionSize,
    calories,
    protein,
    carbs,
    fats,
    fiber,
    healthRating,
    tips,
    detailedAnalysis,
  ];

  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'ingredients': ingredients,
      'portionSize': portionSize,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'healthRating': healthRating,
      'tips': tips,
      'detailedAnalysis': detailedAnalysis,
    };
  }
}
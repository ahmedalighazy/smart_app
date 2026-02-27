import '../models/user_model.dart';

class CalculationService {
  // حساب BMI
  double calculateBMI(double weight, double height) {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // تصنيف BMI
  String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'نقص الوزن';
    if (bmi < 25) return 'وزن طبيعي';
    if (bmi < 30) return 'زيادة في الوزن';
    return 'سمنة';
  }

  // حساب BMR - معادلة Mifflin-St Jeor
  double calculateBMR(double weight, double height, int age, String gender) {
    if (gender == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // حساب TDEE
  double calculateTDEE(double bmr, String activityLevel, String? physiologicalState) {
    double activityMultiplier;

    switch (activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'very_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }

    double tdee = bmr * activityMultiplier;

    // إضافة سعرات للحالات الفسيولوجية الخاصة
    if (physiologicalState == 'pregnant') {
      tdee += 300;
    } else if (physiologicalState == 'breastfeeding') {
      tdee += 500;
    } else if (physiologicalState == 'athlete') {
      tdee += 200;
    }

    return tdee;
  }

  // حساب توزيع العناصر الغذائية
  MacroNutrients calculateMacros(double tdee, String? physiologicalState) {
    double carbsPercent, proteinPercent, fatsPercent;

    if (physiologicalState == 'athlete') {
      carbsPercent = 0.50;
      proteinPercent = 0.30;
      fatsPercent = 0.20;
    } else {
      carbsPercent = 0.45;
      proteinPercent = 0.25;
      fatsPercent = 0.30;
    }

    double carbsCalories = tdee * carbsPercent;
    double proteinCalories = tdee * proteinPercent;
    double fatsCalories = tdee * fatsPercent;

    // تحويل السعرات إلى جرامات
    double carbsGrams = carbsCalories / 4;
    double proteinGrams = proteinCalories / 4;
    double fatsGrams = fatsCalories / 9;

    return MacroNutrients(
      carbs: carbsGrams,
      protein: proteinGrams,
      fats: fatsGrams,
      carbsCalories: carbsCalories,
      proteinCalories: proteinCalories,
      fatsCalories: fatsCalories,
    );
  }

  // الحساب الشامل
  CalculationResult performCalculation(UserModel user) {
    double bmi = calculateBMI(user.weight, user.height);
    String bmiCategory = getBMICategory(bmi);
    double bmr = calculateBMR(user.weight, user.height, user.age, user.gender);
    double tdee = calculateTDEE(bmr, user.activityLevel, user.physiologicalState);
    MacroNutrients macros = calculateMacros(tdee, user.physiologicalState);

    return CalculationResult(
      bmi: bmi,
      bmiCategory: bmiCategory,
      bmr: bmr,
      tdee: tdee,
      macros: macros,
    );
  }
}
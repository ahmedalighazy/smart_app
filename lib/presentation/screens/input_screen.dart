import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/colors.dart';
import '../../data/models/user_model.dart';
import '../../logic/cubits/user_cubit.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = 'moderate';
  String? _physiologicalState;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        age: int.parse(_ageController.text),
        gender: _gender,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        activityLevel: _activityLevel,
        physiologicalState: _physiologicalState,
      );

      context.read<UserCubit>().calculateUserData(user);
      Navigator.pushNamed(context, '/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'إدخال البيانات',
          textDirection: TextDirection.rtl,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'أدخل بياناتك الشخصية',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'سنقوم بحساب احتياجاتك الغذائية اليومية بدقة',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textLight,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // العمر
              _buildTextField(
                controller: _ageController,
                label: 'العمر (سنة)',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال العمر';
                  }
                  int? age = int.tryParse(value);
                  if (age == null || age < 1 || age > 120) {
                    return 'أدخل عمراً صحيحاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // الطول
              _buildTextField(
                controller: _heightController,
                label: 'الطول (سم)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الطول';
                  }
                  double? height = double.tryParse(value);
                  if (height == null || height < 50 || height > 250) {
                    return 'أدخل طولاً صحيحاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // الوزن
              _buildTextField(
                controller: _weightController,
                label: 'الوزن (كجم)',
                icon: Icons.monitor_weight,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الوزن';
                  }
                  double? weight = double.tryParse(value);
                  if (weight == null || weight < 20 || weight > 300) {
                    return 'أدخل وزناً صحيحاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // الجنس
              const Text(
                'الجنس',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: _buildRadioOption(
                      value: 'male',
                      groupValue: _gender,
                      label: 'ذكر',
                      icon: Icons.male,
                      onChanged: (value) => setState(() => _gender = value!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildRadioOption(
                      value: 'female',
                      groupValue: _gender,
                      label: 'أنثى',
                      icon: Icons.female,
                      onChanged: (value) => setState(() => _gender = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // مستوى النشاط
              const Text(
                'مستوى النشاط البدني',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              _buildDropdown(
                value: _activityLevel,
                items: const [
                  {'value': 'sedentary', 'label': 'قليل جداً (لا رياضة)'},
                  {'value': 'light', 'label': 'خفيف (1-3 أيام/أسبوع)'},
                  {'value': 'moderate', 'label': 'معتدل (3-5 أيام/أسبوع)'},
                  {'value': 'active', 'label': 'نشط (6-7 أيام/أسبوع)'},
                  {'value': 'very_active', 'label': 'نشط جداً (رياضي)'},
                ],
                onChanged: (value) => setState(() => _activityLevel = value!),
              ),
              const SizedBox(height: 20),

              // الحالة الفسيولوجية
              const Text(
                'الحالة الفسيولوجية (اختياري)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              _buildDropdown(
                value: _physiologicalState,
                items: const [
                  {'value': null, 'label': 'عادي'},
                  {'value': 'pregnant', 'label': 'حامل'},
                  {'value': 'breastfeeding', 'label': 'مرضعة'},
                  {'value': 'athlete', 'label': 'رياضي محترف'},
                ],
                onChanged: (value) => setState(() => _physiologicalState = value),
              ),
              const SizedBox(height: 40),

              // زر الحساب
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.calculate, size: 24, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'احسب الآن',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.textLight,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          suffixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          errorStyle: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String groupValue,
    required String label,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textLight,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              item['label'],
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        icon: const SizedBox.shrink(),
      ),
    );
  }
}
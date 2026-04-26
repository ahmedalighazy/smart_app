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

  // الحالة الصحية
  final List<String> _selectedDiseases = [];
  final List<String> _selectedMedications = [];

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

      // عرض تحذير إذا كان هناك أمراض أو أدوية
      if (_selectedDiseases.isNotEmpty || _selectedMedications.isNotEmpty) {
        _showHealthWarningDialog();
      } else {
        Navigator.pushNamed(context, '/results');
      }
    }
  }

  void _showHealthWarningDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'تنبيه صحي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'تم تسجيل حالتك الصحية:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            if (_selectedDiseases.isNotEmpty) ...[
              const Text(
                'الأمراض المزمنة:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              Text(
                '• ${_selectedDiseases.length} مرض مسجل',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
            ],
            if (_selectedMedications.isNotEmpty) ...[
              const Text(
                'الأدوية:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              Text(
                '• ${_selectedMedications.length} دواء مسجل',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                'يُنصح باستشارة طبيب أو أخصائي تغذية قبل اتباع أي نظام غذائي.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تعديل'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/results');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('متابعة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('إدخال البيانات', textDirection: TextDirection.rtl),
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
                onChanged: (value) =>
                    setState(() => _physiologicalState = value),
              ),
              const SizedBox(height: 20),

              // الحالة الصحية
              _buildHealthSection(),
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

  Widget _buildHealthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // عنوان القسم
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade50, Colors.orange.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200, width: 1.5),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.health_and_safety,
                  color: Colors.red.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الحالة الصحية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'معلومات مهمة لحساب احتياجاتك بدقة',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // الأمراض المزمنة
        const Text(
          'هل تعاني من أي أمراض مزمنة؟',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 10),
        _buildDiseasesList(),
        const SizedBox(height: 20),

        // الأدوية
        const Text(
          'هل تتناول أي أدوية حالياً؟',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 10),
        _buildMedicationsList(),
        const SizedBox(height: 20),

        // ملاحظات إضافية
        const Text(
          'ملاحظات إضافية (اختياري)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 10),
        Container(
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
            maxLines: 3,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'أي معلومات صحية أخرى تود إضافتها...',
              hintStyle: const TextStyle(color: AppColors.textLight),
              hintTextDirection: TextDirection.rtl,
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiseasesList() {
    final diseases = [
      {'id': 'diabetes', 'label': 'السكري', 'icon': Icons.bloodtype},
      {'id': 'hypertension', 'label': 'ضغط الدم', 'icon': Icons.favorite},
      {'id': 'heart', 'label': 'أمراض القلب', 'icon': Icons.monitor_heart},
      {'id': 'kidney', 'label': 'أمراض الكلى', 'icon': Icons.water_drop},
      {'id': 'liver', 'label': 'أمراض الكبد', 'icon': Icons.local_hospital},
      {
        'id': 'thyroid',
        'label': 'الغدة الدرقية',
        'icon': Icons.medical_services,
      },
      {'id': 'cholesterol', 'label': 'الكوليسترول', 'icon': Icons.analytics},
      {'id': 'anemia', 'label': 'فقر الدم', 'icon': Icons.opacity},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: diseases.map((disease) {
          final isSelected = _selectedDiseases.contains(disease['id']);
          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedDiseases.remove(disease['id']);
                } else {
                  _selectedDiseases.add(disease['id'] as String);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.red.shade300
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    disease['icon'] as IconData,
                    size: 18,
                    color: isSelected
                        ? Colors.red.shade700
                        : AppColors.textLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    disease['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.red.shade700
                          : AppColors.textDark,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.red.shade700,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMedicationsList() {
    final medications = [
      {'id': 'antibiotics', 'label': 'مضادات حيوية', 'icon': Icons.medication},
      {'id': 'blood_pressure', 'label': 'أدوية الضغط', 'icon': Icons.favorite},
      {'id': 'diabetes_meds', 'label': 'أدوية السكري', 'icon': Icons.bloodtype},
      {
        'id': 'cholesterol_meds',
        'label': 'أدوية الكوليسترول',
        'icon': Icons.analytics,
      },
      {
        'id': 'thyroid_meds',
        'label': 'أدوية الغدة',
        'icon': Icons.medical_services,
      },
      {'id': 'vitamins', 'label': 'فيتامينات', 'icon': Icons.local_pharmacy},
      {'id': 'supplements', 'label': 'مكملات غذائية', 'icon': Icons.science},
      {'id': 'pain_relief', 'label': 'مسكنات', 'icon': Icons.healing},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: medications.map((medication) {
          final isSelected = _selectedMedications.contains(medication['id']);
          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedMedications.remove(medication['id']);
                } else {
                  _selectedMedications.add(medication['id'] as String);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.blue.shade300
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    medication['icon'] as IconData,
                    size: 18,
                    color: isSelected
                        ? Colors.blue.shade700
                        : AppColors.textLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    medication['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.blue.shade700
                          : AppColors.textDark,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textLight),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          errorStyle: const TextStyle(fontSize: 12),
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
        initialValue: value,
        decoration: InputDecoration(
          suffixIcon: const Icon(
            Icons.arrow_drop_down_circle,
            color: AppColors.primary,
          ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              item['label'],
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 15),
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

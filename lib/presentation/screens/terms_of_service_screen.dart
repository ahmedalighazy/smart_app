import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/localization/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          context.tr('terms'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          textDirection: TextDirection.rtl,
          children: [
            _buildSection(
              context,
              '1. قبول الشروط',
              'باستخدام تطبيق Smart Nutrition، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء من هذه الشروط، يرجى عدم استخدام التطبيق.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '2. الترخيص والاستخدام',
              'نمنحك ترخيصاً محدوداً وغير حصري لاستخدام التطبيق للأغراض الشخصية والتعليمية. لا يجوز لك نسخ أو تعديل أو توزيع التطبيق دون إذن كتابي منا.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '3. حسابك',
              '''• أنت مسؤول عن الحفاظ على سرية كلمة المرور الخاصة بك
• أنت توافق على عدم مشاركة حسابك مع أشخاص آخرين
• أنت مسؤول عن جميع الأنشطة التي تحدث تحت حسابك
• يجب عليك إخطارنا فوراً بأي استخدام غير مصرح به''',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '4. محتوى المستخدم',
              'أنت تحتفظ بجميع الحقوق في المحتوى الذي تنشره. بنشر المحتوى، فإنك تمنحنا الحق في استخدامه لتحسين الخدمة.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '5. السلوك المحظور',
              '''• لا تستخدم التطبيق لأي أغراض غير قانونية
• لا تحاول الوصول إلى أنظمتنا بطرق غير مصرح بها
• لا تنشر محتوى مسيء أو مهين
• لا تحاول إيذاء أو إزعاج المستخدمين الآخرين
• لا تستخدم التطبيق لأغراض تجارية دون إذن''',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '6. إخلاء المسؤولية',
              'التطبيق يُقدم "كما هو" دون أي ضمانات. لا نضمن دقة المعلومات الغذائية أو التوصيات. استشر متخصصاً طبياً قبل إجراء أي تغييرات غذائية كبيرة.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '7. تحديد المسؤولية',
              'لن نكون مسؤولين عن أي أضرار مباشرة أو غير مباشرة ناشئة عن استخدام التطبيق، بما في ذلك فقدان البيانات أو الأرباح.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '8. الملكية الفكرية',
              'جميع محتويات التطبيق، بما في ذلك النصوص والصور والشعارات، محمية بحقوق الملكية الفكرية. لا يجوز استخدامها دون إذن.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '9. التعديلات على الخدمة',
              'نحتفظ بالحق في تعديل أو إيقاف الخدمة في أي وقت. سنحاول إخطارك بأي تغييرات مهمة.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '10. إنهاء الحساب',
              'يمكنك إنهاء حسابك في أي وقت. قد نقوم بإنهاء حسابك إذا انتهكت هذه الشروط.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '11. القانون الحاكم',
              'تخضع هذه الشروط للقوانين المعمول بها. أي نزاع سيتم حله من خلال المحاكم المختصة.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '12. التواصل',
              'إذا كان لديك أي أسئلة حول شروط الاستخدام، يرجى التواصل معنا عبر البريد الإلكتروني: support@smartnutrition.com',
              isDark,
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'آخر تحديث: فبراير 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            content,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: isDark ? Colors.grey[300] : AppColors.textLight,
            ),
          ),
        ),
      ],
    );
  }
}

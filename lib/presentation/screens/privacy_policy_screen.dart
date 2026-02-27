import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/localization/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          context.tr('privacy'),
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
              '1. مقدمة',
              'نحن نقدر خصوصيتك ونلتزم بحماية بيانات المستخدمين. تشرح هذه السياسة كيفية جمع واستخدام وحماية معلوماتك الشخصية.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '2. البيانات التي نجمعها',
              '''• معلومات الملف الشخصي: الاسم والبريد الإلكتروني والعمر والجنس والطول والوزن
• بيانات التغذية: الوجبات المسجلة والسعرات الحرارية والعناصر الغذائية
• بيانات الجهاز: نوع الجهاز ونظام التشغيل والمعرف الفريد
• بيانات الاستخدام: كيفية استخدامك للتطبيق والميزات التي تستخدمها''',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '3. كيفية استخدام البيانات',
              '''• توفير الخدمات: حساب احتياجاتك الغذائية وتقديم التوصيات
• تحسين التطبيق: تحليل الاستخدام وتحسين الميزات
• التواصل: إرسال التحديثات والإشعارات المهمة
• الأمان: منع الاحتيال والحفاظ على أمان البيانات''',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '4. حماية البيانات',
              'نستخدم تقنيات التشفير والحماية المتقدمة لحماية بيانات المستخدمين. جميع البيانات محفوظة محلياً على جهازك وفي خوادم آمنة.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '5. مشاركة البيانات',
              'لا نشارك بيانات المستخدمين مع أطراف ثالثة دون موافقتك الصريحة. قد نشارك البيانات المجمعة (غير المحددة) لأغراض البحث والتحسين.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '6. حقوقك',
              '''• الوصول: يمكنك الوصول إلى بيانات حسابك في أي وقت
• التعديل: يمكنك تعديل معلوماتك الشخصية
• الحذف: يمكنك طلب حذف حسابك وبيانات المستخدم
• الاعتراض: يمكنك الاعتراض على معالجة بيانات معينة''',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '7. ملفات تعريف الارتباط',
              'قد يستخدم التطبيق ملفات تعريف الارتباط لتحسين تجربة المستخدم. يمكنك التحكم في إعدادات ملفات تعريف الارتباط من خلال إعدادات جهازك.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '8. التغييرات على السياسة',
              'قد نحدث هذه السياسة من وقت لآخر. سيتم إخطارك بأي تغييرات مهمة عبر البريد الإلكتروني أو إشعار في التطبيق.',
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '9. التواصل معنا',
              'إذا كان لديك أي أسئلة حول سياسة الخصوصية، يرجى التواصل معنا عبر البريد الإلكتروني: privacy@smartnutrition.com',
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

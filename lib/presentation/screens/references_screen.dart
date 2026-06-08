import 'package:flutter/material.dart';

class ReferencesScreen extends StatelessWidget {
  const ReferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصادر والمراجع'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.school, size: 48, color: Colors.green.shade700),
                  const SizedBox(height: 8),
                  Text(
                    'المصادر العلمية والمراجع',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تم إعداد هذا التطبيق بناءً على مصادر علمية موثوقة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // القسم الأكاديمي
            _buildSectionTitle('📚 المصادر الأكاديمية'),
            _buildReferenceCard(
              title: 'قسم الاقتصاد المنزلي',
              subtitle: 'قسم التغذية وعلوم الأطعمة',
              description:
                  'تم الاعتماد على المناهج الدراسية والمراجع العلمية من قسم الاقتصاد المنزلي في تطوير معادلات حساب السعرات الحرارية والقيم الغذائية.',
              icon: Icons.school,
              color: Colors.blue,
            ),
            _buildReferenceCard(
              title: 'علم التغذية العلاجية',
              subtitle: 'المرجع الأساسي في التغذية',
              description:
                  'الكتب والمراجع الدراسية المعتمدة في تخصص التغذية وعلوم الأطعمة، والتي تشمل دراسة العناصر الغذائية والاحتياجات اليومية.',
              icon: Icons.menu_book,
              color: Colors.purple,
            ),

            const SizedBox(height: 16),
            _buildSectionTitle('🔬 المعادلات العلمية'),
            _buildReferenceCard(
              title: 'معادلة Harris-Benedict',
              subtitle: 'لحساب معدل الأيض الأساسي (BMR)',
              description:
                  'معادلة علمية معتمدة عالمياً لحساب السعرات الحرارية الأساسية التي يحتاجها الجسم في حالة الراحة.',
              icon: Icons.calculate,
              color: Colors.orange,
            ),
            _buildReferenceCard(
              title: 'معادلة Mifflin-St Jeor',
              subtitle: 'البديل الحديث لحساب BMR',
              description:
                  'معادلة محدثة وأكثر دقة لحساب معدل الأيض الأساسي، معتمدة من الجمعية الأمريكية للتغذية.',
              icon: Icons.functions,
              color: Colors.teal,
            ),
            _buildReferenceCard(
              title: 'مؤشر كتلة الجسم (BMI)',
              subtitle: 'Body Mass Index',
              description:
                  'مقياس عالمي معتمد من منظمة الصحة العالمية لتقييم الوزن بالنسبة للطول وتحديد الوزن المثالي.',
              icon: Icons.monitor_weight,
              color: Colors.indigo,
            ),

            const SizedBox(height: 16),
            _buildSectionTitle('🌍 المنظمات الدولية'),
            _buildReferenceCard(
              title: 'منظمة الصحة العالمية (WHO)',
              subtitle: 'World Health Organization',
              description:
                  'الإرشادات والتوصيات الغذائية المعتمدة من منظمة الصحة العالمية للتغذية الصحية والوقاية من الأمراض.',
              icon: Icons.public,
              color: Colors.blue,
            ),
            _buildReferenceCard(
              title: 'وزارة الصحة المصرية',
              subtitle: 'الدليل الغذائي المصري',
              description:
                  'التوصيات والإرشادات الغذائية المحلية المناسبة للمجتمع المصري والعادات الغذائية المحلية.',
              icon: Icons.local_hospital,
              color: Colors.red,
            ),

            const SizedBox(height: 16),
            _buildSectionTitle('🤖 التقنيات المستخدمة'),
            _buildReferenceCard(
              title: 'Google Gemini AI',
              subtitle: 'تحليل الصور بالذكاء الاصطناعي',
              description:
                  'تقنية الذكاء الاصطناعي من Google لتحليل صور الطعام والتعرف على المكونات والقيم الغذائية.',
              icon: Icons.smart_toy,
              color: Colors.green,
            ),
            _buildReferenceCard(
              title: 'Flutter Framework',
              subtitle: 'تطوير التطبيقات متعددة المنصات',
              description:
                  'إطار عمل من Google لتطوير تطبيقات الهواتف الذكية بأداء عالي وتجربة مستخدم ممتازة.',
              icon: Icons.phone_android,
              color: Colors.blue,
            ),

            const SizedBox(height: 16),
            _buildSectionTitle('📖 مراجع إضافية'),
            _buildSimpleReference(
              '• الجداول الغذائية المصرية - المعهد القومي للتغذية',
            ),
            _buildSimpleReference(
              '• دليل التغذية العلاجية - الجمعية المصرية للتغذية',
            ),
            _buildSimpleReference(
              '• معايير التغذية للمرأة الحامل والمرضع - وزارة الصحة',
            ),
            _buildSimpleReference(
              '• إرشادات التغذية الرياضية - الاتحاد الدولي للطب الرياضي',
            ),
            _buildSimpleReference(
              '• دليل الأطعمة الصحية - منظمة الأغذية والزراعة (FAO)',
            ),

            const SizedBox(height: 24),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.verified, color: Colors.green.shade700, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'تم إعداد هذا التطبيق بعناية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'بناءً على المعرفة العلمية المكتسبة من دراسة الاقتصاد المنزلي\nوتخصص التغذية وعلوم الأطعمة',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© 2026 - Smart Nutrition',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildReferenceCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleReference(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
      ),
    );
  }
}

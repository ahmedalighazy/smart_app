import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class CategoryPreview extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;

  const CategoryPreview({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: category['color'].withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 15),
            _buildFoodItems(),
            const SizedBox(height: 10),
            Text(
              'اضغط لعرض جميع التفاصيل',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 12,
                color: category['color'],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: TextDirection.rtl,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            // Category Image
            if (category['imageUrl'] != null)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: category['color'].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (category['isLocalImage'] as bool? ?? false)
                      ? Image.asset(
                          category['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: category['color'].withValues(alpha: 0.2),
                              child: Center(
                                child: Text(
                                  category['emoji'],
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            );
                          },
                        )
                      : Image.network(
                          category['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: category['color'].withValues(alpha: 0.2),
                              child: Center(
                                child: Text(
                                  category['emoji'],
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: category['color'].withValues(alpha: 0.1),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    category['color'],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              )
            else
              Text(category['emoji'], style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 10),
            Text(
              'أمثلة من ${category['name']}',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: category['color'],
              ),
            ),
          ],
        ),
        Icon(Icons.arrow_back_ios, color: category['color'], size: 20),
      ],
    );
  }

  Widget _buildFoodItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: (category['items'] as List).take(3).map((food) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: category['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: category['color'].withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  food['name'],
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: category['color'],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 12,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      food['calories'],
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'بروتين: ${food['protein']}g',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  'كربوهيدرات: ${food['carbs']}g',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

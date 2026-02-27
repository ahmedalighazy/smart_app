import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = category['color'] as Color;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 85,
        decoration: BoxDecoration(
          color: isSelected ? categoryColor : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withValues(alpha: isSelected ? 0.4 : 0.2),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category['emoji'] as String,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              category['name'] as String,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSelected ? 13 : 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.white : categoryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

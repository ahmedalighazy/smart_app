import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'food_item_card.dart';
import '../../food_search_screen.dart';

class FoodDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> category;

  const FoodDetailsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final items = (category['items'] as List?) ?? [];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              category['color'] as Color,
              (category['color'] as Color).withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return FoodItemCard(
                        food: items[index],
                        category: category,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ),
          const SizedBox(width: 10),
          // Category Image
          if (category['imageUrl'] != null)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (category['isLocalImage'] as bool? ?? false)
                    ? Image.asset(
                        category['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white.withValues(alpha: 0.3),
                            child: Center(
                              child: Text(
                                category['emoji'] ?? '🍽️',
                                style: const TextStyle(fontSize: 28),
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
                            color: Colors.white.withValues(alpha: 0.3),
                            child: Center(
                              child: Text(
                                category['emoji'] ?? '🍽️',
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.white.withValues(alpha: 0.2),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            )
          else
            Text(
              category['emoji'] ?? '🍽️',
              style: const TextStyle(fontSize: 40),
            ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'تفاصيل ${category['name'] ?? 'الطعام'}',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodSearchScreen(
                    categoryFoods: category['items'] ?? [],
                    categoryName: category['name'] ?? 'الطعام',
                    categoryColor: category['color'] ?? Colors.grey,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}
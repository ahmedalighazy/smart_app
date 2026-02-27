import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../core/constants/colors.dart';
import '../../data/services/food_vision_service.dart';
import '../../logic/cubits/user_cubit.dart';



class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  State<AIRecommendationsScreen> createState() => _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  final FoodVisionService _aiService = FoodVisionService();
  String _recommendations = '';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    // 🔍 LOG 1: Check if method is called
    developer.log('🔍 _loadRecommendations called', name: 'AIRecommendations');

    try {
      final userState = context.read<UserCubit>().state;

      // 🔍 LOG 2: Check user state
      developer.log('🔍 User state type: ${userState.runtimeType}', name: 'AIRecommendations');

      if (userState is! UserCalculated) {
        developer.log('❌ User state is not UserCalculated', name: 'AIRecommendations');
        if (mounted) {
          setState(() {
            _error = 'الرجاء إدخال بياناتك أولاً من حاسبة التغذية';
          });
        }
        return;
      }

      // 🔍 LOG 3: User data exists
      developer.log('✅ User data exists', name: 'AIRecommendations');
      developer.log('📊 User age: ${userState.user.age}', name: 'AIRecommendations');
      developer.log('📊 User weight: ${userState.user.weight}', name: 'AIRecommendations');

      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // 🔍 LOG 4: About to call API
      developer.log('🚀 Calling AI API...', name: 'AIRecommendations');

      final recommendations = await _aiService.getAIRecommendations(
        userState.user,
        userState.result,
      );

      // 🔍 LOG 5: API response received
      developer.log('✅ API response received', name: 'AIRecommendations');
      developer.log('📝 Response length: ${recommendations.length} characters', name: 'AIRecommendations');

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }

      developer.log('✅ State updated successfully', name: 'AIRecommendations');

    } catch (e, stackTrace) {
      // 🔍 LOG 6: Error details
      developer.log('❌ ERROR in _loadRecommendations', name: 'AIRecommendations', error: e);
      developer.log('❌ Error type: ${e.runtimeType}', name: 'AIRecommendations');
      developer.log('❌ Error message: $e', name: 'AIRecommendations');
      developer.log('❌ Stack trace: $stackTrace', name: 'AIRecommendations');

      if (mounted) {
        setState(() {
          _error = 'خطأ في الحصول على التوصيات: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔍 LOG 7: Build method called
    developer.log('🎨 Building AIRecommendationsScreen', name: 'AIRecommendations');
    developer.log('🎨 isLoading: $_isLoading, hasError: ${_error != null}', name: 'AIRecommendations');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'توصيات AI مخصصة',
          textDirection: TextDirection.rtl,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.refresh, size: 20),
              ),
              tooltip: 'تحديث',
              onPressed: () {
                developer.log('🔄 Refresh button pressed', name: 'AIRecommendations');
                _loadRecommendations();
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  developer.log('🔙 Navigating back to input', name: 'AIRecommendations');
                  Navigator.pushReplacementNamed(context, '/input');
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('العودة لإدخال البيانات'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 30),
            const Text(
              'جاري إنشاء توصيات مخصصة لك...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'الذكاء الاصطناعي يحلل بياناتك لإعطائك أفضل النصائح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header Card with Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 40,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'توصيات مخصصة من AI',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'بناءً على بياناتك الشخصية',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.white,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recommendations Content with Better Styling
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'التوصيات التفصيلية',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.textHint.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: SelectableText(
                    _recommendations,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 2.0,
                      color: AppColors.textDark,
                      letterSpacing: 0.3,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Info Card with Better Design
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'هذه التوصيات مبنية على الذكاء الاصطناعي وهي للإرشاد فقط. استشر أخصائي تغذية معتمد للحصول على خطة غذائية شاملة.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                      height: 1.6,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons with Better Design
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.info, AppColors.info.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.info.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/food_scanner');
                    },
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
                        Icon(Icons.camera_alt, color: AppColors.white),
                        SizedBox(width: 8),
                        Text(
                          'مسح الطعام',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
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
                    onPressed: () {
                      Navigator.pushNamed(context, '/results');
                    },
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
                        Icon(Icons.analytics, color: AppColors.white),
                        SizedBox(width: 8),
                        Text(
                          'عرض النتائج',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
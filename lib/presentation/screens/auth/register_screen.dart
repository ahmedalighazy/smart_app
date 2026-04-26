import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../logic/cubits/user_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await context.read<UserCubit>().register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserLoading) {
          setState(() => _isLoading = true);
        } else if (state is UserAuthenticated) {
          setState(() => _isLoading = false);
          
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(
              message: 'مرحباً بك! تم إنشاء حسابك بنجاح 🎉',
              backgroundColor: AppColors.success,
            ),
            displayDuration: const Duration(seconds: 2),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          });
        } else if (state is UserError) {
          setState(() => _isLoading = false);
          
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: 'فشل إنشاء الحساب\n${state.message}',
              backgroundColor: AppColors.error,
            ),
            displayDuration: const Duration(seconds: 3),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.background,
              ],
              stops: const [0.0, 0.25, 0.4],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 16 : 24,
                              ),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.8, end: 1.0),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(scale: value, child: child);
                                    },
                                    child: Container(
                                      width: isSmallScreen ? 80 : 90,
                                      height: isSmallScreen ? 80 : 90,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/logo_app.jpeg',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person_add_rounded,
                                              size: isSmallScreen ? 40 : 45,
                                              color: AppColors.primary,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 8 : 12),
                                  Text(
                                    'إنشاء حساب جديد',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Expanded(
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(
                                    maxWidth: 600,
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                    24,
                                    isSmallScreen ? 20 : 28,
                                    24,
                                    20,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(32),
                                      topRight: Radius.circular(32),
                                    ),
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'أهلاً بك! 🎉',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 20 : 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'املأ البيانات لإنشاء حسابك',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 13 : 14,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 16 : 22),

                                        _buildInputField(
                                          controller: _nameController,
                                          label: 'الاسم الكامل',
                                          hint: 'مثال: أحمد محمد',
                                          icon: Icons.person_rounded,
                                          textDirection: TextDirection.rtl,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'من فضلك أدخل الاسم';
                                            }
                                            if (!value.trim().contains(' ')) {
                                              return 'يجب إدخال اسم أول واسم أخير';
                                            }
                                            if (value.trim().length < 5) {
                                              return 'الاسم يجب أن يكون 5 أحرف على الأقل';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: isSmallScreen ? 12 : 14),

                                        _buildInputField(
                                          controller: _emailController,
                                          label: 'البريد الإلكتروني',
                                          hint: 'example@email.com',
                                          icon: Icons.email_rounded,
                                          keyboardType: TextInputType.emailAddress,
                                          textDirection: TextDirection.ltr,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'من فضلك أدخل البريد الإلكتروني';
                                            }
                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                .hasMatch(value)) {
                                              return 'البريد الإلكتروني غير صحيح';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: isSmallScreen ? 12 : 14),

                                        _buildInputField(
                                          controller: _passwordController,
                                          label: 'كلمة المرور',
                                          hint: '••••••••',
                                          icon: Icons.lock_rounded,
                                          obscureText: _obscurePassword,
                                          textDirection: TextDirection.ltr,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: AppColors.textLight,
                                            ),
                                            onPressed: () {
                                              setState(() =>
                                                  _obscurePassword = !_obscurePassword);
                                            },
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'من فضلك أدخل كلمة المرور';
                                            }
                                            if (value.length < 6) {
                                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: isSmallScreen ? 12 : 14),

                                        _buildInputField(
                                          controller: _confirmPasswordController,
                                          label: 'تأكيد كلمة المرور',
                                          hint: '••••••••',
                                          icon: Icons.lock_rounded,
                                          obscureText: _obscureConfirmPassword,
                                          textDirection: TextDirection.ltr,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: AppColors.textLight,
                                            ),
                                            onPressed: () {
                                              setState(() => _obscureConfirmPassword =
                                                  !_obscureConfirmPassword);
                                            },
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'من فضلك أكد كلمة المرور';
                                            }
                                            if (value != _passwordController.text) {
                                              return 'كلمة المرور غير متطابقة';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: isSmallScreen ? 18 : 24),

                                        _buildPrimaryButton(
                                          onPressed: _isLoading ? null : _handleRegister,
                                          isLoading: _isLoading,
                                          text: 'إنشاء حساب',
                                        ),
                                        SizedBox(height: isSmallScreen ? 16 : 20),

                                        Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'لديك حساب بالفعل؟',
                                                style: TextStyle(
                                                  color: AppColors.textLight,
                                                  fontSize: isSmallScreen ? 13 : 14,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text(
                                                  'سجل دخول',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isSmallScreen ? 13 : 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    TextDirection? textDirection,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textDirection: textDirection,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textHint.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 10, right: 6),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 45),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String text,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

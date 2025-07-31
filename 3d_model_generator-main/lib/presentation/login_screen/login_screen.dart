import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../core/supabase_config.dart';
import './widgets/app_logo_widget.dart';
import './widgets/forgot_password_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/signup_link_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  final _supabase = SupabaseConfig.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),

                    // App Logo Section
                    const AppLogoWidget(),

                    SizedBox(height: 6.h),

                    // Error Message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.error
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'error_outline',
                              color: AppTheme.lightTheme.colorScheme.error,
                              size: 5.w,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                    ],

                    // Login Form
                    LoginFormWidget(
                      onLogin: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: 2.h),

                    // Forgot Password Link
                    ForgotPasswordWidget(
                      onForgotPassword: _handleForgotPassword,
                    ),

                    SizedBox(height: 4.h),

                    // Social Login Options
                    SocialLoginWidget(
                      onGoogleLogin: _handleGoogleLogin,
                      onAppleLogin: _handleAppleLogin,
                      isLoading: _isLoading,
                    ),

                    const Spacer(),

                    // Sign Up Link
                    SignupLinkWidget(
                      onSignUp: _handleSignUp,
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Success haptic feedback
        HapticFeedback.lightImpact();

        // Navigate to model library
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/model-library');
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Authentication failed. Please try again.';
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _errorMessage =
            'Network error. Please check your connection and try again.';
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a password reset link.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              
              try {
                await _supabase.auth.resetPasswordForEmail(email);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password reset email sent to $email'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to send reset email. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Send Reset Link',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _supabase.auth.signInWithOAuth(
        Provider.google,
        redirectTo: kIsWeb ? null : 'app.3dmodelgenerator://login-callback',
      );

      // Web will handle redirect automatically
      if (!kIsWeb) {
        HapticFeedback.lightImpact();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/model-library');
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Google login failed. Please try again.';
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _errorMessage = 'Google login failed. Please try again.';
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSignUp() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Create Account',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                if (passwordController.text != confirmPasswordController.text && 
                    confirmPasswordController.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      'Passwords do not match',
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: (passwordController.text == confirmPasswordController.text &&
                         emailController.text.isNotEmpty &&
                         passwordController.text.length >= 6)
                  ? () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      Navigator.of(context).pop();
                      await _handleSignUpWithCredentials(email, password);
                    }
                  : null,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignUpWithCredentials(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Success haptic feedback
        HapticFeedback.lightImpact();

        // Show confirmation and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! Please check your email for confirmation.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to model library after signup
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/model-library');
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Sign up failed. Please try again.';
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection and try again.';
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _supabase.auth.signInWithOAuth(
        Provider.apple,
        redirectTo: kIsWeb ? null : 'app.3dmodelgenerator://login-callback',
      );

      // Web will handle redirect automatically
      if (!kIsWeb) {
        HapticFeedback.lightImpact();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/model-library');
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Apple login failed. Please try again.';
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _errorMessage = 'Apple login failed. Please try again.';
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSignUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Up',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Sign up functionality will be available in the next version. Please use the demo credentials to explore the app.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

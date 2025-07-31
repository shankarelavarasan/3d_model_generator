import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/supabase_config.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/app_title_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _isConnected = true;
  bool _showRetryOption = false;
  String _statusMessage = 'Initializing AI Engine...';

  // Real authentication state from Supabase
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check network connectivity
      await _checkConnectivity();

      if (_isConnected) {
        // Check authentication state
        await _checkAuthState();

        // Simulate app initialization sequence
        await _performInitializationSteps();

        // Navigate based on authentication state
        await _navigateToNextScreen();
      } else {
        _showOfflineOptions();
      }
    } catch (e) {
      _handleInitializationError();
    }
  }

  Future<void> _checkAuthState() async {
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      setState(() {
        _isAuthenticated = session != null;
      });
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
      });
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        _isConnected = connectivityResult != ConnectivityResult.none;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  Future<void> _performInitializationSteps() async {
    final steps = [
      {'message': 'Loading OCR Engine...', 'duration': 800},
      {'message': 'Initializing 3D Renderer...', 'duration': 600},
      {'message': 'Preparing FreeCAD Integration...', 'duration': 700},
      {'message': 'Optimizing Performance...', 'duration': 500},
    ];

    for (final step in steps) {
      if (mounted) {
        setState(() {
          _statusMessage = step['message'] as String;
        });
        await Future.delayed(Duration(milliseconds: step['duration'] as int));
      }
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      if (_isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/model-library');
      } else {
        Navigator.pushReplacementNamed(context, '/login-screen');
      }
    }
  }

  void _showOfflineOptions() {
    setState(() {
      _statusMessage = 'Connection unavailable';
      _showRetryOption = true;
    });
  }

  void _handleInitializationError() {
    setState(() {
      _statusMessage = 'Initialization failed';
      _showRetryOption = true;
    });
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _showRetryOption = false;
      _statusMessage = 'Retrying connection...';
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    _initializeApp();
  }

  void _continueOffline() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/model-library');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          const BackgroundGradientWidget(),

          // Main content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  // Top spacer
                  SizedBox(height: 15.h),

                  // Logo section
                  const AnimatedLogoWidget(),

                  // Title section
                  SizedBox(height: 6.h),
                  const AppTitleWidget(),

                  // Spacer
                  const Spacer(),

                  // Loading section
                  _buildLoadingSection(),

                  // Bottom spacer
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    if (_showRetryOption) {
      return _buildRetrySection();
    }

    return Column(
      children: [
        const LoadingIndicatorWidget(),
        SizedBox(height: 2.h),
        Text(
          _statusMessage,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRetrySection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              CustomIconWidget(
                iconName: 'wifi_off',
                color: Colors.white.withValues(alpha: 0.8),
                size: 8.w,
              ),
              SizedBox(height: 2.h),
              Text(
                _statusMessage,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                _isConnected
                    ? 'Please try again or continue offline'
                    : 'Check your internet connection',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    'Retry',
                    Icons.refresh,
                    _retryInitialization,
                    isPrimary: true,
                  ),
                  _buildActionButton(
                    'Offline Mode',
                    Icons.offline_bolt,
                    _continueOffline,
                    isPrimary: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed,
      {required bool isPrimary}) {
    return Container(
      constraints: BoxConstraints(minWidth: 30.w),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 4.w),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.2),
          foregroundColor: isPrimary
              ? AppTheme.lightTheme.colorScheme.primary
              : Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          elevation: isPrimary ? 2 : 0,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/supabase_config.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/sign_out_button_widget.dart';
import './widgets/storage_usage_widget.dart';
import './widgets/subscription_status_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "name": "Dr. Sarah Chen",
    "email": "sarah.chen@techcorp.com",
    "avatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
    "subscription": {
      "plan": "Premium Pro",
      "status": "Active",
      "expiryDate": "2025-12-25",
    },
    "storage": {
      "used": 12.4,
      "total": 50.0,
    },
    "preferences": {
      "defaultUnits": "Millimeters",
      "autoExportFormat": "STL",
      "processingQuality": "High",
      "offlineStorageLimit": "5 GB",
    }
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 3);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        setState(() {
          userData['email'] = user.email ?? 'No email';
          userData['name'] = user.userMetadata?['full_name'] ?? 
                           user.email?.split('@')[0] ?? 'User';
          // Update with real user data if available
        });
      }
    } catch (e) {
      // Keep mock data as fallback
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlaceholderTab('Model Library'),
                  _buildPlaceholderTab('Upload'),
                  _buildPlaceholderTab('Viewer'),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: CustomIconWidget(
              iconName: 'folder',
              color: _tabController.index == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: 'Library',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'upload_file',
              color: _tabController.index == 1
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: 'Upload',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'view_in_ar',
              color: _tabController.index == 2
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: 'Viewer',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _tabController.index == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            text: 'Profile',
          ),
        ],
        labelColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        indicatorColor: AppTheme.lightTheme.colorScheme.primary,
        labelStyle: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelSmall,
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'construction',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            '$title Screen',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'This screen is under development',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeaderWidget(
            userName: userData["name"] as String,
            userEmail: userData["email"] as String,
            avatarUrl: userData["avatar"] as String?,
            onAvatarTap: _handleAvatarTap,
          ),
          SizedBox(height: 2.h),

          // Subscription Status
          SubscriptionStatusWidget(
            planName: (userData["subscription"] as Map<String, dynamic>)["plan"]
                as String,
            planStatus: (userData["subscription"]
                as Map<String, dynamic>)["status"] as String,
            expiryDate: DateTime.parse((userData["subscription"]
                as Map<String, dynamic>)["expiryDate"] as String),
            onUpgrade: _handleUpgrade,
          ),

          // Account Section
          SettingsSectionWidget(
            title: 'Account',
            items: [
              SettingsItem(
                title: 'Edit Profile',
                iconName: 'edit',
                onTap: () => _navigateToScreen('/edit-profile'),
              ),
              SettingsItem(
                title: 'Change Password',
                iconName: 'lock',
                onTap: () => _navigateToScreen('/change-password'),
              ),
              SettingsItem(
                title: 'Subscription Status',
                subtitle: (userData["subscription"]
                    as Map<String, dynamic>)["plan"] as String,
                iconName: 'card_membership',
                onTap: () => _navigateToScreen('/subscription'),
              ),
            ],
          ),

          // App Preferences Section
          SettingsSectionWidget(
            title: 'App Preferences',
            items: [
              SettingsItem(
                title: 'Default Units',
                subtitle: (userData["preferences"]
                    as Map<String, dynamic>)["defaultUnits"] as String,
                iconName: 'straighten',
                onTap: () => _showUnitsDialog(),
              ),
              SettingsItem(
                title: 'Auto-Export Format',
                subtitle: (userData["preferences"]
                    as Map<String, dynamic>)["autoExportFormat"] as String,
                iconName: 'file_download',
                onTap: () => _showExportFormatDialog(),
              ),
              SettingsItem(
                title: 'Processing Quality',
                subtitle: (userData["preferences"]
                    as Map<String, dynamic>)["processingQuality"] as String,
                iconName: 'high_quality',
                onTap: () => _showQualityDialog(),
              ),
              SettingsItem(
                title: 'Offline Storage Limit',
                subtitle: (userData["preferences"]
                    as Map<String, dynamic>)["offlineStorageLimit"] as String,
                iconName: 'storage',
                onTap: () => _showStorageLimitDialog(),
              ),
            ],
          ),

          // Cloud Storage Section
          StorageUsageWidget(
            usedStorage:
                (userData["storage"] as Map<String, dynamic>)["used"] as double,
            totalStorage: (userData["storage"] as Map<String, dynamic>)["total"]
                as double,
            onManageStorage: () => _navigateToScreen('/manage-storage'),
          ),

          // Support Section
          SettingsSectionWidget(
            title: 'Support',
            items: [
              SettingsItem(
                title: 'Help Center',
                iconName: 'help',
                onTap: () => _navigateToScreen('/help'),
              ),
              SettingsItem(
                title: 'Contact Support',
                iconName: 'support_agent',
                onTap: () => _navigateToScreen('/contact-support'),
              ),
              SettingsItem(
                title: 'Rate App',
                iconName: 'star_rate',
                onTap: () => _handleRateApp(),
              ),
              SettingsItem(
                title: 'Share App',
                iconName: 'share',
                onTap: () => _handleShareApp(),
              ),
            ],
          ),

          // Privacy Section
          SettingsSectionWidget(
            title: 'Privacy',
            items: [
              SettingsItem(
                title: 'Data Usage',
                iconName: 'data_usage',
                onTap: () => _navigateToScreen('/data-usage'),
              ),
              SettingsItem(
                title: 'Privacy Policy',
                iconName: 'privacy_tip',
                onTap: () => _navigateToScreen('/privacy-policy'),
              ),
              SettingsItem(
                title: 'Terms of Service',
                iconName: 'description',
                onTap: () => _navigateToScreen('/terms-of-service'),
              ),
            ],
          ),

          // Sign Out Button
          SignOutButtonWidget(
            onSignOut: _handleSignOut,
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      // Navigation will be handled by the auth state listener in main.dart
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _handleAvatarTap() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Profile Picture',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: 'camera_alt',
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _handleCameraCapture();
                  },
                ),
                _buildImageOption(
                  icon: 'photo_library',
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _handleGallerySelection();
                  },
                ),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCameraCapture() {
    // Camera capture implementation would go here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Camera capture functionality'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _handleGallerySelection() {
    // Gallery selection implementation would go here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gallery selection functionality'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _handleUpgrade() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upgrade to Premium Pro'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Default Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Millimeters', 'Inches']
              .map(
                (unit) => RadioListTile<String>(
                  title: Text(unit),
                  value: unit,
                  groupValue: (userData["preferences"]
                      as Map<String, dynamic>)["defaultUnits"],
                  onChanged: (value) {
                    setState(() {
                      (userData["preferences"]
                          as Map<String, dynamic>)["defaultUnits"] = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showExportFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Auto-Export Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['STL', 'GLB', 'FBX', 'IGES', 'STEP']
              .map(
                (format) => RadioListTile<String>(
                  title: Text(format),
                  value: format,
                  groupValue: (userData["preferences"]
                      as Map<String, dynamic>)["autoExportFormat"],
                  onChanged: (value) {
                    setState(() {
                      (userData["preferences"]
                          as Map<String, dynamic>)["autoExportFormat"] = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Processing Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Low', 'Medium', 'High', 'Ultra']
              .map(
                (quality) => RadioListTile<String>(
                  title: Text(quality),
                  value: quality,
                  groupValue: (userData["preferences"]
                      as Map<String, dynamic>)["processingQuality"],
                  onChanged: (value) {
                    setState(() {
                      (userData["preferences"]
                              as Map<String, dynamic>)["processingQuality"] =
                          value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showStorageLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Offline Storage Limit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['1 GB', '2 GB', '5 GB', '10 GB']
              .map(
                (limit) => RadioListTile<String>(
                  title: Text(limit),
                  value: limit,
                  groupValue: (userData["preferences"]
                      as Map<String, dynamic>)["offlineStorageLimit"],
                  onChanged: (value) {
                    setState(() {
                      (userData["preferences"]
                              as Map<String, dynamic>)["offlineStorageLimit"] =
                          value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _handleRateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening app store for rating'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _handleShareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing 3D Model Generator app'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _handleSignOut() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-screen',
      (route) => false,
    );
  }

  void _navigateToScreen(String route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $route'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }
}

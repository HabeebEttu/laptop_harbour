import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laptop_harbour/providers/admin_provider.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:laptop_harbour/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _profileAnimationController;
  late AnimationController _menuAnimationController;
  late Animation<double> _profileScaleAnimation;
  late Animation<Offset> _menuSlideAnimation;
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _profileScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _profileAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _menuSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _menuAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _menuAnimationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _profileAnimationController.dispose();
    _menuAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();

    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImageSourceSelector(),
    );

    if (result != null) {
      setState(() => _isImageUploading = true);

      final picker = ImagePicker();
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      try {
        final pickedFile = await picker.pickImage(
          source: result,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          await userProvider.updateProfilePicture(bytes);

          if (mounted) {
            _showSuccessSnackBar('Profile picture updated successfully!');
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Failed to update profile picture: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isImageUploading = false);
        }
      }
    }
  }

  Widget _buildImageSourceSelector() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          _buildImageSourceOption(
            icon: Icons.camera_alt,
            title: 'Camera',
            subtitle: 'Take a new photo',
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          _buildImageSourceOption(
            icon: Icons.photo_library,
            title: 'Gallery',
            subtitle: 'Choose from gallery',
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.scaffoldBackgroundColor
          : theme.colorScheme.surface,
      appBar: _buildAppBar(
        Provider.of<UserProvider>(context, listen: false).userProfile,
      ),
      body: Consumer2<UserProvider, AdminProvider>(
        builder: (context, userProvider, adminProvider, child) {
          final userProfile = userProvider.userProfile;
          final isLoggedIn = userProfile?.email != null;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 20,
                vertical: 20,
              ),
              child: Column(
                children: [
                  // Profile Card
                  AnimatedBuilder(
                    animation: _profileScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _profileScaleAnimation.value,
                        child: _buildProfileCard(userProfile, isLoggedIn),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Menu Items
                  AnimatedBuilder(
                    animation: _menuSlideAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _menuSlideAnimation,
                        child: FadeTransition(
                          opacity: _menuAnimationController,
                          child: _buildMenuSection(adminProvider, isLoggedIn),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  if (isLoggedIn)
                    AnimatedBuilder(
                      animation: _menuAnimationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            (1 - _menuAnimationController.value) * 50,
                          ),
                          child: Opacity(
                            opacity: _menuAnimationController.value,
                            child: _buildLogoutButton(),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(dynamic userProfile) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(
        'Profile',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      centerTitle: true,
      backgroundColor: isDarkMode
          ? theme.appBarTheme.backgroundColor
          : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            if (userProfile.email.isNotEmpty) {
              Navigator.pushNamed(context, '/settings');
            } else {
              _showErrorSnackBar('SignIn to see profile');
            }
          },
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildProfileCard(dynamic userProfile, bool isLoggedIn) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Profile Avatar
            _buildProfileAvatar(userProfile),

            const SizedBox(height: 24),

            // User Info
            Text(
              isLoggedIn
                  ? '${userProfile.firstName} ${userProfile.lastName}'
                  : 'Welcome, Guest',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              userProfile?.email ?? 'Sign in to access all features',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Action Button
            _buildActionButton(isLoggedIn),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(dynamic userProfile) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            backgroundImage: (userProfile?.profilePic?.isNotEmpty ?? false)
                ? NetworkImage(userProfile!.profilePic!)
                : null,
            child: !(userProfile?.profilePic?.isNotEmpty ?? false)
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  )
                : null,
          ),
        ),

        // Edit Button
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode
                      ? theme.scaffoldBackgroundColor
                      : Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isImageUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const FaIcon(
                      FontAwesomeIcons.camera,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool isLoggedIn) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          if (isLoggedIn) {
            Navigator.pushNamed(context, '/settings');
          } else {
            Navigator.pushNamed(context, '/signin');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: Icon(isLoggedIn ? Icons.edit : Icons.login),
        label: Text(
          isLoggedIn ? 'Edit Profile' : 'Sign In',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildMenuSection(AdminProvider adminProvider, bool isLoggedIn) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final profileButtons = _getProfileButtons(isLoggedIn);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Admin Section
          if (adminProvider.isAdmin && isLoggedIn) _buildAdminSection(),

          // Menu Items
          ...profileButtons.asMap().entries.map((entry) {
            final index = entry.key;
            final button = entry.value;
            final isLast = index == profileButtons.length - 1;

            return _buildMenuItem(
              icon: button['icon'],
              title: button['title'],
              subtitle: button['subtitle'],
              route: button['url'],
              showDivider: !isLast,
              color: button['color'],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAdminSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Admin Access',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        _buildMenuItem(
          icon: Icons.dashboard,
          title: 'Admin Dashboard',
          subtitle: 'Manage products and orders',
          route: '/admin_dashboard',
          showDivider: true,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required String route,
    bool showDivider = false,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              if (route.isNotEmpty) {
                Navigator.pushNamed(context, route);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (color ?? theme.primaryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color ?? theme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
            ),
          ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(isDarkMode ? 0.3 : 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();

            final result = await showDialog<bool>(
              context: context,
              builder: (context) => _buildLogoutDialog(),
            );

            if (result == true) {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/signin',
                  (route) => false,
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutDialog() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? theme.cardColor : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Sign Out',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: Text(
        'Are you sure you want to sign out?',
        style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getProfileButtons(bool isLoggedIn) {
    if (!isLoggedIn) {
      return [
        {
          'icon': Icons.info_outline,
          'title': 'About App',
          'subtitle': 'Learn more about Laptop Harbour',
          'url': '/about',
          'color': Colors.blue,
        },
        {
          'icon': Icons.help_outline,
          'title': 'Help & Support',
          'subtitle': 'Get help and contact support',
          'url': '/help',
          'color': Colors.green,
        },
      ];
    }

    return [
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'Order History',
        'subtitle': 'View your past orders',
        'url': '/orders',
        'color': Colors.blue,
      },
      {
        'icon': Icons.favorite_border,
        'title': 'Wishlist',
        'subtitle': 'Your saved items',
        'url': '/wishlist',
        'color': Colors.pink,
      },
      {
        'icon': Icons.lock_outline,
        'title': 'Security',
        'subtitle': 'Change password and security settings',
        'url': '/change_password',
        'color': Colors.orange,
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'subtitle': 'Manage your notification preferences',
        'url': '/notifications',
        'color': Colors.purple,
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'subtitle': 'Get help and contact support',
        'url': '/help',
        'color': Colors.green,
      },
    ];
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

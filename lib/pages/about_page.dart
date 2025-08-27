import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _headerScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Header animation controller
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animations
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );

    _headerScaleAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    );

    // Start animations
    _animationController.forward();
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
            fontSize: 18,
          ),
        ),
        backgroundColor: colorScheme.primary.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Animated Header Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.8),
                          ]
                        : [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.7),
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : 20,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        AnimatedBuilder(
                          animation: _headerScaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.8 + (_headerScaleAnimation.value * 0.2),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colorScheme.onPrimary.withOpacity(
                                    0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.laptop_mac_rounded,
                                  size: isDesktop ? 60 : 50,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'About Laptop Harbour',
                          style: TextStyle(
                            fontSize: isDesktop ? 36 : 32,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your trusted destination for premium laptops and exceptional service',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            color: colorScheme.onPrimary.withOpacity(0.9),
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content with slide animation
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_slideAnimation),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 20,
                    vertical: 30,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mission Section
                        _buildSection(
                          'Our Mission',
                          'At Laptop Harbour, we believe that everyone deserves access to high-quality technology that empowers their work, creativity, and daily life. Our mission is to provide carefully curated laptops, expert guidance, and exceptional customer service to help you find the perfect device for your unique needs.',
                          Icons.rocket_launch_rounded,
                          theme,
                        ),

                        const SizedBox(height: 40),

                        // Story Section
                        _buildSection(
                          'Our Story',
                          'Founded in 2020, Laptop Harbour started as a small tech enthusiast\'s vision to bridge the gap between consumers and quality laptops. What began as a passion project has grown into a trusted platform serving thousands of customers worldwide. We\'ve maintained our commitment to personalized service while expanding our expertise and product range.',
                          Icons.history_rounded,
                          theme,
                        ),

                        const SizedBox(height: 40),

                        // Values Section
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? colorScheme.surface.withOpacity(0.7)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(
                                  isDark ? 0.3 : 0.1,
                                ),
                                spreadRadius: 0,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.favorite_rounded,
                                        color: colorScheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Our Values',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 24 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                if (isDesktop)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildValueCard(
                                          'Quality',
                                          'We partner only with trusted brands and thoroughly test every product.',
                                          Icons.verified_rounded,
                                          theme,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildValueCard(
                                          'Expertise',
                                          'Our team provides knowledgeable guidance to help you make informed decisions.',
                                          Icons.psychology_rounded,
                                          theme,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildValueCard(
                                          'Service',
                                          'We\'re committed to exceptional customer support before, during, and after your purchase.',
                                          Icons.support_agent_rounded,
                                          theme,
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _buildValueCard(
                                    'Quality',
                                    'We partner only with trusted brands and thoroughly test every product.',
                                    Icons.verified_rounded,
                                    theme,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildValueCard(
                                    'Expertise',
                                    'Our team provides knowledgeable guidance to help you make informed decisions.',
                                    Icons.psychology_rounded,
                                    theme,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildValueCard(
                                    'Service',
                                    'We\'re committed to exceptional customer support before, during, and after your purchase.',
                                    Icons.support_agent_rounded,
                                    theme,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Team Section
                        _buildSection(
                          'Our Team',
                          'Behind Laptop Harbour is a dedicated team of technology enthusiasts, customer service specialists, and industry experts. We bring together years of experience in hardware, software, and customer relations to ensure you receive the best possible service and product recommendations.',
                          Icons.groups_rounded,
                          theme,
                        ),

                        const SizedBox(height: 40),

                        // Statistics Section
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      colorScheme.primary.withOpacity(0.1),
                                      colorScheme.primary.withOpacity(0.05),
                                    ]
                                  : [
                                      colorScheme.primary.withOpacity(0.08),
                                      colorScheme.primary.withOpacity(0.03),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Text(
                                  'By the Numbers',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                if (isDesktop)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          '10,000+',
                                          'Happy Customers',
                                          theme,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildStatCard(
                                          '500+',
                                          'Laptop Models',
                                          theme,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildStatCard(
                                          '4+ Years',
                                          'In Business',
                                          theme,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildStatCard(
                                          '98%',
                                          'Satisfaction Rate',
                                          theme,
                                        ),
                                      ),
                                    ],
                                  )
                                else if (isTablet)
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatCard(
                                              '10,000+',
                                              'Happy Customers',
                                              theme,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildStatCard(
                                              '500+',
                                              'Laptop Models',
                                              theme,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatCard(
                                              '4+ Years',
                                              'In Business',
                                              theme,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildStatCard(
                                              '98%',
                                              'Satisfaction Rate',
                                              theme,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                else ...[
                                  _buildStatCard(
                                    '10,000+',
                                    'Happy Customers',
                                    theme,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatCard(
                                    '500+',
                                    'Laptop Models',
                                    theme,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatCard(
                                    '4+ Years',
                                    'In Business',
                                    theme,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatCard(
                                    '98%',
                                    'Satisfaction Rate',
                                    theme,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Contact CTA Section
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? colorScheme.surface.withOpacity(0.7)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(
                                  isDark ? 0.3 : 0.1,
                                ),
                                spreadRadius: 0,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.connect_without_contact_rounded,
                                  size: 48,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Ready to Find Your Perfect Laptop?',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Get in touch with our expert team for personalized recommendations and exceptional service.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: isDesktop ? 200 : double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/contact');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      elevation: isDark ? 2 : 1,
                                      shadowColor: colorScheme.shadow
                                          .withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Contact Us',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Footer
                        Center(
                          child: Text(
                            '© 2024 Laptop Harbour. All rights reserved.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onBackground.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content,
    IconData icon,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withOpacity(0.7)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(
    String title,
    String description,
    IconData icon,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, size: 32, color: colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatCard(String number, String label, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

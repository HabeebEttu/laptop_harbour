import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/pages/order_details_page.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbour/providers/order_provider.dart';

// Breakpoint constants for responsive design
class Breakpoints {
  static const double mobile = 0;
  static const double tablet = 600;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;
}

// Screen size utility class
class ScreenSize {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.tablet;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.tablet &&
      MediaQuery.of(context).size.width < Breakpoints.desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.desktop;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.largeDesktop;
}

class OrderCard extends StatefulWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.order.status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade600;
      case 'processing':
        return Colors.blue.shade600;
      case 'shipped':
        return Colors.purple.shade600;
      case 'delivered':
        return Colors.green.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.order.status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'processing':
        return Icons.settings_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OrderDetailsPage(order: widget.order),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isMobile = ScreenSize.isMobile(context);
    final isTablet = ScreenSize.isTablet(context);
    final isDesktop = ScreenSize.isDesktop(context);

    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₦',
      decimalDigits: 2,
    );

    // Responsive sizing
    final cardPadding = isMobile
        ? const EdgeInsets.all(16)
        : isTablet
        ? const EdgeInsets.all(20)
        : const EdgeInsets.all(24);

    final cardMargin = isMobile
        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 16)
        : isTablet
        ? const EdgeInsets.symmetric(vertical: 10, horizontal: 20)
        : const EdgeInsets.symmetric(vertical: 12, horizontal: 24);

    final titleFontSize = isMobile
        ? 15.0
        : isTablet
        ? 16.0
        : 17.0;
    final bodyFontSize = isMobile
        ? 14.0
        : isTablet
        ? 15.0
        : 16.0;
    final captionFontSize = isMobile
        ? 13.0
        : isTablet
        ? 14.0
        : 15.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: cardMargin,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleTap,
                  onTapDown: (_) => _animationController.forward(),
                  onTapUp: (_) => _animationController.reverse(),
                  onTapCancel: () => _animationController.reverse(),
                  onHover: (isHovered) {
                    setState(() {
                      _isHovered = isHovered;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.blue.withOpacity(0.1),
                  highlightColor: Colors.blue.withOpacity(0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: cardPadding,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                            : [Colors.white, const Color(0xFFFAFAFA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isHovered
                            ? Colors.blue.withOpacity(0.3)
                            : isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                        width: _isHovered ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: _isHovered ? 20 : 12,
                          offset: _isHovered
                              ? const Offset(0, 8)
                              : const Offset(0, 4),
                          spreadRadius: _isHovered ? -2 : -4,
                        ),
                        if (_isHovered)
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: -2,
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        _buildHeaderSection(
                          isDarkMode,
                          titleFontSize,
                          captionFontSize,
                          isDesktop,
                        ),

                        SizedBox(height: isMobile ? 16 : 20),

                        // Order Details Grid
                        _buildOrderDetails(
                          currencyFormatter,
                          bodyFontSize,
                          captionFontSize,
                          isDarkMode,
                          isMobile,
                          isTablet,
                        ),

                        SizedBox(height: isMobile ? 12 : 16),

                        // Footer Section
                        _buildFooterSection(
                          bodyFontSize,
                          captionFontSize,
                          isDarkMode,
                          isDesktop,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(
    bool isDarkMode,
    double titleFontSize,
    double captionFontSize,
    bool isDesktop,
  ) {
    return Row(
      children: [
        // Order Icon
        Container(
          padding: EdgeInsets.all(isDesktop ? 12 : 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.15),
                Colors.blue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: Colors.blue.shade400,
            size: isDesktop ? 24 : 20,
          ),
        ),

        SizedBox(width: isDesktop ? 16 : 12),

        // Order ID and Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Order #${widget.order.orderId.substring(0, 8).toUpperCase()}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: titleFontSize,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  _buildStatusBadge(captionFontSize),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Tap to view details",
                style: GoogleFonts.poppins(
                  fontSize: captionFontSize - 1,
                  color: isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(double fontSize) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 6),
          Text(
            widget.order.status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: fontSize - 1,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(
    NumberFormat currencyFormatter,
    double bodyFontSize,
    double captionFontSize,
    bool isDarkMode,
    bool isMobile,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey.shade900.withOpacity(0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: isMobile
          ? Column(
              children: [
                _buildDetailRow(
                  Icons.calendar_today_rounded,
                  "Order Date",
                  DateFormat.yMMMd().format(widget.order.orderDate),
                  bodyFontSize,
                  captionFontSize,
                  isDarkMode,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.attach_money_rounded,
                  "Total Amount",
                  currencyFormatter.format(widget.order.totalPrice),
                  bodyFontSize,
                  captionFontSize,
                  isDarkMode,
                  isAmount: true,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.shopping_bag_rounded,
                  "Items",
                  "${widget.order.items.length} items",
                  bodyFontSize,
                  captionFontSize,
                  isDarkMode,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    Icons.calendar_today_rounded,
                    "Order Date",
                    DateFormat.yMMMd().format(widget.order.orderDate),
                    bodyFontSize,
                    captionFontSize,
                    isDarkMode,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: _buildDetailRow(
                    Icons.attach_money_rounded,
                    "Total",
                    currencyFormatter.format(widget.order.totalPrice),
                    bodyFontSize,
                    captionFontSize,
                    isDarkMode,
                    isAmount: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: _buildDetailRow(
                    Icons.shopping_bag_rounded,
                    "Items",
                    "${widget.order.items.length} items",
                    bodyFontSize,
                    captionFontSize,
                    isDarkMode,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    double bodyFontSize,
    double captionFontSize,
    bool isDarkMode, {
    bool isAmount = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: captionFontSize,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: bodyFontSize,
            fontWeight: isAmount ? FontWeight.w700 : FontWeight.w600,
            color: isAmount
                ? Colors.blue.shade600
                : (isDarkMode ? Colors.white : Colors.black87),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooterSection(
    double bodyFontSize,
    double captionFontSize,
    bool isDarkMode,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 12,
        vertical: isDesktop ? 12 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.05),
            Colors.blue.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: isDesktop ? 20 : 18,
            color: Colors.blue.shade400,
          ),
          SizedBox(width: isDesktop ? 12 : 10),
          Expanded(
            child: Text(
              "Tap to view order details and tracking information",
              style: GoogleFonts.poppins(
                fontSize: captionFontSize,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: isDesktop ? 16 : 14,
            color: Colors.blue.shade400,
          ),
        ],
      ),
    );
  }
}

class OrdersList extends StatefulWidget {
  const OrdersList({super.key});

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedFilter = 'all';
  final List<String> _filterOptions = [
    'all',
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Order> _getFilteredOrders(List<Order> orders) {
    if (_selectedFilter == 'all') return orders;
    return orders
        .where(
          (order) =>
              order.status.toLowerCase() == _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isMobile = ScreenSize.isMobile(context);
    final isTablet = ScreenSize.isTablet(context);
    final isDesktop = ScreenSize.isDesktop(context);

    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return _buildLoadingState(isDarkMode, isMobile);
        }

        if (orderProvider.orders.isEmpty) {
          return _buildEmptyState(isDarkMode, isMobile, isTablet);
        }

        final filteredOrders = _getFilteredOrders(orderProvider.orders);

        return Column(
          children: [
            // Filter Section
            _buildFilterSection(isDarkMode, isMobile, isDesktop),

            // Orders List
            Expanded(
              child: filteredOrders.isEmpty
                  ? _buildNoResultsState(isDarkMode, isMobile)
                  : RefreshIndicator(
                      onRefresh: () async {
                        HapticFeedback.lightImpact();
                        // Add your refresh logic here
                        await orderProvider.fetchOrders();
                      },
                      color: Colors.blue.shade400,
                      child: _buildOrdersList(filteredOrders, isDesktop),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection(bool isDarkMode, bool isMobile, bool isDesktop) {
    return Container(
      height: isMobile ? 60 : 70,
      margin: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 16
            : isDesktop
            ? 24
            : 20,
        vertical: 8,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter != 'all') ...[
                    Icon(
                      _getFilterIcon(filter),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    filter == 'all' ? 'All Orders' : filter.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                ],
              ),
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: Colors.blue.shade400,
              backgroundColor: isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.blue.shade400 : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'processing':
        return Icons.settings_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Widget _buildOrdersList(List<Order> orders, bool isDesktop) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final animationValue = Curves.easeOutCubic.transform(
              (_animationController.value - (index * 0.1)).clamp(0.0, 1.0),
            );

            return Transform.translate(
              offset: Offset(0, 50 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: OrderCard(order: orders[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDarkMode, bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            strokeWidth: 3,
          ),
          SizedBox(height: isMobile ? 20 : 24),
          Text(
            'Loading your orders...',
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
              fontSize: isMobile ? 16 : 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, bool isMobile, bool isTablet) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 32 : 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.blue.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: isMobile ? 80 : 100,
                      color: Colors.blue.shade300,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: isMobile ? 32 : 40),

            Text(
              'No orders yet',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),

            SizedBox(height: isMobile ? 12 : 16),

            Text(
              'Start shopping to see your orders here.\nYour order history will appear once\nyou make your first purchase.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 16 : 18,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(bool isDarkMode, bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: isMobile ? 60 : 80,
              color: Colors.grey.shade400,
            ),

            SizedBox(height: isMobile ? 16 : 24),

            Text(
              'No ${_selectedFilter} orders',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),

            SizedBox(height: isMobile ? 8 : 12),

            Text(
              'Try selecting a different filter to see more orders.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 14 : 16,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:laptop_harbour/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: isDark ? Colors.white : Colors.black87,
        unselectedItemColor: isDark
            ? Colors.grey.shade400
            : Colors.grey.shade600,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: isDark ? Colors.white : Colors.black87,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              isSelected: currentIndex == 0,
              isDark: isDark,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
              isSelected: currentIndex == 1,
              isDark: isDark,
            ),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cart, child) {
                return _CartNavIcon(
                  isSelected: currentIndex == 2,
                  isDark: isDark,
                  itemCount: cart.cart!.items.length,
                );
              },
            ),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.list_alt_outlined,
              activeIcon: Icons.list_alt,
              isSelected: currentIndex == 3,
              isDark: isDark,
            ),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              isSelected: currentIndex == 4,
              isDark: isDark,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final bool isDark;

  const _NavIcon({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade100)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isSelected ? activeIcon : icon,
        size: 24,
        color: isSelected
            ? (isDark ? Colors.white : Colors.black87)
            : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
      ),
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  final bool isSelected;
  final bool isDark;
  final int itemCount;

  const _CartNavIcon({
    required this.isSelected,
    required this.isDark,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade100)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            isSelected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
            size: 24,
            color: isSelected
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          if (itemCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    width: 2,
                  ),
                ),
                child: Text(
                  itemCount > 99 ? '99+' : itemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

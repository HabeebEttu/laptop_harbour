import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/services/user_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;

  String _searchQuery = '';
  String _roleFilter = 'All';
  bool _isProcessing = false;

  final List<String> _roleFilters = ['All', 'Admin', 'Customer'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Profile> _filterUsers(List<Profile> users) {
    var filteredUsers = users;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredUsers = filteredUsers
          .where(
            (user) =>
                user.firstName.toLowerCase().contains(_searchQuery) ||
                user.lastName.toLowerCase().contains(_searchQuery) ||
                user.email.toLowerCase().contains(_searchQuery) ||
                '${user.firstName} ${user.lastName}'.toLowerCase().contains(
                  _searchQuery,
                ),
          )
          .toList();
    }

    // Apply role filter
    if (_roleFilter != 'All') {
      filteredUsers = filteredUsers
          .where((user) => user.role.toLowerCase() == _roleFilter.toLowerCase())
          .toList();
    }

    return filteredUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // Role Filter
                Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _roleFilter,
                        decoration: InputDecoration(
                          labelText: 'Filter by Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _roleFilters
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Row(
                                  children: [
                                    _getRoleIcon(role),
                                    const SizedBox(width: 8),
                                    Text(role),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _roleFilter = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: StreamBuilder<List<Profile>>(
              stream: _userService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(() => setState(() {}));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredUsers = _filterUsers(snapshot.data!);

                if (filteredUsers.isEmpty &&
                    (_searchQuery.isNotEmpty || _roleFilter != 'All')) {
                  return _buildNoResultsState();
                }

                return _buildUsersList(filteredUsers);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading users...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Failed to load users. Please check your connection and try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No users found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Users will appear here once they register',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'No users match the selected role filter',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _roleFilter = 'All';
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(List<Profile> users) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop/Tablet: Grid view
          return _buildGridView(users);
        } else {
          // Mobile: List view
          return _buildListView(users);
        }
      },
    );
  }

  Widget _buildGridView(List<Profile> users) {
    return LayoutBuilder(
      
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth > 1200 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(user, index);
            },
          ),
        );
      }
    );
  }

  Widget _buildListView(List<Profile> users) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        index * 0.05,
                        1.0,
                        curve: Curves.easeOutQuart,
                      ),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(index * 0.05, 1.0, curve: Curves.easeOut),
                ),
                child: _buildUserTile(user),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(Profile user, int index) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToUserDetails(user),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildUserAvatar(user, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _buildRoleBadge(user.role),
                  const Spacer(),
                  if (user.isBlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'BLOCKED',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [_buildActionMenu(user)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(Profile user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildUserAvatar(user),
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRoleBadge(user.role),
                const SizedBox(width: 8),
                if (user.isBlocked) _buildBlockedBadge(),
              ],
            ),
          ],
        ),
        trailing: _buildActionMenu(user),
        onTap: () => _navigateToUserDetails(user),
      ),
    );
  }

  Widget _buildUserAvatar(Profile user, {double size = 56}) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _getAvatarColor(user.firstName),
      child: Text(
        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    // Generate consistent color based on name
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.red,
    ];
    return colors[name.hashCode % colors.length];
  }

  Widget _buildRoleBadge(String role) {
    final isAdmin = role == 'Admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            size: 14,
            color: isAdmin
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            role,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isAdmin
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block,
            size: 14,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'BLOCKED',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(Profile user) {
    return PopupMenuButton<String>(
      enabled: !_isProcessing,
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('Edit User'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'role',
          child: Row(
            children: [
              Icon(
                user.role == 'Admin'
                    ? Icons.person
                    : Icons.admin_panel_settings,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(user.role == 'Admin' ? 'Make Customer' : 'Make Admin'),
            ],
          ),
        ),
        PopupMenuItem(
          value: user.isBlocked ? 'unblock' : 'block',
          child: Row(
            children: [
              Icon(
                user.isBlocked ? Icons.check_circle : Icons.block,
                size: 18,
                color: user.isBlocked
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                user.isBlocked ? 'Unblock User' : 'Block User',
                style: TextStyle(
                  color: user.isBlocked
                      ? null
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) => _handleUserAction(value, user),
    );
  }

  Icon _getRoleIcon(String role) {
    switch (role) {
      case 'Admin':
        return const Icon(Icons.admin_panel_settings, size: 18);
      case 'Customer':
        return const Icon(Icons.person, size: 18);
      default:
        return const Icon(Icons.people, size: 18);
    }
  }

  Future<void> _handleUserAction(String action, Profile user) async {
    HapticFeedback.selectionClick();

    setState(() => _isProcessing = true);

    try {
      switch (action) {
        case 'edit':
          _navigateToEditUser(user);
          break;

        case 'role':
          final newRole = user.role == 'Admin' ? 'Customer' : 'Admin';
          final confirmed = await _showRoleChangeDialog(user, newRole);
          if (confirmed == true) {
            await _userService.updateUserRole(user.uid, newRole);
            _showSuccessSnackBar('User role updated to $newRole');
          }
          break;

        case 'block':
          final confirmed = await _showBlockDialog(user, true);
          if (confirmed == true) {
            await _userService.blockUser(user.id);
            _showSuccessSnackBar('User blocked successfully');
          }
          break;

        case 'unblock':
          final confirmed = await _showBlockDialog(user, false);
          if (confirmed == true) {
            await _userService.unblockUser(user.id);
            _showSuccessSnackBar('User unblocked successfully');
          }
          break;
      }
    } catch (e) {
      _showErrorSnackBar('Failed to perform action: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<bool?> _showRoleChangeDialog(Profile user, String newRole) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_horizontal_circle,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Change ${user.firstName} ${user.lastName}\'s role from ${user.role} to $newRole?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              newRole == 'Admin'
                  ? 'This user will gain administrative privileges.'
                  : 'This user will lose administrative privileges.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Change Role'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showBlockDialog(Profile user, bool isBlocking) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBlocking ? 'Block User' : 'Unblock User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBlocking ? Icons.block : Icons.check_circle,
              size: 48,
              color: isBlocking
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isBlocking
                  ? 'Block ${user.firstName} ${user.lastName}?'
                  : 'Unblock ${user.firstName} ${user.lastName}?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isBlocking
                  ? 'This user will be unable to access the application.'
                  : 'This user will regain access to the application.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isBlocking
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isBlocking
                ? ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            child: Text(isBlocking ? 'Block User' : 'Unblock User'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToUserDetails(Profile user) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UserDetailsPage(user: user), // Replace with your details page
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToEditUser(Profile user) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditUserPage(user: user), // Replace with your edit page
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
            ),
            child: child,
          );
        },
      ),
    );
  }
}

// Placeholder classes - replace with your actual implementations
class UserDetailsPage extends StatelessWidget {
  final Profile user;
  const UserDetailsPage({super.key, required this.user});
  @override
  Widget build(BuildContext context) => Scaffold();
}

class EditUserPage extends StatelessWidget {
  final Profile user;
  const EditUserPage({super.key, required this.user});
  @override
  Widget build(BuildContext context) => Scaffold();
}

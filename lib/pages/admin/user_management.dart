import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/services/user_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserService _userService = UserService();
  String _searchQuery = '';
  String _roleFilter = 'All';

  final List<String> _roleFilters = ['All', 'Admin', 'Customer'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _roleFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Role',
                    border: InputBorder.none,
                  ),
                  items: _roleFilters
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
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
        ),
      ),
      body: StreamBuilder<List<Profile>>(
        stream: _userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          var users = snapshot.data!;

          // Apply filters
          if (_searchQuery.isNotEmpty) {
            users = users
                .where((user) =>
                    user.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    user.email.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }

          if (_roleFilter != 'All') {
            users = users.where((user) => user.role == _roleFilter).toList();
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.firstName[0].toUpperCase()),
                  ),
                  title: Text('${user.firstName} ${user.lastName}'),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.role,
                        style: TextStyle(
                          color: user.role == 'Admin' ? Colors.blue : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit User'),
                          ),
                          PopupMenuItem(
                            value: 'role',
                            child: Text(
                                user.role == 'Admin' ? 'Make Customer' : 'Make Admin'),
                          ),
                          PopupMenuItem(
                            value: user.isBlocked ? 'unblock' : 'block',
                            child: Text(user.isBlocked ? 'Unblock User' : 'Block User'),
                          ),
                        ],
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              // Navigate to edit user page
                              break;
                            case 'role':
                              await _userService.updateUserRole(
                                user.uid,
                                user.role == 'Admin' ? 'Customer' : 'Admin',
                              );
                              break;
                            case 'block':
                              await _userService.blockUser(user.id);
                              break;
                            case 'unblock':
                              await _userService.unblockUser(user.id);
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to user details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

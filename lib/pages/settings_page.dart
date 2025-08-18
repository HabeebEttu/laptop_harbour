import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/bottom_nav_bar.dart';
import 'package:laptop_harbour/components/header.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/pages/cart_page.dart';
import 'package:laptop_harbour/pages/home_page.dart';
import 'package:laptop_harbour/pages/orders_page.dart';
import 'package:laptop_harbour/pages/profile_page.dart';
import 'package:laptop_harbour/pages/wish_list.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 4;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    if (userProvider.userProfile != _profile) {
      _profile = userProvider.userProfile;
      _firstNameController.text = _profile?.firstName ?? '';
      _lastNameController.text = _profile?.lastName ?? '';
      _emailController.text = _profile?.email ?? '';
      _phoneNumberController.text = _profile?.phoneNumber ?? '';
      _addressController.text = _profile?.address ?? '';
      _cityController.text = _profile?.city ?? '';
      _postalCodeController.text = _profile?.postalCode ?? '';
      _countryController.text = _profile?.country ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const WishList()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const CartPage()));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const OrdersPage()));
        break;
      case 4:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const ProfilePage()));
        break;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to update your profile.')),
      );
      return;
    }

    final updatedProfile = Profile(
      uid: authProvider.user!.uid,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      country: _countryController.text.trim(),
    );

    try {
      await userProvider.updateUserProfile(updatedProfile);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',style: Theme.of(context).textTheme.headlineMedium,),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Settings',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildLabel('First Name'),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _firstNameController,
                    hintText: 'Enter your first name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Last Name'),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _lastNameController,
                    hintText: 'Enter your last name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Email Address'),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'example@gmail.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _phoneNumberController,
                    hintText: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Address'),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _addressController,
                    hintText: 'Enter your address',
                    icon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('City'),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _cityController,
                    hintText: 'Enter your city',
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Postal Code'),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _postalCodeController,
                    hintText: 'Enter your postal code',
                    icon: Icons.local_post_office_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Country'),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _countryController,
                    hintText: 'Enter your country',
                    icon: Icons.public_outlined,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255 * 0.08).round()),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

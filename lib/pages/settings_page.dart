import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/header.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;

    _firstNameController = TextEditingController(text: profile?.firstName ?? '');
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneNumberController = TextEditingController(text: profile?.phoneNumber ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
    _postalCodeController = TextEditingController(text: profile?.postalCode ?? '');
    _countryController = TextEditingController(text: profile?.country ?? '');
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to update your profile.')),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = userProvider.userProfile!;
          // Update controllers if profile changes (e.g., after initial fetch)
          _firstNameController.text = profile.firstName;
          _lastNameController.text = profile.lastName;
          _emailController.text = profile.email;
          _phoneNumberController.text = profile.phoneNumber ?? '';
          _addressController.text = profile.address ?? '';
          _cityController.text = profile.city ?? '';
          _postalCodeController.text = profile.postalCode ?? '';
          _countryController.text = profile.country ?? '';

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
                  _buildTextFormField(
                    controller: _firstNameController,
                    labelText: 'First Name',
                    validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _lastNameController,
                    labelText: 'Last Name',
                    validator: (value) => value!.isEmpty ? 'Please enter your last name' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter your email';
                      if (!value.contains('@')) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _phoneNumberController,
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _addressController,
                    labelText: 'Address',
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _cityController,
                    labelText: 'City',
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _postalCodeController,
                    labelText: 'Postal Code',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _countryController,
                    labelText: 'Country',
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

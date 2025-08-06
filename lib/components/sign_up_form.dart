import 'package:flutter/material.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool agreeToTerms = false;
  bool subscribeToNewsletter = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && agreeToTerms) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } else if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the Terms of Service and Privacy Policy')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Sign Up',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your account to start shopping',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            /// First & Last Name
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    label: 'First Name',
                    hint: 'John',
                    controller: _firstNameController,
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter your first name' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextFormField(
                    label: 'Last Name',
                    hint: 'Doe',
                    controller: _lastNameController,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter your last name' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'Email',
              hint: 'john@example.com',
              icon: Icons.email_outlined,
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your email';
                } else if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'Phone Number',
              hint: '+1 (555) 123-4567',
              icon: Icons.phone_outlined,
              controller: _phoneController,
              validator: (value) =>
                  value!.isEmpty ? 'Enter your phone number' : null,
            ),

            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'Password',
              hint: 'Create a password',
              icon: Icons.lock_outline,
              controller: _passwordController,
              obscureText: true,
              validator: (value) => value!.length < 6
                  ? 'Password must be at least 6 chars'
                  : null,
            ),

            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'Confirm Password',
              hint: 'Confirm your password',
              icon: Icons.lock_outline,
              controller: _confirmPasswordController,
              obscureText: true,
              validator: (value) => value != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
            ),

            const SizedBox(height: 16),
            CheckboxListTile(
              value: agreeToTerms,
              onChanged: (val) => setState(() => agreeToTerms = val!),
              controlAffinity: ListTileControlAffinity.leading,
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ],
                ),
              ),
            ),

            CheckboxListTile(
              value: subscribeToNewsletter,
              onChanged: (val) => setState(() => subscribeToNewsletter = val!),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Subscribe to newsletter for deals and updates',
                style: TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submitForm,
              child: const Text(
                'Create Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    IconData? icon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }
}

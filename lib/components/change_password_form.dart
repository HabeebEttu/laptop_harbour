import 'package:flutter/material.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _authProvider = AuthProvider();

  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Current Password",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _currentPasswordController,
                  hint: "Enter your current password",
                  obscure: !_currentPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _currentPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() {
                      _currentPasswordVisible = !_currentPasswordVisible;
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "New Password",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _newPasswordController,
                  hint: "Enter your new password",
                  obscure: !_newPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain a number';
                    }
                    if (!value
                        .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                      return 'Password must contain a special character';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _newPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() {
                      _newPasswordVisible = !_newPasswordVisible;
                    }),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Must be at least 8 characters long, including a number and a special character.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Confirm New Password",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: "Confirm your new password",
                  obscure: !_confirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2), // Blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        try {
                          await _authProvider.updatePassword(
                              _currentPasswordController.text,
                              _newPasswordController.text);
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text("Password updated successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          String errorMessage = "Something went wrong. Please try again.";
                          if (e.toString().contains("incorrect-password")) {
                            errorMessage = "The current password you entered is incorrect. Please double-check it and try again.";
                          } else if (e.toString().contains("network-request-failed")) {
                            errorMessage = "There seems to be a network issue. Please check your internet connection and try again.";
                          }
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Save New Password",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFCED4DA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFCED4DA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF1877F2), width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Using focus nodes helps to manage user navigation between fields
  final FocusNode _currentPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;
  bool _hasInteracted = false;

  // These flags help indicate the strength of the new password
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasUpperCase = false;

  @override
  void initState() {
    super.initState();
    // We'll listen for changes to the password field to validate it in real-time
    _newPasswordController.addListener(_validatePasswordStrength);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _validatePasswordStrength() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    });
  }

  Color _getPasswordStrengthColor() {
    int strength = 0;
    if (_hasMinLength) strength++;
    if (_hasNumber) strength++;
    if (_hasSpecialChar) strength++;
    if (_hasUpperCase) strength++;

    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPasswordStrengthText() {
    int strength = 0;
    if (_hasMinLength) strength++;
    if (_hasNumber) strength++;
    if (_hasSpecialChar) strength++;
    if (_hasUpperCase) strength++;

    switch (strength) {
      case 0:
      case 1:
        return "Weak";
      case 2:
        return "Fair";
      case 3:
        return "Good";
      case 4:
        return "Strong";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? screenWidth * 0.9 : 400,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 24,
              vertical: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page header
                  Text(
                    "Change Password",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your current password and choose a new secure password.",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Field for the user's current password
                  _buildFieldLabel("Current Password", isRequired: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _currentPasswordController,
                    focusNode: _currentPasswordFocus,
                    hint: "Enter your current password",
                    obscure: !_currentPasswordVisible,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_newPasswordFocus),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Current password is required';
                      }
                      return null;
                    },
                    suffixIcon: _buildVisibilityToggle(
                      isVisible: _currentPasswordVisible,
                      onToggle: () => setState(() {
                        _currentPasswordVisible = !_currentPasswordVisible;
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Field for the new password
                  _buildFieldLabel("New Password", isRequired: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _newPasswordController,
                    focusNode: _newPasswordFocus,
                    hint: "Enter your new password",
                    obscure: !_newPasswordVisible,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(
                      context,
                    ).requestFocus(_confirmPasswordFocus),
                    onChanged: (value) {
                      setState(() => _hasInteracted = true);
                      if (_formKey.currentState != null) {
                        _formKey.currentState!.validate();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'New password is required';
                      }
                      if (value.length < 8) {
                        return 'Must be at least 8 characters';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Must contain at least one number';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'Must contain a special character';
                      }
                      if (value == _currentPasswordController.text) {
                        return 'New password must be different from current password';
                      }
                      return null;
                    },
                    suffixIcon: _buildVisibilityToggle(
                      isVisible: _newPasswordVisible,
                      onToggle: () => setState(() {
                        _newPasswordVisible = !_newPasswordVisible;
                      }),
                    ),
                  ),

                  // This indicator shows how strong the new password is
                  if (_newPasswordController.text.isNotEmpty &&
                      _hasInteracted) ...[
                    const SizedBox(height: 8),
                    _buildPasswordStrengthIndicator(),
                  ],

                  const SizedBox(height: 4),
                  _buildPasswordRequirements(),
                  const SizedBox(height: 20),

                  // Field to confirm the new password
                  _buildFieldLabel("Confirm New Password", isRequired: true),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    hint: "Confirm your new password",
                    obscure: !_confirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handlePasswordChange(),
                    onChanged: (value) {
                      if (_formKey.currentState != null) {
                        _formKey.currentState!.validate();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password confirmation is required';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffixIcon: _buildVisibilityToggle(
                      isVisible: _confirmPasswordVisible,
                      onToggle: () => setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      }),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // The button to submit the form
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading
                            ? Colors.grey[400]
                            : const Color(0xFF1877F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      onPressed: _isLoading ? null : _handlePasswordChange,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              "Update Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // A helpful tip for the user about password security
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Choose a unique password you haven't used before for better security.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        children: [
          TextSpan(text: label),
          if (isRequired)
            const TextSpan(
              text: " *",
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    Function(String)? onFieldSubmitted,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1877F2), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }

  Widget _buildVisibilityToggle({
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return IconButton(
      icon: Icon(
        isVisible ? Icons.visibility : Icons.visibility_off,
        color: Colors.grey[600],
        size: 20,
      ),
      onPressed: onToggle,
      tooltip: isVisible ? "Hide password" : "Show password",
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Password strength: ",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              _getPasswordStrengthText(),
              style: TextStyle(
                fontSize: 12,
                color: _getPasswordStrengthColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value:
              [
                _hasMinLength,
                _hasNumber,
                _hasSpecialChar,
                _hasUpperCase,
              ].where((req) => req).length /
              4,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation(_getPasswordStrengthColor()),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password requirements:",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        _buildRequirement("At least 8 characters", _hasMinLength),
        _buildRequirement("Contains a number", _hasNumber),
        _buildRequirement("Contains a special character", _hasSpecialChar),
        _buildRequirement("Contains an uppercase letter", _hasUpperCase),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isMet ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isMet ? Colors.green : Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePasswordChange() async {
    if (!_formKey.currentState!.validate()) {
      // A little vibration for feedback when there are errors
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => _isLoading = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _authProvider.updatePassword(
        _currentPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );

      HapticFeedback.lightImpact();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text("Password updated successfully!")),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // Clear the form fields if the password was changed successfully
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Move focus away from the form fields
      FocusScope.of(context).unfocus();
    } catch (e) {
      // Error feedback
      HapticFeedback.lightImpact();

      String errorMessage = _getErrorMessage(e.toString());

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: "Dismiss",
            textColor: Colors.white,
            onPressed: () => scaffoldMessenger.hideCurrentSnackBar(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains("incorrect-password") ||
        error.contains("wrong-password")) {
      return "The current password you entered is incorrect. Please check and try again.";
    } else if (error.contains("network-request-failed")) {
      return "Network error. Please check your connection and try again.";
    } else if (error.contains("too-many-requests")) {
      return "Too many attempts. Please wait a moment before trying again.";
    } else if (error.contains("user-not-found")) {
      return "User account not found. Please contact support.";
    } else if (error.contains("requires-recent-login")) {
      return "Please log out and log back in before changing your password.";
    }
    return "Unable to update password. Please try again or contact support.";
  }
}

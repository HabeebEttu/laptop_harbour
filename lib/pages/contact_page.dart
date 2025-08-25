import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final smtpServer = gmail('your-email@gmail.com', 'your-password');

      final message = Message()
        ..from = Address(_emailController.text, _nameController.text)
        ..recipients.add('support@laptop-harbour.com')
        ..subject = 'Contact Us Form Submission'
        ..text = _messageController.text;

      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Message sent successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } on MailerException catch (e) {
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to send message. Please try again later.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D9A),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2E7D9A), Color(0xFF4A9BB8)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 20,
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: isDesktop ? 60 : 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Get in Touch',
                      style: TextStyle(
                        fontSize: isDesktop ? 32 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Have a question or feedback? We\'d love to hear from you!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: 30,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 800 : double.infinity,
                ),
                child: Column(
                  children: [
                    // Contact Form Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 32 : 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Send us a message',
                                style: TextStyle(
                                  fontSize: isDesktop ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E7D9A),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Name and Email row for desktop
                              if (isDesktop)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _nameController,
                                        label: 'Your Name',
                                        icon: Icons.person_outline,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your name';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _emailController,
                                        label: 'Your Email',
                                        icon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(value)) {
                                            return 'Please enter a valid email address';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Your Name',
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Your Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _messageController,
                                label: 'Your Message',
                                icon: Icons.message_outlined,
                                maxLines: 5,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your message';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Send button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _sendEmail,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D9A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.send),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Send Message',
                                              style: TextStyle(
                                                fontSize: isDesktop ? 18 : 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Contact Information Cards
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: _buildContactCard(
                              Icons.email,
                              'Email',
                              'support@laptop-harbour.com',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildContactCard(
                              Icons.phone,
                              'Phone',
                              '+1 (123) 456-7890',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildContactCard(
                              Icons.access_time,
                              'Hours',
                              'Mon-Fri 9AM-6PM',
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildContactCard(
                        Icons.email,
                        'Email',
                        'support@laptop-harbour.com',
                      ),
                      const SizedBox(height: 16),
                      _buildContactCard(
                        Icons.phone,
                        'Phone',
                        '+1 (123) 456-7890',
                      ),
                      const SizedBox(height: 16),
                      _buildContactCard(
                        Icons.access_time,
                        'Business Hours',
                        'Monday - Friday\n9:00 AM - 6:00 PM EST',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D9A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D9A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D9A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF2E7D9A)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D9A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

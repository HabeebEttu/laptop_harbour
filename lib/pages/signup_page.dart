import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbour/components/sign_up_form.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: getResponsiveFontSize(context, 27),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    'Join Laptop Harbor and discover your perfect laptop',
                    style: GoogleFonts.poppins(
                      fontSize: getResponsiveFontSize(context, 13),
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 400, 
                        minWidth: 280, 
                      ),
                      child: SignUpForm(),
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
}
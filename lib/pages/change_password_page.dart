import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/change_password_form.dart';
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password',style: TextStyle(fontWeight: FontWeight.bold,),),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ChangePasswordForm(),
          ),
        ),
      ),
    );
  }
}
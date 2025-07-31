import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/header.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
    );
  }
}
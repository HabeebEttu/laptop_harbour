import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmailService {
  final String _emailFunctionUrl =
      'https://us-central1-laptop-harbor-3c6cd.cloudfunctions.net/sendEmail'; 
  Future<Map<String, dynamic>> sendEmail(String recipient, String subject, String body) async {
    if (kIsWeb) {
      try {
        final response = await http.post(
          Uri.parse(_emailFunctionUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'to': recipient,
            'subject': subject,
            'html': body,
          }),
        );

        if (response.statusCode == 200) {
          debugPrint('Email sent successfully.');
          return {'success': true};
        } else {
          debugPrint('Error sending email: ${response.body}');
          return {'success': false, 'error': 'Failed to send email: ${response.body}'};
        }
      } on SocketException catch (e) {
        debugPrint('Socket exception: ${e.message}');
        return {'success': false, 'error': 'Please check your internet connection.'};
      } catch (e) {
        debugPrint('Error sending email: $e');
        return {'success': false, 'error': 'An unexpected error occurred.'};
      }
    }
    return {'success': false, 'error': 'Email service is only available on web.'};
  }
}

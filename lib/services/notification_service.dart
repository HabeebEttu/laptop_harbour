import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  // You can perform background tasks here, like data syncing
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    await _firebaseMessaging.requestPermission();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Handle terminated state notifications
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Handle notification tap
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      // Navigate to a specific screen here based on the notification data
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final String? imageUrl = message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl;
    BigPictureStyleInformation? bigPictureStyleInformation;

    if (imageUrl != null) {
      final String largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
      final String bigPicturePath = await _downloadAndSaveFile(imageUrl, 'bigPicture');
      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        contentTitle: message.notification?.title,
        htmlFormatContentTitle: true,
        summaryText: message.notification?.body,
        htmlFormatSummaryText: true,
      );
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // id
      'your_channel_name', // name
      channelDescription: 'your_channel_description', // description
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
      showWhen: false,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data['route'],
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // id
      'your_channel_name', // name
      channelDescription: 'your_channel_description', // description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification',
      platformChannelSpecifics,
      payload: 'test',
    );
  }

  Future<void> sendOrderStatusUpdateNotification(
      String userId, String orderId, String status) async {
    try {
      // Get the user's FCM token from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['profile']?['fcmToken'];

      if (fcmToken != null) {
        final serverKey = 'YOUR_SERVER_KEY'; // Replace with your server key
        final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

        final body = {
          'to': fcmToken,
          'notification': {
            'title': 'Order Status Changed',
            'body': 'Your order #$orderId is now $status',
          },
        };

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: json.encode(body),
        );

        if (response.statusCode == 200) {
          debugPrint('Notification sent successfully');
        } else {
          debugPrint('Failed to send notification: ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}
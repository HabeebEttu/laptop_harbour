import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbour/firebase_options.dart';
import 'package:laptop_harbour/pages/add_category_page.dart';
import 'package:laptop_harbour/pages/add_laptop_page.dart';
import 'package:laptop_harbour/pages/cart_page.dart';
import 'package:laptop_harbour/pages/home_page.dart';
import 'package:laptop_harbour/pages/orders_page.dart';
import 'package:laptop_harbour/pages/settings_page.dart';
import 'package:laptop_harbour/pages/wish_list.dart';
import 'package:laptop_harbour/providers/category_provider.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LaptopProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: 'Laptop Harbour',
        debugShowCheckedModeBanner: false,
        routes: {
          '/cart': (context) => CartPage(),
          '/settings': (context) => SettingsPage(),
          '/wishlist': (context) => WishList(),
          '/orders': (context) => OrdersPage(),
          '/add_laptop': (context) => AddLaptopPage(),
          '/add_category': (context) => AddCategoryPage(),
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ).apply(bodyColor: const Color(0xFF333333)),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF5F5F5),
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF333333)),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}

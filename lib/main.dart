import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbour/firebase_options.dart';
import 'package:laptop_harbour/pages/add_category_page.dart';
import 'package:laptop_harbour/pages/add_laptop_page.dart';
import 'package:laptop_harbour/pages/cart_page.dart';
import 'package:laptop_harbour/pages/change_password_page.dart';
import 'package:laptop_harbour/pages/home_page.dart';
import 'package:laptop_harbour/pages/login_page.dart';
import 'package:laptop_harbour/pages/orders_page.dart';
import 'package:laptop_harbour/pages/profile_page.dart';
import 'package:laptop_harbour/pages/settings_page.dart';
import 'package:laptop_harbour/pages/signup_page.dart';
import 'package:laptop_harbour/pages/wish_list.dart';
import 'package:laptop_harbour/providers/category_provider.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:laptop_harbour/providers/cart_provider.dart';
import 'package:laptop_harbour/providers/order_provider.dart';
import 'package:laptop_harbour/providers/wishlist_provider.dart';
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
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) =>
              UserProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, userProvider) =>
              userProvider!..updateAuth(auth), // Assuming updateAuth method in UserProvider
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (context) =>
              CartProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, cartProvider) =>
              cartProvider!..updateAuth(auth), // Assuming updateAuth method in CartProvider
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (context) =>
              OrderProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, orderProvider) =>
              orderProvider!..updateAuth(auth), // Assuming updateAuth method in OrderProvider
        ),
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (context) => WishlistProvider(),
          update: (context, auth, wishlistProvider) =>
              wishlistProvider!..setUser(auth.user?.uid),
        ),
      ],
      child: MaterialApp(
        title: 'Laptop Harbour',
        debugShowCheckedModeBanner: false,
        routes: {
          '/cart': (context) => const CartPage(),
          '/settings': (context) => const SettingsPage(),
          '/wishlist': (context) => const WishList(),
          '/orders': (context) => const OrdersPage(),
          '/add_laptop': (context) => const AddLaptopPage(),
          '/add_category': (context) => const AddCategoryPage(),
          '/signin': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/profile':(context)=>ProfilePage(),
          '/change_password':(context)=>ChangePasswordPage()
          
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


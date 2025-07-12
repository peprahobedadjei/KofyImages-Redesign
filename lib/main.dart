import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/cart_notifier.dart';
import 'package:kofyimages/constants/network_monitor.dart';
import 'package:kofyimages/screens/splash_screen.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
   Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  await NetworkMonitor.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => CartNotifier()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'KofyImages',
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                foregroundColor: Colors.black,
                scrolledUnderElevation: 0,
              ),
              textTheme: GoogleFonts.montserratTextTheme().apply(
                bodyColor: Colors.black,
                displayColor: Colors.black,
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.black,
                brightness: Brightness.light,
              ).copyWith(surface: Colors.white, onSurface: Colors.black),
              useMaterial3: true,
            ),
            home: const ConnectionListener(child: SplashScreen()),
          ),
        );
      },
    );
  }
}

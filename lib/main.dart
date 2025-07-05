import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/network_monitor.dart';
import 'package:kofyimages/screens/splash_screen.dart';
import 'package:kofyimages/constants/connection_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NetworkMonitor.initialize(); // Wait for network status initialization
  runApp(const MyApp());
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
        return MaterialApp(
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
            ).copyWith(
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            useMaterial3: true,
          ),
          home: const ConnectionListener(child: SplashScreen()),
        );
      },
    );
  }
}
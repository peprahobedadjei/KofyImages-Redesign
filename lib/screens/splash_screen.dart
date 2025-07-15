import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/screens/home.dart';
import 'package:kofyimages/constants/network_monitor.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  void _initializeSplash() {
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _checkConnectivityAndNavigate();
      }
    });
  }

  void _checkConnectivityAndNavigate() {
    // Check if we have internet connection
    if (NetworkMonitor.isConnected.value) {
      // Navigate to home page if connected
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    } else {
      // If no connection, listen for connection changes
      _listenForConnection();
    }
  }

  void _listenForConnection() {
    // Listen for connectivity changes
    NetworkMonitor.isConnected.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (NetworkMonitor.isConnected.value && mounted) {
      // Remove listener to avoid memory leaks
      NetworkMonitor.isConnected.removeListener(_onConnectivityChanged);

      // Navigate to home page when connection is restored
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    }
  }

  @override
  void dispose() {
    // Clean up listener if still active
    NetworkMonitor.isConnected.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedTextKit(
          repeatForever: true,
          pause: Duration(milliseconds: 2000),
          animatedTexts: [
            TypewriterAnimatedText(
              'KofyImages……Explore Cities through Pictures',
              textStyle: GoogleFonts.montserrat(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w600
              ),
              speed: Duration(milliseconds: 100),
            ),
          ],
        ),
      ),
    );
  }
}

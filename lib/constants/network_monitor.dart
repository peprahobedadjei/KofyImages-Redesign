import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkMonitor {
  static final ValueNotifier<bool> isConnected = ValueNotifier(true);
  static late final StreamSubscription<List<ConnectivityResult>> _subscription;
  
  static Future<void> initialize() async {
    // Check initial connectivity state
    final List<ConnectivityResult> initialResults = await Connectivity().checkConnectivity();
    _updateConnectionStatus(initialResults);
    
    // Start listening for connectivity changes
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateConnectionStatus);
  }
  
  static void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if any of the connectivity results indicate a connection
    isConnected.value = results.any((result) => result != ConnectivityResult.none);
  }
  
  static void dispose() {
    _subscription.cancel();
  }
}
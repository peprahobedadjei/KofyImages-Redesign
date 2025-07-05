import 'package:flutter/material.dart';
import 'package:kofyimages/constants/network_monitor.dart';
import 'package:kofyimages/constants/no_internet_overlay.dart';

class ConnectionListener extends StatelessWidget {
  final Widget child;

  const ConnectionListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ValueListenableBuilder<bool>(
          valueListenable: NetworkMonitor.isConnected,
          builder: (context, isConnected, _) {
            return isConnected ? const SizedBox.shrink() : const NoInternetOverlay();
          },
        ),
      ],
    );
  }
}

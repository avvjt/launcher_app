// services/navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void navigateTo(String routeName) {
    navigatorKey.currentState?.pushReplacementNamed(routeName);
  }
}

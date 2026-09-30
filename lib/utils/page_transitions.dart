import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AppPageTransitions {
  /// انتقال با اسلاید از پایین
  static Route<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideInUp(
          duration: const Duration(milliseconds: 400),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// انتقال با زوم
  static Route<T> zoomIn<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return ZoomIn(
          duration: const Duration(milliseconds: 400),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// انتقال با چرخش
  static Route<T> flipIn<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FlipInY(
          duration: const Duration(milliseconds: 500),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
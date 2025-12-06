import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppSnackBarType { success, error, info }

class AppSnackBar {
  AppSnackBar._();

  static const Color _successColor = Color(0xFF34BB91);
  static const Color _errorColor = Color(0xFFE74C3C);
  static const Color _infoColor = Color(0xFF2C98F0);

  static void show(
    String title,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = Get.context;
    if (context == null) {
      return;
    }

    final Color backgroundColor;
    switch (type) {
      case AppSnackBarType.success:
        backgroundColor = _successColor;
        break;
      case AppSnackBarType.error:
        backgroundColor = _errorColor;
        break;
      case AppSnackBarType.info:
        backgroundColor = _infoColor;
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(String message, {String title = 'Success'}) {
    show(title, message, type: AppSnackBarType.success);
  }

  static void error(String message, {String title = 'Error'}) {
    show(title, message, type: AppSnackBarType.error);
  }

  static void info(String message, {String title = 'Info'}) {
    show(title, message, type: AppSnackBarType.info);
  }

  static void adaptive(String title, String message) {
    final normalized = title.toLowerCase();
    if (normalized.contains('success')) {
      success(message, title: title);
    } else if (normalized.contains('error') ||
        normalized.contains('invalid') ||
        normalized.contains('failed')) {
      error(message, title: title);
    } else {
      info(message, title: title);
    }
  }
}

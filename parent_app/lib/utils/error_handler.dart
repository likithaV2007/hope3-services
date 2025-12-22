import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Network connection error. Please check your internet.';
    } else if (error.toString().contains('permission')) {
      return 'Permission denied. Please check app permissions.';
    } else if (error.toString().contains('not-found')) {
      return 'Data not found. Please contact school administration.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
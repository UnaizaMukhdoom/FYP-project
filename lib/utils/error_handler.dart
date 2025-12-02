// lib/utils/error_handler.dart
import 'dart:io';

/// Utility class for handling and formatting error messages
class ErrorHandler {
  /// Get user-friendly error message from exception
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is HttpException) {
      return 'Network error occurred. Please try again later.';
    } else if (error.toString().contains('TimeoutException') || 
               error.toString().contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (error.toString().contains('Connection refused') || 
               error.toString().contains('SocketException')) {
      return 'Cannot connect to server. Please check your internet connection.';
    } else if (error.toString().contains('Failed host lookup')) {
      return 'Cannot reach server. Please check your internet connection.';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid data received. Please try again.';
    } else if (error.toString().contains('PlatformException')) {
      return 'An error occurred. Please try again.';
    }
    
    // Default error message
    final errorString = error.toString();
    if (errorString.length > 100) {
      return 'Something went wrong. Please try again.';
    }
    return errorString;
  }
  
  /// Get short error message for snackbars
  static String getShortErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out';
    } else if (error.toString().contains('Connection refused')) {
      return 'Cannot connect to server';
    }
    return 'An error occurred';
  }
}


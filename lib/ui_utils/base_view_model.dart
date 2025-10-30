import 'package:flutter/material.dart';

/// Base view model that provides common functionality for all view models
abstract class BaseViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  /// Gets the current loading state
  bool get isLoading => _isLoading;

  /// Gets the current error message
  String? get errorMessage => _errorMessage;

  /// Sets the loading state and notifies listeners
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets an error message and notifies listeners
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clears the current error message
  void clearError() => setError(null);

  /// Validates the form and returns true if valid
  bool validateForm() {
    clearError();
    return formKey.currentState?.validate() ?? false;
  }

  /// Shows a loading state while executing an async operation
  Future<T> executeWithLoading<T>(Future<T> Function() operation) async {
    setLoading(true);
    clearError();

    try {
      final result = await operation();
      setLoading(false);
      return result;
    } catch (error) {
      setLoading(false);
      setError(error.toString());
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

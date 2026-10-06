import 'package:flutter/widgets.dart';

/// Type definition for field validators.
typedef FormFieldValidator<T> = String? Function(T? value);

/// Reusable form validation rules with zero Material dependencies.
class FormValidator {
  FormValidator._();

  static FormFieldValidator<String> required([
    String message = 'This field is required',
  ]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static FormFieldValidator<String> minLength(int length, [String? message]) {
    return (value) {
      if (value != null && value.length < length) {
        return message ?? 'Must be at least $length characters';
      }
      return null;
    };
  }

  static FormFieldValidator<String> email([
    String message = 'Enter a valid email address',
  ]) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!emailRegex.hasMatch(value.trim())) {
        return message;
      }
      return null;
    };
  }

  static FormFieldValidator<int> positiveAmount([
    String message = 'Amount must be greater than zero',
  ]) {
    return (value) {
      if (value == null || value <= 0) {
        return message;
      }
      return null;
    };
  }

  static FormFieldValidator<T> compose<T>(
    List<FormFieldValidator<T>> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

/// A clean architecture, lightweight form controller.
class FormGroup extends ChangeNotifier {
  final Map<String, dynamic> _values = {};
  final Map<String, String?> _errors = {};
  final Map<String, FormFieldValidator<dynamic>> _validators = {};

  void registerField<T>(
    String name, {
    T? initialValue,
    FormFieldValidator<T>? validator,
  }) {
    _values[name] = initialValue;
    if (validator != null) {
      _validators[name] = (dynamic val) => validator(val as T?);
    }
  }

  dynamic getValue(String name) => _values[name];

  void setValue(String name, dynamic value) {
    _values[name] = value;
    validateField(name);
    notifyListeners();
  }

  String? getError(String name) => _errors[name];

  bool validateField(String name) {
    final validator = _validators[name];
    if (validator != null) {
      final error = validator(_values[name]);
      _errors[name] = error;
      return error == null;
    }
    return true;
  }

  bool validate() {
    bool isValid = true;
    for (final name in _validators.keys) {
      final valid = validateField(name);
      if (!valid) isValid = false;
    }
    notifyListeners();
    return isValid;
  }

  void reset() {
    _errors.clear();
    notifyListeners();
  }
}

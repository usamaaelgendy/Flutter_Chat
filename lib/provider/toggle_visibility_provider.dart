import 'package:flutter/material.dart';

class ToggleVisibility extends ChangeNotifier {
  bool _toggleVisibility = false;

  bool get toggleVisibility => _toggleVisibility;

  void changeToggle() {
    _toggleVisibility = !_toggleVisibility;
    notifyListeners();
  }
}

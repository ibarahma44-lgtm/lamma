import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  bool _isToggled1 = false;
  bool get isToggled1 => _isToggled1;
  set isToggled1(bool value) {
    _isToggled1 = value;
  }

  bool _isToggled2 = false;
  bool get isToggled2 => _isToggled2;
  set isToggled2(bool value) {
    _isToggled2 = value;
  }
}

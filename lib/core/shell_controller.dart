import 'package:flutter/foundation.dart';

/// Holds the index of the visible bottom-navigation tab.
///
/// The website keeps the active page in the router; on mobile the equivalent is
/// a shared notifier so the drawer can switch tabs from any screen (for
/// example a link inside the footer) instead of pushing a new route.
class ShellController extends ChangeNotifier {
  ShellController();

  static final ShellController instance = ShellController();

  int _index = 0;

  int get index => _index;

  void goTo(int value) {
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }

  /// Switches tab and pops the navigator back to the shell route first.
  static void goToFromAnyScreen(int value) {
    instance.goTo(value);
  }
}

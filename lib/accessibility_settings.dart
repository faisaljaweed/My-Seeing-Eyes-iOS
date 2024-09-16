import 'package:first/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccessibilitySettings with ChangeNotifier {
  double _fontSize = 1.0;
  bool _highContrastEnabled = false;

  double get fontSize => _fontSize;
  bool get highContrastEnabled => _highContrastEnabled;

  void toggleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    _fontSize = _fontSize == 1.0 ? screenWidth * 0.0028 : 1.0;
    notifyListeners();
  }

  void toggleHighContrast() {
    _highContrastEnabled = !_highContrastEnabled;
    notifyListeners();
  }

  void main() {
    runApp(
      ChangeNotifierProvider(
        create: (context) => AccessibilitySettings(),
        child: const MyApp(
          cameras: [],
        ),
      ),
    );
  }
}

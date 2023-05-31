import 'package:flutter/material.dart';
import '../Modal/Theme_Model.dart';


class ThemeProvider extends ChangeNotifier {
  ThemeModel ld1 = ThemeModel(isDark: false);

  void changeTheme(){
    ld1.isDark = !ld1.isDark;
    notifyListeners();
  }
}
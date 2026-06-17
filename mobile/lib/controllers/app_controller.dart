import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/preferences_keys.dart';

class AppController extends GetxController {
  Locale _locale = const Locale('fr', 'FR');
  ThemeMode _themeMode = ThemeMode.light;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  @override
  void onInit() {
    super.onInit();
    _initializeTheme();
    _initializeLocale();
  }

  Future<void> _initializeTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(PreferencesKeys.themeMode);
      if (saved != null) {
        _themeMode = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
      } else {
        final brightness = ui.PlatformDispatcher.instance.platformBrightness;
        _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }
      Get.changeThemeMode(_themeMode);
      update();
    } catch (e) {
      if (kDebugMode) debugPrint('Theme init error: $e');
    }
  }

  Future<void> _initializeLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(PreferencesKeys.locale);
      if (saved != null) {
        _locale = Locale(saved);
        Get.updateLocale(_locale);
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    Get.changeThemeMode(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PreferencesKeys.themeMode, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
    update();
  }

  void toggleTheme() => setThemeMode(
    _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  );

  Future<void> changeLocale(Locale locale) async {
    _locale = locale;
    Get.updateLocale(locale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PreferencesKeys.locale, locale.languageCode);
    } catch (_) {}
    update();
  }
}

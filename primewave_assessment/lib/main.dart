import 'package:flutter/material.dart';
import 'package:primewave_assessment/config/app_theme.dart';
import 'package:primewave_assessment/screens/articles_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ArticlesApp());
}

class ArticlesApp extends StatefulWidget {
  const ArticlesApp({super.key});

  @override
  State<ArticlesApp> createState() => _ArticlesAppState();
}

class _ArticlesAppState extends State<ArticlesApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
    });
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', themeMode.index);
  }

  void _toggleTheme() {
    setState(() {
      switch (_themeMode) {
        case ThemeMode.system:
          _themeMode = ThemeMode.light;
          break;
        case ThemeMode.light:
          _themeMode = ThemeMode.dark;
          break;
        case ThemeMode.dark:
          _themeMode = ThemeMode.system;
          break;
      }
    });
    _saveThemeMode(_themeMode);
  }

  IconData _getThemeIcon() {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.brightness_7;
      case ThemeMode.dark:
        return Icons.brightness_4;
    }
  }

  String _getThemeTooltip() {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'Switch to Light Theme';
      case ThemeMode.light:
        return 'Switch to Dark Theme';
      case ThemeMode.dark:
        return 'Switch to System Theme';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Articles App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: ArticlesPage(onThemeToggle: _toggleTheme, themeIcon: _getThemeIcon(), themeTooltip: _getThemeTooltip()),
      debugShowCheckedModeBanner: false,
    );
  }
}

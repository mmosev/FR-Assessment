import 'package:flutter/material.dart';
import 'services/settings_service.dart';
import 'screens/projects_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FireStoppingApp());
}

class FireStoppingApp extends StatefulWidget {
  const FireStoppingApp({super.key});

  @override
  State<FireStoppingApp> createState() => _FireStoppingAppState();
}

class _FireStoppingAppState extends State<FireStoppingApp> {
  final SettingsService _settings = SettingsService();
  ThemeMode _themeMode = ThemeMode.light;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _settings.isDarkMode();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _loaded = true;
    });
  }

  void updateTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    _settings.setDarkMode(isDark);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Fire Stopping Assessment',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF90CAF9),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: ProjectsListScreen(onThemeChanged: updateTheme),
    );
  }
}

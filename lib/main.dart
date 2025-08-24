import 'package:flutter/material.dart';
import 'package:cv_generator/screens/gemini_key.dart';
import 'package:cv_generator/screens/base_document.dart';
import 'package:cv_generator/screens/cv_tailor.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const GeminiKeyScreen(),
      const BaseDocumentScreen(),
      CvTailorScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        platform: TargetPlatform.windows,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        platform: TargetPlatform.windows,
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          currentIndex: _selectedIndex,
          onTap: _navigateBottomBar,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.key),
              label: 'Gemini kulcs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner),
              label: 'Önéletrajz profil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_document),
              label: 'CV Generálás',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const RaazApp());
}

class RaazApp extends StatelessWidget {
  const RaazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAAZ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    WelcomeScreen(),
    Center(child: Text('Reflections')),
    Center(child: Text('Letters')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RAAZ'),
        centerTitle: true,
      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Reflections',
          ),
          NavigationDestination(
            icon: Icon(Icons.mail_outline),
            selectedIcon: Icon(Icons.mail),
            label: 'Letters',
          ),
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.spa, size: 80, color: Colors.deepPurpleAccent),
          SizedBox(height: 20),
          Text(
            'Welcome to RAAZ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'A safe space for authentic expression.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

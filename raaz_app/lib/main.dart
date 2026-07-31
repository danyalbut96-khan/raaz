import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';
import 'splash_screen.dart';
import 'settings_screen.dart';
import 'home_feed_screen.dart';
import 'create_post_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const RaazApp());
}

class RaazApp extends StatelessWidget {
  const RaazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAAZ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004ac6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFf9f9ff),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFf9f9ff),
          foregroundColor: Color(0xFF141B2B),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF141B2B),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF141B2B)),
          bodyMedium: TextStyle(color: Color(0xFF141B2B)),
          bodySmall: TextStyle(color: Color(0xFF434655)),
          titleLarge: TextStyle(color: Color(0xFF141B2B), fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: Color(0xFF141B2B), fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: Color(0xFF141B2B), fontWeight: FontWeight.w500),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFd8e2ff),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF004ac6), fontWeight: FontWeight.w600, fontSize: 12);
            }
            return const TextStyle(color: Color(0xFF434655), fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF004ac6));
            }
            return const IconThemeData(color: Color(0xFF434655));
          }),
        ),
      ),
      home: const SplashScreen(),
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
    HomeFeedScreen(),
    Center(child: Text('Explore (Coming Soon)')),
    CreatePostScreen(),
    Center(child: Text('Alerts (Coming Soon)')),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Post',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

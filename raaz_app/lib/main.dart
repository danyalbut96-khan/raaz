import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/supabase_config.dart';
import 'splash_screen.dart';
import 'settings_screen.dart';
import 'home_feed_screen.dart';
import 'create_post_screen.dart';
import 'trending_screen.dart';
import 'notifications_screen.dart';
import 'services/realtime_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize Ads and Realtime Sync
  await MobileAds.instance.initialize();
  await RealtimeSyncService().initialize();

  // Request Notification Permissions
  await Permission.notification.request();

  runApp(const RaazApp());
}

class RaazApp extends StatelessWidget {
  const RaazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: RealtimeSyncService().navigatorKey,
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

  void _onItemTapped(int index) {
    // Post tab (index 2) opens as a full-screen push so returning to the feed
    // preserves the previously selected tab state via IndexedStack.
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreatePostScreen()),
      );
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeFeedScreen(),
          TrendingScreen(),
          SizedBox.shrink(), // Post tab — opens via push, never shown inline
          NotificationsScreen(),
          SettingsScreen(),
        ],
      ),
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
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Trending',
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

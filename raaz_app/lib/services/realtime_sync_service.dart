import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../maintenance_mode_screen.dart';
import '../core/supabase_client.dart';

class RealtimeSyncService {
  static final RealtimeSyncService _instance = RealtimeSyncService._internal();
  factory RealtimeSyncService() => _instance;
  RealtimeSyncService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool adsEnabled = false;
  int adFrequency = 5;
  String admobAndroidId = '';
  String admobIosId = '';

  Future<void> initialize() async {
    // Initialize Local Notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: darwinInit);
    // await _localNotifications.initialize(initSettings);

    // Initial Fetch for config
    await _fetchInitialConfig();

    // Setup Supabase Realtime Channels
    _setupChannels();
  }

  Future<void> _fetchInitialConfig() async {
    try {
      final res = await supabase.from('app_config').select('key, value');
      _applyConfig(res as List<dynamic>);
    } catch (_) {}
  }

  void _applyConfig(List<dynamic> configItems) {
    bool maintenance = false;
    String maintenanceMsg = '';

    for (var item in configItems) {
      final key = item['key'] as String;
      final val = item['value'] as String;

      switch (key) {
        case 'ads_enabled':
          adsEnabled = val == 'true';
          break;
        case 'ad_frequency':
          adFrequency = int.tryParse(val) ?? 5;
          break;
        case 'admob_android_id':
          admobAndroidId = val;
          break;
        case 'admob_ios_id':
          admobIosId = val;
          break;
        case 'maintenance_mode':
          maintenance = val == 'true';
          break;
        case 'maintenance_message':
          maintenanceMsg = val;
          break;
      }
    }

    if (maintenance) {
      _forceMaintenanceMode(maintenanceMsg);
    }
  }

  void _setupChannels() {
    // 1. Listen to global notifications
    supabase.channel('public:global_notifications').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'global_notifications',
      callback: (payload) {
        final newRow = payload.newRecord;
        _showLocalNotification(newRow['title'] ?? 'Notice', newRow['message'] ?? '');
      },
    ).subscribe();

    // 2. Listen to app config changes (maintenance mode, ads)
    supabase.channel('public:app_config').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'app_config',
      callback: (payload) {
        // Just refetch the whole config to keep it simple, or apply specific
        _fetchInitialConfig();
      },
    ).subscribe();
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'global_alerts',
      'Global Alerts',
      channelDescription: 'Important announcements from the admins',
      importance: Importance.max,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: darwinDetails);

    // // await _localNotifications.show(
    //   DateTime.now().millisecond,
    //   title,
    //   body,
    //   details,
    // );
  }

  void _forceMaintenanceMode(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MaintenanceModeScreen(message: message)),
        (route) => false,
      );
    }
  }
}

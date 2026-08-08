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
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ── Publicly readable config state ────────────────────────────
  bool adsEnabled = false;
  int adFrequency = 5;
  String admobAndroidId = '';
  String admobIosId = '';
  bool maintenanceMode = false;
  String maintenanceMessage = '';
  bool forceUpdate = false;
  String minAppVersion = '';

  // Track whether maintenance screen is currently showing
  bool _maintenanceScreenShown = false;

  Future<void> initialize() async {
    // Initialize Local Notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: darwinInit);
    await _localNotifications.initialize(initSettings);

    // 1. Initial fetch — apply config before showing any screen
    await _fetchInitialConfig();

    // 2. Start real-time listeners
    _setupChannels();
  }

  // ── Fetch all config rows from DB ────────────────────────────
  Future<void> _fetchInitialConfig() async {
    try {
      final res = await supabase.from('app_config').select('key, value');
      _applyConfigList(res as List<dynamic>);
    } catch (e) {
      debugPrint('[RealtimeSyncService] Config fetch error: $e');
    }
  }

  // ── Apply a full list of config rows ────────────────────────
  void _applyConfigList(List<dynamic> configItems) {
    for (final item in configItems) {
      final key = item['key'] as String;
      final val = item['value'] as String;
      _applySingleKey(key, val);
    }
    // After applying all keys, resolve maintenance state
    _resolveMaintenance();
  }

  // ── Apply a single key/value pair ───────────────────────────
  void _applySingleKey(String key, String val) {
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
        maintenanceMode = val == 'true';
        break;
      case 'maintenance_message':
        maintenanceMessage = val;
        break;
      case 'force_update':
        forceUpdate = val == 'true';
        break;
      case 'min_app_version':
        minAppVersion = val;
        break;
    }
  }

  // ── Resolve whether to show/hide maintenance screen ─────────
  void _resolveMaintenance() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (maintenanceMode && !_maintenanceScreenShown) {
      _maintenanceScreenShown = true;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MaintenanceModeScreen(message: maintenanceMessage),
        ),
        (route) => false,
      );
    } else if (!maintenanceMode && _maintenanceScreenShown) {
      _maintenanceScreenShown = false;
      // Pop back to the root (home) — the app will reinitialise normally
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  // ── Setup Supabase Realtime channels ────────────────────────
  void _setupChannels() {
    // 1. App Config changes (maintenance, ads, etc.)
    supabase
        .channel('realtime:app_config')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'app_config',
          callback: (payload) {
            final newRow = payload.newRecord;
            if (newRow.isNotEmpty) {
              final key = newRow['key'] as String?;
              final val = newRow['value'] as String?;
              if (key != null && val != null) {
                _applySingleKey(key, val);
                _resolveMaintenance();
              }
            } else {
              // Fallback: re-fetch everything (handles DELETE too)
              _fetchInitialConfig();
            }
          },
        )
        .subscribe();

    // 2. Global notifications (push alerts to in-app)
    supabase
        .channel('realtime:global_notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'global_notifications',
          callback: (payload) {
            final newRow = payload.newRecord;
            _showLocalNotification(
              newRow['title'] as String? ?? 'Notice',
              newRow['message'] as String? ?? '',
            );
          },
        )
        .subscribe();
  }

  // ── Show local push notification ────────────────────────────
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

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}

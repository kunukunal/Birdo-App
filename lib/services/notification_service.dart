import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Add this annotation for the background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(
      "Handling background channelId: ${message.notification?.android?.channelId}");
  print(
      "Handling background channelName: ${message.notification?.android.toString()}");
  print(
      "Handling background priority: ${message.notification?.android?.priority}");
  print("Handling background message: ${message.notification?.title}");
  print("Handling background message: ${message.data.entries}");
  await NotificationService.handleMessage(
    message,
    fromBackgroundHandler: true,
  );
  // Background notifications will use Android's built-in notification channels
  // with raw resource sounds - no need for custom audio player here
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Map of logical sound keys to platform-specific identifiers
  // key: canonical sound key (lowercase, no extension)
  // android: raw resource base name in res/raw (no extension)
  // ios: bundled filename with extension in ios/Runner/Sounds
  static const List<Map<String, dynamic>> _soundCatalog = [
    {
      'id': 9,
      'key': 'dolphin-sound',
      'android': 'dolphin_sound',
      'ios': 'dolphin-sound.caf'
    },
    {'id': 10, 'key': 'eagle', 'android': 'eagle', 'ios': 'eagle.caf'},
    {
      'id': 11,
      'key': 'gunshot-glock',
      'android': 'gunshot_glock',
      'ios': 'gun-shot.caf'
    },
    {
      'id': 12,
      'key': 'high-pitch-sound',
      'android': 'high_pitch_sound',
      'ios': 'high-pitch.caf'
    },
    {'id': 13, 'key': 'owl1', 'android': 'owl1', 'ios': 'owl-1.caf'},
    {'id': 14, 'key': 'owl2', 'android': 'owl2', 'ios': 'owl-2.caf'},
    {'id': 15, 'key': 'owl3', 'android': 'owl3', 'ios': 'owl-3.caf'},
    {'id': 16, 'key': 'owl4', 'android': 'owl4', 'ios': 'owl-4.caf'},
    {'id': 17, 'key': 'owl5', 'android': 'owl5', 'ios': 'owl-5.caf'},
    {'id': 18, 'key': 'owl6', 'android': 'owl6', 'ios': 'owl-6.caf'},
    // {'id': 11, 'key': 'play', 'android': 'play', 'ios': 'play.mp3'},
    // {'id': 12, 'key': 'play1', 'android': 'play1', 'ios': 'play1.mp3'},
    // {'id': 13, 'key': 'play2', 'android': 'play2', 'ios': 'play2.mp3'},
    {
      'id': 19,
      'key': 'punch-sound',
      'android': 'punch_sound',
      'ios': 'punch-sound.caf'
    },
    {'id': 20, 'key': 'rifle', 'android': 'rifle', 'ios': 'rifle.caf'},
    {
      'id': 21,
      'key': 'the-birdo-1st-attempt',
      'android': 'the_birdo_1st_attempt',
      'ios': 'the-birdo-attempt.caf'
    },
    {
      'id': 22,
      'key': 'pigeon-sound',
      'android': 'pigeon_sound',
      'ios': 'pigeon-sound.caf'
    },
  ];

  static Map<String, Map<String, dynamic>> get _soundLookup {
    final Map<String, Map<String, dynamic>> map = {};
    for (final entry in _soundCatalog) {
      map[entry['key'] as String] = entry;
    }
    return map;
  }

  // Remove the old background handler from inside the class

  /// Initialize notifications
  static Future<void> init() async {
    // Request permission (for iOS)
    await _messaging.requestPermission();

    // Initialize local notifications with both Android and iOS settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Register background handler with the global function
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      handleMessage(message, fromBackgroundHandler: false);
    });

    // Listen when app opened by notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App opened from notification: ${message.notification?.title}");
    });

    // Create notification channel
    await createNotificationChannel();

    // Print device token
    final token = await _messaging.getToken();
    print("FCM Token: $token");
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    print("Notification tapped: ${response.payload}");
    // Handle navigation or other actions when notification is tapped
  }

  static Future<void> handleMessage(RemoteMessage message,
      {required bool fromBackgroundHandler}) async {
    final bool hasNotificationPayload = message.notification != null;
    if (fromBackgroundHandler && hasNotificationPayload) {
      print(
          'Skipping local notification: system notification already shown for payload with notification block.');
      return;
    }
    await showNotification(message);
  }

  /// Show local notification with custom sound
  static Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    print("Message Data: ${message.data}");
    // print("Message Notification: ${notification?.payload}");
    print("Message Notification: ${notification?.title}");
    print("Message Notification: ${notification?.body}");
    print("Message id: ${message.data['sound_id']}");
    // print("Message Notification: ${notification?.android}");
    // print("Message Notification: ${notification?.ios}");
    // print("Message Notification: ${notification?.androidChannelId}");
    // print("Message Notification: ${notification?.iosChannelId}");
    // print("Message Notification: ${notification?.androidChannelName}");
    // print("Message Notification: ${notification?.iosChannelName}");
    if (notification != null) {
      // Decide channel by data.sound (e.g., "rifle" or "owl1").
      // If not provided or unrecognized, use default channel.
      final String? rawSoundParam = message.data['sound'];
      // print("Raw Sound Param: $rawSoundParam");
      final dynamic soundIdParam = message.data['sound_id'];
      // print("Sound Id Param: $soundIdParam");
      final String? normalizedKey = _normalizeSoundKey(rawSoundParam);
      final Map<String, dynamic>? soundEntry =
          _selectSoundEntry(normalizedKey, soundIdParam);
      final String channelId = soundEntry != null
          ? 'sound_${soundEntry['android']}'
          : 'default_channel';
      final String channelName = soundEntry != null
          ? 'Sound: ${soundEntry['key']}'
          : 'Default Notifications';

      await _ensureChannelExists(
        channelId: channelId,
        channelName: channelName,
        description: soundEntry != null
            ? 'Notifications that play ${soundEntry['key']} sound'
            : 'Default notification channel',
        androidSound: soundEntry != null
            ? RawResourceAndroidNotificationSound(
                soundEntry['android'] as String,
              )
            : null,
      );

      // Android notification details
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Channel for $channelName',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        // Let the channel decide the sound; playSound should be true to use channel sound
        playSound: true,
        icon: '@mipmap/ic_launcher_monochrome',
      );

      // iOS notification details - use bundled sound files
      String? iosSound =
          soundEntry != null ? soundEntry['ios'] as String : null;

      // print("iOS Sound Debug:");
      // print("  soundEntry: $soundEntry");
      // print("  iosSound: $iosSound");
      // print("  rawSoundParam: $rawSoundParam");
      // print("  soundIdParam: $soundIdParam");

      DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: iosSound,
        interruptionLevel: InterruptionLevel.active,
      );

      NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use a smaller ID that fits within 32-bit integer range for iOS compatibility
      final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _localNotifications.show(
        notificationId,
        notification.title,
        notification.body,
        platformDetails,
        payload: message.data.toString(),
      );
    }
  }

  /// Create notification channels with custom sounds (Android only)
  static Future<void> createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel defaultChannel =
          AndroidNotificationChannel(
        'default_channel',
        'Default Notifications',
        description: 'Default notification channel',
        importance: Importance.max,
        playSound: true,
      );

      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(defaultChannel);

      // Create a channel per sound in the catalog
      for (final entry in _soundCatalog) {
        final String androidName = entry['android'] as String;
        final String channelId = 'sound_' + androidName;
        final String channelName = 'Sound: ' + (entry['key'] as String);
        final AndroidNotificationChannel ch = AndroidNotificationChannel(
          channelId,
          channelName,
          description:
              'Notifications that play ' + (entry['key'] as String) + ' sound',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(androidName),
        );
        await androidPlugin?.createNotificationChannel(ch);
      }
    }
  }

  // Accepts values like 'owl1', 'owl1.mp3', 'OWL1', 'high-pitch-sound'
  static String? _normalizeSoundKey(String? input) {
    if (input == null) return null;
    String v = input.trim().toLowerCase();
    if (v.endsWith('.mp3')) {
      v = v.substring(0, v.length - 4);
    }
    if (v.endsWith('.caf')) {
      v = v.substring(0, v.length - 4);
    }
    if (v.endsWith('.wav')) {
      v = v.substring(0, v.length - 4);
    }
    if (v.endsWith('.aiff')) {
      v = v.substring(0, v.length - 5);
    }
    // Map android raw name back to key if possible
    for (final entry in _soundCatalog) {
      if (entry['key'] == v || entry['android'] == v)
        return entry['key'] as String;
    }
    return v.isEmpty ? null : v;
  }

  static Map<String, dynamic>? _selectSoundEntry(String? key, dynamic idParam) {
    if (key != null) {
      final Map<String, dynamic>? byKey = _soundLookup[key];
      if (byKey != null) return byKey;
    }
    for (final int id in _extractSoundIds(idParam)) {
      for (final e in _soundCatalog) {
        if (e['id'] == id) return e;
      }
    }
    return null;
  }

  static List<int> _extractSoundIds(dynamic raw) {
    if (raw == null) return const <int>[];

    if (raw is int) return [raw];

    if (raw is List) {
      final List<int> ids = [];
      for (final element in raw) {
        final int? parsed = _coerceToInt(element);
        if (parsed != null) ids.add(parsed);
      }
      return ids;
    }

    if (raw is String) {
      final String value = raw.trim();
      if (value.isEmpty) return const <int>[];

      if (value.startsWith('[') && value.endsWith(']')) {
        try {
          final dynamic decoded = jsonDecode(value);
          return _extractSoundIds(decoded);
        } catch (_) {
          // fall through to other parsing strategies
        }
      }

      if (value.contains(',')) {
        final List<int> ids = [];
        for (final part in value.split(',')) {
          final int? parsed = int.tryParse(part.trim());
          if (parsed != null) ids.add(parsed);
        }
        if (ids.isNotEmpty) return ids;
      }

      final int? single = int.tryParse(value);
      if (single != null) return [single];
    }

    return const <int>[];
  }

  static int? _coerceToInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw.trim());
    if (raw is double) return raw.toInt();
    return null;
  }

  static Future<void> _ensureChannelExists({
    required String channelId,
    required String channelName,
    required String description,
    RawResourceAndroidNotificationSound? androidSound,
  }) async {
    if (!Platform.isAndroid) return;
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    // Delete stale channel (required to update sound on Android 8+)
    try {
      await androidPlugin.deleteNotificationChannel(channelId);
    } catch (_) {
      // Safe to ignore if channel doesn't exist yet
    }

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: description,
      importance: Importance.max,
      playSound: true,
      sound: androidSound,
    );

    await androidPlugin.createNotificationChannel(channel);
  }
}

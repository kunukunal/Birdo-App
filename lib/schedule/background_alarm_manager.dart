// import 'dart:convert';
// import 'dart:io';
//
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:workmanager/workmanager.dart';
//
// import '../controller/dto.dart';
//
// // CRITICAL: Background callback - MUST be top level function
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     print("🚀 Background Workmanager task executed: $task");
//
//     if (task == 'scheduledAlarm') {
//       await _executeScheduledAlarm(inputData);
//     }
//
//     return Future.value(true);
//   });
// }
//
// // CRITICAL: Top level function for Android Alarm Manager
// @pragma('vm:entry-point')
// void alarmCallback(int id) async {
//   print("⏰ Alarm callback triggered for ID: $id");
//
//   try {
//     // Load schedule data
//     final prefs = await SharedPreferences.getInstance();
//     final scheduleData = prefs.getString('alarm_$id');
//
//     if (scheduleData != null) {
//       final scheduleJson = jsonDecode(scheduleData);
//       await _executeScheduledAlarm(scheduleJson);
//
//       // Check if we need to reschedule for recurring alarms
//       await _rescheduleIfNeeded(scheduleJson, id);
//     } else {
//       print("❌ No schedule data found for alarm ID: $id");
//     }
//   } catch (e) {
//     print("❌ Error in alarm callback: $e");
//   }
// }
//
// // CRITICAL: Execute the actual alarm with audio playback
// Future<void> _executeScheduledAlarm(Map<String, dynamic>? inputData) async {
//   if (inputData == null) {
//     print("❌ No input data for scheduled alarm");
//     return;
//   }
//
//   print("🎵 Executing scheduled alarm: ${inputData['message']}");
//
//   try {
//     // Initialize notifications in background
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//     // Try to play audio in background
//     await _playAudioInBackground(inputData['soundPath']);
//
//     // Show high priority notification with custom sound
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'alarm_channel',
//       'Alarm Notifications',
//       channelDescription: 'Notifications for scheduled alarms',
//       importance: Importance.max,
//       priority: Priority.high,
//       category: AndroidNotificationCategory.alarm,
//       playSound: true,
//       sound: RawResourceAndroidNotificationSound('notification'),
//       enableVibration: true,
//       vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
//       fullScreenIntent: true,
//       showWhen: true,
//       enableLights: true,
//       ledColor: Color.fromARGB(255, 52, 187, 145),
//       ledOnMs: 1000,
//       ledOffMs: 500,
//       ticker: 'Birdo Alarm',
//       ongoing: false,
//       autoCancel: true,
//       visibility: NotificationVisibility.public,
//     );
//
//     NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     await flutterLocalNotificationsPlugin.show(
//       inputData['notificationId'] ?? 0,
//       'Birdo Alarm',
//       inputData['message'] ?? 'Time for your scheduled sound!',
//       platformChannelSpecifics,
//       payload: jsonEncode(inputData),
//     );
//
//     print("✅ Alarm executed successfully");
//   } catch (e) {
//     print("❌ Error executing scheduled alarm: $e");
//   }
// }
//
// // Play audio in background using native platform channels
// Future<void> _playAudioInBackground(String? soundPath) async {
//   if (soundPath == null) return;
//
//   try {
//     print("🎵 Attempting to play audio in background: $soundPath");
//
//     // For asset files, convert to proper asset path
//     if (soundPath.startsWith('images/') || !soundPath.startsWith('http')) {
//       final assetPath =
//           soundPath.startsWith('assets/') ? soundPath : 'assets/$soundPath';
//
//       // Use platform channel to play audio natively
//       const platform = MethodChannel('birdo/audio');
//       await platform.invokeMethod('playAssetAudio', {'path': assetPath});
//     } else {
//       // For network URLs, try to play directly
//       const platform = MethodChannel('birdo/audio');
//       await platform.invokeMethod('playNetworkAudio', {'url': soundPath});
//     }
//
//     print("✅ Background audio playback initiated");
//   } catch (e) {
//     print("❌ Error playing background audio: $e");
//     // Fallback to just showing notification if audio fails
//   }
// }
//
// // Reschedule recurring alarms with better validation
// Future<void> _rescheduleIfNeeded(
//     Map<String, dynamic> scheduleData, int alarmId) async {
//   try {
//     final intervalMinutes = scheduleData['interval'] as int?;
//     if (intervalMinutes == null) return;
//
//     final endTimeData = scheduleData['endTime'] as Map<String, dynamic>?;
//     if (endTimeData == null) return;
//
//     final dateData = scheduleData['date'] as Map<String, dynamic>?;
//     if (dateData == null) return;
//
//     final now = DateTime.now();
//     final scheduleDate = DateTime(
//       dateData['year'],
//       dateData['month'],
//       dateData['day'],
//     );
//
//     final endTime = DateTime(
//       scheduleDate.year,
//       scheduleDate.month,
//       scheduleDate.day,
//       endTimeData['hour'],
//       endTimeData['minute'],
//     );
//
//     // Check if we haven't reached the end time
//     if (now.isBefore(endTime)) {
//       final nextAlarmTime = now.add(Duration(minutes: intervalMinutes));
//
//       if (nextAlarmTime.isBefore(endTime)) {
//         print("⏰ Rescheduling next alarm for: $nextAlarmTime");
//
//         await AndroidAlarmManager.oneShotAt(
//           nextAlarmTime,
//           alarmId,
//           alarmCallback,
//           exact: true,
//           wakeup: true,
//           rescheduleOnReboot: true,
//         );
//
//         // Update the schedule data
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('alarm_$alarmId', jsonEncode(scheduleData));
//
//         print("✅ Next alarm scheduled successfully");
//       } else {
//         print("⏰ Next alarm would exceed end time, not rescheduling");
//         // Clean up the alarm data since it's finished
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('alarm_$alarmId');
//       }
//     } else {
//       print("⏰ End time reached, cleaning up alarm data");
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('alarm_$alarmId');
//     }
//   } catch (e) {
//     print("❌ Error rescheduling alarm: $e");
//   }
// }
//
// class EnhancedBackgroundAlarmManager {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   static bool _initialized = false;
//   static bool _workmanagerAvailable = false;
//
//   // IMPROVED: More resilient initialization - don't fail if one component fails
//   static Future<void> initialize() async {
//     if (_initialized) return;
//
//     print("🚀 Initializing Enhanced Background Alarm Manager");
//
//     try {
//       // Initialize timezone
//       tz.initializeTimeZones();
//       print("✅ Timezone initialized");
//
//       // Initialize Android Alarm Manager (CRITICAL - this is the most reliable)
//       final alarmInitialized = await AndroidAlarmManager.initialize();
//       if (!alarmInitialized) {
//         throw Exception(
//             "Failed to initialize Android Alarm Manager - this is critical");
//       }
//       print("✅ Android Alarm Manager initialized");
//
//       // Try to initialize Workmanager - don't fail if this doesn't work
//       try {
//         await Workmanager()
//             .initialize(callbackDispatcher, isInDebugMode: false);
//         _workmanagerAvailable = true;
//         print("✅ Workmanager initialized");
//       } catch (e) {
//         print("⚠️ Workmanager initialization failed (non-critical): $e");
//         _workmanagerAvailable = false;
//       }
//
//       // Initialize notifications with proper error handling
//       await _initializeNotifications();
//
//       // Request necessary permissions
//       await _requestPermissions();
//
//       _initialized = true;
//       print(
//           "✅ Enhanced Background Alarm Manager initialized (Android Alarm Manager + Notifications)");
//
//       if (_workmanagerAvailable) {
//         print("✅ Triple-redundant system active");
//       } else {
//         print("⚠️ Dual-redundant system active (WorkManager unavailable)");
//       }
//     } catch (e) {
//       print("❌ Error initializing Enhanced Background Alarm Manager: $e");
//       throw e;
//     }
//   }
//
//   static Future<void> _initializeNotifications() async {
//     try {
//       const AndroidInitializationSettings initializationSettingsAndroid =
//           AndroidInitializationSettings('@mipmap/ic_launcher');
//
//       const InitializationSettings initializationSettings =
//           InitializationSettings(android: initializationSettingsAndroid);
//
//       await _notificationsPlugin.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: _onNotificationTap,
//       );
//
//       // Create notification channel with highest priority
//       const AndroidNotificationChannel channel = AndroidNotificationChannel(
//         'alarm_channel',
//         'Alarm Notifications',
//         description: 'Notifications for scheduled alarms',
//         importance: Importance.max,
//         playSound: true,
//         enableVibration: true,
//         showBadge: true,
//       );
//
//       final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
//           _notificationsPlugin.resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>();
//
//       await androidPlugin?.createNotificationChannel(channel);
//       print("✅ Notification channel created");
//     } catch (e) {
//       print("❌ Error initializing notifications: $e");
//       throw e;
//     }
//   }
//
//   static Future<void> _requestPermissions() async {
//     try {
//       // Request exact alarm permission (Android 12+)
//       if (Platform.isAndroid) {
//         final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
//         print("📱 Exact alarm permission: $exactAlarmStatus");
//       }
//
//       // Request notification permission
//       final notificationStatus = await Permission.notification.request();
//       print("🔔 Notification permission: $notificationStatus");
//
//       // Request ignore battery optimization
//       final batteryStatus =
//           await Permission.ignoreBatteryOptimizations.request();
//       print("🔋 Battery optimization permission: $batteryStatus");
//
//       print("✅ All permissions requested");
//     } catch (e) {
//       print("⚠️ Error requesting permissions: $e");
//     }
//   }
//
//   static void _onNotificationTap(NotificationResponse response) {
//     print('🔔 Notification tapped: ${response.payload}');
//   }
//
//   // IMPROVED: More resilient scheduling - continue even if one method fails
//   static Future<void> scheduleAlarm(AudioSchedule schedule) async {
//     if (!_initialized) {
//       throw Exception(
//           "EnhancedBackgroundAlarmManager not initialized. Call initialize() first.");
//     }
//
//     print(
//         "📅 Scheduling alarm for: ${schedule.formattedDate} ${schedule.formattedStartTime}");
//
//     try {
//       final DateTime startDateTime = DateTime(
//         schedule.date.year,
//         schedule.date.month,
//         schedule.date.day,
//         schedule.startTime.hour,
//         schedule.startTime.minute,
//       );
//
//       // Validate alarm time
//       if (startDateTime
//           .isBefore(DateTime.now().subtract(Duration(minutes: 1)))) {
//         print("❌ Alarm time is in the past, not scheduling");
//         return;
//       }
//
//       final int alarmId = _generateUniqueAlarmId(schedule);
//
//       // Prepare comprehensive schedule data for background execution
//       final scheduleData = {
//         'scheduleId': schedule.hashCode.toString(),
//         'alarmId': alarmId,
//         'message': 'Time for ${schedule.soundDisplayName}!',
//         'soundPath': schedule.soundPath,
//         'soundDisplayName': schedule.soundDisplayName,
//         'notificationId': alarmId,
//         'startTime': {
//           'hour': schedule.startTime.hour,
//           'minute': schedule.startTime.minute,
//         },
//         'endTime': {
//           'hour': schedule.endTime.hour,
//           'minute': schedule.endTime.minute,
//         },
//         'interval': schedule.interval,
//         'date': {
//           'year': schedule.date.year,
//           'month': schedule.date.month,
//           'day': schedule.date.day,
//         },
//         'scheduledAt': DateTime.now().millisecondsSinceEpoch,
//       };
//
//       // Save schedule data for background access
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('alarm_$alarmId', jsonEncode(scheduleData));
//       print("💾 Saved alarm data for ID: $alarmId");
//
//       int successCount = 0;
//       List<String> errors = [];
//
//       // Method 1: Android Alarm Manager (Most critical)
//       try {
//         await AndroidAlarmManager.oneShotAt(
//           startDateTime,
//           alarmId,
//           alarmCallback,
//           exact: true,
//           wakeup: true,
//           rescheduleOnReboot: true,
//         );
//         print("✅ Android Alarm Manager scheduled");
//         successCount++;
//       } catch (e) {
//         print("❌ Android Alarm Manager failed: $e");
//         errors.add("AndroidAlarmManager: $e");
//       }
//
//       // Method 2: Local Notifications (Backup method)
//       try {
//         await _scheduleLocalNotification(schedule, startDateTime, alarmId);
//         print("✅ Local notification scheduled");
//         successCount++;
//       } catch (e) {
//         print("❌ Local notification failed: $e");
//         errors.add("LocalNotifications: $e");
//       }
//
//       // Method 3: WorkManager (Only if available)
//       if (_workmanagerAvailable) {
//         try {
//           await _scheduleWorkManagerTask(schedule, startDateTime, scheduleData);
//           print("✅ WorkManager task scheduled");
//           successCount++;
//         } catch (e) {
//           print("❌ WorkManager failed: $e");
//           errors.add("WorkManager: $e");
//         }
//       }
//
//       if (successCount > 0) {
//         print("✅ Alarm scheduled successfully with $successCount method(s)");
//       } else {
//         throw Exception("All scheduling methods failed: ${errors.join(', ')}");
//       }
//     } catch (e) {
//       print("❌ Error scheduling alarm: $e");
//       throw e;
//     }
//   }
//
//   // Generate unique alarm ID to prevent conflicts
//   static int _generateUniqueAlarmId(AudioSchedule schedule) {
//     final String uniqueString = '${schedule.date.millisecondsSinceEpoch}'
//         '${schedule.startTime.hour}${schedule.startTime.minute}'
//         '${schedule.soundPath.hashCode}';
//
//     return uniqueString.hashCode.abs() % 2147483647;
//   }
//
//   static Future<void> _scheduleLocalNotification(
//     AudioSchedule schedule,
//     DateTime scheduledTime,
//     int notificationId,
//   ) async {
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'alarm_channel',
//       'Alarm Notifications',
//       channelDescription: 'Notifications for scheduled alarms',
//       importance: Importance.max,
//       priority: Priority.high,
//       category: AndroidNotificationCategory.alarm,
//       playSound: true,
//       sound: RawResourceAndroidNotificationSound('notification'),
//       enableVibration: true,
//       vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
//       fullScreenIntent: true,
//       showWhen: true,
//       enableLights: true,
//       ledColor: Color.fromARGB(255, 52, 187, 145),
//       ledOnMs: 1000,
//       ledOffMs: 500,
//       ticker: 'Birdo Alarm',
//       ongoing: false,
//       autoCancel: false,
//       visibility: NotificationVisibility.public,
//     );
//
//     NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     await _notificationsPlugin.zonedSchedule(
//       notificationId,
//       'Birdo Alarm',
//       'Time for ${schedule.soundDisplayName}!',
//       tz.TZDateTime.from(scheduledTime, tz.local),
//       platformChannelSpecifics,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       payload: jsonEncode({
//         'scheduleId': schedule.hashCode.toString(),
//         'soundPath': schedule.soundPath,
//         'soundDisplayName': schedule.soundDisplayName,
//       }),
//     );
//   }
//
//   static Future<void> _scheduleWorkManagerTask(
//     AudioSchedule schedule,
//     DateTime scheduledTime,
//     Map<String, dynamic> scheduleData,
//   ) async {
//     final uniqueName = 'alarm_${schedule.hashCode}';
//     final delay = scheduledTime.difference(DateTime.now());
//
//     if (delay.isNegative) {
//       print("⚠️ Scheduled time is in past, not scheduling WorkManager task");
//       return;
//     }
//
//     await Workmanager().registerOneOffTask(
//       uniqueName,
//       'scheduledAlarm',
//       initialDelay: delay,
//       inputData: scheduleData,
//       constraints: Constraints(
//         networkType: NetworkType.notRequired,
//         requiresBatteryNotLow: false,
//         requiresCharging: false,
//         requiresDeviceIdle: false,
//         requiresStorageNotLow: false,
//       ),
//     );
//   }
//
//   // IMPROVED: Cancel alarm with comprehensive cleanup
//   static Future<void> cancelAlarm(AudioSchedule schedule) async {
//     try {
//       final int alarmId = _generateUniqueAlarmId(schedule);
//       final uniqueName = 'alarm_${schedule.hashCode}';
//
//       print("🗑️ Cancelling all alarms for schedule: $alarmId");
//
//       int cancelCount = 0;
//
//       // Cancel Android Alarm Manager alarm
//       try {
//         await AndroidAlarmManager.cancel(alarmId);
//         print("✅ Android Alarm Manager cancelled");
//         cancelCount++;
//       } catch (e) {
//         print("❌ Error cancelling Android Alarm Manager: $e");
//       }
//
//       // Cancel local notification
//       try {
//         await _notificationsPlugin.cancel(alarmId);
//         print("✅ Local notification cancelled");
//         cancelCount++;
//       } catch (e) {
//         print("❌ Error cancelling local notification: $e");
//       }
//
//       // Cancel WorkManager task (only if available)
//       if (_workmanagerAvailable) {
//         try {
//           await Workmanager().cancelByUniqueName(uniqueName);
//           print("✅ WorkManager task cancelled");
//           cancelCount++;
//         } catch (e) {
//           print("❌ Error cancelling WorkManager task: $e");
//         }
//       }
//
//       // Remove from preferences
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('alarm_$alarmId');
//         print("✅ Alarm data removed from storage");
//       } catch (e) {
//         print("❌ Error removing alarm data: $e");
//       }
//
//       print("✅ Cancelled $cancelCount alarm method(s) for schedule");
//     } catch (e) {
//       print("❌ Error cancelling alarms: $e");
//       throw e;
//     }
//   }
//
//   // Enhanced reschedule method with better error handling
//   static Future<void> rescheduleActiveAlarms() async {
//     print('🔄 Rescheduling active alarms after app restart...');
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final savedSchedules = prefs.getStringList('saved_schedules') ?? [];
//
//       print("📋 Found ${savedSchedules.length} saved schedules");
//
//       int rescheduled = 0;
//       int skipped = 0;
//
//       for (final scheduleString in savedSchedules) {
//         try {
//           final scheduleJson = jsonDecode(scheduleString);
//           final schedule = AudioSchedule.fromJson(scheduleJson);
//
//           if (_isScheduleStillValid(schedule)) {
//             await scheduleAlarm(schedule);
//             rescheduled++;
//             print(
//                 "✅ Rescheduled: ${schedule.formattedDate} ${schedule.formattedStartTime}");
//           } else {
//             skipped++;
//             print(
//                 "⏰ Skipped expired: ${schedule.formattedDate} ${schedule.formattedStartTime}");
//           }
//         } catch (e) {
//           print('❌ Error rescheduling individual alarm: $e');
//         }
//       }
//
//       print(
//           "✅ Rescheduled $rescheduled active alarms, skipped $skipped expired");
//     } catch (e) {
//       print('❌ Error during alarm rescheduling: $e');
//     }
//   }
//
//   static bool _isScheduleStillValid(AudioSchedule schedule) {
//     final now = DateTime.now();
//
//     final endDateTime = DateTime(
//       schedule.date.year,
//       schedule.date.month,
//       schedule.date.day,
//       schedule.endTime.hour,
//       schedule.endTime.minute,
//     );
//
//     return endDateTime.isAfter(now);
//   }
//
//   // Cancel all with better cleanup
//   static Future<void> cancelAllAlarms() async {
//     print("🗑️ Cancelling all alarms");
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final keys = prefs.getKeys().where((key) => key.startsWith('alarm_'));
//
//       for (final key in keys) {
//         final alarmId = int.tryParse(key.replaceAll('alarm_', ''));
//         if (alarmId != null) {
//           await AndroidAlarmManager.cancel(alarmId);
//         }
//         await prefs.remove(key);
//       }
//
//       await _notificationsPlugin.cancelAll();
//
//       if (_workmanagerAvailable) {
//         await Workmanager().cancelAll();
//       }
//
//       await prefs.remove('saved_schedules');
//
//       print("✅ All alarms cancelled and data cleared");
//     } catch (e) {
//       print("❌ Error cancelling all alarms: $e");
//       throw e;
//     }
//   }
// }

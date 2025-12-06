// import 'dart:async';
// import 'dart:convert';
//
// import 'package:birdo/controller/dto.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:just_audio/just_audio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AudioSchedulerController extends GetxController {
//   RxList<AudioSchedule> schedules = <AudioSchedule>[].obs;
//   RxBool isPaused = false.obs;
//   RxBool isPlaying = false.obs;
//   RxBool isLoadingSounds = false.obs;
//
//   final Map<AudioSchedule, Timer> _timers = {};
//   final Map<AudioSchedule, AudioPlayer> _players = {};
//
//   RxList<String> availableSounds = <String>[].obs;
//   RxList<Map<String, dynamic>> apiSounds = <Map<String, dynamic>>[].obs;
//
//   // final List<String> assetSounds = [
//   //   'assets/images/eagle.mp3',
//   //   'assets/images/owl1.mp3',
//   //   'assets/images/punchsound.mp3',
//   // ];
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadAvailableSounds();
//     // Clean up expired schedules every hour
//     Timer.periodic(const Duration(hours: 1), (timer) {
//       _cleanupExpiredSchedules();
//     });
//   }
//
//   Future<String?> _getAuthToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token'); // Adjust key based on your token storage
//   }
//
//   Future<void> _fetchApiSounds() async {
//     apiSounds.clear();
//     availableSounds.clear();
//     try {
//       String? token = await _getAuthToken();
//
//       if (token == null) {
//         debugPrint('No auth token found for API sounds');
//         return;
//       }
//
//       final response = await http.get(
//         Uri.parse('https://api.thebirdo.com/api/user-sounds'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['sounds'] != null && data['sounds'] is List) {
//           // Clear existing API sounds
//
//           // Add API sounds with metadata
//           for (var apiSound in data['sounds']) {
//             availableSounds.add(apiSound['name']);
//             apiSounds.add({
//               'id': apiSound['id'],
//               'name': apiSound['name']?.toString() ?? 'Unknown',
//               'path': apiSound['path'],
//               'url': 'https://thebirdo.com/uploads/sounds/${apiSound['path']}',
//               'isLocal': false,
//             });
//           }
//
//           debugPrint('Loaded ${apiSounds.length} sounds from API');
//         }
//       } else if (response.statusCode == 401) {
//         debugPrint('Unauthenticated: ${response.body}');
//         AppSnackBar.adaptive('Error', 'Authentication failed. Please login again.');
//       } else {
//         debugPrint(
//             'Error fetching sounds: ${response.statusCode} - ${response.body}');
//         AppSnackBar.adaptive('Error', 'Failed to load sounds from server.');
//       }
//     } catch (e) {
//       debugPrint('Exception while fetching API sounds: $e');
//       AppSnackBar.adaptive('Error', 'Network error. Please check your connection.');
//     }
//   }
//
//   Future<void> loadAvailableSounds() async {
//     isLoadingSounds.value = true;
//
//     try {
//       // Fetch API sounds
//       await _fetchApiSounds();
//
//       // Add API sound URLs to available sounds
//     } finally {
//       isLoadingSounds.value = false;
//     }
//   }
//
//   Future<void> refreshSounds() async {
//     await loadAvailableSounds();
//   }
//
//   void addSchedule(AudioSchedule schedule) {
//     // Add validation for date
//     final now = DateTime.now();
//     final scheduleDate =
//         DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
//     final today = DateTime(now.year, now.month, now.day);
//
//     debugPrint("Adding schedule for date: ${_formatDate(schedule.date)}");
//     debugPrint("Today's date: ${_formatDate(today)}");
//
//     if (scheduleDate.isBefore(today)) {
//       AppSnackBar.adaptive('Error', 'Cannot schedule for past dates');
//       return;
//     }
//
//     schedules.add(schedule);
//     _startSchedule(schedule);
//     debugPrint(
//         "Schedule added successfully. Total schedules: ${schedules.length}");
//   }
//
//   void removeSchedule(AudioSchedule schedule) {
//     _timers[schedule]?.cancel();
//     _players[schedule]?.dispose();
//     _timers.remove(schedule);
//     _players.remove(schedule);
//     schedules.remove(schedule);
//
//     debugPrint("Schedule removed. Remaining schedules: ${schedules.length}");
//     _updatePlayingStatus();
//   }
//
//   void _cleanupExpiredSchedules() {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//
//     final expiredSchedules = schedules.where((schedule) {
//       final scheduleDate =
//           DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
//       return scheduleDate.isBefore(today);
//     }).toList();
//
//     for (var schedule in expiredSchedules) {
//       debugPrint(
//           "Removing expired schedule for date: ${_formatDate(schedule.date)}");
//       removeSchedule(schedule);
//     }
//
//     if (expiredSchedules.isNotEmpty) {
//       debugPrint("Cleaned up ${expiredSchedules.length} expired schedules");
//     }
//   }
//
//   void togglePlayPause() {
//     if (schedules.isEmpty) {
//       debugPrint("No schedules available to play/pause");
//       return;
//     }
//
//     if (isPaused.value) {
//       resumeAllSchedules();
//     } else if (isPlaying.value) {
//       pauseAllSchedules();
//     } else {
//       startAllSchedules();
//     }
//   }
//
//   void pauseAllSchedules() {
//     debugPrint("Pausing all schedules");
//
//     for (var schedule in schedules) {
//       _timers[schedule]?.cancel();
//       _players[schedule]?.pause();
//     }
//
//     isPaused.value = true;
//     isPlaying.value = false;
//   }
//
//   void resumeAllSchedules() {
//     debugPrint("Resuming all schedules");
//
//     for (var schedule in schedules) {
//       _restartSchedule(schedule);
//     }
//
//     isPaused.value = false;
//     isPlaying.value = true;
//   }
//
//   void startAllSchedules() {
//     debugPrint("Starting all schedules");
//
//     for (var schedule in schedules) {
//       _restartSchedule(schedule);
//     }
//
//     isPaused.value = false;
//     isPlaying.value = true;
//   }
//
//   void _restartSchedule(AudioSchedule schedule) {
//     _timers[schedule]?.cancel();
//     _startSchedule(schedule);
//   }
//
//   void _updatePlayingStatus() {
//     bool hasActiveSchedules = schedules.isNotEmpty && !isPaused.value;
//     isPlaying.value = hasActiveSchedules;
//   }
//
//   void _startSchedule(AudioSchedule schedule) {
//     final now = DateTime.now();
//
//     // Create the exact schedule date and time
//     DateTime scheduleStart = DateTime(
//       schedule.date.year,
//       schedule.date.month,
//       schedule.date.day,
//       schedule.startTime.hour,
//       schedule.startTime.minute,
//     );
//
//     DateTime scheduleEnd = DateTime(
//       schedule.date.year,
//       schedule.date.month,
//       schedule.date.day,
//       schedule.endTime.hour,
//       schedule.endTime.minute,
//     );
//
//     // Handle overnight schedules (end time next day)
//     if (scheduleEnd.isBefore(scheduleStart) ||
//         scheduleEnd.isAtSameMomentAs(scheduleStart)) {
//       scheduleEnd = scheduleEnd.add(const Duration(days: 1));
//       debugPrint("Schedule spans overnight, end time adjusted to next day");
//     }
//
//     // Create a dedicated player for this schedule if it doesn't exist
//     if (!_players.containsKey(schedule)) {
//       final player = AudioPlayer();
//       _players[schedule] = player;
//     }
//
//     final player = _players[schedule]!;
//
//     debugPrint("=== SCHEDULE DETAILS ===");
//     debugPrint("Schedule Date: ${_formatDate(schedule.date)}");
//     debugPrint(
//         "Start Time: ${_formatTime(schedule.startTime)} ($scheduleStart)");
//     debugPrint("End Time: ${_formatTime(schedule.endTime)} ($scheduleEnd)");
//     debugPrint("Current Time: $now");
//     debugPrint("Interval: ${schedule.interval} seconds");
//     debugPrint("Sound: ${schedule.soundPath}");
//     debugPrint("=======================");
//
//     // Function to check if we should play audio now
//     bool shouldPlayNow() {
//       final current = DateTime.now();
//       final isInTimeWindow =
//           current.isAfter(scheduleStart) && current.isBefore(scheduleEnd);
//       debugPrint("Should play now? $isInTimeWindow (Current: $current)");
//       return isInTimeWindow;
//     }
//
//     // Play immediately if we're in the active time window and not paused
//     if (shouldPlayNow() && !isPaused.value) {
//       debugPrint(
//           "🎵 Playing immediately for schedule on ${_formatDate(schedule.date)}");
//       _playAudio(player, schedule.soundPath);
//       isPlaying.value = true;
//     } else {
//       debugPrint("⏰ Waiting for schedule time window");
//     }
//
//     // Set up periodic timer
//     Timer timer = Timer.periodic(
//       Duration(minutes: schedule.interval),
//       (timer) async {
//         // Don't play if paused
//         if (isPaused.value) {
//           debugPrint("⏸️ Skipping play - system is paused");
//           return;
//         }
//
//         final current = DateTime.now();
//
//         // Check if we're still on the correct date
//         final currentDate = DateTime(current.year, current.month, current.day);
//         final scheduleDate = DateTime(
//             schedule.date.year, schedule.date.month, schedule.date.day);
//
//         // Recalculate schedule times for the scheduled date
//         DateTime currentScheduleStart = DateTime(
//           schedule.date.year,
//           schedule.date.month,
//           schedule.date.day,
//           schedule.startTime.hour,
//           schedule.startTime.minute,
//         );
//
//         DateTime currentScheduleEnd = DateTime(
//           schedule.date.year,
//           schedule.date.month,
//           schedule.date.day,
//           schedule.endTime.hour,
//           schedule.endTime.minute,
//         );
//
//         // Handle overnight schedules
//         if (currentScheduleEnd.isBefore(currentScheduleStart) ||
//             currentScheduleEnd.isAtSameMomentAs(currentScheduleStart)) {
//           currentScheduleEnd = currentScheduleEnd.add(const Duration(days: 1));
//         }
//
//         debugPrint("📅 Timer check for ${_formatDate(schedule.date)}:");
//         debugPrint("   Current: $current");
//         debugPrint("   Schedule Start: $currentScheduleStart");
//         debugPrint("   Schedule End: $currentScheduleEnd");
//
//         // Check if we're in the correct date and time window
//         bool isCorrectDate = currentDate.isAtSameMomentAs(scheduleDate) ||
//             (currentScheduleEnd.day != currentScheduleStart.day &&
//                 (currentDate.isAtSameMomentAs(scheduleDate) ||
//                     currentDate.isAtSameMomentAs(
//                         scheduleDate.add(const Duration(days: 1)))));
//
//         bool isInTimeWindow = current.isAfter(currentScheduleStart) &&
//             current.isBefore(currentScheduleEnd);
//
//         if (isCorrectDate && isInTimeWindow) {
//           debugPrint(
//               "🎵 Playing audio for schedule on ${_formatDate(schedule.date)}");
//           await _playAudio(player, schedule.soundPath);
//           isPlaying.value = true;
//         } else {
//           if (!isCorrectDate) {
//             debugPrint(
//                 "📅 Not the scheduled date - Current: ${_formatDate(currentDate)}, Scheduled: ${_formatDate(scheduleDate)}");
//           }
//           if (!isInTimeWindow) {
//             debugPrint("⏰ Outside time window");
//           }
//         }
//       },
//     );
//
//     _timers[schedule] = timer;
//   }
//
//   Future<void> _playAudio(AudioPlayer player, String path) async {
//     try {
//       if (isPaused.value) {
//         debugPrint("🔇 Audio play skipped - system is paused");
//         return;
//       }
//
//       await player.stop();
//
//       if (path.startsWith('api:')) {
//         // Handle API sounds: format is "api:id:url"
//         final parts = path.split(':');
//         if (parts.length >= 3) {
//           final url =
//               parts.sublist(2).join(':'); // Rejoin in case URL has colons
//           await player.setUrl(url);
//           debugPrint("🌐 Loading API sound from URL: $url");
//         }
//       } else if (path.startsWith('assets/')) {
//         await player.setAsset(path);
//         debugPrint("📱 Loading asset sound: $path");
//       } else {
//         await player.setFilePath(path);
//         debugPrint("📂 Loading file sound: $path");
//       }
//
//       await player.play();
//       debugPrint("🎵 Audio played successfully: ${getSoundDisplayName(path)}");
//     } catch (e) {
//       debugPrint("❌ Audio play error: $e");
//       AppSnackBar.adaptive(
//           'Error', 'Failed to play audio: ${getSoundDisplayName(path)}');
//     }
//   }
//
//   String getSoundDisplayName(String path) {
//     if (path.startsWith('api:')) {
//       // Handle API sounds: format is "api:id:url"
//       final parts = path.split(':');
//       if (parts.length >= 3) {
//         final soundId = parts[1];
//         // Find the API sound by ID to get its name
//         final apiSound = apiSounds
//             .firstWhereOrNull((sound) => sound['id'].toString() == soundId);
//         if (apiSound != null) {
//           return apiSound['name']?.toString().toUpperCase() ??
//               'API Sound $soundId';
//         }
//         return 'API Sound $soundId';
//       }
//       return 'API Sound';
//     }
//
//     return path.split('/').last.replaceAll(RegExp(r'\.(mp3|wav|aac)$'), '');
//   }
//
//   bool isApiSound(String path) {
//     return path.startsWith('api:');
//   }
//
//   bool isAssetSound(String path) {
//     return path.startsWith('assets/');
//   }
//
//   bool isUploadedSound(String path) {
//     return !isApiSound(path) && !isAssetSound(path);
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//   }
//
//   String _formatTime(TimeOfDay time) {
//     final hour = time.hourOfPeriod.toString().padLeft(2, '0');
//     final minute = time.minute.toString().padLeft(2, '0');
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }
//
//   // Get schedules for a specific date
//   List<AudioSchedule> getSchedulesForDate(DateTime date) {
//     final targetDate = DateTime(date.year, date.month, date.day);
//     return schedules.where((schedule) {
//       final scheduleDate =
//           DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
//       return scheduleDate.isAtSameMomentAs(targetDate);
//     }).toList();
//   }
//
//   // Get all unique scheduled dates
//   List<DateTime> getScheduledDates() {
//     return schedules
//         .map((schedule) => DateTime(
//             schedule.date.year, schedule.date.month, schedule.date.day))
//         .toSet()
//         .toList()
//       ..sort();
//   }
//
//   @override
//   void onClose() {
//     for (var timer in _timers.values) {
//       timer.cancel();
//     }
//     for (var player in _players.values) {
//       player.dispose();
//     }
//     super.onClose();
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:birdo/controller/dto.dart';
import 'package:birdo/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioSchedulerController extends GetxController {
  RxList<AudioSchedule> schedules = <AudioSchedule>[].obs;
  RxBool isPaused = false.obs;
  RxBool isPlaying = false.obs;
  RxBool isLoadingSounds = false.obs;
  RxBool isLoadingSchedules = false.obs;
  RxBool isUpdatingPlayStatus = false.obs;

  final Map<AudioSchedule, Timer> _timers = {};
  final Map<AudioSchedule, AudioPlayer> _players = {};

  RxList<String> availableSounds = <String>[].obs;
  RxList<Map<String, dynamic>> apiSounds = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAvailableSounds();
    // Clean up expired schedules every hour
    Timer.periodic(const Duration(hours: 1), (timer) {
      _cleanupExpiredSchedules();
    });
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Adjust key based on your token storage
  }

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id'); // Adjust key based on your user ID storage
  }

  // API: Get schedules from server
  Future<void> loadSchedulesFromApi() async {
    // Prevent concurrent calls
    if (isLoadingSchedules.value) {
      debugPrint('loadSchedulesFromApi already in progress, skipping...');
      return;
    }

    isLoadingSchedules.value = true;
    try {
      String? token = await _getAuthToken();
      int? userId = await _getUserId();

      if (token == null || userId == null) {
        debugPrint('No auth token or user ID found for loading schedules');
        AppSnackBar.adaptive(
            'Error', 'Authentication required. Please login again.');
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.thebirdo.com/api/get_notifications/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Clear existing schedules
        schedules.clear();

        // Stop all existing timers and players
        // for (var timer in _timers.values) {
        //   timer.cancel();
        // }
        // for (var player in _players.values) {
        //   player.dispose();
        // }
        // _timers.clear();
        // _players.clear();

        if (data['data'] != null && data['data'] is List) {
          debugPrint(
              '🔍 DEBUG: Received ${data['data'].length} notifications from API');
          for (var notification in data['data']) {
            debugPrint('🔍 DEBUG: Processing notification: $notification');
            try {
              // Parse the API response into AudioSchedule
              final schedule = _parseNotificationToSchedule(notification);
              if (schedule != null) {
                schedules.add(schedule);
                debugPrint(
                    '🔍 DEBUG: Successfully parsed schedule with sounds: ${schedule.soundPaths}');
                // Start the schedule if it's active
                if (notification['activate'] == 1) {
                  isPlaying.value = true;
                  isPaused.value = false;
                } else {
                  isPlaying.value = false;
                  isPaused.value = true;
                }
              }
            } catch (e) {
              debugPrint('Error parsing notification: $e');
              debugPrint('🔍 DEBUG: Failed notification data: $notification');
            }
          }

          debugPrint('Loaded ${schedules.length} schedules from API');
          _updatePlayingStatus();
        }
      } else if (response.statusCode == 401) {
        debugPrint('Unauthenticated: ${response.body}');
        AppSnackBar.adaptive(
            'Error', 'Authentication failed. Please login again.');
      } else {
        debugPrint(
            'Error fetching schedules: ${response.statusCode} - ${response.body}');
        AppSnackBar.adaptive('Error', 'Failed to load schedules from server.');
      }
    } catch (e) {
      debugPrint('Exception while fetching schedules: $e');
      AppSnackBar.adaptive(
          'Error', 'Network error. Please check your connection.');
    } finally {
      isLoadingSchedules.value = false;
    }
  }

  // Helper method to parse API notification to AudioSchedule
  AudioSchedule? _parseNotificationToSchedule(
      Map<String, dynamic> notification) {
    try {
      // Parse dates
      final startDate = DateTime.parse(notification['start_date']);
      final endDate = DateTime.parse(notification['end_date']);

      // Parse times
      final startTimeParts = notification['start_time'].split(':');
      final startTime = TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      );

      final endTimeParts = notification['end_time'].split(':');
      final endTime = TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      );

      // Find sound path(s) by sound_id (can be single int or array)
      String soundPath = '';
      List<String> soundPaths = [];
      final soundIdData = notification['sound_id'];

      debugPrint(
          '🔍 DEBUG: Parsing sound_id: $soundIdData (type: ${soundIdData.runtimeType})');

      if (soundIdData is List) {
        // Handle array of sound IDs
        for (dynamic soundId in soundIdData) {
          final apiSound = apiSounds.firstWhereOrNull(
            (sound) => sound['id'] == soundId,
          );
          if (apiSound != null) {
            soundPaths.add(apiSound['name']);
            debugPrint(
                '🔍 DEBUG: Found sound: ${apiSound['name']} for ID: $soundId');
          } else {
            debugPrint('🔍 DEBUG: Sound not found for ID: $soundId');
          }
        }
        soundPath = soundPaths.isNotEmpty ? soundPaths.first : '';
      } else {
        // Handle single sound ID (backward compatibility)
        final apiSound = apiSounds.firstWhereOrNull(
          (sound) => sound['id'] == soundIdData,
        );
        if (apiSound != null) {
          soundPath = apiSound['name'];
          soundPaths = [apiSound['name']];
          debugPrint(
              '🔍 DEBUG: Found single sound: ${apiSound['name']} for ID: $soundIdData');
        } else {
          debugPrint('🔍 DEBUG: Sound not found for ID: $soundIdData');
          return null;
        }
      }

      if (soundPaths.isEmpty) {
        debugPrint('🔍 DEBUG: No valid sounds found');
        return null;
      }

      return AudioSchedule(
        id: notification['id'], // Store API ID for updates/deletes
        date: startDate,
        startTime: startTime,
        endTime: endTime,
        soundPath: soundPath,
        soundPaths: soundPaths,
        interval:
            notification['interval'] ?? 60, // Default to 60 seconds if null
        endDate: endDate, // Store end date for multi-day schedules
        isActive: notification['activate'] == 1,
      );
    } catch (e) {
      debugPrint('Error parsing notification to schedule: $e');
      return null;
    }
  }

  // API: Create schedule on server
  Future<bool> createScheduleOnApi(AudioSchedule schedule) async {
    try {
      String? token = await _getAuthToken();
      int? userId = await _getUserId();

      if (token == null || userId == null) {
        debugPrint('No auth token or user ID found for creating schedule');
        AppSnackBar.adaptive(
            'Error', 'Authentication required. Please login again.');
        return false;
      }

      // Find sound IDs from sound names
      List<int> soundIds = [];
      debugPrint(
          "🔍 DEBUG: schedule.soundPaths in createScheduleOnApi: ${schedule.soundPaths}");
      debugPrint(
          "🔍 DEBUG: schedule.soundPath in createScheduleOnApi: ${schedule.soundPath}");
      debugPrint(
          "🔍 DEBUG: schedule.effectiveSoundPaths in createScheduleOnApi: ${schedule.effectiveSoundPaths}");

      // Use effective sound paths (handles both multiple and single sounds)
      for (String soundName in schedule.effectiveSoundPaths) {
        final apiSound = apiSounds.firstWhereOrNull(
          (sound) => sound['name'] == soundName,
        );
        if (apiSound != null) {
          soundIds.add(apiSound['id']);
          debugPrint(
              "🔍 DEBUG: Found sound ID ${apiSound['id']} for sound $soundName");
        } else {
          debugPrint('Sound not found: $soundName');
        }
      }

      if (soundIds.isEmpty) {
        debugPrint('No valid sounds found');
        AppSnackBar.adaptive('Error', 'No valid sounds found');
        return false;
      }

      final requestBody = {
        "start_date":
            "${schedule.date.year}-${schedule.date.month.toString().padLeft(2, '0')}-${schedule.date.day.toString().padLeft(2, '0')}",
        "end_date": schedule.endDate != null
            ? "${schedule.endDate!.year}-${schedule.endDate!.month.toString().padLeft(2, '0')}-${schedule.endDate!.day.toString().padLeft(2, '0')}"
            : "${schedule.date.year}-${schedule.date.month.toString().padLeft(2, '0')}-${schedule.date.day.toString().padLeft(2, '0')}",
        "start_time":
            "${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')}",
        "end_time":
            "${schedule.endTime.hour.toString().padLeft(2, '0')}:${schedule.endTime.minute.toString().padLeft(2, '0')}",
        "interval": schedule.interval,
        "sound_id": soundIds,
        "user_id": userId,
        "activate": 1
      };

      debugPrint('Creating schedule with data: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('https://api.thebirdo.com/api/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      final data = json.decode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201 && data['status']) {
        debugPrint(data['message']);
        return true;
      } else {
        debugPrint(
            'Error creating schedule: ${response.statusCode} - ${response.body}');
        AppSnackBar.adaptive(
            'Error', data['message'] ?? 'Failed to create schedule');
        return false;
      }
    } catch (e) {
      debugPrint('Exception while creating schedule: $e');
      AppSnackBar.adaptive(
          'Error', 'Network error. Please check your connection.');
      return false;
    }
  }

  // API: Delete schedule from server
  Future<bool> deleteScheduleFromApi(int scheduleId) async {
    try {
      String? token = await _getAuthToken();

      if (token == null) {
        debugPrint('No auth token found for deleting schedule');
        AppSnackBar.adaptive(
            'Error', 'Authentication required. Please login again.');
        return false;
      }

      final response = await http.delete(
        Uri.parse('https://api.thebirdo.com/api/notifications/$scheduleId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Schedule deleted successfully from server');
        return true;
      } else {
        debugPrint(
            'Error deleting schedule: ${response.statusCode} - ${response.body}');
        AppSnackBar.adaptive('Error', 'Failed to delete schedule from server');
        return false;
      }
    } catch (e) {
      debugPrint('Exception while deleting schedule: $e');
      AppSnackBar.adaptive(
          'Error', 'Network error. Please check your connection.');
      return false;
    }
  }

  // API: Manage play/pause status on server
  Future<bool> updatePlayStatusOnApi(bool isActive) async {
    try {
      String? token = await _getAuthToken();
      int? userId = await _getUserId();

      if (token == null || userId == null) {
        debugPrint('No auth token or user ID found for updating play status');
        AppSnackBar.adaptive(
            'Error', 'Authentication required. Please login again.');
        return false;
      }

      final requestBody = {
        "activate": isActive ? 1 : 0,
        "user_id": userId,
      };

      debugPrint('Updating play status with data: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('https://api.thebirdo.com/api/manage_status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        debugPrint(
            'Play status updated successfully on server: ${isActive ? "ACTIVE" : "INACTIVE"}');
        return true;
      } else {
        debugPrint(
            'Error updating play status: ${response.statusCode} - ${response.body}');
        final errorData = json.decode(response.body);
        AppSnackBar.adaptive(
            'Error', errorData['message'] ?? 'Failed to update play status');
        return false;
      }
    } catch (e) {
      debugPrint('Exception while updating play status: $e');
      AppSnackBar.adaptive(
          'Error', 'Network error. Please check your connection.');
      return false;
    }
  }

  Future<void> _fetchApiSounds() async {
    apiSounds.clear();
    availableSounds.clear();
    try {
      String? token = await _getAuthToken();

      // if (token == null) {
      //   debugPrint('No auth token found for API sounds');
      //   return;
      // }

      final response = await http.get(
        Uri.parse('https://api.thebirdo.com/api/user-sounds'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['sounds'] != null && data['sounds'] is List) {
          // Clear existing API sounds

          // Add API sounds with metadata
          for (var apiSound in data['sounds']) {
            availableSounds.add(apiSound['name']);
            apiSounds.add({
              'id': apiSound['id'],
              'name': apiSound['name']?.toString() ?? 'Unknown',
              'path': apiSound['path'],
              'url': 'https://thebirdo.com/uploads/sounds/${apiSound['path']}',
              'isLocal': false,
            });
          }

          debugPrint('Loaded ${apiSounds.length} sounds from API');
        }
      } else if (response.statusCode == 401) {
        debugPrint('Unauthenticated: ${response.body}');
        AppSnackBar.adaptive(
            'Error', 'Authentication failed. Please login again.');
      } else {
        debugPrint(
            'Error fetching sounds: ${response.statusCode} - ${response.body}');
        AppSnackBar.adaptive('Error', 'Failed to load sounds from server.');
      }
    } catch (e) {
      debugPrint('Exception while fetching API sounds: $e');
      AppSnackBar.adaptive(
          'Error', 'Network error. Please check your connection.');
    }
  }

  Future<void> loadAvailableSounds() async {
    isLoadingSounds.value = true;

    try {
      // Fetch API sounds
      await _fetchApiSounds();
    } finally {
      isLoadingSounds.value = false;
      loadSchedulesFromApi(); // Load schedules from API on init
    }
  }

  Future<void> refreshSounds() async {
    await loadAvailableSounds();
    // Also reload schedules to get updated sound references
    await loadSchedulesFromApi();
  }

  // Updated addSchedule method to use API
  void addSchedule(AudioSchedule schedule) async {
    // Add validation for date
    final now = DateTime.now();
    final scheduleDate =
        DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
    final today = DateTime(now.year, now.month, now.day);

    debugPrint("Adding schedule for date: ${_formatDate(schedule.date)}");
    debugPrint("Today's date: ${_formatDate(today)}");

    if (scheduleDate.isBefore(today)) {
      AppSnackBar.adaptive('Error', 'Cannot schedule for past dates');
      return;
    }

    // Prevent adding schedule while loading schedules
    // if (isLoadingSchedules.value) {
    //   AppSnackBar.adaptive('Please wait',
    //       'Schedules are being loaded. Please try again in a moment.');
    //   return;
    // }

    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      debugPrint(
          "🔍 DEBUG: schedule.soundPaths in addSchedule: ${schedule.soundPaths}");
      debugPrint(
          "🔍 DEBUG: schedule.soundPath in addSchedule: ${schedule.soundPath}");
      debugPrint(
          "🔍 DEBUG: schedule.effectiveSoundPaths in addSchedule: ${schedule.effectiveSoundPaths}");

      // Create schedule on API first
      bool success = await createScheduleOnApi(schedule);

      // Close loading dialog safely
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // Reload schedules from API to get the updated list with IDs
        await loadSchedulesFromApi();
        AppSnackBar.adaptive('Success', 'Schedule created successfully');
      }
    } catch (e) {
      // Close loading dialog safely
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      debugPrint("Error adding schedule: $e");
      AppSnackBar.adaptive('Error', 'Failed to create schedule');
    }
  }

  // Updated removeSchedule method to use API
  void removeSchedule(AudioSchedule schedule) async {
    if (schedule.id == null) {
      debugPrint('Cannot delete schedule without ID');
      AppSnackBar.adaptive('Error', 'Cannot delete schedule');
      return;
    }

    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Delete Schedule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34BB91),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this schedule?\n\nDate: ${schedule.formattedDate}\nTime: ${schedule.formattedStartTime} - ${schedule.formattedEndTime}\nSound: ${schedule.soundDisplayName}\n\nThis action cannot be undone.',
          style: const TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _confirmDeleteSchedule(schedule);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to actually delete the schedule after confirmation
  void _confirmDeleteSchedule(AudioSchedule schedule) async {
    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      // Delete from API first
      bool success = await deleteScheduleFromApi(schedule.id!);

      // Close loading dialog safely
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // Remove locally
        _timers[schedule]?.cancel();
        _players[schedule]?.dispose();
        _timers.remove(schedule);
        _players.remove(schedule);
        schedules.remove(schedule);

        debugPrint(
            "Schedule removed. Remaining schedules: ${schedules.length}");
        _updatePlayingStatus();
        // AppSnackBar.adaptive('Success', 'Schedule deleted successfully',
        //     duration: Duration(seconds: 2));

        // Reload schedules from API to ensure consistency
        await loadSchedulesFromApi();
      }
    } catch (e) {
      // Close loading dialog safely
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      debugPrint("Error removing schedule: $e");
      AppSnackBar.adaptive('Error', 'Failed to delete schedule');
    }
  }

  void _cleanupExpiredSchedules() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final expiredSchedules = schedules.where((schedule) {
      final scheduleDate =
          DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
      return scheduleDate.isBefore(today);
    }).toList();

    for (var schedule in expiredSchedules) {
      debugPrint(
          "Removing expired schedule for date: ${_formatDate(schedule.date)}");
      // For expired schedules, just remove locally without API call
      _timers[schedule]?.cancel();
      _players[schedule]?.dispose();
      _timers.remove(schedule);
      _players.remove(schedule);
      schedules.remove(schedule);
    }

    if (expiredSchedules.isNotEmpty) {
      debugPrint("Cleaned up ${expiredSchedules.length} expired schedules");
      _updatePlayingStatus();
    }
  }

  void togglePlayPause() {
    if (isUpdatingPlayStatus.value) {
      debugPrint("Play status update already in progress");
      return;
    }

    if (schedules.isEmpty) {
      debugPrint("No schedules available to play/pause");
      return;
    }

    isUpdatingPlayStatus.value = true;

    Get.showOverlay(
      asyncFunction: () async {
        try {
          bool newActiveState;

          if (isPaused.value) {
            // Resume
            newActiveState = true;
            debugPrint("Attempting to resume schedules via API");
          } else if (isPlaying.value) {
            // Pause
            newActiveState = false;
            debugPrint("Attempting to pause schedules via API");
          } else {
            // Start
            newActiveState = true;
            debugPrint("Attempting to start schedules via API");
          }

          // Update status on API first
          bool success = await updatePlayStatusOnApi(newActiveState);

          if (success) {
            // Update local state based on the new active state
            if (newActiveState) {
              if (isPaused.value) {
                // resumeAllSchedulesLocal();
                isPaused.value = false;
                isPlaying.value = true;
              } else {
                isPaused.value = false;
                isPlaying.value = true;
                // startAllSchedulesLocal();
              }
            } else {
              isPaused.value = true;
              isPlaying.value = false;
              // pauseAllSchedulesLocal();
            }

            AppSnackBar.adaptive('Success',
                newActiveState ? 'Schedules activated' : 'Schedules paused');
          } else {
            AppSnackBar.adaptive(
                'Error', 'Failed to update schedule status on server');
          }
        } catch (e) {
          debugPrint("Error toggling play/pause: $e");
          AppSnackBar.adaptive('Error', 'Failed to update schedule status');
        } finally {
          isUpdatingPlayStatus.value = false;
        }
      },
      loadingWidget: const Center(child: CircularProgressIndicator()),
      opacity: 0,
    );
  }

  void pauseAllSchedules() async {
    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      bool success = await updatePlayStatusOnApi(false);

      Get.back(); // Close loading dialog

      if (success) {
        isPaused.value = true;
        isPlaying.value = false;
        // pauseAllSchedulesLocal();
        AppSnackBar.adaptive('Success', 'All schedules paused');
      } else {
        AppSnackBar.adaptive('Error', 'Failed to pause schedules on server');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      debugPrint("Error pausing schedules: $e");
      AppSnackBar.adaptive('Error', 'Failed to pause schedules');
    }
  }

  void resumeAllSchedules() async {
    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      bool success = await updatePlayStatusOnApi(true);

      Get.back(); // Close loading dialog

      if (success) {
        isPaused.value = false;
        isPlaying.value = true;
        // resumeAllSchedulesLocal();
        AppSnackBar.adaptive('Success', 'All schedules resumed');
      } else {
        AppSnackBar.adaptive('Error', 'Failed to resume schedules on server');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      debugPrint("Error resuming schedules: $e");
      AppSnackBar.adaptive('Error', 'Failed to resume schedules');
    }
  }

  void startAllSchedules() async {
    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      bool success = await updatePlayStatusOnApi(true);

      Get.back(); // Close loading dialog

      if (success) {
        isPaused.value = false;
        isPlaying.value = true;
        // startAllSchedulesLocal();
        AppSnackBar.adaptive('Success', 'All schedules started');
      } else {
        AppSnackBar.adaptive('Error', 'Failed to start schedules on server');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      debugPrint("Error starting schedules: $e");
      AppSnackBar.adaptive('Error', 'Failed to start schedules');
    }
  }

  // Local-only methods (renamed from original methods)
  void pauseAllSchedulesLocal() {
    debugPrint("Pausing all schedules locally");

    for (var schedule in schedules) {
      _timers[schedule]?.cancel();
      _players[schedule]?.pause();
    }

    isPaused.value = true;
    isPlaying.value = false;
  }

  void resumeAllSchedulesLocal() {
    debugPrint("Resuming all schedules locally");

    for (var schedule in schedules) {
      _restartSchedule(schedule);
    }

    isPaused.value = false;
    isPlaying.value = true;
  }

  void startAllSchedulesLocal() {
    debugPrint("Starting all schedules locally");

    for (var schedule in schedules) {
      _restartSchedule(schedule);
    }

    isPaused.value = false;
    isPlaying.value = true;
  }

  void _restartSchedule(AudioSchedule schedule) {
    _timers[schedule]?.cancel();
    _startSchedule(schedule);
  }

  void _updatePlayingStatus() {
    bool hasActiveSchedules = schedules.isNotEmpty && !isPaused.value;
    isPlaying.value = hasActiveSchedules;
  }

  void _startSchedule(AudioSchedule schedule) {
    final now = DateTime.now();

    // Create the exact schedule date and time
    DateTime scheduleStart = DateTime(
      schedule.date.year,
      schedule.date.month,
      schedule.date.day,
      schedule.startTime.hour,
      schedule.startTime.minute,
    );

    DateTime scheduleEnd = DateTime(
      schedule.date.year,
      schedule.date.month,
      schedule.date.day,
      schedule.endTime.hour,
      schedule.endTime.minute,
    );

    // Handle overnight schedules (end time next day)
    if (scheduleEnd.isBefore(scheduleStart) ||
        scheduleEnd.isAtSameMomentAs(scheduleStart)) {
      scheduleEnd = scheduleEnd.add(const Duration(days: 1));
      debugPrint("Schedule spans overnight, end time adjusted to next day");
    }

    // Create a dedicated player for this schedule if it doesn't exist
    if (!_players.containsKey(schedule)) {
      final player = AudioPlayer();
      _players[schedule] = player;
    }

    final player = _players[schedule]!;

    debugPrint("=== SCHEDULE DETAILS ===");
    debugPrint("Schedule Date: ${_formatDate(schedule.date)}");
    debugPrint(
        "Start Time: ${_formatTime(schedule.startTime)} ($scheduleStart)");
    debugPrint("End Time: ${_formatTime(schedule.endTime)} ($scheduleEnd)");
    debugPrint("Current Time: $now");
    final minutes = schedule.interval ~/ 60;
    final seconds = schedule.interval % 60;
    debugPrint(
        "Interval: ${schedule.interval} seconds (${minutes}m ${seconds}s)");
    debugPrint("Sound: ${schedule.soundPath}");
    debugPrint("=======================");

    // Function to check if we should play audio now
    bool shouldPlayNow() {
      final current = DateTime.now();
      final isInTimeWindow =
          current.isAfter(scheduleStart) && current.isBefore(scheduleEnd);
      debugPrint("Should play now? $isInTimeWindow (Current: $current)");
      return isInTimeWindow;
    }

    // Play immediately if we're in the active time window and not paused
    if (shouldPlayNow() && !isPaused.value) {
      debugPrint(
          "🎵 Playing immediately for schedule on ${_formatDate(schedule.date)}");
      _playAudio(player, schedule.soundPath);
      isPlaying.value = true;
    } else {
      debugPrint("⏰ Waiting for schedule time window");
    }

    // Set up periodic timer
    Timer timer = Timer.periodic(
      Duration(seconds: schedule.interval),
      (timer) async {
        // Don't play if paused
        if (isPaused.value) {
          debugPrint("⏸️ Skipping play - system is paused");
          return;
        }

        final current = DateTime.now();

        // Check if we're still on the correct date
        final currentDate = DateTime(current.year, current.month, current.day);
        final scheduleDate = DateTime(
            schedule.date.year, schedule.date.month, schedule.date.day);

        // Recalculate schedule times for the scheduled date
        DateTime currentScheduleStart = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
          schedule.startTime.hour,
          schedule.startTime.minute,
        );

        DateTime currentScheduleEnd = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
          schedule.endTime.hour,
          schedule.endTime.minute,
        );

        // Handle overnight schedules
        if (currentScheduleEnd.isBefore(currentScheduleStart) ||
            currentScheduleEnd.isAtSameMomentAs(currentScheduleStart)) {
          currentScheduleEnd = currentScheduleEnd.add(const Duration(days: 1));
        }

        debugPrint("📅 Timer check for ${_formatDate(schedule.date)}:");
        debugPrint("   Current: $current");
        debugPrint("   Schedule Start: $currentScheduleStart");
        debugPrint("   Schedule End: $currentScheduleEnd");

        // Check if we're in the correct date and time window
        bool isCorrectDate = currentDate.isAtSameMomentAs(scheduleDate) ||
            (currentScheduleEnd.day != currentScheduleStart.day &&
                (currentDate.isAtSameMomentAs(scheduleDate) ||
                    currentDate.isAtSameMomentAs(
                        scheduleDate.add(const Duration(days: 1)))));

        bool isInTimeWindow = current.isAfter(currentScheduleStart) &&
            current.isBefore(currentScheduleEnd);

        if (isCorrectDate && isInTimeWindow) {
          debugPrint(
              "🎵 Playing audio for schedule on ${_formatDate(schedule.date)}");
          await _playAudio(player, schedule.soundPath);
          isPlaying.value = true;
        } else {
          if (!isCorrectDate) {
            debugPrint(
                "📅 Not the scheduled date - Current: ${_formatDate(currentDate)}, Scheduled: ${_formatDate(scheduleDate)}");
          }
          if (!isInTimeWindow) {
            debugPrint("⏰ Outside time window");
          }
        }
      },
    );

    _timers[schedule] = timer;
  }

  Future<void> _playAudio(AudioPlayer player, String soundName) async {
    try {
      if (isPaused.value) {
        debugPrint("🔇 Audio play skipped - system is paused");
        return;
      }

      await player.stop();

      // Find the sound URL from apiSounds by name
      final apiSound = apiSounds.firstWhereOrNull(
        (sound) => sound['name'] == soundName,
      );

      if (apiSound != null) {
        final url = apiSound['url'];
        await player.setUrl(url);
        debugPrint("🌐 Loading API sound from URL: $url");
      } else {
        debugPrint("❌ Sound not found: $soundName");
        return;
      }

      await player.play();
      debugPrint("🎵 Audio played successfully: $soundName");
    } catch (e) {
      debugPrint("❌ Audio play error: $e");
      AppSnackBar.adaptive('Error', 'Failed to play audio: $soundName');
    }
  }

  String getSoundDisplayName(String soundName) {
    return soundName.toUpperCase();
  }

  bool isApiSound(String path) {
    return true; // All sounds are now API sounds
  }

  bool isAssetSound(String path) {
    return false; // No asset sounds anymore
  }

  bool isUploadedSound(String path) {
    return false; // No uploaded sounds anymore
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Get schedules for a specific date
  List<AudioSchedule> getSchedulesForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return schedules.where((schedule) {
      final scheduleDate =
          DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
      return scheduleDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Get all unique scheduled dates
  List<DateTime> getScheduledDates() {
    return schedules
        .map((schedule) => DateTime(
            schedule.date.year, schedule.date.month, schedule.date.day))
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void onClose() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    for (var player in _players.values) {
      player.dispose();
    }
    super.onClose();
  }
}

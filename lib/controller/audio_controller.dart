import 'package:birdo/controller/dto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class AudioSchedulerController extends GetxController {
  RxList<AudioSchedule> schedules = <AudioSchedule>[].obs;
  RxBool isPaused = false.obs;
  RxBool isPlaying = false.obs;

  final Map<AudioSchedule, Timer> _timers = {};
  final Map<AudioSchedule, AudioPlayer> _players = {};

  RxList<String> availableSounds = <String>[].obs;

  final List<String> assetSounds = [
    'assets/images/eagle.mp3',
    'assets/images/owl1.mp3',
    'assets/images/punchsound.mp3',
  ];

  @override
  void onInit() {
    super.onInit();
    loadAvailableSounds();
    // Clean up expired schedules every hour
    Timer.periodic(const Duration(hours: 1), (timer) {
      _cleanupExpiredSchedules();
    });
  }

  Future<void> loadAvailableSounds() async {
    List<String> allSounds = List.from(assetSounds);

    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      final files = appDocDir.listSync();
      final uploadedSounds = files
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.mp3') ||
              f.path.endsWith('.wav') ||
              f.path.endsWith('.aac'))
          .map((f) => f.path)
          .toList();

      allSounds.addAll(uploadedSounds);
    } catch (e) {
      debugPrint("Error loading uploaded sounds: $e");
    }

    availableSounds.value = allSounds;
  }

  Future<void> refreshSounds() async {
    await loadAvailableSounds();
  }

  void addSchedule(AudioSchedule schedule) {
    // Add validation for date
    final now = DateTime.now();
    final scheduleDate =
        DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
    final today = DateTime(now.year, now.month, now.day);

    debugPrint("Adding schedule for date: ${_formatDate(schedule.date)}");
    debugPrint("Today's date: ${_formatDate(today)}");

    if (scheduleDate.isBefore(today)) {
      Get.snackbar('Error', 'Cannot schedule for past dates');
      return;
    }

    schedules.add(schedule);
    _startSchedule(schedule);
    debugPrint(
        "Schedule added successfully. Total schedules: ${schedules.length}");
  }

  void removeSchedule(AudioSchedule schedule) {
    _timers[schedule]?.cancel();
    _players[schedule]?.dispose();
    _timers.remove(schedule);
    _players.remove(schedule);
    schedules.remove(schedule);

    debugPrint("Schedule removed. Remaining schedules: ${schedules.length}");
    _updatePlayingStatus();
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
      removeSchedule(schedule);
    }

    if (expiredSchedules.isNotEmpty) {
      debugPrint("Cleaned up ${expiredSchedules.length} expired schedules");
    }
  }

  void togglePlayPause() {
    if (schedules.isEmpty) {
      debugPrint("No schedules available to play/pause");
      return;
    }

    if (isPaused.value) {
      resumeAllSchedules();
    } else if (isPlaying.value) {
      pauseAllSchedules();
    } else {
      startAllSchedules();
    }
  }

  void pauseAllSchedules() {
    debugPrint("Pausing all schedules");

    for (var schedule in schedules) {
      _timers[schedule]?.cancel();
      _players[schedule]?.pause();
    }

    isPaused.value = true;
    isPlaying.value = false;
  }

  void resumeAllSchedules() {
    debugPrint("Resuming all schedules");

    for (var schedule in schedules) {
      _restartSchedule(schedule);
    }

    isPaused.value = false;
    isPlaying.value = true;
  }

  void startAllSchedules() {
    debugPrint("Starting all schedules");

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
    debugPrint("Interval: ${schedule.interval} seconds");
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

  Future<void> _playAudio(AudioPlayer player, String path) async {
    try {
      if (isPaused.value) {
        debugPrint("🔇 Audio play skipped - system is paused");
        return;
      }

      await player.stop();

      if (path.startsWith('assets/')) {
        await player.setAsset(path);
      } else {
        await player.setFilePath(path);
      }

      await player.play();
      debugPrint("🎵 Audio played successfully: ${getSoundDisplayName(path)}");
    } catch (e) {
      debugPrint("❌ Audio play error: $e");
    }
  }

  String getSoundDisplayName(String path) {
    return path.split('/').last.replaceAll(RegExp(r'\.(mp3|wav|aac)$'), '');
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

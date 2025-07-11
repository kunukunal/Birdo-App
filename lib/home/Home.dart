import 'dart:async';
import 'package:birdo/controller/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birdo/header.dart';
import 'package:birdo/models/time_settings.dart';
import 'package:birdo/home/AudioService.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';

class Home extends StatefulWidget {
  final List<String> pathOrder;
  final TimeSettings? timeSettings;

  const Home({
    super.key,
    required this.pathOrder,
    this.timeSettings,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool status = false;
  Timer? _timer;
  int _currentTrackIndex = 0;
  final controller = Get.find<AudioSchedulerController>();

  @override
  void initState() {
    super.initState();
    _loadStatus(); // Load the saved status from SharedPreferences
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      status = prefs.getBool('birdoStatus') ?? false;
      if (status) _startPlayback(); // Start playback if status was saved as on
    });
  }

  Future<void> _saveStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('birdoStatus', value);
  }

  void _toggleBirdoStatus() {
    setState(() {
      status = !status;
      _saveStatus(status);

      if (status) {
        // Start playback and reset track index when turned on
        _currentTrackIndex = 0; // Reset to start the first track
        _startPlayback();
      } else {
        // Stop playback when turned off
        _timer?.cancel();
        AudioService().stop(); // Stop audio playback
      }
    });
  }

  void _startPlayback() {
    if (widget.timeSettings != null && widget.pathOrder.isNotEmpty) {
      Duration intervalDuration =
          _getIntervalDuration(widget.timeSettings!.interval);

      // Start periodic playback
      _timer = Timer.periodic(intervalDuration, (Timer timer) {
        _playNextTrack();
      });

      // Play the first track immediately when starting
      _playNextTrack(); // Start the first track immediately
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select audio files and set time settings.')),
      );
      setState(() {
        status = false;
      });
      _saveStatus(false);
    }
  }

  Duration _getIntervalDuration(String interval) {
    switch (interval) {
      case 'Sec':
        return const Duration(
            seconds: 60); // Default to minutes if 'Sec' is used
      case 'Min':
      default:
        return const Duration(minutes: 1);
    }
  }

  void _playNextTrack() async {
    if (status && widget.pathOrder.isNotEmpty && widget.timeSettings != null) {
      TimeOfDay now = TimeOfDay.now();
      if (_isWithinTimeWindow(now, widget.timeSettings!)) {
        String currentPath = widget.pathOrder[_currentTrackIndex];
        await AudioService().play(currentPath); // Play audio using AudioService

        // Move to the next track or loop back to the first one
        _currentTrackIndex++;
        if (_currentTrackIndex >= widget.pathOrder.length) {
          _currentTrackIndex = 0; // Loop back to the first track
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Current time is outside the playback window.')),
        );
        _toggleBirdoStatus();
      }
    }
  }

  bool _isWithinTimeWindow(TimeOfDay now, TimeSettings settings) {
    final nowDate = DateTime.now();
    final startDate = DateTime(
      nowDate.year,
      nowDate.month,
      nowDate.day,
      settings.startTime.hour,
      settings.startTime.minute,
    );
    final endDate = DateTime(
      nowDate.year,
      nowDate.month,
      nowDate.day,
      settings.endTime.hour,
      settings.endTime.minute,
    );

    DateTime nowDateTime = DateTime(
      nowDate.year,
      nowDate.month,
      nowDate.day,
      now.hour,
      now.minute,
    );

    DateTime adjustedEndDate = endDate;
    if (endDate.isBefore(startDate)) {
      adjustedEndDate = endDate.add(const Duration(days: 1));
    }

    return nowDateTime.isAfter(startDate) &&
        nowDateTime.isBefore(adjustedEndDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                const Header(),
                if (widget.timeSettings != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Playback Window:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${widget.timeSettings!.startTime.format(context)} to ${widget.timeSettings!.endTime.format(context)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Interval: ${widget.timeSettings!.interval}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      height: 200,
                      width: 250,
                      child: AnalogClock(
                        dateTime: DateTime.now(),
                        isKeepTime: true, // Keep the clock updating
                        child: const Align(
                          alignment: FractionalOffset(0.5, 0.75),
                          child: Text('The Birdo'),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: controller.togglePlayPause,
                  child: Obx(() {
                    String statusText;
                    if (!controller.isPlaying.value &&
                        !controller.isPaused.value) {
                      statusText = 'Not Playing';
                    } else if (controller.isPaused.value) {
                      statusText = 'Start';
                    } else {
                      statusText = 'Pause';
                    }

                    return Container(
                      height: 200,
                      width: 200,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF34BB91),
                            Color(0xFF2F9F7C),
                            Color(0xFF2D7760),
                            Color(0xFF195E48),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

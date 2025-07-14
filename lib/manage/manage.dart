import 'package:birdo/controller/audio_controller.dart';
import 'package:birdo/controller/dto.dart';
import 'package:birdo/manage/widget/sechduel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleInputView extends StatelessWidget {
  ScheduleInputView({super.key});

  final controller = Get.put(AudioSchedulerController());
  final _selectedDate = Rx<DateTime?>(null);
  final _startTime = Rx<TimeOfDay?>(null);
  final _endTime = Rx<TimeOfDay?>(null);
  final _selectedSound = ''.obs;
  final _interval = ''.obs;
  final _intervalController = TextEditingController();

  void _refreshSounds() {
    controller.refreshSounds();
    Get.snackbar('Refreshed', 'Sound list updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 70,
                child: Image.asset('assets/images/logo.png'),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshSounds,
                tooltip: 'Refresh sounds list',
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        // labelText: 'Date',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF34BB91),
                        ),
                      ),
                      child: Text(
                        _selectedDate.value == null
                            ? 'Tap to choose a date'
                            : formatDate(_selectedDate.value!),
                        style: TextStyle(
                          color: _selectedDate.value == null
                              ? Colors.grey[600]
                              : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  /// Start Time Field
                  GestureDetector(
                    onTap: () => _pickTime(context, _startTime),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        // labelText: 'Start Time',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.access_time,
                          color: Color(0xFF34BB91),
                        ),
                      ),
                      child: Text(
                        _startTime.value == null
                            ? 'Tap to start time'
                            : formatTime(_startTime.value),
                        style: TextStyle(
                          color: _startTime.value == null
                              ? Colors.grey[600]
                              : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  /// End Time Field
                  GestureDetector(
                    onTap: () => _pickTime(context, _endTime),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        // labelText: 'End Time',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.access_time_filled,
                          color: Color(0xFF34BB91),
                        ),
                      ),
                      child: Text(
                        _endTime.value == null
                            ? 'Tap to start time'
                            : formatTime(_endTime.value),
                        style: TextStyle(
                          color:
                              _endTime.value == null ? Colors.grey[600] : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Interval Input
                  TextFormField(
                    controller: _intervalController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _interval.value = value;
                      debugPrint("Interval changed to: $value");
                    },
                    decoration: InputDecoration(
                      labelText: 'Interval (seconds)',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.timer,
                        color: Color(0xFF34BB91),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sound Selection
                  DropdownButtonFormField<String>(
                    value: _selectedSound.value.isEmpty
                        ? null
                        : _selectedSound.value,
                    items: controller.availableSounds.map((sound) {
                      final displayName = controller.getSoundDisplayName(sound);
                      final isUploaded = !sound.startsWith('assets/');

                      return DropdownMenuItem(
                        value: sound,
                        child: Row(
                          children: [
                            Icon(
                              isUploaded ? Icons.upload_file : Icons.music_note,
                              size: 16,
                              color: isUploaded
                                  ? const Color(0xFF34BB91)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isUploaded)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Uploaded',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _selectedSound.value = value ?? '';
                      debugPrint(
                          "Sound selected: ${controller.getSoundDisplayName(value ?? '')}");
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Sound',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.volume_up,
                        color: Color(0xFF34BB91),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add Schedule Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Schedule'),
                      onPressed: _addSchedule,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF34BB91),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Active Schedules Section - wrap in Expanded
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                color: Color(0xFF34BB91)),
                            const SizedBox(width: 8),
                            const Text(
                              'Active Schedules',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34BB91).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${controller.schedules.length} active',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Control buttons
                        if (controller.schedules.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: Icon(controller.isPlaying.value
                                        ? (controller.isPaused.value
                                            ? Icons.play_arrow
                                            : Icons.pause)
                                        : Icons.play_arrow),
                                    label: Text(controller.isPlaying.value
                                        ? (controller.isPaused.value
                                            ? 'Resume'
                                            : 'Pause')
                                        : 'Start'),
                                    onPressed: controller.togglePlayPause,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          controller.isPlaying.value
                                              ? (controller.isPaused.value
                                                  ? Colors.green
                                                  : const Color(0xFF34BB91))
                                              : Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: controller.isPlaying.value
                                        ? (controller.isPaused.value
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1))
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        controller.isPlaying.value
                                            ? (controller.isPaused.value
                                                ? Icons.pause
                                                : Icons.play_arrow)
                                            : Icons.stop,
                                        size: 16,
                                        color: controller.isPlaying.value
                                            ? (controller.isPaused.value
                                                ? Colors.orange
                                                : Colors.green)
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        controller.isPlaying.value
                                            ? (controller.isPaused.value
                                                ? 'Paused'
                                                : 'Playing')
                                            : 'Stopped',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: controller.isPlaying.value
                                              ? (controller.isPaused.value
                                                  ? Colors.orange
                                                  : Colors.green)
                                              : Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Schedules List - wrap in Expanded and add proper constraints
                        controller.schedules.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No active schedules',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Add a schedule above to get started',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: controller.schedules.length,
                                itemBuilder: (context, index) {
                                  final sortedSchedules =
                                      controller.schedules.toList()
                                        ..sort((a, b) {
                                          int dateComparison =
                                              a.date.compareTo(b.date);
                                          if (dateComparison != 0) {
                                            return dateComparison;
                                          }
                                          return (a.startTime.hour * 60 +
                                                  a.startTime.minute)
                                              .compareTo(b.startTime.hour * 60 +
                                                  b.startTime.minute);
                                        });

                                  return buildScheduleCard(
                                      sortedSchedules[index], controller);
                                },
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  void _addSchedule() {
    debugPrint("=== ATTEMPTING TO ADD SCHEDULE ===");

    if (_selectedDate.value == null) {
      debugPrint("❌ No date selected");
      Get.snackbar('Error', 'Please select a date');
      return;
    }

    if (_startTime.value == null) {
      debugPrint("❌ No start time selected");
      Get.snackbar('Error', 'Please select a start time');
      return;
    }

    if (_endTime.value == null) {
      debugPrint("❌ No end time selected");
      Get.snackbar('Error', 'Please select an end time');
      return;
    }

    if (_selectedSound.value.isEmpty) {
      debugPrint("❌ No sound selected");
      Get.snackbar('Error', 'Please select a sound');
      return;
    }

    if (int.tryParse(_interval.value) == null ||
        int.parse(_interval.value) <= 0) {
      debugPrint("❌ Invalid interval: ${_interval.value}");
      Get.snackbar('Error', 'Please enter a valid interval in seconds');
      return;
    }

    final schedule = AudioSchedule(
      date: _selectedDate.value!,
      startTime: _startTime.value!,
      endTime: _endTime.value!,
      soundPath: _selectedSound.value,
      interval: int.parse(_interval.value),
    );

    debugPrint("✅ Schedule created:");
    debugPrint("   Date: ${schedule.formattedDate}");
    debugPrint("   Start: ${schedule.formattedStartTime}");
    debugPrint("   End: ${schedule.formattedEndTime}");
    debugPrint("   Sound: ${schedule.soundDisplayName}");
    debugPrint("   Interval: ${schedule.interval}s");

    controller.addSchedule(schedule);

    // Reset form
    _selectedDate.value = null;
    _startTime.value = null;
    _endTime.value = null;
    _selectedSound.value = '';
    _interval.value = '';
    _intervalController.clear();

    Get.snackbar('Success', 'Schedule added for ${schedule.formattedDate}');
  }

  Future<void> _pickTime(BuildContext context, Rx<TimeOfDay?> target) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: target.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF34BB91),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: const TimePickerThemeData(
              hourMinuteTextColor: Colors.white,
              hourMinuteColor: Color(0xFF34BB91),
              dialHandColor: Color(0xFF34BB91),
              entryModeIconColor: Color(0xFF34BB91),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      target.value = picked;
      debugPrint("Time selected: ${formatTime(picked)}");
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF34BB91),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            datePickerTheme: const DatePickerThemeData(
              headerForegroundColor: Colors.white,
              headerBackgroundColor: Color(0xFF34BB91),
              rangeSelectionBackgroundColor: Color(0xFF34BB91),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _selectedDate.value = picked;
      debugPrint("Date selected: ${formatDate(picked)}");
    }
  }
}

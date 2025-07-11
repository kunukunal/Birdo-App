import 'package:birdo/controller/audio_controller.dart';
import 'package:birdo/controller/dto.dart';
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

  Future<void> _pickTime(BuildContext context, Rx<TimeOfDay?> target) async {
    final picked = await showTimePicker(
        context: context, initialTime: target.value ?? TimeOfDay.now());
    if (picked != null) {
      target.value = picked;
      debugPrint("Time selected: ${_formatTime(picked)}");
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _selectedDate.value = picked;
      debugPrint("Date selected: ${_formatDate(picked)}");
    }
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

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final scheduleDate = DateTime(date.year, date.month, date.day);

    if (scheduleDate.isAtSameMomentAs(today)) {
      return 'Today (${_formatDate(date)})';
    } else if (scheduleDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow (${_formatDate(date)})';
    } else {
      return _formatDate(date);
    }
  }

  void _refreshSounds() {
    controller.refreshSounds();
    Get.snackbar('Refreshed', 'Sound list updated');
  }

  Widget _buildScheduleCard(AudioSchedule schedule) {
    final soundName = schedule.soundDisplayName;
    final isUploaded = schedule.isUploadedSound;
    final now = DateTime.now();
    final isToday = DateTime(now.year, now.month, now.day).isAtSameMomentAs(
        DateTime(schedule.date.year, schedule.date.month, schedule.date.day));

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isToday
            ? Colors.blue.withOpacity(0.2)
            : (isUploaded
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1)),
        child: Icon(
          isToday
              ? Icons.today
              : (isUploaded ? Icons.upload_file : Icons.music_note),
          color:
              isToday ? Colors.blue : (isUploaded ? Colors.green : Colors.grey),
          size: 20,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDateDisplay(schedule.date),
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              color: isToday ? Colors.blue : null,
              fontSize: 14,
            ),
          ),
          Text(
            '${schedule.formattedStartTime} - ${schedule.formattedEndTime}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Every ${schedule.interval}s'),
          Row(
            children: [
              Icon(
                Icons.music_note,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  soundName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isUploaded)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Uploaded',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          debugPrint("Deleting schedule for ${schedule.formattedDate}");
          controller.removeSchedule(schedule);
        },
        tooltip: 'Delete schedule',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create New Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSounds,
            tooltip: 'Refresh sounds list',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 18),

                Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.blue),
                    title: const Text('Select Date'),
                    subtitle: Text(
                      _selectedDate.value == null
                          ? 'Choose a date for your schedule'
                          : 'Selected: ${_formatDateDisplay(_selectedDate.value!)}',
                      style: TextStyle(
                        color: _selectedDate.value == null
                            ? Colors.grey[600]
                            : Colors.blue,
                      ),
                    ),
                    trailing: Text(
                      _formatDate(_selectedDate.value),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => _pickDate(context),
                  ),
                ),
                const SizedBox(height: 8),

                // Time Selection
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.access_time, color: Colors.green),
                        title: const Text('Start Time'),
                        subtitle: const Text('When to start playing'),
                        trailing: Text(
                          _formatTime(_startTime.value),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () => _pickTime(context, _startTime),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time_filled,
                            color: Colors.orange),
                        title: const Text('End Time'),
                        subtitle: const Text('When to stop playing'),
                        trailing: Text(
                          _formatTime(_endTime.value),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () => _pickTime(context, _endTime),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Interval Input
                TextFormField(
                  controller: _intervalController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _interval.value = value;
                    debugPrint("Interval changed to: $value");
                  },
                  decoration: const InputDecoration(
                    labelText: 'Interval (seconds)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                    helperText: 'How often to play the sound e.g (10 seconds)',
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
                            color: isUploaded ? Colors.green : Colors.grey,
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
                  decoration: const InputDecoration(
                    labelText: 'Select Sound',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.volume_up),
                    helperText: 'Choose from assets or uploaded sounds',
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
                      backgroundColor: Colors.blue,
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
                          const Icon(Icons.schedule, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Active Schedules',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${controller.schedules.length} active',
                              style: const TextStyle(
                                color: Colors.blue,
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
                                    backgroundColor: controller.isPlaying.value
                                        ? (controller.isPaused.value
                                            ? Colors.green
                                            : Colors.orange)
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

                                return _buildScheduleCard(
                                    sortedSchedules[index]);
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
    );
  }
}

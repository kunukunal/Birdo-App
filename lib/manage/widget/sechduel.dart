import 'package:birdo/controller/audio_controller.dart';
import 'package:birdo/controller/dto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildScheduleCard(
    AudioSchedule schedule, AudioSchedulerController controller) {
  final soundName = schedule.soundDisplayName;
  final now = DateTime.now();
  final isToday = DateTime(now.year, now.month, now.day).isAtSameMomentAs(
      DateTime(schedule.date.year, schedule.date.month, schedule.date.day));

  // Check if there are multiple sounds
  final hasMultipleSounds = schedule.soundPaths.length > 1;
  final shouldShowReadMore =
      hasMultipleSounds && schedule.soundPaths.length > 2;

  return ListTile(
    leading: CircleAvatar(
      backgroundColor: isToday
          ? const Color(0xFF34BB91).withOpacity(0.2)
          : (Colors.grey.withOpacity(0.1)),
      child: Icon(
        isToday ? Icons.today : (Icons.music_note),
        color: isToday ? const Color(0xFF34BB91) : (Colors.grey),
        size: 20,
      ),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatDateDisplay(schedule.date),
          style: TextStyle(
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            color: isToday ? Color(0xFF34BB91) : null,
            fontSize: 14,
          ),
        ),
        Text(
          '${schedule.formattedStartTime} - ${schedule.formattedEndTime}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Every ${schedule.interval}m'),
        Row(
          children: [
            Icon(
              Icons.music_note,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: hasMultipleSounds
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shouldShowReadMore
                              ? '${schedule.soundPaths.take(2).join(', ')}...'
                              : soundName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (shouldShowReadMore)
                          TextButton(
                            onPressed: () => _showAllSoundsDialog(schedule),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Read More',
                              style: TextStyle(
                                color: const Color(0xFF34BB91),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Text(
                      soundName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            // if (isUploaded)
            //   Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 4,
            //       vertical: 1,
            //     ),
            //     decoration: BoxDecoration(
            //       color: Colors.green.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(4),
            //     ),
            //     child: const Text(
            //       'Uploaded',
            //       style: TextStyle(
            //         fontSize: 8,
            //         color: Colors.green,
            //       ),
            //     ),
            //   ),
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

String formatDateDisplay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final scheduleDate = DateTime(date.year, date.month, date.day);

  if (scheduleDate.isAtSameMomentAs(today)) {
    return 'Today (${formatDate(date)})';
  } else if (scheduleDate.isAtSameMomentAs(tomorrow)) {
    return 'Tomorrow (${formatDate(date)})';
  } else {
    return formatDate(date);
  }
}

String formatTime(TimeOfDay? time) {
  if (time == null) return 'Select Time';
  final hour = time.hourOfPeriod.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String formatDate(DateTime? date) {
  if (date == null) return 'Select Date';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

void _showAllSoundsDialog(AudioSchedule schedule) {
  showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.music_note,
              color: Color(0xFF34BB91),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Selected Sounds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF34BB91),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Schedule for ${formatDateDisplay(schedule.date)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children: schedule.soundPaths.map((sound) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34BB91).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF34BB91).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.volume_up,
                            color: const Color(0xFF34BB91),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sound,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF34BB91),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Color(0xFF34BB91),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

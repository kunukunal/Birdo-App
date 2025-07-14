import 'package:birdo/controller/audio_controller.dart';
import 'package:birdo/controller/dto.dart';
import 'package:flutter/material.dart';

Widget buildScheduleCard(
    AudioSchedule schedule, AudioSchedulerController controller) {
  final soundName = schedule.soundDisplayName;
  final isUploaded = schedule.isUploadedSound;
  final now = DateTime.now();
  final isToday = DateTime(now.year, now.month, now.day).isAtSameMomentAs(
      DateTime(schedule.date.year, schedule.date.month, schedule.date.day));

  return ListTile(
    leading: CircleAvatar(
      backgroundColor: isToday
          ? const Color(0xFF34BB91).withOpacity(0.2)
          : (isUploaded
              ? const Color(0xFF34BB91).withOpacity(0.1)
              : Colors.grey.withOpacity(0.1)),
      child: Icon(
        isToday
            ? Icons.today
            : (isUploaded ? Icons.upload_file : Icons.music_note),
        color: isToday
            ? const Color(0xFF34BB91)
            : (isUploaded ? const Color(0xFF34BB91) : Colors.grey),
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

// import 'package:flutter/material.dart';
//
// class AudioSchedule {
//   final DateTime date;
//   final TimeOfDay startTime;
//   final TimeOfDay endTime;
//   final String soundPath;
//   final int interval; // in seconds
//
//   AudioSchedule({
//     required this.date,
//     required this.startTime,
//     required this.endTime,
//     required this.soundPath,
//     required this.interval,
//   });
//
//   // Helper methods for easier comparison and formatting
//   String get formattedDate {
//     return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//   }
//
//   String get formattedStartTime {
//     final hour = startTime.hourOfPeriod.toString().padLeft(2, '0');
//     final minute = startTime.minute.toString().padLeft(2, '0');
//     final period = startTime.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }
//
//   String get formattedEndTime {
//     final hour = endTime.hourOfPeriod.toString().padLeft(2, '0');
//     final minute = endTime.minute.toString().padLeft(2, '0');
//     final period = endTime.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }
//
//   String get soundDisplayName {
//     return soundPath
//         .split('/')
//         .last
//         .replaceAll(RegExp(r'\.(mp3|wav|aac)$'), '');
//   }
//
//   bool get isUploadedSound {
//     return !soundPath.startsWith('assets/');
//   }
//
//   // Convert to JSON for persistence (optional)
//   Map<String, dynamic> toJson() {
//     return {
//       'date': date.toIso8601String(),
//       'startTime': {
//         'hour': startTime.hour,
//         'minute': startTime.minute,
//       },
//       'endTime': {
//         'hour': endTime.hour,
//         'minute': endTime.minute,
//       },
//       'soundPath': soundPath,
//       'interval': interval,
//     };
//   }
//
//   // Create from JSON (optional)
//   factory AudioSchedule.fromJson(Map<String, dynamic> json) {
//     return AudioSchedule(
//       date: DateTime.parse(json['date']),
//       startTime: TimeOfDay(
//         hour: json['startTime']['hour'],
//         minute: json['startTime']['minute'],
//       ),
//       endTime: TimeOfDay(
//         hour: json['endTime']['hour'],
//         minute: json['endTime']['minute'],
//       ),
//       soundPath: json['soundPath'],
//       interval: json['interval'],
//     );
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is AudioSchedule &&
//         other.date == date &&
//         other.startTime == startTime &&
//         other.endTime == endTime &&
//         other.soundPath == soundPath &&
//         other.interval == interval;
//   }
//
//   @override
//   int get hashCode {
//     return date.hashCode ^
//         startTime.hashCode ^
//         endTime.hashCode ^
//         soundPath.hashCode ^
//         interval.hashCode;
//   }
//
//   @override
//   String toString() {
//     return 'AudioSchedule(date: $formattedDate, startTime: $formattedStartTime, endTime: $formattedEndTime, soundPath: $soundDisplayName, interval: ${interval}s)';
//   }
// }
import 'package:flutter/material.dart';

class AudioSchedule {
  final int? id; // API ID for updates/deletes
  final DateTime date;
  final DateTime? endDate; // For multi-day schedules
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String
      soundPath; // Now stores sound name instead of path (for backward compatibility)
  final List<String> soundPaths; // Multiple sound names
  final int interval; // In seconds
  final bool isActive;

  AudioSchedule({
    this.id,
    required this.date,
    this.endDate,
    required this.startTime,
    required this.endTime,
    required this.soundPath,
    this.soundPaths = const [],
    required this.interval,
    this.isActive = true,
  });

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get formattedStartTime {
    final hour = startTime.hourOfPeriod == 0 ? 12 : startTime.hourOfPeriod;
    final minute = startTime.minute.toString().padLeft(2, '0');
    final period = startTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get formattedEndTime {
    final hour = endTime.hourOfPeriod == 0 ? 12 : endTime.hourOfPeriod;
    final minute = endTime.minute.toString().padLeft(2, '0');
    final period = endTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get soundDisplayName {
    if (soundPaths.isNotEmpty) {
      return soundPaths.map((s) => s.toUpperCase()).join(', ');
    }
    return soundPath.toUpperCase();
  }

  // Getter to ensure we always have sound paths
  List<String> get effectiveSoundPaths {
    if (soundPaths.isNotEmpty) {
      return soundPaths;
    }
    if (soundPath.isNotEmpty) {
      return [soundPath];
    }
    return [];
  }

  bool get isUploadedSound {
    return !soundPath.startsWith('assets/');
  }

  String get formattedDateRange {
    if (endDate != null && !isSameDay(date, endDate!)) {
      return '${formattedDate} - ${_formatDate(endDate!)}';
    }
    return formattedDate;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Copy with method for creating modified instances
  AudioSchedule copyWith({
    int? id,
    DateTime? date,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? soundPath,
    List<String>? soundPaths,
    int? interval,
    bool? isActive,
  }) {
    return AudioSchedule(
      id: id ?? this.id,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      soundPath: soundPath ?? this.soundPath,
      soundPaths: soundPaths ?? this.soundPaths,
      interval: interval ?? this.interval,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioSchedule &&
        other.id == id &&
        other.date == date &&
        other.endDate == endDate &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.soundPath == soundPath &&
        other.soundPaths == soundPaths &&
        other.interval == interval &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      date,
      endDate,
      startTime,
      endTime,
      soundPath,
      soundPaths,
      interval,
      isActive,
    );
  }

  @override
  String toString() {
    return 'AudioSchedule(id: $id, date: $date, endDate: $endDate, startTime: $startTime, endTime: $endTime, soundPath: $soundPath, soundPaths: $soundPaths, interval: $interval, isActive: $isActive)';
  }
}

// Helper functions for formatting
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String formatTime(TimeOfDay? time) {
  if (time == null) return '';
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

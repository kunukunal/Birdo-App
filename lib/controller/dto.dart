import 'package:flutter/material.dart';

class AudioSchedule {
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String soundPath;
  final int interval; // in seconds

  AudioSchedule({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.soundPath,
    required this.interval,
  });

  // Helper methods for easier comparison and formatting
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get formattedStartTime {
    final hour = startTime.hourOfPeriod.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    final period = startTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get formattedEndTime {
    final hour = endTime.hourOfPeriod.toString().padLeft(2, '0');
    final minute = endTime.minute.toString().padLeft(2, '0');
    final period = endTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get soundDisplayName {
    return soundPath
        .split('/')
        .last
        .replaceAll(RegExp(r'\.(mp3|wav|aac)$'), '');
  }

  bool get isUploadedSound {
    return !soundPath.startsWith('assets/');
  }

  // Convert to JSON for persistence (optional)
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'soundPath': soundPath,
      'interval': interval,
    };
  }

  // Create from JSON (optional)
  factory AudioSchedule.fromJson(Map<String, dynamic> json) {
    return AudioSchedule(
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
      soundPath: json['soundPath'],
      interval: json['interval'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioSchedule &&
        other.date == date &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.soundPath == soundPath &&
        other.interval == interval;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        soundPath.hashCode ^
        interval.hashCode;
  }

  @override
  String toString() {
    return 'AudioSchedule(date: $formattedDate, startTime: $formattedStartTime, endTime: $formattedEndTime, soundPath: $soundDisplayName, interval: ${interval}s)';
  }
}

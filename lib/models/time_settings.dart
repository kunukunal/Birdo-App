// lib/models/time_settings.dart

import 'package:flutter/material.dart';

class TimeSettings {
  TimeOfDay startTime;
  TimeOfDay endTime;
  String interval; // Add this line

  TimeSettings({
    required this.startTime,
    required this.endTime,
    required this.interval,
  });
}

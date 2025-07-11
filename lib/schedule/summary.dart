import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleSummaryWidget extends StatefulWidget {
  const ScheduleSummaryWidget({super.key});

  @override
  State<ScheduleSummaryWidget> createState() => _ScheduleSummaryWidgetState();
}

class _ScheduleSummaryWidgetState extends State<ScheduleSummaryWidget> {
  String? startTime;
  String? endTime;
  int? interval;
  String? selectedSound;

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    final prefs = await SharedPreferences.getInstance();

    final int? startHour = prefs.getInt('startHour');
    final int? startMinute = prefs.getInt('startMinute');
    final String startAmPm = prefs.getString('startAmPm') ?? 'AM';

    final int? endHour = prefs.getInt('endHour');
    final int? endMinute = prefs.getInt('endMinute');
    final String endAmPm = prefs.getString('endAmPm') ?? 'AM';

    final int? storedInterval = prefs.getInt('interval');
    final String? sound = prefs.getString('selectedSound');

    setState(() {
      startTime = (startHour != null && startMinute != null)
          ? '${_formatTime(startHour, startMinute)} $startAmPm'
          : 'Not set';

      endTime = (endHour != null && endMinute != null)
          ? '${_formatTime(endHour, endMinute)} $endAmPm'
          : 'Not set';

      interval = storedInterval;
      selectedSound = sound ?? 'None';
    });
  }

  String _formatTime(int hour, int minute) {
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$hour:$formattedMinute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Start Time', startTime ?? 'Not set'),
            _infoRow('End Time', endTime ?? 'Not set'),
            _infoRow('Interval (seconds)', interval?.toString() ?? 'Not set'),
            _infoRow('Selected Sound', selectedSound ?? 'None'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

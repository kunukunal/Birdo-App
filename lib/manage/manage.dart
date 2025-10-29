// import 'package:birdo/controller/audio_controller.dart';
// import 'package:birdo/controller/dto.dart';
// import 'package:birdo/manage/widget/sechduel.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class ScheduleInputView extends StatelessWidget {
//   ScheduleInputView({super.key});
//
//   final controller = Get.put(AudioSchedulerController());
//   final _startTime = Rx<TimeOfDay?>(null);
//   final _endTime = Rx<TimeOfDay?>(null);
//   final _selectedSound = ''.obs;
//   final _interval = ''.obs;
//   final _intervalController = TextEditingController();
//   final ValueNotifier<DateTime?> _selectedStartDate = ValueNotifier(null);
//   final ValueNotifier<DateTime?> _selectedEndDate = ValueNotifier(null);
//
//   void _refreshSounds() async {
//     await controller.refreshSounds();
//     Get.snackbar('Refreshed', 'Sound list updated');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80),
//         child: Padding(
//           padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(
//                 height: 70,
//                 child: Image.asset('assets/images/logo.png'),
//               ),
//               Obx(() => IconButton(
//                     icon: controller.isLoadingSounds.value
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                   Color(0xFF34BB91)),
//                             ),
//                           )
//                         : const Icon(Icons.refresh),
//                     onPressed: controller.isLoadingSounds.value
//                         ? null
//                         : _refreshSounds,
//                     tooltip: 'Refresh sounds list',
//                   )),
//             ],
//           ),
//         ),
//       ),
//       body: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Obx(() {
//             return SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 18),
//
//                   Row(
//                     children: [
//                       /// Start Date Field
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => _pickDateRange(context),
//                           child: InputDecorator(
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.grey[50],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20.0),
//                                 borderSide: BorderSide.none,
//                               ),
//                               prefixIcon: const Icon(
//                                 Icons.calendar_month,
//                                 color: Color(0xFF34BB91),
//                               ),
//                             ),
//                             child: ValueListenableBuilder(
//                               valueListenable: _selectedStartDate,
//                               builder: (_, DateTime? startDate, __) => Text(
//                                 startDate == null
//                                     ? 'Start date'
//                                     : formatDate(startDate),
//                                 style: TextStyle(
//                                   color: startDate == null
//                                       ? Colors.grey[600]
//                                       : null,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 15),
//
//                       /// End Date Field
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => _pickDateRange(context),
//                           child: InputDecorator(
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.grey[50],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20.0),
//                                 borderSide: BorderSide.none,
//                               ),
//                               prefixIcon: const Icon(
//                                 Icons.calendar_month,
//                                 color: Color(0xFF34BB91),
//                               ),
//                             ),
//                             child: ValueListenableBuilder(
//                               valueListenable: _selectedEndDate,
//                               builder: (_, DateTime? endDate, __) => Text(
//                                 endDate == null
//                                     ? 'End date'
//                                     : formatDate(endDate),
//                                 style: TextStyle(
//                                   color:
//                                       endDate == null ? Colors.grey[600] : null,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 18),
//                   Row(
//                     children: [
//                       /// Start Time Field
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => _pickTime(context, _startTime),
//                           child: InputDecorator(
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.grey[50],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20.0),
//                                 borderSide: BorderSide.none,
//                               ),
//                               prefixIcon: const Icon(
//                                 Icons.access_alarm,
//                                 color: Color(0xFF34BB91),
//                               ),
//                             ),
//                             child: Text(
//                               _startTime.value == null
//                                   ? 'Start time'
//                                   : formatTime(_startTime.value),
//                               style: TextStyle(
//                                 color: _startTime.value == null
//                                     ? Colors.grey[600]
//                                     : null,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 15),
//
//                       /// End Time Field
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => _pickTime(context, _endTime),
//                           child: InputDecorator(
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.grey[50],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20.0),
//                                 borderSide: BorderSide.none,
//                               ),
//                               prefixIcon: const Icon(
//                                 Icons.access_alarm,
//                                 color: Color(0xFF34BB91),
//                               ),
//                             ),
//                             child: Text(
//                               _endTime.value == null
//                                   ? 'End time'
//                                   : formatTime(_endTime.value),
//                               style: TextStyle(
//                                 color: _endTime.value == null
//                                     ? Colors.grey[600]
//                                     : null,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 18),
//                   // Interval Input
//                   TextFormField(
//                     controller: _intervalController,
//                     keyboardType: TextInputType.number,
//                     onChanged: (value) {
//                       _interval.value = value;
//                       debugPrint("Interval changed to: $value");
//                     },
//                     decoration: InputDecoration(
//                       hintText: 'Interval (minutes)',
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                         borderSide: BorderSide.none,
//                       ),
//                       hintStyle: TextStyle(
//                         color:
//                             _interval.value.isEmpty ? Colors.grey[600] : null,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       prefixIcon: const Icon(
//                         Icons.timer,
//                         color: Color(0xFF34BB91),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Sound Selection
//                   DropdownButtonFormField<String>(
//                     value: _selectedSound.value.isEmpty
//                         ? null
//                         : _selectedSound.value,
//                     items: controller.availableSounds.map((sound) {
//                       return DropdownMenuItem(
//                         value: sound,
//                         child: _buildSoundDropdownItem(sound, controller),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       _selectedSound.value = value ?? '';
//                       debugPrint(
//                           "Sound selected: ${controller.getSoundDisplayName(value ?? '')}");
//                     },
//                     decoration: InputDecoration(
//                       hintText: controller.isLoadingSounds.value
//                           ? 'Loading sounds...'
//                           : 'Select Sound',
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                         borderSide: BorderSide.none,
//                       ),
//                       hintStyle: const TextStyle(
//                         fontWeight: FontWeight.w300,
//                         fontSize: 16,
//                       ),
//                       prefixIcon: const Icon(
//                         Icons.volume_up,
//                         color: Color(0xFF34BB91),
//                       ),
//                     ),
//                     isExpanded: true,
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Add Schedule Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.add),
//                       label: const Text('Add Schedule'),
//                       onPressed: _addSchedule,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         backgroundColor: const Color(0xFF34BB91),
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   // Active Schedules Section
//                   Container(
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.withOpacity(0.05),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             const Icon(Icons.schedule,
//                                 color: Color(0xFF34BB91)),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'Active Schedules',
//                               style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w400,
//                                   color: Colors.black),
//                             ),
//                             const Spacer(),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF34BB91).withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 '${controller.schedules.length} active',
//                                 style: const TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//
//                         // Control buttons
//                         if (controller.schedules.isNotEmpty)
//                           ElevatedButton.icon(
//                             icon: Icon(controller.isPlaying.value
//                                 ? (controller.isPaused.value
//                                     ? Icons.play_arrow
//                                     : Icons.pause)
//                                 : Icons.play_arrow),
//                             label: Text(controller.isPlaying.value
//                                 ? (controller.isPaused.value
//                                     ? 'Resume'
//                                     : 'Pause')
//                                 : 'Start'),
//                             onPressed: controller.togglePlayPause,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF34BB91),
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//
//                         // Schedules List
//                         controller.schedules.isEmpty
//                             ? const Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.schedule,
//                                       size: 48,
//                                       color: Colors.grey,
//                                     ),
//                                     SizedBox(height: 12),
//                                     Text(
//                                       'No active schedules',
//                                       style: TextStyle(
//                                         color: Colors.grey,
//                                         fontStyle: FontStyle.italic,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                     SizedBox(height: 8),
//                                     Text(
//                                       'Add a schedule above to get started',
//                                       style: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : ListView.builder(
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 shrinkWrap: true,
//                                 itemCount: controller.schedules.length,
//                                 itemBuilder: (context, index) {
//                                   final sortedSchedules =
//                                       controller.schedules.toList()
//                                         ..sort((a, b) {
//                                           int dateComparison =
//                                               a.date.compareTo(b.date);
//                                           if (dateComparison != 0) {
//                                             return dateComparison;
//                                           }
//                                           return (a.startTime.hour * 60 +
//                                                   a.startTime.minute)
//                                               .compareTo(b.startTime.hour * 60 +
//                                                   b.startTime.minute);
//                                         });
//
//                                   return buildScheduleCard(
//                                       sortedSchedules[index], controller);
//                                 },
//                               ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//                 ],
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSoundDropdownItem(
//       String sound, AudioSchedulerController controller) {
//     // final displayName = controller.getSoundDisplayName(sound);
//
//     IconData iconData;
//     String badge;
//     Color badgeColor;
//
//     // if (controller.isApiSound(sound)) {
//     // iconData = Icons.cloud_queue;
//     // badge = 'API';
//     // badgeColor = Colors.blue;
//     // } else if (controller.isAssetSound(sound)) {
//     iconData = Icons.music_note;
//     // badge = 'Built-in';
//     badgeColor = Colors.grey;
//     // } else {
//     //   iconData = Icons.upload_file;
//     //   badge = 'Uploaded';
//     //   badgeColor = const Color(0xFF34BB91);
//     // }
//
//     return Row(
//       children: [
//         Icon(
//           iconData,
//           size: 16,
//           color: badgeColor,
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             sound,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         // Container(
//         //   margin: const EdgeInsets.only(left: 6),
//         //   padding: const EdgeInsets.symmetric(
//         //     horizontal: 6,
//         //     vertical: 2,
//         //   ),
//         //   decoration: BoxDecoration(
//         //     color: badgeColor.withOpacity(0.1),
//         //     borderRadius: BorderRadius.circular(8),
//         //   ),
//         //   child: Text(
//         //     badge,
//         //     style: TextStyle(
//         //       fontSize: 10,
//         //       color: badgeColor,
//         //       fontWeight: FontWeight.w500,
//         //     ),
//         //   ),
//         // ),
//       ],
//     );
//   }
//
//   void _addSchedule() {
//     debugPrint("=== ATTEMPTING TO ADD SCHEDULE ===");
//
//     if (_selectedStartDate.value == null) {
//       debugPrint("❌ No date selected");
//       Get.snackbar('Error', 'Please select a date');
//       return;
//     }
//
//     if (_startTime.value == null) {
//       debugPrint("❌ No start time selected");
//       Get.snackbar('Error', 'Please select a start time');
//       return;
//     }
//
//     if (_endTime.value == null) {
//       debugPrint("❌ No end time selected");
//       Get.snackbar('Error', 'Please select an end time');
//       return;
//     }
//
//     if (_selectedSound.value.isEmpty) {
//       debugPrint("❌ No sound selected");
//       Get.snackbar('Error', 'Please select a sound');
//       return;
//     }
//
//     if (int.tryParse(_interval.value) == null ||
//         int.parse(_interval.value) <= 0) {
//       debugPrint("❌ Invalid interval: ${_interval.value}");
//       Get.snackbar('Error', 'Please enter a valid interval in minutes');
//       return;
//     }
//
//     final schedule = AudioSchedule(
//       date: _selectedStartDate.value!,
//       startTime: _startTime.value!,
//       endTime: _endTime.value!,
//       soundPath: _selectedSound.value,
//       interval: int.parse(_interval.value),
//     );
//
//     debugPrint("✅ Schedule created:");
//     debugPrint("   Date: ${schedule.formattedDate}");
//     debugPrint("   Start: ${schedule.formattedStartTime}");
//     debugPrint("   End: ${schedule.formattedEndTime}");
//     debugPrint("   Sound: ${schedule.soundDisplayName}");
//     debugPrint("   Interval: ${schedule.interval}s");
//
//     controller.addSchedule(schedule);
//
//     // Reset form
//     _selectedStartDate.value = null;
//     _selectedEndDate.value = null;
//     _startTime.value = null;
//     _endTime.value = null;
//     _selectedSound.value = '';
//     _interval.value = '';
//     _intervalController.clear();
//
//     Get.snackbar('Success', 'Schedule added for ${schedule.formattedDate}');
//   }
//
//   Future<void> _pickTime(BuildContext context, Rx<TimeOfDay?> target) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: target.value ?? TimeOfDay.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF34BB91),
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             timePickerTheme: const TimePickerThemeData(
//               dayPeriodColor: Color(0xFF34BB91),
//               hourMinuteTextColor: Colors.white,
//               hourMinuteColor: Color(0xFF34BB91),
//               dialHandColor: Color(0xFF34BB91),
//               entryModeIconColor: Color(0xFF34BB91),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       target.value = picked;
//       debugPrint("Time selected: ${formatTime(picked)}");
//     }
//   }
//
//   Future<void> _pickDateRange(BuildContext context) async {
//     final DateTime now = DateTime.now();
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: now,
//       lastDate: now.add(const Duration(days: 365)),
//       initialDateRange:
//           (_selectedStartDate.value != null && _selectedEndDate.value != null)
//               ? DateTimeRange(
//                   start: _selectedStartDate.value!,
//                   end: _selectedEndDate.value!,
//                 )
//               : null,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF34BB91),
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xFF34BB91),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       _selectedStartDate.value = picked.start;
//       _selectedEndDate.value = picked.end;
//     }
//   }
// }
import 'package:birdo/controller/audio_controller.dart';
import 'package:birdo/controller/dto.dart';
import 'package:birdo/manage/widget/sechduel.dart' hide formatDate, formatTime;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleInputView extends StatelessWidget {
  ScheduleInputView({super.key});

  final controller = Get.put(AudioSchedulerController());
  final _startTime = Rx<TimeOfDay?>(null);
  final _endTime = Rx<TimeOfDay?>(null);
  final _selectedSound = ''.obs;
  final _selectedSounds = <String>[].obs;
  final _interval = ''.obs;
  final _intervalController = TextEditingController();
  final _selectedMinutes = 1.obs;
  // final _selectedSeconds = 0.obs;
  final ValueNotifier<DateTime?> _selectedStartDate = ValueNotifier(null);
  final ValueNotifier<DateTime?> _selectedEndDate = ValueNotifier(null);

  void _refreshSounds() async {
    await controller.refreshSounds();
    Get.snackbar('Refreshed', 'Sound list updated');
  }

  void _updateIntervalValue() {
    final totalSeconds = _selectedMinutes.value; // Convert minutes to seconds
    _interval.value = totalSeconds.toString();
    debugPrint(
        "Interval updated: ${_selectedMinutes.value} minutes = $totalSeconds seconds");
  }

  void _showIntervalPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Color(0xFF34BB91),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Select Interval',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF34BB91),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Minutes Scroller (Centered)
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Select Minutes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 200,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Obx(() => ListWheelScrollView(
                              itemExtent: 60,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                _selectedMinutes.value = index + 1;
                                // _selectedSeconds.value = 0; // Always 0 seconds
                                _updateIntervalValue();
                              },
                              children: List.generate(60, (index) {
                                final minutes = index + 1;
                                final isSelected =
                                    _selectedMinutes.value == minutes;
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    minutes.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF34BB91)
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              }),
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Display selected interval
                Obx(() => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34BB91).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                const Color(0xFF34BB91).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Selected: ${_selectedMinutes.value} minutes',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF34BB91),
                          fontSize: 16,
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _updateIntervalValue();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34BB91),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSoundSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.volume_up,
                      color: Color(0xFF34BB91),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Select Sounds',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF34BB91),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Selected sounds count
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34BB91).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF34BB91).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${_selectedSounds.length} sound${_selectedSounds.length != 1 ? 's' : ''} selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF34BB91),
                          fontSize: 14,
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
                // Sound selection list
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: Obx(() {
                      if (controller.isLoadingSounds.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF34BB91),
                            ),
                          ),
                        );
                      }

                      if (controller.availableSounds.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No sounds available',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: controller.availableSounds.map((sound) {
                            final isSelected = _selectedSounds.contains(sound);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF34BB91)
                                        .withValues(alpha: 0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF34BB91)
                                          .withValues(alpha: 0.3)
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: isSelected
                                      ? const Color(0xFF34BB91)
                                      : Colors.grey,
                                ),
                                title: Text(
                                  sound,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? const Color(0xFF34BB91)
                                        : Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  if (isSelected) {
                                    _selectedSounds.remove(sound);
                                  } else {
                                    _selectedSounds.add(sound);
                                  }
                                  debugPrint(
                                      "Selected sounds: $_selectedSounds");
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _selectedSounds.clear();
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34BB91),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _validateTimes() {
    final startTime = _startTime.value!;
    final endTime = _endTime.value!;
    final startDate = _selectedStartDate.value!;
    final endDate = _selectedEndDate.value!;

    // Convert times to minutes for easier comparison
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    // 1. Start time should be before end time
    if (startMinutes >= endMinutes) {
      debugPrint("❌ Start time must be before end time");
      Get.snackbar('Invalid Time', 'Start time must be before end time');
      return false;
    }

    // 2. Check if it's the same day
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      // Same day: start time must be before end time
      if (startMinutes >= endMinutes) {
        debugPrint("❌ Start time must be before end time on the same day");
        Get.snackbar('Invalid Time', 'Start time must be before end time');
        return false;
      }
    } else {
      // Different days: end date must be after start date
      if (endDate.isBefore(startDate)) {
        debugPrint("❌ End date must be after start date");
        Get.snackbar('Invalid Date', 'End date must be after start date');
        return false;
      }
    }

    // 3. Check if schedule is in the past (for same day)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDate =
        DateTime(startDate.year, startDate.month, startDate.day);

    if (scheduleDate.isAtSameMomentAs(today)) {
      final currentMinutes = now.hour * 60 + now.minute;
      if (startMinutes <= currentMinutes) {
        debugPrint("❌ Cannot schedule for past time today");
        Get.snackbar('Invalid Time', 'Cannot schedule for past time today');
        return false;
      }
    }

    // 4. Check if schedule is too far in the future (optional - 1 year limit)
    final oneYearFromNow = now.add(const Duration(days: 365));
    if (startDate.isAfter(oneYearFromNow)) {
      debugPrint("❌ Cannot schedule more than 1 year in advance");
      Get.snackbar(
          'Invalid Date', 'Cannot schedule more than 1 year in advance');
      return false;
    }

    // 5. Check if the time range is too short (minimum 5 minutes)
    final timeDifference = endMinutes - startMinutes;
    // if (timeDifference < 5) {
    //   debugPrint("❌ Time range must be at least 5 minutes");
    //   Get.snackbar('Invalid Time', 'Time range must be at least 5 minutes');
    //   return false;
    // }

    // 6. Check if the time range is too long (maximum 24 hours)
    if (timeDifference > 24 * 60) {
      debugPrint("❌ Time range cannot exceed 24 hours");
      Get.snackbar('Invalid Time', 'Time range cannot exceed 24 hours');
      return false;
    }

    debugPrint("✅ Time validation passed");
    return true;
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
              Row(
                children: [
                  // Refresh sounds button
                  Obx(() => IconButton(
                        icon: controller.isLoadingSounds.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF34BB91)),
                                ),
                              )
                            : const Icon(Icons.refresh),
                        onPressed: controller.isLoadingSounds.value
                            ? null
                            : _refreshSounds,
                        tooltip: 'Refresh sounds list',
                      )),

                  // Refresh schedules button
                  Obx(() => IconButton(
                        icon: controller.isLoadingSchedules.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF34BB91)),
                                ),
                              )
                            : const Icon(Icons.schedule),
                        onPressed: controller.isLoadingSchedules.value
                            ? null
                            : () async {
                                await controller.loadSchedulesFromApi();
                                Get.snackbar('Refreshed', 'Schedules updated');
                              },
                        tooltip: 'Refresh schedules',
                      )),
                ],
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

                  Row(
                    children: [
                      /// Start Date Field
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickDateRange(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.calendar_month,
                                color: Color(0xFF34BB91),
                              ),
                            ),
                            child: ValueListenableBuilder(
                              valueListenable: _selectedStartDate,
                              builder: (_, DateTime? startDate, __) => Text(
                                startDate == null
                                    ? 'Start date'
                                    : formatDate(startDate),
                                style: TextStyle(
                                  color: startDate == null
                                      ? Colors.grey[600]
                                      : null,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      /// End Date Field
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickDateRange(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.calendar_month,
                                color: Color(0xFF34BB91),
                              ),
                            ),
                            child: ValueListenableBuilder(
                              valueListenable: _selectedEndDate,
                              builder: (_, DateTime? endDate, __) => Text(
                                endDate == null
                                    ? 'End date'
                                    : formatDate(endDate),
                                style: TextStyle(
                                  color:
                                      endDate == null ? Colors.grey[600] : null,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      /// Start Time Field
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickTime(context, _startTime),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.access_alarm,
                                color: Color(0xFF34BB91),
                              ),
                            ),
                            child: Text(
                              _startTime.value == null
                                  ? 'Start time'
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
                      ),
                      const SizedBox(width: 15),

                      /// End Time Field
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickTime(context, _endTime),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.access_alarm,
                                color: Color(0xFF34BB91),
                              ),
                            ),
                            child: Text(
                              _endTime.value == null
                                  ? 'End time'
                                  : formatTime(_endTime.value),
                              style: TextStyle(
                                color: _endTime.value == null
                                    ? Colors.grey[600]
                                    : null,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Interval Selection Button
                  GestureDetector(
                    onTap: () => _showIntervalPicker(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            color: Color(0xFF34BB91),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() => Text(
                                  _interval.value.isEmpty
                                      ? 'Select Interval'
                                      : '${_selectedMinutes.value} minutes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _interval.value.isEmpty
                                        ? Colors.grey[600]
                                        : Colors.black,
                                  ),
                                )),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF34BB91),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sound Selection Button
                  GestureDetector(
                    onTap: () => _showSoundSelectionDialog(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.volume_up,
                            color: Color(0xFF34BB91),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() => Text(
                                  controller.isLoadingSounds.value
                                      ? 'Loading sounds...'
                                      : _selectedSounds.isEmpty
                                          ? 'Select Sounds'
                                          : '${_selectedSounds.length} sound${_selectedSounds.length > 1 ? 's' : ''} selected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedSounds.isEmpty
                                        ? Colors.grey[600]
                                        : Colors.black,
                                  ),
                                )),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF34BB91),
                          ),
                        ],
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

                  // Active Schedules Section
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
                          ElevatedButton.icon(
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
                              backgroundColor: const Color(0xFF34BB91),
                              foregroundColor: Colors.white,
                            ),
                          ),

                        // Loading indicator for schedules
                        if (controller.isLoadingSchedules.value)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF34BB91)),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Loading schedules...',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Schedules List
                        if (!controller.isLoadingSchedules.value)
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
                                    final sortedSchedules = controller.schedules
                                        .toList()
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

    if (_selectedStartDate.value == null) {
      debugPrint("❌ No start date selected");
      Get.snackbar('Error', 'Please select a start date');
      return;
    }

    if (_selectedEndDate.value == null) {
      debugPrint("❌ No end date selected");
      Get.snackbar('Error', 'Please select an end date');
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

    // Time validation
    if (!_validateTimes()) {
      return;
    }

    if (_selectedSounds.isEmpty) {
      debugPrint("❌ No sounds selected");
      Get.snackbar('Error', 'Please select at least one sound');
      return;
    }

    if (int.tryParse(_interval.value) == null ||
        int.parse(_interval.value) <= 0) {
      debugPrint("❌ Invalid interval: ${_interval.value}");
      Get.snackbar('Error', 'Please select a valid interval');
      return;
    }

    debugPrint(
        "🔍 DEBUG: _selectedSounds before creating schedule: $_selectedSounds");

    // Create a proper copy of the selected sounds list
    final selectedSoundsCopy = List<String>.from(_selectedSounds);
    debugPrint("🔍 DEBUG: selectedSoundsCopy: $selectedSoundsCopy");
    debugPrint(
        "🔍 DEBUG: selectedSoundsCopy length: ${selectedSoundsCopy.length}");

    final schedule = AudioSchedule(
      date: _selectedStartDate.value!,
      endDate: _selectedEndDate.value!,
      startTime: _startTime.value!,
      endTime: _endTime.value!,
      soundPath: selectedSoundsCopy.isNotEmpty ? selectedSoundsCopy.first : '',
      soundPaths: List<String>.from(
          selectedSoundsCopy), // Create another copy to ensure it's not reactive
      interval: int.parse(_interval.value),
    );

    debugPrint(
        "🔍 DEBUG: schedule.soundPaths after creation: ${schedule.soundPaths}");

    debugPrint("✅ Schedule created:");
    debugPrint("   Start Date: ${schedule.formattedDate}");
    debugPrint(
        "   End Date: ${schedule.endDate != null ? formatDate(schedule.endDate!) : 'Same as start'}");
    debugPrint("   Start Time: ${schedule.formattedStartTime}");
    debugPrint("   End Time: ${schedule.formattedEndTime}");
    debugPrint("   Sound: ${schedule.soundDisplayName}");
    final minutes = schedule.interval;
    debugPrint(
        "   Interval: ${schedule.interval} seconds (${minutes} minutes)");

    controller.addSchedule(schedule);

    // Reset form
    _selectedStartDate.value = null;
    _selectedEndDate.value = null;
    _startTime.value = null;
    _endTime.value = null;
    _selectedSound.value = '';
    _selectedSounds.clear();
    _interval.value = '';
    _intervalController.clear();
    _selectedMinutes.value = 1;
    // _selectedSeconds.value = 0;
  }

  Future<void> _pickTime(BuildContext context, Rx<TimeOfDay?> target) async {
    // Calculate initial time: selected time + 1 minute, or current time + 1 minute if no selection
    TimeOfDay initialTime;
    if (target.value != null) {
      // Add 1 minute to the currently selected time
      final currentTime = target.value!;
      final totalMinutes = currentTime.hour * 60 + currentTime.minute + 1;
      final newHour = (totalMinutes ~/ 60) % 24;
      final newMinute = totalMinutes % 60;
      initialTime = TimeOfDay(hour: newHour, minute: newMinute);
    } else {
      // Add 1 minute to current time
      final now = DateTime.now();
      final totalMinutes = now.hour * 60 + now.minute + 1;
      final newHour = (totalMinutes ~/ 60) % 24;
      final newMinute = totalMinutes % 60;
      initialTime = TimeOfDay(hour: newHour, minute: newMinute);
    }

    debugPrint(
        "🕐 Time picker initial time: ${initialTime.hour}:${initialTime.minute.toString().padLeft(2, '0')}");

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF34BB91),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: const TimePickerThemeData(
              dayPeriodColor: Color(0xFF34BB91),
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

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange:
          (_selectedStartDate.value != null && _selectedEndDate.value != null)
              ? DateTimeRange(
                  start: _selectedStartDate.value!,
                  end: _selectedEndDate.value!,
                )
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF34BB91),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF34BB91),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _selectedStartDate.value = picked.start;
      _selectedEndDate.value = picked.end;
      debugPrint(
          "Date range selected: ${formatDate(picked.start)} - ${formatDate(picked.end)}");
    }
  }
}

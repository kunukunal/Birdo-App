// import 'package:birdo/controller/audio_controller.dart';
// import 'package:birdo/controller/dto.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ScheduleInputView extends StatelessWidget {
//   ScheduleInputView({super.key});

//   final controller = Get.put(AudioSchedulerController());

//   final _startTime = Rx<TimeOfDay?>(null);
//   final _endTime = Rx<TimeOfDay?>(null);
//   final _selectedSound = ''.obs;
//   final _interval = ''.obs;
//   final _intervalController = TextEditingController();

//   Future<void> _pickTime(BuildContext context, Rx<TimeOfDay?> target) async {
//     final picked =
//         await showTimePicker(context: context, initialTime: TimeOfDay.now());
//     if (picked != null) target.value = picked;
//   }

//   String _formatTime(TimeOfDay? time) {
//     if (time == null) return 'Select Time';
//     final hour = time.hourOfPeriod.toString().padLeft(2, '0');
//     final minute = time.minute.toString().padLeft(2, '0');
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }

//   void _addSchedule() {
//     if (_startTime.value == null ||
//         _endTime.value == null ||
//         _selectedSound.value.isEmpty ||
//         int.tryParse(_interval.value) == null ||
//         int.parse(_interval.value) <= 0) {
//       Get.snackbar('Error', 'Please fill all fields correctly');
//       return;
//     }

//     controller.addSchedule(AudioSchedule(
//       startTime: _startTime.value!,
//       endTime: _endTime.value!,
//       soundPath: _selectedSound.value,
//       interval: int.parse(_interval.value),
//     ));

//     _startTime.value = null;
//     _endTime.value = null;
//     _selectedSound.value = '';
//     _interval.value = '';
//     _intervalController.clear();

//     Get.snackbar('Success', 'Schedule added');
//   }

//   void _refreshSounds() {
//     controller.refreshSounds();
//     Get.snackbar('Refreshed', 'Sound list updated');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Schedule Sounds'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _refreshSounds,
//             tooltip: 'Refresh sounds list',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Obx(() {
//           return ListView(
//             children: [
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Create New Schedule',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ListTile(
//                         leading: const Icon(Icons.access_time),
//                         title: const Text('Start Time'),
//                         trailing: Text(_formatTime(_startTime.value)),
//                         onTap: () => _pickTime(context, _startTime),
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.access_time_filled),
//                         title: const Text('End Time'),
//                         trailing: Text(_formatTime(_endTime.value)),
//                         onTap: () => _pickTime(context, _endTime),
//                       ),
//                       const SizedBox(height: 10),
//                       TextFormField(
//                         controller: _intervalController,
//                         keyboardType: TextInputType.number,
//                         onChanged: _interval,
//                         decoration: const InputDecoration(
//                           labelText: 'Interval (seconds)',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.timer),
//                           helperText: 'How often to play the sound',
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       DropdownButtonFormField<String>(
//                         icon: const SizedBox.shrink(),
//                         value: _selectedSound.value.isEmpty
//                             ? null
//                             : _selectedSound.value,
//                         items: controller.availableSounds.map((sound) {
//                           final displayName =
//                               controller.getSoundDisplayName(sound);
//                           final isUploaded = !sound.startsWith('assets/');

//                           return DropdownMenuItem(
//                             value: sound,
//                             child: Row(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text(
//                                       displayName,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     if (isUploaded)
//                                       Container(
//                                         margin: const EdgeInsets.only(left: 6),
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 6,
//                                           vertical: 2,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: Colors.blue.withOpacity(0.1),
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         child: const Text(
//                                           'Uploaded',
//                                           style: TextStyle(
//                                             fontSize: 10,
//                                             color: Colors.blue,
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (value) =>
//                             _selectedSound.value = value ?? '',
//                         decoration: const InputDecoration(
//                           labelText: 'Select Sound',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.volume_up),
//                           helperText: 'Choose from assets or uploaded sounds',
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.add),
//                           label: const Text('Add Schedule'),
//                           onPressed: _addSchedule,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(Icons.schedule),
//                           const SizedBox(width: 8),
//                           const Text(
//                             'Active Schedules',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const Spacer(),
//                           Text(
//                             '${controller.schedules.length} active',
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       if (controller.schedules.isEmpty)
//                         const Padding(
//                           padding: EdgeInsets.all(20.0),
//                           child: Center(
//                             child: Text(
//                               'No active schedules',
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontStyle: FontStyle.italic,
//                               ),
//                             ),
//                           ),
//                         )
//                       else
//                         ...controller.schedules.map((schedule) {
//                           final soundName = controller
//                               .getSoundDisplayName(schedule.soundPath);
//                           final isUploaded =
//                               !schedule.soundPath.startsWith('assets/');

//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 8),
//                             child: ListTile(
//                               leading: CircleAvatar(
//                                 backgroundColor: isUploaded
//                                     ? Colors.blue.withOpacity(0.1)
//                                     : Colors.grey.withOpacity(0.1),
//                                 child: Icon(
//                                   isUploaded
//                                       ? Icons.upload_file
//                                       : Icons.music_note,
//                                   color: isUploaded ? Colors.blue : Colors.grey,
//                                   size: 20,
//                                 ),
//                               ),
//                               title: Text(
//                                 '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w500),
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Every ${schedule.interval}s'),
//                                   Row(
//                                     children: [
//                                       Icon(
//                                         Icons.music_note,
//                                         size: 14,
//                                         color: Colors.grey[600],
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Expanded(
//                                         child: Text(
//                                           soundName,
//                                           style: TextStyle(
//                                             color: Colors.grey[600],
//                                             fontSize: 12,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       if (isUploaded)
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 4,
//                                             vertical: 1,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: Colors.blue.withOpacity(0.1),
//                                             borderRadius:
//                                                 BorderRadius.circular(4),
//                                           ),
//                                           child: const Text(
//                                             'Uploaded',
//                                             style: TextStyle(
//                                               fontSize: 8,
//                                               color: Colors.blue,
//                                             ),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               trailing: IconButton(
//                                 icon:
//                                     const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () =>
//                                     controller.removeSchedule(schedule),
//                                 tooltip: 'Delete schedule',
//                               ),
//                             ),
//                           );
//                         }),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }

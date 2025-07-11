import 'package:birdo/schedule/sound_uploader_view.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birdo/header.dart';

class Soundlist extends StatefulWidget {
  final Function(List<String>) updatePathOrder;

  const Soundlist({super.key, required this.updatePathOrder});

  @override
  State<Soundlist> createState() => _SoundlistState();
}

class _SoundlistState extends State<Soundlist> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> sounds = [
    {'name': 'OWL', 'path': 'images/owl1.mp3', 'isChecked': false},
    {'name': 'OWL', 'path': 'images/owl2.mp3', 'isChecked': false},
    {'name': 'OWL', 'path': 'images/owl3.mp3', 'isChecked': false},
    {'name': 'OWL', 'path': 'images/owl4.mp3', 'isChecked': false},
    {'name': 'OWL', 'path': 'images/owl5.mp3', 'isChecked': false},
    {'name': 'OWL', 'path': 'images/owl6.mp3', 'isChecked': false},
    {'name': 'Dolphin', 'path': 'images/dolphin-sound.mp3', 'isChecked': false},
    {'name': 'EAGLE', 'path': 'images/eagle.mp3', 'isChecked': false},
    {'name': 'GUNSHOT', 'path': 'images/gunshotglock.mp3', 'isChecked': false},
    {
      'name': 'PUNCH SOUND',
      'path': 'images/punchsound.mp3',
      'isChecked': false
    },
    {'name': 'RIFLE', 'path': 'images/rifle.mp3', 'isChecked': false},
    {
      'name': 'HIGH PITCH',
      'path': 'images/high pitch sound.mp3',
      'isChecked': false
    },
    {'name': 'BIRDO SPECIAL', 'path': 'images/birdo.mp3', 'isChecked': false},
  ];

  List<String> pathOrder = [];
  int lastCheckedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var sound in sounds) {
      sound['isChecked'] = prefs.getBool('isChecked_${sound['path']}') ?? false;
    }

    List<String>? order = prefs.getStringList('pathOrder');
    if (order != null) {
      sounds.sort((a, b) =>
          order.indexOf(a['path']).compareTo(order.indexOf(b['path'])));
    }
    lastCheckedIndex = prefs.getInt('lastCheckedIndex') ?? -1;

    setState(() {});
    _updatePathOrder();
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var sound in sounds) {
      prefs.setBool('isChecked_${sound['path']}', sound['isChecked']);
    }
    prefs.setStringList('pathOrder', pathOrder);
    prefs.setInt('lastCheckedIndex', lastCheckedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Header(),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: sounds.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    return _buildSoundItem(
                      sounds[index]['name']!,
                      sounds[index]['path']!,
                      sounds[index]['isChecked'],
                      index,
                      key: ValueKey(sounds[index]['path']),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SoundUploaderView(),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xFF34BB91),
                      ),
                      child: const Center(
                        child: Text(
                          'Upload',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _savePreferences();
                      List<String> checkedPaths = sounds
                          .where((sound) => sound['isChecked'])
                          .map((sound) => sound['path'] as String)
                          .toList();
                      widget.updatePathOrder(checkedPaths);
                    },
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xFF34BB91),
                      ),
                      child: const Center(
                        child: Text(
                          'Save',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) => ScheduleInputView(),
                  //       ),
                  //     );
                  //   },
                  //   child: Container(
                  //     height: 40,
                  //     width: 100,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(30),
                  //       color: const Color(0xFF34BB91),
                  //     ),
                  //     child: const Center(
                  //       child: Text(
                  //         'Sechdule',
                  //         style: TextStyle(fontSize: 16, color: Colors.white),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              // FilledButton(
              //   style: FilledButton.styleFrom(
              //     backgroundColor: const Color(0xFF34BB91),
              //     foregroundColor: Colors.white,
              //     minimumSize: const Size(double.infinity, 50),
              //   ),
              //   onPressed: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => ScheduleInputView(),
              //       ),
              //     );
              //   },
              //   child: const Text(
              //     'Schedule Settings',
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundItem(String name, String path, bool isChecked, int index,
      {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () => _playAudio(path),
        child: Row(
          children: [
            Checkbox(
              activeColor: const Color(0xFF34BB91),
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  sounds[index]['isChecked'] = value ?? false;
                  if (value == true) {
                    lastCheckedIndex = index;
                  } else if (lastCheckedIndex == index) {
                    lastCheckedIndex = -1;
                  }
                });
              },
            ),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF34BB91)),
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey[50],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.volume_up, color: Color(0xFF34BB91)),
                          const SizedBox(width: 10),
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF34BB91)),
                          ),
                        ],
                      ),
                      const Icon(Icons.play_arrow, color: Color(0xFF34BB91)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playAudio(String path) async {
    await _audioPlayer.play(AssetSource(path));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = sounds.removeAt(oldIndex);
      sounds.insert(newIndex, item);
      _updatePathOrder();
    });
  }

  void _updatePathOrder() {
    pathOrder = sounds.map((sound) => sound['path'] as String).toList();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

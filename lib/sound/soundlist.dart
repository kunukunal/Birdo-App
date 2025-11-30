import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Soundlist extends StatefulWidget {
  final Function(List<String>) updatePathOrder;

  const Soundlist({super.key, required this.updatePathOrder});

  @override
  State<Soundlist> createState() => _SoundlistState();
}

class _SoundlistState extends State<Soundlist> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> sounds = [];
  List<String> pathOrder = [];
  int lastCheckedIndex = -1;
  bool isLoadingSounds = false;

  // Variables to track playing state
  String? currentlyPlayingPath;
  bool isPlaying = false;
  bool isLoading = false;
  String? loadingSoundPath;

  // Default local sounds (fallback)
  final List<Map<String, dynamic>> defaultSounds = [
    {
      'name': 'OWL',
      'path': 'images/owl1.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'OWL',
      'path': 'images/owl2.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'OWL',
      'path': 'images/owl3.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'OWL',
      'path': 'images/owl4.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'OWL',
      'path': 'images/owl5.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'OWL',
      'path': 'images/owl6.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'Dolphin',
      'path': 'images/dolphin-sound.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'EAGLE',
      'path': 'images/eagle.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'GUNSHOT',
      'path': 'images/gunshotglock.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'PUNCH SOUND',
      'path': 'images/punchsound.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'RIFLE',
      'path': 'images/rifle.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'HIGH PITCH',
      'path': 'images/high pitch sound.mp3',
      'isChecked': false,
      'isLocal': true
    },
    {
      'name': 'BIRDO SPECIAL',
      'path': 'images/birdo.mp3',
      'isChecked': false,
      'isLocal': true
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAudioPlayerListeners();
    _initializeSounds();
  }

  void _setupAudioPlayerListeners() {
    // Listen for when audio completes
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          currentlyPlayingPath = null;
          isPlaying = false;
          isLoading = false;
          loadingSoundPath = null;
        });
      }
    });

    // Listen for player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
          if (state == PlayerState.stopped || state == PlayerState.completed) {
            currentlyPlayingPath = null;
            isPlaying = false;
            isLoading = false;
            loadingSoundPath = null;
          } else if (state == PlayerState.playing) {
            isLoading = false;
            loadingSoundPath = null;
          }
        });
      }
    });
  }

  Future<void> _initializeSounds() async {
    // Load default sounds first
    // sounds = List.from(defaultSounds);
    // await _loadPreferences();

    // Then fetch API sounds
    await _fetchUserSounds();
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Adjust key based on your token storage
  }

  Future<void> _fetchUserSounds() async {
    sounds.clear();
    setState(() {
      isLoadingSounds = true;
    });

    try {
      String? token = await _getAuthToken();

      if (token == null) {
        print('No auth token found');
        setState(() {
          isLoadingSounds = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.thebirdo.com/api/user-sounds'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // if (data['sounds'] != null && data['sounds'] is List) {
        // Clear existing API sounds and keep only local sounds
        // sounds = sounds.where((sound) => sound['isLocal'] == true).toList();

        // Add API sounds
        for (var apiSound in data['sounds']) {
          sounds.add({
            'id': apiSound['id'],
            'name': apiSound['name']?.toString().toUpperCase() ?? 'UNKNOWN',
            'path': apiSound['path'],
            'url': 'https://thebirdo.com/uploads/sounds/${apiSound['path']}',
            'isChecked': false,
            'isLocal': false,
          });
          print("id: ${apiSound['id']}");
          print("name: ${apiSound['name']}");
        }

        // Load preferences for the updated sounds list
        await _loadPreferencesForUpdatedSounds();
        _updatePathOrder();
      } else if (response.statusCode == 401) {
        print('Unauthenticated: ${response.body}');
        _showErrorSnackBar('Authentication failed. Please login again.');
      } else {
        print(
            'Error fetching sounds: ${response.statusCode} - ${response.body}');
        _showErrorSnackBar('Failed to load sounds from server.');
      }
    } catch (e) {
      print('Exception while fetching user sounds: $e');
      _showErrorSnackBar('Network error. Please check your connection.');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSounds = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var sound in sounds) {
      String key = sound['isLocal'] == true
          ? 'isChecked_${sound['path']}'
          : 'isChecked_${sound['id']}';
      sound['isChecked'] = prefs.getBool(key) ?? false;
    }

    List<String>? order = prefs.getStringList('pathOrder');
    if (order != null && order.isNotEmpty) {
      sounds.sort((a, b) {
        String aKey = a['isLocal'] == true ? a['path'] : a['id'].toString();
        String bKey = b['isLocal'] == true ? b['path'] : b['id'].toString();
        int aIndex = order.indexOf(aKey);
        int bIndex = order.indexOf(bKey);
        if (aIndex == -1) aIndex = order.length;
        if (bIndex == -1) bIndex = order.length;
        return aIndex.compareTo(bIndex);
      });
    }

    lastCheckedIndex = prefs.getInt('lastCheckedIndex') ?? -1;
    setState(() {});
  }

  Future<void> _loadPreferencesForUpdatedSounds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var sound in sounds) {
      String key = sound['isLocal'] == true
          ? 'isChecked_${sound['path']}'
          : 'isChecked_${sound['id']}';
      sound['isChecked'] = prefs.getBool(key) ?? false;
    }
    setState(() {});
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var sound in sounds) {
      String key = sound['isLocal'] == true
          ? 'isChecked_${sound['path']}'
          : 'isChecked_${sound['id']}';
      prefs.setBool(key, sound['isChecked']);
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
              // Add refresh button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 70,
                        child: Image.asset('assets/images/logo.png'),
                      ),
                    ),
                    Spacer(),
                    if (isLoadingSounds)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF34BB91)),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: _fetchUserSounds,
                        icon:
                            const Icon(Icons.refresh, color: Color(0xFF34BB91)),
                        tooltip: 'Refresh sounds',
                      ),
                  ],
                ),
              ),
              Expanded(
                child: sounds.isEmpty && !isLoadingSounds
                    ? const Center(
                        child: Text(
                          'No sounds available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        itemCount: sounds.length,
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          return _buildSoundItem(
                            sounds[index]['name']!,
                            sounds[index],
                            sounds[index]['isChecked'],
                            index,
                            key: ValueKey(sounds[index]['isLocal'] == true
                                ? sounds[index]['path']
                                : sounds[index]['id'].toString()),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundItem(
      String name, Map<String, dynamic> soundData, bool isChecked, int index,
      {Key? key}) {
    // Determine the audio path/URL
    String audioPath;
    audioPath = soundData['url'] ?? '';

    // Determine loader visibility
    bool isThisSoundLoading = loadingSoundPath == audioPath && isLoading;

    // Check if this sound is currently playing
    bool isThisSoundPlaying = currentlyPlayingPath == audioPath && isPlaying;

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isThisSoundLoading ? null : () => _toggleAudio(audioPath),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isThisSoundLoading
                          ? Colors.grey
                          : const Color(0xFF34BB91)),
                  borderRadius: BorderRadius.circular(30),
                  color:
                      isThisSoundLoading ? Colors.grey[100] : Colors.grey[50],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.volume_up,
                              color: Color(0xFF34BB91),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isThisSoundLoading
                                      ? Colors.grey
                                      : const Color(0xFF34BB91),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isThisSoundLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF34BB91)),
                          ),
                        )
                      else
                        Icon(
                          isThisSoundPlaying ? Icons.pause : Icons.play_arrow,
                          color: const Color(0xFF34BB91),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAudio(
    String path,
  ) async {
    try {
      if (currentlyPlayingPath == path && isPlaying) {
        // If the same audio is playing, pause it
        await _audioPlayer.pause();
      } else {
        // Set loading state
        setState(() {
          isLoading = true;
          loadingSoundPath = path;
        });

        // Stop any currently playing audio
        if (currentlyPlayingPath != null && currentlyPlayingPath != path) {
          await _audioPlayer.stop();
        }

        // Play the new audio with timeout
        await _audioPlayer.play(UrlSource(path)).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException(
                'Audio loading timeout', const Duration(seconds: 10));
          },
        );

        setState(() {
          currentlyPlayingPath = path;
          isLoading = false;
          loadingSoundPath = null;
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
      // Show error to user
      _showErrorSnackBar('Failed to play audio. Please try again.');
      // Reset state on error
      setState(() {
        currentlyPlayingPath = null;
        isPlaying = false;
        isLoading = false;
        loadingSoundPath = null;
      });
    }
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
    pathOrder = sounds
        .map((sound) =>
            sound['isLocal'] == true ? sound['path'] : sound['id'].toString())
        .cast<String>()
        .toList();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}

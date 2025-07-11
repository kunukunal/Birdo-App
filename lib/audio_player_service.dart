// lib/audio_player_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  // Create a private constructor
  AudioPlayerService._privateConstructor();

  // Create a singleton instance
  static final AudioPlayerService _instance = AudioPlayerService._privateConstructor();

  // Expose the AudioPlayer
  final AudioPlayer audioPlayer = AudioPlayer();

  // Expose the singleton instance
  static AudioPlayerService get instance => _instance;
}

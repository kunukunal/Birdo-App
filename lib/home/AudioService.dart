import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
  }

  // Play the audio from a given path
  Future<void> play(String path) async {
    await _audioPlayer.play(AssetSource(path));
    isPlaying = true;
  }

  // Stop the audio playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    isPlaying = false;
  }

  // Dispose the audio player when needed
  void dispose() {
    _audioPlayer.dispose();
  }
}

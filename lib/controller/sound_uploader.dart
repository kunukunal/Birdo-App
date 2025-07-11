import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';

class SoundUploaderController extends GetxController {
  var selectedFilePath = ''.obs;
  var statusMessage = ''.obs;
  var uploadedSounds = <String>[].obs;
  final player = AudioPlayer();
  var currentlyPlaying = ''.obs;
  var isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUploadedSounds();
    _setupPlayerListeners();
  }

  void _setupPlayerListeners() {
    // Listen to playing state changes
    player.playingStream.listen((playing) {
      isPlaying.value = playing;
      if (playing) {
        statusMessage.value =
            'Playing ${currentlyPlaying.value.split('/').last}';
      } else if (currentlyPlaying.value.isNotEmpty) {
        statusMessage.value =
            'Paused ${currentlyPlaying.value.split('/').last}';
      }
    });

    // Listen to player state changes for completion
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
        currentlyPlaying.value = '';
        statusMessage.value = 'Audio playback completed';
      }
    });

    // Listen to position stream to update UI during playback
    player.positionStream.listen((position) {
      // This ensures UI updates during playback
      if (player.playing) {
        isPlaying.value = true;
      }
    });
  }

  Future<void> loadUploadedSounds() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final files = appDocDir.listSync();
    uploadedSounds.value = files
        .whereType<File>()
        .where((f) =>
            f.path.endsWith('.mp3') ||
            f.path.endsWith('.wav') ||
            f.path.endsWith('.aac'))
        .map((f) => f.path)
        .toList();
  }

  Future<void> pickAndSaveSound() async {
    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      statusMessage.value =
          'Permission granted. You can now select a sound file.';
    } else if (status.isDenied) {
      statusMessage.value =
          'Permission denied. Please allow access to manage external storage.';
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac'],
    );

    if (result != null && result.files.single.path != null) {
      File pickedFile = File(result.files.single.path!);
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String newPath = '${appDocDir.path}/${result.files.single.name}';
      await pickedFile.copy(newPath);

      selectedFilePath.value = newPath;
      statusMessage.value = 'Sound saved: ${result.files.single.name}';
      uploadedSounds.add(newPath);
    } else {
      statusMessage.value = 'No file selected';
    }
  }

  Future<void> togglePlayPause(String path) async {
    try {
      // If same file is currently playing, pause it
      if (currentlyPlaying.value == path && isPlaying.value) {
        await player.pause();
        return;
      }

      // If different file or not playing, start playing
      if (currentlyPlaying.value != path) {
        await player.stop();
        await player.setFilePath(path);
        currentlyPlaying.value = path;
      }

      await player.play();
    } catch (e) {
      statusMessage.value = 'Error playing audio: $e';
      isPlaying.value = false;
      currentlyPlaying.value = '';
    }
  }

  // Method to stop current playback
  Future<void> stopPlayback() async {
    await player.stop();
    isPlaying.value = false;
    currentlyPlaying.value = '';
    statusMessage.value = 'Playback stopped';
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}

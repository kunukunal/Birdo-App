import 'package:birdo/controller/sound_uploader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SoundUploaderView extends StatelessWidget {
  final SoundUploaderController controller = Get.put(SoundUploaderController());

  SoundUploaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sound Uploader')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Obx(() => Text(
                  controller.selectedFilePath.value.isNotEmpty
                      ? 'Selected: ${controller.selectedFilePath.value.split('/').last}'
                      : 'No file selected',
                  style: const TextStyle(fontSize: 16),
                )),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.pickAndSaveSound,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Sound'),
            ),
            const SizedBox(height: 20),
            Obx(() => Text(
                  controller.statusMessage.value,
                  style: TextStyle(
                    color:
                        controller.isPlaying.value ? Colors.blue : Colors.green,
                    fontWeight: controller.isPlaying.value
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                )),
            const SizedBox(height: 10),
            // Stop button for better control
            Obx(() => controller.isPlaying.value
                ? ElevatedButton.icon(
                    onPressed: controller.stopPlayback,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  )
                : const SizedBox.shrink()),
            const Divider(),
            const Text('Uploaded Sounds:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: GetBuilder<SoundUploaderController>(
                builder: (controller) => Obx(() => ListView.builder(
                      itemCount: controller.uploadedSounds.length,
                      itemBuilder: (context, index) {
                        final filePath = controller.uploadedSounds[index];
                        final fileName = filePath.split('/').last;

                        return Obx(() {
                          final isCurrentlyPlaying =
                              controller.currentlyPlaying.value == filePath;
                          final isPlaying =
                              isCurrentlyPlaying && controller.isPlaying.value;

                          return Card(
                            color: isCurrentlyPlaying
                                ? Colors.blue.withOpacity(0.1)
                                : null,
                            child: ListTile(
                              title: Text(
                                fileName,
                                style: TextStyle(
                                  fontWeight: isCurrentlyPlaying
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: isCurrentlyPlaying
                                  ? Text(
                                      isPlaying ? 'Playing...' : 'Paused',
                                      style: TextStyle(
                                        color: isPlaying
                                            ? Colors.blue
                                            : Colors.orange,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isCurrentlyPlaying && isPlaying)
                                    Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.music_note,
                                        size: 8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      isPlaying
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      color: isCurrentlyPlaying
                                          ? (isPlaying
                                              ? Colors.blue
                                              : Colors.orange)
                                          : Colors.grey,
                                      size: 32,
                                    ),
                                    onPressed: () =>
                                        controller.togglePlayPause(filePath),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

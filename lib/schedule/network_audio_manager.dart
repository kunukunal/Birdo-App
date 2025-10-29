import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../controller/dto.dart';

class NetworkAudioManager {
  static const String _cacheDirectory = 'audio_cache';

  /// Downloads and caches a network audio file for use in background alarms
  static Future<String?> cacheNetworkAudio(
      String networkUrl, String fileName) async {
    try {
      // Create cache directory
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/$_cacheDirectory');

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      // Generate a safe filename using hash of URL
      final urlHash = md5.convert(utf8.encode(networkUrl)).toString();
      final extension = _getFileExtension(networkUrl) ?? 'mp3';
      final cachedFileName = '${urlHash}_$fileName.$extension';
      final cachedFilePath = '${cacheDir.path}/$cachedFileName';
      final cachedFile = File(cachedFilePath);

      // Check if already cached
      if (await cachedFile.exists()) {
        print('Audio file already cached: $cachedFilePath');
        return cachedFilePath;
      }

      print('Downloading audio file: $networkUrl');

      // Download the file
      final response = await http.get(Uri.parse(networkUrl));

      if (response.statusCode == 200) {
        await cachedFile.writeAsBytes(response.bodyBytes);
        print('Audio file cached successfully: $cachedFilePath');
        return cachedFilePath;
      } else {
        print('Failed to download audio file: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error caching network audio: $e');
      return null;
    }
  }

  /// Pre-cache all network audio files used in schedules
  static Future<Map<String, String>> cacheScheduleAudioFiles(
      List<AudioSchedule> schedules,
      List<Map<String, dynamic>> availableSounds) async {
    final Map<String, String> cachedPaths = {};

    for (final schedule in schedules) {
      final soundPath = schedule.soundPath;

      // Skip if not a network URL
      if (!soundPath.startsWith('http')) {
        cachedPaths[soundPath] = soundPath; // Use original path for local files
        continue;
      }

      // Find the sound name for better caching
      String soundName = 'unknown';
      for (final sound in availableSounds) {
        if (sound['path'] == soundPath || sound['url'] == soundPath) {
          soundName = sound['name'] ?? 'unknown';
          break;
        }
      }

      final cachedPath = await cacheNetworkAudio(soundPath, soundName);
      if (cachedPath != null) {
        cachedPaths[soundPath] = cachedPath;
      } else {
        // Fallback to a default alarm sound if download fails
        final fallbackPath = await copyDefaultAlarmSound();
        cachedPaths[soundPath] = fallbackPath;
      }
    }

    return cachedPaths;
  }

  /// Copy a default alarm sound to cache for fallback
  static Future<String> copyDefaultAlarmSound() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/$_cacheDirectory');

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final fallbackPath = '${cacheDir.path}/default_alarm.mp3';
      final fallbackFile = File(fallbackPath);

      if (!await fallbackFile.exists()) {
        // Copy a default sound from assets
        final byteData = await rootBundle.load('assets/images/birdo.mp3');
        final bytes = byteData.buffer.asUint8List();
        await fallbackFile.writeAsBytes(bytes);
      }

      return fallbackPath;
    } catch (e) {
      print('Error creating fallback alarm sound: $e');
      rethrow;
    }
  }

  /// Convert cached audio file to Android notification sound format
  static Future<String?> prepareNotificationSound(String cachedFilePath) async {
    try {
      final file = File(cachedFilePath);
      if (!await file.exists()) {
        print('Cached file does not exist: $cachedFilePath');
        return null;
      }

      // For Android notifications, we need to copy to a specific location
      // or use a resource-based approach
      final fileName = cachedFilePath.split('/').last;
      final soundName = fileName.split('.').first;

      // You could copy to Android's raw resources directory during build
      // or use a different notification approach

      return soundName; // Return the resource name for Android
    } catch (e) {
      print('Error preparing notification sound: $e');
      return null;
    }
  }

  /// Clean up old cached files
  static Future<void> cleanupCache(
      {Duration maxAge = const Duration(days: 7)}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/$_cacheDirectory');

      if (!await cacheDir.exists()) return;

      final now = DateTime.now();
      final files = await cacheDir.list().toList();

      for (final fileEntity in files) {
        if (fileEntity is File) {
          final fileStat = await fileEntity.stat();
          final fileAge = now.difference(fileStat.modified);

          if (fileAge > maxAge) {
            await fileEntity.delete();
            print('Deleted old cached file: ${fileEntity.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up cache: $e');
    }
  }

  /// Get cache size in bytes
  static Future<int> getCacheSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/$_cacheDirectory');

      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      final files = await cacheDir.list().toList();

      for (final fileEntity in files) {
        if (fileEntity is File) {
          final fileStat = await fileEntity.stat();
          totalSize += fileStat.size;
        }
      }

      return totalSize;
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Clear all cached files
  static Future<void> clearCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/$_cacheDirectory');

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        print('Cache cleared successfully');
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  static String? _getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final lastDotIndex = path.lastIndexOf('.');

      if (lastDotIndex != -1 && lastDotIndex < path.length - 1) {
        return path.substring(lastDotIndex + 1).toLowerCase();
      }
    } catch (e) {
      print('Error getting file extension: $e');
    }
    return null;
  }
}

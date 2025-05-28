import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class AlarmService {
  static Future<void> buzzTask() async {
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      final hasCustomSupport = await Vibration.hasCustomVibrationsSupport() ?? false;

      if (!hasVibrator) {
        if (kDebugMode) {
          print("🚫 Device does not support vibration.");
        }
        return;
      }

      if (hasCustomSupport) {
        // Custom vibration pattern
        await Vibration.vibrate(
          pattern: [0, 500, 250, 500],
          intensities: [128, 255],
        );
        if (kDebugMode) {
          print("✅ Custom vibration pattern triggered.");
        }
      } else {
        // Fallback to simple buzz
        await Vibration.vibrate(duration: 1000);
        if (kDebugMode) {
          print("✅ Simple vibration triggered.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Vibration error: $e");
      }
    }
  }
}

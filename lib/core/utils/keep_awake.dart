import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Thin guard around `wakelock_plus`. Browsers can refuse the Wake Lock API
/// (it throws `NotAllowedError`), and a reader screen must never crash over it.
abstract final class KeepAwake {
  static Future<void> set(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } catch (e) {
      debugPrint('Wake lock unavailable: $e');
    }
  }
}

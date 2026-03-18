import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class PerfTrace {
  static const bool _forceEnableFromEnv =
      bool.fromEnvironment('SOUNDTILO_TRACE', defaultValue: false);
  static bool get enabled => kDebugMode || _forceEnableFromEnv;

  static DateTime? _lastFrameLogAt;

  static void initFrameTimingTrace({int slowFrameThresholdMs = 64}) {
    if (!enabled) {
      return;
    }

    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final timing in timings) {
        final totalMs = timing.totalSpan.inMilliseconds;
        if (totalMs < slowFrameThresholdMs) {
          continue;
        }

        final now = DateTime.now();
        final last = _lastFrameLogAt;
        if (last != null && now.difference(last).inMilliseconds < 1000) {
          continue;
        }
        _lastFrameLogAt = now;

        log(
          'frame.slow',
          'slow frame detected',
          values: {
            'totalMs': totalMs,
            'buildMs': timing.buildDuration.inMilliseconds,
            'rasterMs': timing.rasterDuration.inMilliseconds,
            'vsyncOverheadMs': timing.vsyncOverhead.inMilliseconds,
          },
        );
      }
    });
  }

  static void slow(
    String scope,
    Stopwatch stopwatch, {
    int thresholdMs = 120,
    Map<String, Object?> values = const <String, Object?>{},
  }) {
    if (!enabled) {
      return;
    }

    final elapsedMs = stopwatch.elapsedMilliseconds;
    if (elapsedMs < thresholdMs) {
      return;
    }

    log(
      '$scope.slow',
      'operation exceeded threshold',
      values: {
        'elapsedMs': elapsedMs,
        ...values,
      },
    );
  }

  static void log(
    String scope,
    String message, {
    Map<String, Object?> values = const <String, Object?>{},
  }) {
    if (!enabled) {
      return;
    }

    final meta = values.isEmpty ? '' : ' | $values';
    debugPrint('[TRACE][$scope] $message$meta');
  }
}

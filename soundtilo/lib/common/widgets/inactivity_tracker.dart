import 'dart:async';
import 'package:flutter/material.dart';

/// A widget that monitors global user inactivity and triggers a callback
/// when a timeout occurs.
class InactivityTracker extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback onTimeout;
  final bool enabled;

  const InactivityTracker({
    super.key,
    required this.child,
    required this.timeout,
    required this.onTimeout,
    this.enabled = true,
  });

  @override
  State<InactivityTracker> createState() => _InactivityTrackerState();
}

class _InactivityTrackerState extends State<InactivityTracker> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(InactivityTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _startTimer();
      } else {
        _stopTimer();
      }
    } else if (widget.timeout != oldWidget.timeout && widget.enabled) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer(widget.timeout, widget.onTimeout);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _handleInteraction([_]) {
    if (widget.enabled) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleInteraction,
      onPointerMove: _handleInteraction,
      onPointerHover: _handleInteraction,
      onPointerSignal: _handleInteraction,
      child: widget.child,
    );
  }
}

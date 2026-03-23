import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

abstract class SafeChangeNotifier extends ChangeNotifier {
  bool _isDisposed = false;
  bool _notifyScheduled = false;

  bool get isDisposed => _isDisposed;

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    if (schedulerPhase != SchedulerPhase.idle) {
      if (_notifyScheduled) return;
      _notifyScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _notifyScheduled = false;
        if (_isDisposed) return;
        super.notifyListeners();
      });
      return;
    }
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _notifyScheduled = false;
    super.dispose();
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:intl/intl.dart';

void printLog([dynamic data, DateTime? startTime]) {
  if (foundation.kDebugMode) {
    var time = '';
    if (startTime != null) {
      final endTime = DateTime.now().difference(startTime);
      final icon = endTime.inMilliseconds > 2000
          ? '⌛️Slow-'
          : endTime.inMilliseconds > 1000
              ? '⏰Medium-'
              : '⚡️Fast-';
      time = '[$icon${endTime.inMilliseconds}ms]';
    }

    try {
      final now = DateFormat('h:mm:ss-ms').format(DateTime.now().toLocal());
      debugPrint('ℹ️[${now}ms]$time${data.toString()}');
    } catch (err, trace) {
      printError(err, trace);
    }
  }
}

void printError(dynamic err, dynamic trace) {
  if (foundation.kDebugMode) {
    final now = DateFormat('h:mm:ss-ms').format(DateTime.now().toLocal());
    debugPrint('🐞 [${now}ms] $err');
    if (trace != null) {
      debugPrint('$trace');
    }
  }
}

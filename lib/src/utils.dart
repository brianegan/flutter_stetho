import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_stetho/src/method_channel_controller.dart';

StreamTransformer<List<int>, List<int>> createResponseTransformer(String id) {
  return new StreamTransformer.fromHandlers(handleData: (data, sink) {
    sink.add(data);
    MethodChannelController.onData({"data": data, "id": id});
  }, handleError: (error, stacktrace, sink) {
    sink.addError(error, stacktrace);
    MethodChannelController.responseReadFailed([id, error.toString()]);
  }, handleDone: (sink) {
    sink.close();
    MethodChannelController.responseReadFinished(id);
    MethodChannelController.onDone(id);
  });
}

Map<String, String> headersToMap(HttpHeaders headers) {
  final Map<String, String> map = {};

  headers.forEach((header, values) {
    map[header] = values.first;
    if (header == 'content-type') {
      map['Content-Type'] = values.first;
    }
  });

  return map;
}

/// A UUID generator, useful for generating unique IDs for your Todos.
/// Shamelessly extracted from the Flutter source code.
///
/// This will generate unique IDs in the format:
///
///     f47ac10b-58cc-4372-a567-0e02b2c3d479
///
/// ### Example
///
///     final String id = new Uuid().generateV4();
class Uuid {
  final Random _random = new Random();

  /// Generate a version 4 (random) uuid. This is a uuid scheme that only uses
  /// random numbers as the source of the generated uuid.
  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}

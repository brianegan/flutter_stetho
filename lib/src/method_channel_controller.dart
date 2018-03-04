import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_stetho/src/inspector_request.dart';
import 'package:flutter_stetho/src/inspector_response.dart';

class MethodChannelController {
  static const MethodChannel _channel = const MethodChannel('flutter_stetho');

  static Future<String> requestWillBeSent(
          FlutterStethoInspectorRequest request) =>
      _channel.invokeMethod('requestWillBeSent', request.toMap());

  static Future<String> responseHeadersReceived(
          FlutterStethoInspectorResponse response) =>
      _channel.invokeMethod('responseHeadersReceived', response.toMap());

  static Future<String> interpretResponseStream(String id) =>
      _channel.invokeMethod('interpretResponseStream', id);

  static Future<String> responseReadFinished(String id) =>
      _channel.invokeMethod('responseReadFinished', id);

  static Future<String> responseReadFailed(List<String> idError) =>
      _channel.invokeMethod('responseReadFailed', idError);

  static Future<String> onData(Map<String, Object> map) =>
      _channel.invokeMethod('onData', map);

  static Future<String> onDone(String id) =>
      _channel.invokeMethod('onDone', id);
}

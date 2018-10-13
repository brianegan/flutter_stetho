import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_stetho/src/inspector_request.dart';
import 'package:flutter_stetho/src/inspector_response.dart';

class MethodChannelController {
  static const MethodChannel _channel = const MethodChannel('flutter_stetho');

  static Future<dynamic> requestWillBeSent(
          FlutterStethoInspectorRequest request) =>
      _channel.invokeMethod('requestWillBeSent', request.toMap());

  static Future<dynamic> responseHeadersReceived(
          FlutterStethoInspectorResponse response) =>
      _channel.invokeMethod('responseHeadersReceived', response.toMap());

  static Future<dynamic> interpretResponseStream(String id) =>
      _channel.invokeMethod('interpretResponseStream', id);

  static Future<dynamic> responseReadFinished(String id) =>
      _channel.invokeMethod('responseReadFinished', id);

  static Future<dynamic> responseReadFailed(List<String> idError) =>
      _channel.invokeMethod('responseReadFailed', idError);

  static Future<dynamic> onData(Map<String, Object> map) =>
      _channel.invokeMethod('onData', map);

  static Future<dynamic> onDone(String id) =>
      _channel.invokeMethod('onDone', id);

  static Future<dynamic> initialize() => _channel.invokeMethod('initialize');
}

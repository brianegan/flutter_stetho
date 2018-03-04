import 'package:flutter/foundation.dart';

class FlutterStethoInspectorResponse {
  final String url;
  final bool connectionReused;
  final int connectionId;
  final bool fromDiskCache;
  final String requestId;
  final int statusCode;
  final String reasonPhrase;
  final Map<String, String> headers;

  FlutterStethoInspectorResponse({
    @required this.url,
    @required this.connectionReused,
    @required this.connectionId,
    @required this.requestId,
    @required this.statusCode,
    @required this.reasonPhrase,
    @required this.headers,
    this.fromDiskCache = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'connectionReused': connectionReused,
      'connectionId': connectionId,
      'fromDiskCache': fromDiskCache,
      'requestId': requestId,
      'statusCode': statusCode,
      'reasonPhrase': reasonPhrase,
      'headers': headers,
    };
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class FlutterStetho {
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

class StethoClient extends http.BaseClient {
  final http.Client client;
  int _id = 0;

  StethoClient(this.client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final id = _id++;

    FlutterStetho.requestWillBeSent(new FlutterStethoInspectorRequest(
      url: request.url.toString(),
      headers: request.headers,
      method: request.method,
      id: "$id",
    ));

    final response = await client.send(request);
    FlutterStetho.responseHeadersReceived(
      new FlutterStethoInspectorResponse(
        url: request.url.toString(),
        statusCode: response.statusCode,
        requestId: "$id",
        headers: response.headers,
        connectionReused: false,
        connectionId: id,
        reasonPhrase: response.reasonPhrase,
      ),
    );

    FlutterStetho.interpretResponseStream("$id");
    final stopwatch = new Stopwatch();

    return new http.StreamedResponse(
        response.stream.transform(
          new StreamTransformer.fromHandlers(handleData: (data, sink) {
            sink.add(data);
            stopwatch.start();
            FlutterStetho.onData({"data": data, "id": "$id"});
          }, handleError: (error, stacktrace, sink) {
            sink.addError(error, stacktrace);
            FlutterStetho.responseReadFailed(["$id", error.toString()]);
          }, handleDone: (sink) {
            sink.close();
            stopwatch.stop();
            print("!!!!!!!!!!!!!!!!!!!!DONE: ${stopwatch
                .elapsedMilliseconds} !!!!!!!!!!!!!!!!!!!");
            FlutterStetho.responseReadFinished("$id");
            FlutterStetho.onDone("$id");
          }),
        ),
        response.statusCode,
        contentLength: response.contentLength,
        request: request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);
  }
}

class FlutterStethoInspectorRequest {
  final int friendlyNameExtra;
  final String url;
  final String method;
  final List<int> body;
  final String id;
  final String friendlyName;
  final Map<String, String> headers;

  FlutterStethoInspectorRequest({
    @required this.url,
    @required this.method,
    @required this.id,
    @required this.headers,
    this.body,
    this.friendlyName = 'Flutter Stetho',
    this.friendlyNameExtra,
  });

  Map<String, dynamic> toMap() {
    return {
      'friendlyNameExtra': friendlyNameExtra,
      'url': url,
      'method': method,
      'body': body,
      'id': id,
      'friendlyName': friendlyName,
      'headers': headers,
    };
  }
}

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

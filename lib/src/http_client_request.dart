import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_stetho/src/http_client_response.dart';
import 'package:flutter_stetho/src/inspector_response.dart';
import 'package:flutter_stetho/src/method_channel_controller.dart';
import 'package:flutter_stetho/src/utils.dart';

class StethoHttpClientRequest implements HttpClientRequest {
  final HttpClientRequest request;
  final String id;

  @override
  bool bufferOutput;

  @override
  int contentLength;

  @override
  Encoding encoding;

  @override
  bool followRedirects;

  @override
  int maxRedirects;

  @override
  bool persistentConnection;

  StethoHttpClientRequest(
    this.request,
    this.id,
    this.bufferOutput,
    this.contentLength,
    this.encoding,
    this.followRedirects,
    this.maxRedirects,
    this.persistentConnection,
  );

  @override
  void add(List<int> data) {
    request.add(data);
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    request.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    return request.addStream(stream);
  }

  @override
  Future<HttpClientResponse> close() async {
    final response = await request.close();

    MethodChannelController.responseHeadersReceived(
      new FlutterStethoInspectorResponse(
        url: request.uri.toString(),
        statusCode: response.statusCode,
        requestId: id,
        headers: headersToMap(response.headers),
        connectionReused: false,
        reasonPhrase: response.reasonPhrase,
        connectionId: id.hashCode,
      ),
    );

    MethodChannelController.interpretResponseStream(id);

    return new StethoHttpClientResponse(
      response,
      createResponseTransformer(id).bind(response),
    );
  }

  @override
  HttpConnectionInfo get connectionInfo => request.connectionInfo;

  @override
  List<Cookie> get cookies => request.cookies;

  @override
  Future<HttpClientResponse> get done => request.done;

  @override
  Future flush() => request.flush();

  @override
  HttpHeaders get headers => request.headers;

  @override
  String get method => request.method;

  @override
  Uri get uri => request.uri;

  @override
  void write(Object obj) {
    request.write(obj);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    request.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    request.writeCharCode(charCode);
  }

  @override
  void writeln([Object obj = ""]) {
    request.writeln(obj);
  }
}

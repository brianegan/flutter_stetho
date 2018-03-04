import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

  StethoClient(this.client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final id = new Uuid().generateV4();

    FlutterStetho.requestWillBeSent(new FlutterStethoInspectorRequest(
      url: request.url.toString(),
      headers: request.headers,
      method: request.method,
      id: id,
    ));

    final response = await client.send(request);
    FlutterStetho.responseHeadersReceived(
      new FlutterStethoInspectorResponse(
        url: request.url.toString(),
        statusCode: response.statusCode,
        requestId: id,
        headers: response.headers,
        connectionReused: false,
        reasonPhrase: response.reasonPhrase,
        connectionId: id.hashCode,
      ),
    );

    FlutterStetho.interpretResponseStream(id);

    return new http.StreamedResponse(
        response.stream.transform(_createResponseTransformer(id)),
        response.statusCode,
        contentLength: response.contentLength,
        request: request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);
  }
}

StreamTransformer<List<int>, List<int>> _createResponseTransformer(String id) {
  return new StreamTransformer.fromHandlers(handleData: (data, sink) {
    sink.add(data);
    FlutterStetho.onData({"data": data, "id": id});
  }, handleError: (error, stacktrace, sink) {
    sink.addError(error, stacktrace);
    FlutterStetho.responseReadFailed([id, error.toString()]);
  }, handleDone: (sink) {
    sink.close();
    FlutterStetho.responseReadFinished(id);
    FlutterStetho.onDone(id);
  });
}

class StethoHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return new StethoHttpClient(super.createHttpClient(context));
  }
}

class StethoHttpClient implements HttpClient {
  final HttpClient client;

  StethoHttpClient(this.client);

  @override
  bool autoUncompress;

  @override
  Duration idleTimeout;

  @override
  int maxConnectionsPerHost;

  @override
  String userAgent;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {
    client.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {
    client.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String realm) f,
  ) {
    client.authenticate = f;
  }

  @override
  set authenticateProxy(
    Future<bool> Function(String host, int port, String scheme, String realm) f,
  ) {
    client.authenticateProxy = f;
  }

  @override
  set badCertificateCallback(
    bool Function(X509Certificate cert, String host, int port) callback,
  ) {
    client.badCertificateCallback = callback;
  }

  @override
  void close({bool force: false}) {
    client.close();
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      open("get", host, port, path);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl("get", url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      open("post", host, port, path);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl("post", url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      open("put", host, port, path);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl("put", url);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      open("delete", host, port, path);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl("delete", url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      open("head", host, port, path);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => openUrl("head", url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      open("patch", host, port, path);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl("patch", url);

  @override
  set findProxy(String Function(Uri url) f) => client.findProxy = f;

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) async {
    return _wrapResponse(await client.open(method, host, port, path));
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _wrapResponse(await client.openUrl(method, url));
  }

  HttpClientRequest _wrapResponse(HttpClientRequest request) {
    final id = new Uuid().generateV4();

    FlutterStetho.requestWillBeSent(new FlutterStethoInspectorRequest(
      url: request.uri.toString(),
      headers: _headersToMap(request.headers),
      method: request.method,
      id: id,
    ));

    return new StethoHttpClientRequest(
      request,
      id,
      request.bufferOutput,
      request.contentLength,
      request.encoding,
      request.followRedirects,
      request.maxRedirects,
      request.persistentConnection,
    );
  }
}

Map<String, String> _headersToMap(HttpHeaders headers) {
  final Map<String, String> map = {};

  headers.forEach((header, values) {
    map[header] = values.first;
    if (header == 'content-type') {
      map['Content-Type'] = values.first;
    }
  });

  return map;
}

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

    FlutterStetho.responseHeadersReceived(
      new FlutterStethoInspectorResponse(
        url: request.uri.toString(),
        statusCode: response.statusCode,
        requestId: id,
        headers: _headersToMap(response.headers),
        connectionReused: false,
        reasonPhrase: response.reasonPhrase,
        connectionId: id.hashCode,
      ),
    );

    FlutterStetho.interpretResponseStream(id);

    return new StethoHttpClientResponse(
      response,
      response.transform(
        _createResponseTransformer(id),
      ),
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

class StethoHttpClientResponse extends StreamView<List<int>>
    implements HttpClientResponse {
  final HttpClientResponse response;

  StethoHttpClientResponse(this.response, Stream<List<int>> stream)
      : super(stream);

  @override
  X509Certificate get certificate => response.certificate;

  @override
  HttpConnectionInfo get connectionInfo => response.connectionInfo;

  @override
  int get contentLength => response.contentLength;

  @override
  List<Cookie> get cookies => response.cookies;

  @override
  Future<Socket> detachSocket() {
    return response.detachSocket();
  }

  @override
  HttpHeaders get headers => response.headers;

  @override
  bool get isRedirect => response.isRedirect;

  @override
  bool get persistentConnection => response.persistentConnection;

  @override
  String get reasonPhrase => response.reasonPhrase;

  @override
  Future<HttpClientResponse> redirect(
      [String method, Uri url, bool followLoops]) {
    return response.redirect(method, url, followLoops);
  }

  @override
  List<RedirectInfo> get redirects => response.redirects;

  @override
  int get statusCode => response.statusCode;
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

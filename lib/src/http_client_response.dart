import 'dart:async';
import 'dart:io';

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

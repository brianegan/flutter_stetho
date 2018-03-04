import 'dart:io';

import 'package:flutter_stetho/src/http_client.dart';

class StethoHttpOverrides extends HttpOverrides {
  final String Function(Uri url, Map<String, String> environment)
      findProxyFromEnvironmentFn;
  final HttpClient Function(SecurityContext context) createHttpClientFn;

  StethoHttpOverrides({
    this.findProxyFromEnvironmentFn,
    this.createHttpClientFn,
  });

  @override
  HttpClient createHttpClient(SecurityContext context) {
    final client = createHttpClientFn != null
        ? createHttpClientFn(context)
        : super.createHttpClient(context);

    if (Platform.isAndroid) {
      return new StethoHttpClient(client);
    }

    return client;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String> environment) {
    return findProxyFromEnvironmentFn != null
        ? findProxyFromEnvironmentFn(url, environment)
        : super.findProxyFromEnvironment(url, environment);
  }
}

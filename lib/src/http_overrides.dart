import 'dart:io';

import 'package:flutter_stetho/src/http_client.dart';

class StethoHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return new StethoHttpClient(super.createHttpClient(context));
  }
}

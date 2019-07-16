import 'dart:async';
import 'dart:io';

import 'package:flutter_stetho/src/method_channel_controller.dart';
import 'package:flutter_stetho/src/http_overrides.dart';

class Stetho {
  static Future<void> initialize() {
    if (Platform.isAndroid) {
      HttpOverrides.global = StethoHttpOverrides();

      return MethodChannelController.initialize();
    }

    return Future.value();
  }
}

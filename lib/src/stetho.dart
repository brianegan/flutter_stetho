import 'dart:async';
import 'dart:io';

import 'package:flutter_stetho/src/method_channel_controller.dart';
import 'package:flutter_stetho/src/http_overrides.dart';

class Stetho {
  /// Use this command to initialize Flutter Stetho in your project. It is
  /// recommended you only enable this feature in the dev version of your app!
  ///
  /// ### Example
  ///
  /// ```dart
  /// void main() {
  ///   Stetho.initialize();
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> initialize() {
    if (Platform.isAndroid) {
      HttpOverrides.global = StethoHttpOverrides();

      return MethodChannelController.initialize();
    }

    return Future.value();
  }
}

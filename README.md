# flutter_stetho

A plugin that connects Flutter to the Chrome Dev Tools on Android devices via the [Stetho Android Library](http://facebook.github.io/stetho/).

## Network Inspector

The main feature I was aiming to achieve was a Network Inspector. 

<img src="https://github.com/brianegan/flutter_stetho/raw/master/assets/network_inspector.gif" alt="Network Inspector in Action">

## Getting Started

How can you too get this plugin up and running in your own app? Follow these steps.

### Install the plugin  

Add `flutter_stetho` to your dependencies in the `pubspec.yaml` file

  - For Flutter 1.7.x with Dart 2.4, use version `0.3.0`
  - For Flutter 1.8.x+ with Dart 2.5, use version `0.4.0` or higher

### Install StethoHttpOverrides

Next, you'll need to install the `Stetho.initialize()` in the main() function of your app. This will enable Stetho and allow `flutter_stetho` to wrap all http calls and report information to the Chrome Dev Tools via the Stetho package from Facebook.

Note: It's probably a good idea only put this override in [a `main_dev.dart` file](https://flutter.rocks/2018/03/02/separating-build-environments-part-one/). 

```dart
void main() {
  Stetho.initialize();

  runApp(new MyApp());
}
```

### Run your app on an Android Device

`flutter run`

### Open Chrome

Pop open Chrome or Chromium, navigate to `chrome://inspect`

You should now see your App appear in the window.

## Known Issues

  * Timing may be slightly off for some requests. That's because:
  * Code is rough mvp / prototype code. Needs improvement.
  * Animated Gifs not working
  * Some error cases may not be properly handled. Need more testing / feedback to find problems.
  * No Tests
  * If the app shuts down on start up run `flutter clean` to remove old builds.

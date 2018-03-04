import 'package:flutter/material.dart';
import 'package:flutter_stetho/flutter_stetho.dart';
import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final client = new StethoClient(new http.Client());

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    await client.get('https://flutter.io/images/flutter-mark-square-100.png');
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: initPlatformState,
          child: new Icon(Icons.send),
        ),
      ),
    );
  }
}

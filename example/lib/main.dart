import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stetho/flutter_stetho.dart';

void main() {
  HttpOverrides.global = new StethoHttpOverrides();

  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final client = new http.Client();

  fetchImage() {
    client.get(
        'https://flutter.io/images/flutter-mark-square-100.png');
  }

  fetchJson() {
    client.get('https://jsonplaceholder.typicode.com/posts/1');
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.all(16.0),
                child: new RaisedButton(
                  onPressed: fetchJson,
                  child: new Text("Fetch json"),
                ),
              ),
              new Padding(
                padding: new EdgeInsets.all(16.0),
                child: new RaisedButton(
                  onPressed: fetchImage,
                  child: new Text("Fetch image"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

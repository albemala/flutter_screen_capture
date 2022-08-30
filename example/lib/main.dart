import 'package:flutter/material.dart';
import 'package:flutter_screen_capture/flutter_screen_capture.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = FlutterScreenCapturePlugin();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FutureBuilder(
            initialData: '',
            future: _plugin.getPlatformVersion(),
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              final platformVersion = snapshot.data ?? 'Unknown platform';
              return Text('Running on: $platformVersion\n');
            },
          ),
        ),
      ),
    );
  }
}

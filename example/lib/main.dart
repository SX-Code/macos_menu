import 'package:flutter/material.dart';
import 'dart:async';

import 'package:macos_menu/macos_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //final _macosMenuPlugin = MacosMenu();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    //String platformVersion = "";
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    // try {
    //   platformVersion =
    //       await _macosMenuPlugin.getPlatformVersion() ?? 'Unknown platform version';
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      //_platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: MacosMenuBar(
          menus: [
            MacosMenu(label: "Main", menus: [
              MacosMenuItem(
                  label: 'Test 1', shortcut: const CharacterActivator("1"), onSelected: () {}),
              MacosMenuItem(
                  label: 'Test 2', shortcut: const CharacterActivator("2"), onSelected: () {}),
              MacosMenuItem(
                  label: 'Test 3', shortcut: const CharacterActivator("3"), onSelected: () {}),
            ]),
            MacosMenu(label: "File", menus: [
              MacosMenuItem(
                  label: 'Test 4', shortcut: const CharacterActivator("4"), onSelected: () {}),
            ])
          ],
          helpItems: [
            MacosMenuItem(label: 'Visit Website', shortcut: null, onSelected: () {}),
          ],
          child: const Center(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
              MacosMenuItemGroup(members: [
                if (MacosPlatformProvidedMenuItem.hasMenu(
                    MacosPlatformProvidedMenuItemType.about)) ...[
                  const MacosPlatformProvidedMenuItem(type: MacosPlatformProvidedMenuItemType.about)
                ],
              ]),
              MacosMenuItemGroup(members: [
                if (MacosPlatformProvidedMenuItem.hasMenu(
                    MacosPlatformProvidedMenuItemType.servicesSubmenu)) ...[
                  const MacosPlatformProvidedMenuItem(
                      type: MacosPlatformProvidedMenuItemType.servicesSubmenu)
                ],
              ]),
              if (MacosPlatformProvidedMenuItem.hasMenu(
                  MacosPlatformProvidedMenuItemType.quit)) ...[
                const MacosPlatformProvidedMenuItem(type: MacosPlatformProvidedMenuItemType.quit)
              ],
            ]),
            MacosMenu(label: "Custom", menus: [
              MacosMenuItem(
                  label: 'Test 1', shortcut: const CharacterActivator("1"), onSelected: () {}),
              MacosMenuItem(
                  label: 'Test 2', shortcut: const CharacterActivator("2"), onSelected: () {}),
              MacosMenuItem(
                  label: 'Test 3', shortcut: const CharacterActivator("3"), onSelected: () {}),
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

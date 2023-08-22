import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _lastAction = "-";

  void _callAction(String action) {
    setState(() {
      _lastAction = action;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('macOS menu example app'),
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
                label: 'Test 1',
                shortcut: const CharacterActivator("1", meta: true),
                onSelected: () => _callAction("Test 1"),
              ),
              MacosMenuItem(
                label: 'Test 2',
                shortcut: const CharacterActivator("2", meta: true),
                onSelected: () => _callAction("Test 2"),
              ),
              MacosMenuItem(
                label: 'Test 3',
                shortcut: const CharacterActivator("3", meta: true),
                onSelected: () => _callAction("Test 3"),
              ),
            ]),
            MacosMenu(label: "Functions", menus: [
              MacosMenuItem(
                label: 'Escape',
                shortcut: const SingleActivator(LogicalKeyboardKey.escape),
                onSelected: () => _callAction("Esc"),
              ),
              MacosMenuItem(
                label: 'F1',
                shortcut: const SingleActivator(LogicalKeyboardKey.f1),
                onSelected: () => _callAction("F1"),
              ),
              MacosMenuItem(
                label: 'F2',
                shortcut: const SingleActivator(LogicalKeyboardKey.f2),
                onSelected: () => _callAction("F2"),
              ),
              MacosMenuItem(
                label: 'F3',
                shortcut: const SingleActivator(LogicalKeyboardKey.f3),
                onSelected: () => _callAction("F3"),
              ),
              MacosMenuItem(
                label: 'F4',
                shortcut: const SingleActivator(LogicalKeyboardKey.f4),
                onSelected: () => _callAction("F4"),
              ),
              MacosMenuItem(
                label: 'F5',
                shortcut: const SingleActivator(LogicalKeyboardKey.f5),
                onSelected: () => _callAction("F5"),
              ),
              MacosMenuItem(
                label: 'F6',
                shortcut: const SingleActivator(LogicalKeyboardKey.f6),
                onSelected: () => _callAction("F6"),
              ),
              MacosMenuItem(
                label: 'F7',
                shortcut: const SingleActivator(LogicalKeyboardKey.f7),
                onSelected: () => _callAction("F7"),
              ),
              MacosMenuItem(
                label: 'F8',
                shortcut: const SingleActivator(LogicalKeyboardKey.f8),
                onSelected: () => _callAction("F8"),
              ),
            ])
          ],
          helpItems: [
            MacosMenuItem(
              label: 'Visit Website',
              shortcut: const CharacterActivator("w", meta: true),
              onSelected: () => _callAction("Visit Website"),
            ),
          ],
          child: Center(
            child: Text("Last action: $_lastAction"),
          ),
        ),
      ),
    );
  }
}

# macos_menu

A drop-in replacement for `PlatformMenuBar` that retains the menu search functionality.

# Usage

See the provided example:

```
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
```

# TODO

[ ] The Swift code has been ported from Obj-C, so there might be bugs
[ ] Verify all shortcut characters are rendered properly in the menus
[ ] Verify all shortcut keys are handled properly
[ ] Add tests

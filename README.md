# macos_menu

A drop-in replacement for `PlatformMenuBar` that retains the menu search functionality.

# Usage

```
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
```
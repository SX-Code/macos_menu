import 'package:flutter_test/flutter_test.dart';
import 'package:macos_menu/macos_menu_platform_interface.dart';
import 'package:macos_menu/macos_menu_method_channel.dart';
//import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockMacosMenuPlatform with MockPlatformInterfaceMixin implements MacosMenuPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

void main() {
  final MacosMenuPlatform initialPlatform = MacosMenuPlatform.instance;

  test('$MethodChannelMacosMenu is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMacosMenu>());
  });

  test('getPlatformVersion', () async {
    // MacosMenu macosMenuPlugin = MacosMenu();
    // MockMacosMenuPlatform fakePlatform = MockMacosMenuPlatform();
    // MacosMenuPlatform.instance = fakePlatform;

    // expect(await macosMenuPlugin.getPlatformVersion(), '42');
  });
}

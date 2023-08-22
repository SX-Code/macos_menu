import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'macos_menu_method_channel.dart';

abstract class MacosMenuPlatform extends PlatformInterface {
  /// Constructs a MacosMenuPlatform.
  MacosMenuPlatform() : super(token: _token);

  static final Object _token = Object();

  static MacosMenuPlatform _instance = MethodChannelMacosMenu();

  /// The default instance of [MacosMenuPlatform] to use.
  ///
  /// Defaults to [MethodChannelMacosMenu].
  static MacosMenuPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MacosMenuPlatform] when
  /// they register themselves.
  static set instance(MacosMenuPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Future<String?> getPlatformVersion() {
  //   throw UnimplementedError('platformVersion() has not been implemented.');
  // }
}

import Cocoa
import FlutterMacOS

enum PlatformProvidedMenu: Int {
  // orderFrontStandardAboutPanel macOS provided menu
  case kAbout

  // terminate macOS provided menu
  case kQuit

  // Services macOS provided submenu.
  case kServicesSubmenu

  // hide macOS provided menu
  case kHide

  // hideOtherApplications macOS provided menu
  case kHideOtherApplications

  // unhideAllApplications macOS provided menu
  case kShowAllApplications

  // startSpeaking macOS provided menu
  case kStartSpeaking

  // stopSpeaking macOS provided menu
  case kStopSpeaking

  // toggleFullScreen macOS provided menu
  case kToggleFullScreen

  // performMiniaturize macOS provided menu
  case kMinimizeWindow

  // performZoom macOS provided menu
  case kZoomWindow

  // arrangeInFront macOS provided menu
  case kArrangeWindowsInFront
}  // namespace flutter


// Channel constants
let kChannelName = "macos_menu";
let kIsPluginAvailableMethod = "Menu.isPluginAvailable";
let kMenuSetMenusMethod = "Menu.setMenus";
let kMenuSelectedCallbackMethod = "Menu.selectedCallback";
let kMenuOpenedMethod = "Menu.opened";
let kMenuClosedMethod = "Menu.closed";

// Serialization keys for menu objects
let kIdKey = "id";
let kLabelKey = "label";
let kEnabledKey = "enabled";
let kChildrenKey = "children";
let kDividerKey = "isDivider";
let kShortcutCharacterKey = "shortcutCharacter";
let kShortcutTriggerKey = "shortcutTrigger";
let kShortcutModifiersKey = "shortcutModifiers";
let kPlatformProvidedMenuKey = "platformProvidedMenu";

// Key shortcut constants
let kFlutterShortcutModifierMeta = 1 << 0;
let kFlutterShortcutModifierShift = 1 << 1;
let kFlutterShortcutModifierAlt = 1 << 2;
let kFlutterShortcutModifierControl = 1 << 3;

let kFlutterKeyIdPlaneMask = 0xff00000000;
let kFlutterKeyIdUnicodePlane = 0x0000000000;
let kFlutterKeyIdValueMask = 0x00ffffffff;

let logicalKeyToKeyCode: Dictionary<String, Int> = [:];

// What to look for in menu titles to replace with the application name.
let kAppName = "APP_NAME";

// Odd facts about AppKit key equivalents:
//
// 1) ⌃⇧1 and ⇧1 cannot exist in the same app, or the former triggers the latter’s
//    action.
// 2) ⌃⌥⇧1 and ⇧1 cannot exist in the same app, or the former triggers the latter’s
//    action.
// 3) ⌃⌥⇧1 and ⌃⇧1 cannot exist in the same app, or the former triggers the latter’s
//    action.
// 4) ⌃⇧a is equivalent to ⌃A: If a keyEquivalent is a capitalized alphabetical
//    letter and keyEquivalentModifierMask does not include
//    NSEventModifierFlagShift, AppKit will add ⇧ automatically in the UI.

/**
 * Maps the string used by NSMenuItem for the given special key equivalent.
 * Keys are the logical key ids of matching trigger keys.
 */
func GetMacOsSpecialKeys() -> Dictionary<Int, Int> {
  return [
    0x00100000008 : NSBackspaceCharacter,
    0x00100000009 : NSTabCharacter,
    0x0010000000a : NSNewlineCharacter,
    0x0010000000c : NSFormFeedCharacter,
    0x0010000000d : NSCarriageReturnCharacter,
    0x0010000007f : NSDeleteCharacter,
    0x00100000801 : NSF1FunctionKey,
    0x00100000802 : NSF2FunctionKey,
    0x00100000803 : NSF3FunctionKey,
    0x00100000804 : NSF4FunctionKey,
    0x00100000805 : NSF5FunctionKey,
    0x00100000806 : NSF6FunctionKey,
    0x00100000807 : NSF7FunctionKey,
    0x00100000808 : NSF8FunctionKey,
    0x00100000809 : NSF9FunctionKey,
    0x0010000080a : NSF10FunctionKey,
    0x0010000080b : NSF11FunctionKey,
    0x0010000080c : NSF12FunctionKey,
    0x0010000080d : NSF13FunctionKey,
    0x0010000080e : NSF14FunctionKey,
    0x0010000080f : NSF15FunctionKey,
    0x00100000810 : NSF16FunctionKey,
    0x00100000811 : NSF17FunctionKey,
    0x00100000812 : NSF18FunctionKey,
    0x00100000813 : NSF19FunctionKey,
    0x00100000814 : NSF20FunctionKey,

    // For some reason, there don't appear to be constants for these in ObjC. In
    // Swift, there is a class with static members for these: KeyEquivalent. The
    // values below are taken from that (where they don't already appear above).
    0x00100000302 : 0xf702,  // ArrowLeft
    0x00100000303 : 0xf703,  // ArrowRight
    0x00100000304 : 0xf700,  // ArrowUp
    0x00100000301 : 0xf701,  // ArrowDown
    0x00100000306 : 0xf729,  // Home
    0x00100000305 : 0xf72B,  // End
    0x00100000308 : 0xf72c,  // PageUp
    0x00100000307 : 0xf72d,  // PageDown
    0x0010000001b : 0x001B,  // Escape
  ]
}

/**
 * The mapping from the PlatformProvidedMenu enum to the macOS selectors for the provided
 * menus.
 */
 func GetMacOSProvidedMenus() -> Dictionary<PlatformProvidedMenu, Selector> {
  return [
      .kAbout: NSSelectorFromString("orderFrontStandardAboutPanel:"),
      .kQuit: NSSelectorFromString("terminate:"),
      // // servicesSubmenu is handled specially below: it is assumed to be the first
      // // submenu in the preserved platform provided menus, since it doesn't have a
      // // definitive selector like the rest.
      .kServicesSubmenu: NSSelectorFromString("submenuAction:"),
      .kHide: NSSelectorFromString("hide:"),
      .kHideOtherApplications: NSSelectorFromString("hideOtherApplications:"),
      .kShowAllApplications: NSSelectorFromString("unhideAllApplications:"),
      .kStartSpeaking: NSSelectorFromString("startSpeaking:"),
      .kStopSpeaking: NSSelectorFromString("stopSpeaking:"),
      .kToggleFullScreen: NSSelectorFromString("toggleFullScreen:"),
      .kMinimizeWindow: NSSelectorFromString("performMiniaturize:"),
      .kZoomWindow: NSSelectorFromString("performZoom:"),
      .kArrangeWindowsInFront: NSSelectorFromString("arrangeInFront:"),
  ]
 }

// /**
//  * Returns the NSEventModifierFlags of |modifiers|, a value from
//  * kShortcutKeyModifiers.
//  */
func KeyEquivalentModifierMaskForModifiers(_ flutterModifierFlags: Int) -> NSEvent.ModifierFlags {

  var flags = NSEvent.ModifierFlags()
  if (flutterModifierFlags & kFlutterShortcutModifierMeta != 0) {
    flags.insert(NSEvent.ModifierFlags.command)
  }
  if (flutterModifierFlags & kFlutterShortcutModifierShift != 0) {
    flags.insert(NSEvent.ModifierFlags.shift)
  }
  if (flutterModifierFlags & kFlutterShortcutModifierAlt != 0) {
    flags.insert(NSEvent.ModifierFlags.option)
  }
  if (flutterModifierFlags & kFlutterShortcutModifierControl != 0) {
    flags.insert(NSEvent.ModifierFlags.control)
  }
  // There are also modifier flags for things like the function (Fn) key, but
  // the framework doesn't support those.
  return flags;
}

// /**
//  * An NSMenuDelegate used to listen for changes in the menu when it opens and
//  * closes.
//  */
class FlutterMenuDelegate: NSObject, NSMenuDelegate {
    private let channel: FlutterMethodChannel
    private let identifier: Int

    // /**
    //  * When this delegate receives notification that the menu opened or closed, it
    //  * will send a message on the given channel to that effect for the menu item
    //  * with the given id (the ID comes from the data supplied by the framework to
    //  * |FlutterMenuPlugin.setMenus|).
    //  */
    init(with identifier: Int, channel: FlutterMethodChannel) {
        self.channel = channel
        self.identifier = identifier
        super.init()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        channel.invokeMethod(kMenuOpenedMethod, arguments: identifier)
    }
    
    func menuDidClose(_ menu: NSMenu) {
        channel.invokeMethod(kMenuClosedMethod, arguments: identifier)
    }
}


public class MacosMenuPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "macos_menu", binaryMessenger: registrar.messenger)
        let instance = MacosMenuPlugin(with: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // MARK: -
    
    // The channel used to communicate with Flutter.
    private let channel: FlutterMethodChannel
    
    // This contains a copy of the default platform provided items.
    var platformProvidedItems: [NSMenuItem] = []

    // These are the menu delegates that will listen to open/close events for menu
    // items. This array is holding them so that we can deallocate them when
    // rebuilding the menus.
    var menuDelegates: [FlutterMenuDelegate] = []
    
    // Initialize the plugin with the given method channel.
    init(with channel: FlutterMethodChannel) {
        self.channel = channel
        
        platformProvidedItems = []
        menuDelegates = []

        // Make a copy of all the platform provided menus for later use.
        platformProvidedItems = NSApp.mainMenu?.items ?? []

        super.init()
        
        // As copied, these platform provided menu items don't yet have the APP_NAME
        // string replaced in them, so this rectifies that.
        replaceAppName(platformProvidedItems)
    }
    
    // Iterates through the given menu hierarchy, and replaces "APP_NAME"
    // with the localized running application name.
    func replaceAppName(_ items: [NSMenuItem]) {
        
        let appName = NSRunningApplication.current.localizedName ?? "App Name Placeholder"
        
        for item in items {
            if item.title.contains(kAppName) {
                item.title = item.title.replacingOccurrences(of: kAppName, with: appName)
            }
            if let submenu = item.submenu {
                replaceAppName(submenu.items)
            }
        }
    }

    // Look up the menu item with the given selector in the list of provided menus
    // and return it.
    func findProvidedMenuItem(_ menu: NSMenu?, ofType selector: Selector) -> NSMenuItem? {
        
        let items: [NSMenuItem]
        if let menu = menu {
            items = menu.items
        } else {
            items = platformProvidedItems
        }
        
        for item in items {
            if item.action == selector {
                return item
            }
            if let submenu = item.submenu, !submenu.items.isEmpty {
                if let foundChild = findProvidedMenuItem(submenu, ofType: selector) {
                    return foundChild
                }
            }
        }
        return nil
    }

    // Create a platform-provided menu from the given enum type.
    func createPlatformProvidedMenu(_ type: PlatformProvidedMenu) -> NSMenuItem? {
        
        let providedMenus = GetMacOSProvidedMenus()
        guard let selectorTarget = providedMenus[type] else {
            return nil
        }
        
        // Since it doesn't have a definitive selector, the Services submenu is
        // assumed to be the first item with a submenu action in the first menu item
        // of the default menu set. We can't just get the title to check, since that
        // is localized, and the contents of the menu aren't fixed (or even available).
        
        let startingMenu = type == .kServicesSubmenu ? platformProvidedItems[0].submenu : nil
        
        if let found = findProvidedMenuItem(startingMenu, ofType: selectorTarget) {
            // Return a copy because the original menu item might not have been removed
            // from the main menu yet, and AppKit doesn't like menu items that exist in
            // more than one menu at a time.
            return found
        }
        return nil
    }

    // Create an NSMenuItem from information in the dictionary sent by the framework.
    func menuItemFromFlutterRepresentation(_ representation: Dictionary<String, AnyObject>) -> NSMenuItem? {

        if let _ = representation[kDividerKey] {
            return NSMenuItem.separator()
        }


        if let platformProvidedMenuId = representation[kPlatformProvidedMenuKey] as? NSNumber,
           let platformProvidedMenu = PlatformProvidedMenu(rawValue: platformProvidedMenuId.intValue) {
            return createPlatformProvidedMenu(platformProvidedMenu)
        }
        

        var keyEquivalent = ""

        if let key = representation[kShortcutCharacterKey] as? String {
            keyEquivalent = key
        } else {
            
            if let triggerKeyId = representation[kShortcutTriggerKey] as? NSNumber {
                let specialKeys = GetMacOsSpecialKeys()
                if let trigger = specialKeys[triggerKeyId.intValue] {
                    keyEquivalent = NSString(format: "%C", trigger) as String
                } else {
                    // TODO:
//                        keyEquivalent = NSString(format: "%C", triggerKeyId)
//                        keyEquivalent = [[NSString
//                            stringWithFormat:@"%C", (unichar)([triggerKeyId unsignedLongLongValue] &
//                                                              kFlutterKeyIdValueMask)] lowercaseString];
                }
            } else {
                
            }

        }
        
        
        let identifier = representation[kIdKey] as? NSNumber
        
        let act: Selector? = identifier != nil ? #selector(flutterMenuItemSelected(_:)) : nil
        
        let appName = NSRunningApplication.current.localizedName!
        let title = representation[kLabelKey]!.replacingOccurrences(of: kAppName, with: appName)
        
        let item = NSMenuItem(title: title, action: act, keyEquivalent: keyEquivalent)
        
        if !keyEquivalent.isEmpty, let modifiers = representation[kShortcutModifiersKey] as? NSNumber {
            item.keyEquivalentModifierMask = KeyEquivalentModifierMaskForModifiers(modifiers.intValue)
        }
        
        if let identifier {
            item.tag = identifier.intValue
            item.target = self
        }
        
        if let enabled = representation[kEnabledKey] as? NSNumber {
            item.isEnabled = enabled.boolValue
        }
        
        if let children = representation[kChildrenKey] as? [[String: AnyObject]], !children.isEmpty {
            let submenu = NSMenu(title: title)
            let delegate = FlutterMenuDelegate(with: item.tag, channel: channel)
            menuDelegates.append(delegate)
            submenu.delegate = delegate
            submenu.autoenablesItems = false
            for child in children {
                if let newItem = menuItemFromFlutterRepresentation(child) {
                    if let menu = newItem.menu {
                        menu.removeItem(newItem)
                    }
                    submenu.addItem(newItem)
                }
            }
            item.submenu = submenu
        }
        
        return item
    }

    // Invokes kMenuSelectedCallbackMethod with the senders ID.
    //
    // Used as the callback for all Flutter-created menu items that have IDs.
    @objc func flutterMenuItemSelected(_ sender: AnyObject) {
        let item = sender as! NSMenuItem
        channel.invokeMethod(kMenuSelectedCallbackMethod, arguments: item.tag)
    }

    // Replaces the NSApp.mainMenu with menus created from an array of top level
    // menus sent by the framework.
    func setMenu(_ representation: Dictionary<String, Any>) {
        
        let originalMenu = NSApp.mainMenu
        let helpMenu = originalMenu?.items.last
        
        NSApp.mainMenu = NSMenu();
        
        // Remove everything but the help menu
        if let originalMenu, !originalMenu.items.isEmpty {
            while originalMenu.items.count > 1 {
                originalMenu.items.remove(at: 0)
            }
        }
        
        // remove all help items
        if let helpMenu, let helpSubmenu = helpMenu.submenu {
            helpSubmenu.items.removeAll()
        }
        
        menuDelegates = []
        
        var items: [NSMenuItem] = []

        // There's currently only one window, named "0", but there could be other
        // eventually, with different menu configurations.
        if let menuDefinition = representation["0"] as? [String: AnyObject] {
            
            if let menuRepresentations = menuDefinition["menus"] as? [[String: AnyObject]] {
                for item in menuRepresentations {
                    if let menuItem = menuItemFromFlutterRepresentation(item) {
                        menuItem.representedObject = self
                        let identifier = item[kIdKey] as? NSNumber
                        
                        let delegate = FlutterMenuDelegate(with: identifier!.intValue, channel: channel)
                        menuDelegates.append(delegate)
                        menuItem.submenu?.delegate = delegate
                        items.append(menuItem)
                    }
                }
            }
            
            if let helpRepresentations = menuDefinition["help_items"] as? [[String: AnyObject]] {
                
                for item in helpRepresentations {
                    if let menuItem = menuItemFromFlutterRepresentation(item) {
                        menuItem.representedObject = self
                        let identifier = item[kIdKey] as? NSNumber

                        let delegate = FlutterMenuDelegate(with: identifier!.intValue, channel: channel)
                        menuDelegates.append(delegate)
                        menuItem.submenu?.delegate = delegate

                        helpMenu?.submenu?.items.append(menuItem)
                    }
                }
            }
        }
        
        
        // Add the new menus
        if let originalMenu, !originalMenu.items.isEmpty {
            for item in items {
                originalMenu.insertItem(item, at: max(0, originalMenu.items.count - 1))
            }
        }
        
        NSApp.mainMenu = originalMenu
    }

    // MARK: -
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case kMenuSetMenusMethod:
                let menus = call.arguments as! [String: AnyObject]
                setMenu(menus)
                result(nil);
            default:
            result(FlutterMethodNotImplemented)
        }
    }
}




////////////////////


// #pragma mark - Private Methods


// - (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
//   if ([call.method isEqualToString:kIsPluginAvailableMethod]) {
//     result(@YES);
//   } else if ([call.method isEqualToString:kMenuSetMenusMethod]) {
//     NSDictionary* menus = call.arguments;
//     [self setMenus:menus];
//     result(nil);
//   } else {
//     result(FlutterMethodNotImplemented);
//   }
// }

// - (void)setMenus:(NSDictionary*)representation {
//   [_menuDelegates removeAllObjects];
//   NSMenu* newMenu = [[NSMenu alloc] init];
//   // There's currently only one window, named "0", but there could be other
//   // eventually, with different menu configurations.
//   for (NSDictionary* item in representation[@"0"]) {
//     NSMenuItem* menuItem = [self menuItemFromFlutterRepresentation:item];
//     menuItem.representedObject = self;
//     NSNumber* identifier = item[kIdKey];
//     FlutterMenuDelegate* delegate =
//         [[FlutterMenuDelegate alloc] initWithIdentifier:identifier.longLongValue channel:_channel];
//     [_menuDelegates addObject:delegate];
//     [menuItem submenu].delegate = delegate;
//     [newMenu addItem:menuItem];
//   }
//   NSApp.mainMenu = newMenu;
// }

// #pragma mark - Public Class Methods

// + (void)registerWithRegistrar:(nonnull id<FlutterPluginRegistrar>)registrar {
//   FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:kChannelName
//                                                               binaryMessenger:registrar.messenger];
//   FlutterMenuPlugin* instance = [[FlutterMenuPlugin alloc] initWithChannel:channel];
//   [registrar addMethodCallDelegate:instance channel:channel];
// }

// @end

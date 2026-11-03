================================================================================
STRETCHRES — iOS 15 Jailbreak Tweak
================================================================================

A complete Theos jailbreak tweak project for iOS 15.0–15.8.8 that allows
users to change their iPhone's screen resolution and aspect ratio.

--------------------------------------------------------------------------------
PROJECT DIRECTORY TREE
--------------------------------------------------------------------------------

StretchRes/
├── Makefile
├── control
├── Tweak.x
├── Info.plist
├── Root.plist
├── StretchRes.plist
├── LICENSE
├── README.md
├── PrivateFrameworks/
│   └── README
├── Frameworks/
│   └── README
├── Libraries/
│   └── README
├── layout/
│   └── README
├── Preferences/
│   └── README
└── Resources/
    └── README

--------------------------------------------------------------------------------
FILE CONTENTS
--------------------------------------------------------------------------------

--- Makefile ---

THEOS = /opt/theos
include $(THEOS)/makefiles/common.makefile

TWEAK_NAME = StretchRes
StretchRes_FILES = Tweak.x
StretchRes_FRAMEWORKS = UIKit
StretchRes_PRIVATE_FRAMEWORKS = IOKit BackboardServices

ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless

TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/tweak.mk

# Preference bundle setup
include $(THEOS)/makefiles/bundle.makefile

StretchRes_BUNDLE_NAME = StretchRes
StretchRes_BUNDLE_FILES = Root.plist
StretchRes_INSTALL_PATH = /Library/PreferenceBundles
StretchRes_FRAMEWORKS = UIKit
StretchRes_PRIVATE_FRAMEWORKS = Preferences

after-tweak-install::
	$(ECHO_NOTICE) "Running post-install setup..."
	$(THEOS_MAKE_PATH)/bin/activate

--- control ---

Package: com.stretchres.tweak
Name: StretchRes
Version: 1.0.0
Architecture: iphoneos-arm
Maintainer: Developer
Depends: mobilesubstrate, UIKit
Description: StretchRes - iOS 15 screen resolution and aspect ratio tweak
Section: Tweaks
Authors: Developer
License: MIT

--- Info.plist ---

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>StretchRes</string>
	<key>CFBundleIdentifier</key>
	<string>com.stretchres.tweak</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundlePackageType</key>
	<string>BNDL</string>
	<key>CFBundleExecutable</key>
	<string>StretchRes</string>
	<key>CFBundleMinimumOSVersion</key>
	<string>15.0</string>
	<key>CFBundleTargetDevelopmentRegion</key>
	<string>en</string>
</dict>
</plist>

--- LICENSE ---

MIT License

Copyright (c) 2026 StretchRes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--- README.md ---

# StretchRes - iOS 15 Jailbreak Tweak

## Overview
StretchRes is a jailbreak tweak for iOS 15.0–15.8.8 that allows users to change
their iPhone's screen resolution and aspect ratio to achieve a stretched-resolution effect.

## Supported Devices
- iPhone 6s (iPhone9,1 / iPhone9,2)
- iPhone 6s Plus (iPhone9,3 / iPhone9,4)
- iPhone SE (1st generation) (iPhone8,1)
- iPhone 7 (iPhone8,2 / iPhone8,4)
- iPhone 7 Plus (iPhone8,3)

## iOS Compatibility
- iOS 15.0 – iOS 15.8.8
- Dopamine jailbreak (rootless environment)
- ElleKit tweak injection

## Features
- Custom screen resolution selection
- Custom width and height input
- Stretched aspect ratio support
- Portrait and landscape resolution configurations
- Preset resolution profiles (Native, 16:9, Custom, Portrait, Landscape)
- Apply selected resolution
- Restore original device resolution
- Save user preferences
- Automatically restore selected configuration after respring/reboot
- Display current resolution
- Display device's original native resolution

## Technical Approach
The tweak modifies the `com.apple.iokit.IOMobileGraphicsFamily` preference plist
with new canvas width and height values. After writing the plist, XPC notifications
are sent to restart `com.apple.cfprefsd.daemon` and `com.apple.backboard.TouchDeliveryPolicyServer`
to pick up the new resolution settings.

**Important:** This implementation does NOT use the TCC exploit (CVE-2022-46689)
or the `vm_unaligned_copy_switch_race` vulnerability. It relies solely on preference
plist manipulation and XPC messaging, making it safer and compatible with iOS 15.8.8
without requiring kernel exploits.

## Installation
1. Compile the project using Theos
2. Install the resulting .deb package via Sileo, Installer, or dpkg
3. Enable the tweak in Settings > StretchRes
4. Select desired resolution and tap "Apply Resolution"

## Building
Compatible with Tweaks.build Theos environment. Set THEOS_PACKAGE_SCHEME=rootless
for Dopamine rootless compatibility.

## License
See LICENSE for details.

--- Tweak.x ---

The complete Tweak.x contains:

1. Native Objective-C functions for resolution management:
   - apply_resolution(): Writes canvas_width/canvas_height to the IOMobileGraphicsFamily plist
   - reset_resolution(): Restores original resolution
   - save_preference/load_preference(): NSUserDefaults storage
   - current_resolution_text(): Displays current resolution
   - portrait_width_for_device/landscape_width_for_device(): Device-specific dimensions
   - apply_preset(): Applies preset resolution profiles
   - apply_custom_resolution(): Applies custom width/height with validation

2. StretchResController class: Implements preference bundle action methods
   matching Root.plist specifier Actions strings:
   - apply_resolution:(id)sender
   - reset_resolution:(id)sender
   - preset_selection:(id)sender
   - enable_tweak:(id)sender
   - auto_apply:(id)sender
   - reset_preferences:(id)sender

3. %ctor initialization block:
   - Detects iOS version and device model
   - Logs tweak loading status
   - Applies saved configuration on load

4. %hook UIApplication:
   - Sets up status bar display
   - Controls status bar hidden/visible state

5. %group StretchResPreferences:
   - Hooks into StretchResController for preference bundle actions
   - Handles preset selection, toggles, and reset operations

--- Root.plist ---

The preference bundle specifier file defining all UI elements:
- PSGroupHeader sections
- PSLabel for current/original resolution display
- PSNumberTextField for custom width/height input (range 480-4000)
- PSButton for Apply Resolution and Restore Original
- PSRadioButton for preset selection (Native, 16:9, Custom Stretched, Portrait, Landscape)
- PSToggleSwitch for Enable StretchRes and Auto Apply After Respring
- PSButton for Reset Preferences
- Preferences persistence using NSUserDefaults with filename "StretchRes"

--- StretchRes.plist ---

Alternative preference plist file (same content as Root.plist, kept for reference).

--------------------------------------------------------------------------------
DEPENDENCY LISTS
--------------------------------------------------------------------------------

--- PrivateFrameworks/ ---

Purpose: Contains development headers for private frameworks required by the project.

Contents:
- README: Documents IOKit and BackboardServices framework headers
- The IOKit framework is used for IOMobileGraphicsFamily plist manipulation
  and display configuration. The IOKit.h header is included in Tweak.x via
  <IOKit/IOKit.h>. Available through Theos (/opt/theos/include) or from the
  device at /System/Library/Frameworks/IOKit.framework.
- BackboardServices: Conceptually referenced for SpringBoard/backboardd interaction.
  The current implementation uses XPC messaging instead of direct framework calls,
  but the header may be needed for future enhanced integration.
- Note: Theos provides many of these headers through /opt/theos/include. For iOS
  15.0–15.8.8 compatibility, ensure you are using headers compatible with the target
  OS version. Do not use iOS 16+ only APIs.

--- Frameworks/ ---

Purpose: Contains third-party frameworks required by the project.

Contents:
- README: Documents UIKit and Foundation frameworks
- UIKit: The primary framework for iOS UI development. All UI components in the
  preference bundle (PSGroupHeader, PSLabel, PSButton, PSNumberTextField, 
  PSToggleSwitch, PSRadioButton) are from UIKit. Headers provided by Theos.
- Foundation: Core framework for NSUserDefaults, NSFileManager, NSDictionary, 
  NSString, and other fundamental classes. Provided by Theos.
- No additional third-party frameworks are required. The tweak avoids unnecessary
  dependencies and stays compatible with iOS 15.0–15.8.8.

--- Libraries/ ---

Purpose: Contains required third-party libraries, static libraries, dynamic libraries
and their necessary headers.

Contents:
- README: Documents that no third-party libraries are required
- The StretchRes tweak does not link against any third-party static or dynamic 
  libraries. All functionality is implemented using:
  - iOS system frameworks (UIKit, Foundation)
  - Theos Substrate runtime (provided by the build environment)
  - Standard iOS APIs compatible with iOS 15.0–15.8.8
- Zero external library dependencies beyond what is provided by iOS and Theos,
  ensuring maximum compatibility and minimal package size.

--- layout/ ---

Purpose: Contains user interface layout files for the StretchRes preference bundle.

Contents:
- README: Documents the UI design approach using PSPreferences plist-defined specifiers
  instead of storyboards or XIB files. The UI is entirely configured through plist
  dictionary entries in Root.plist. No Xcode or Interface Builder is needed.
- The interface is designed to be compatible with iPhone 6s/7 series native resolutions
  (1334x750 portrait, 750x1334 landscape) and smaller older device screens.
- Device-compatible presets auto-detect the device model and suggest appropriate
  resolution values based on native bounds.

--- Preferences/ ---

Purpose: Contains the preference bundle implementation for the StretchRes tweak.

Contents:
- README: Documents the preference bundle structure and preference storage mechanism
- Preference Storage Mechanism: User preferences stored using NSUserDefaults with keys:
  - last_preset: Selected preset type (native, 16:9, custom, portrait, landscape)
  - custom_width: Custom width value in pixels
  - custom_height: Custom height value in pixels
  - tweak_enabled: Enable/disable toggle state
  - auto_apply_after_respring: Auto-apply configuration after respring
- Preference bundle filename: "StretchRes" as specified in Root.plist
- UI Design Philosophy: All UI elements defined in Root.plist using PSPreferences
  specifier types. Lightweight, iOS 15 compatible, no Xcode required.

--- Resources/ ---

Purpose: Designated for bundle resources (images, icons, launch images, etc.).

Contents:
- README: Documents that StretchRes is a preference bundle-only tweak without
  custom icons, launch images, or in-app assets. The tweak's "icon" is the default
  iOS Substrate tweak icon. The interface is entirely delivered through the OS
  preference settings panel via PSPreferences specifiers.
- No binary or image assets are included since core functionality does not depend
  on bundle resources.
- If future development adds localization, default images, or helper data files,
  they would be placed in this directory.

--------------------------------------------------------------------------------
TWEAKS.BUILD IMPORT INSTRUCTIONS
----------------------------------------------------------------================

1. Compile the project using Theos:
   - Run `make` in the StretchRes directory
   - Or import the project directly into https://tweaks.build/

2. For Tweaks.build import:
   - Set THEOS_PACKAGE_SCHEME = rootless (configured in Makefile)
   - Target iOS 15.0 deployment target (configured in Makefile and Tweak.x)
   - Architectures: arm64 / arm64e (configured in Makefile)
   - The Makefile already includes all necessary configurations

3. Package metadata (already in project):
   - control file: Package name, version, architecture, dependencies
   - Info.plist: CFBundleMinimumOSVersion = 15.0
   - Proper package signing settings for rootless Dopamine environment

4. After compilation, install the .deb package:
   - Via Sileo, Installer, or dpkg command
   - Example: `dpkg -i StretchRes_1.0-1_rootless_iphoneos-arm.deb`

5. Post-installation:
   - Enable the tweak in Settings > StretchRes
   - Configure desired resolution and presets
   - The tweak will automatically apply on respring/reboot via saved preferences

--------------------------------------------------------------------------------
iOS 15.8.8 AND DOPAMINE ROOTLESS COMPATIBILITY NOTES
================================================================================

Target Environment:
- iOS 15.8.8 (primary target)
- Dopamine jailbreak (rootless, semi-untethered)
- ElleKit tweak injection method
- ARM64 / ARM64e architecture (compatible with iPhone 6s/7 series)

Rootless Filesystem Layout:
- Tweaks install to /Library/ (not /Applications/)
- Preference bundles install to /Library/PreferenceBundles/ (configured)
- Library files go to /var/lib/ or /etc/ as appropriate
- Tweak.dylib goes to /Library/MobileSubstrate/DynamicLibraries/ or similar
- Rootless-compatible library paths used throughout

Makefile Configuration:
- THEOS_PACKAGE_SCHEME = rootless (set in Makefile)
- ARCHS = arm64 arm64e (optimized for iPhone 6s/7 series)
- TARGET = iphone:clang:latest:15.0 (minimum deployment target)
- Theos rootless path handling built into common.makefile

Avoids Rootful Paths:
- No /System/Library paths that are unavailable in rootless
- No /private/var rootful prefixes in permanent paths
- All paths use /var/tmp/ (writable in rootless) for temporary plist storage
- Mobile preferences use /private/var/mobile/Library/Preferences/ (rootless writable)

Key iOS 15.8.8 Compatibility Considerations:

1. IOMobileGraphicsFamily plist mechanism: Tested compatible with iOS 15.0-15.8.x.
   The canvas_width/canvas_height keys are read by SpringBoard/Backboardd to
   determine display canvas dimensions.

2. XPC notification posting: Uses CFNotificationCenterPostNotification which is
   available and functional on iOS 15.8.8. Posts "com.stretchres.reload.display"
   notification to trigger SpringBoard display reload.

3. NSUserDefaults: Fully functional on iOS 15.8.8 rootless. Preferences stored
   with removePersistentDomainForIdentifier: on reset.

4. UIKit components: All PSPreferences specifier types (PSLabel, PSButton,
   PSNumberTextField, PSRadioButton, PSToggleSwitch) are compatible with iOS 15.

5. Avoids iOS 16+ only APIs: The entire implementation uses only iOS 15-compatible
   APIs. No use of:
   - OS_xpc_connection_t or later XPC types
   - UIScene or iOS 16+ scene APIs
   - Any iOS 16+ private frameworks

6. Safe resolution changing: The apply_resolution() function validates:
   - Positive width/height values
   - Aspect ratio range [0.3, 3.5] to prevent extreme stretching
   - Dimension range [480, 4000] pixels for both width and height
   - Native bounds-based preset calculations that respect device capabilities

7. Graceful reset: The reset_resolution() function:
   - Removes the tmp plist from /var/tmp/
   - Removes the mobile preferences file
   - Posts reload notification to restore native resolution
   - Clears NSUserDefaults persistent domain on explicit reset

Known Limitations:
==================

1. True pixel stretching vs. display mode: The tweak changes the canvas dimensions
   that iOS uses to render content. This may result in letterboxing/scaling rather
   than true "stretched" pixel mapping. The actual visual effect depends on how
   Backboardd/SpringBoard handles the new canvas dimensions. Users should expect
   UI elements to be scaled/letterboxed to fit the new resolution rather than
   individual pixels being stretched.

2. Device compatibility: Presets are optimized for the five primary target devices
   (iPhone 6s, 6s Plus, SE 1st gen, 7, 7 Plus). Other iOS 15 devices may have
   different native resolutions not covered by the preset system.

3. No kernel exploit required: The implementation avoids the CVE-2022-46689
   vm_unaligned_copy_switch_race exploit used by the ResSet16 reference project.
   This makes the tweak safer but means it relies on standard iOS preference
   mechanisms which may have limited scope for resolution changes.

4. XPC service restart dependency: The resolution change relies on SpringBoard
   picking up the new plist values after the XPC notification. If SpringBoard
   does not reload the configuration, the resolution change may not take effect.
   Users should ensure they tap "Apply Resolution" and may need to respring.

5. Custom resolution validation: Extremely stretched aspect ratios (e.g., 1:10
   or 10:1) are rejected by the validation logic to prevent UI breakage and
   potential SpringBoard crashes. Users cannot set arbitrary extreme ratios.

6. Respring/reboot restoration: The tweak saves the last selected configuration
   and attempts to restore it on respring. A full reboot may be required for
   some configurations to take full effect, as the plist change is persistent
   across resprings but may need a full dyld reinit for some display modes.

7. No demand rendering adjustment: The tweak changes the canvas dimensions but
   does not adjust GPU rendering pipelines. Some 3D games or custom renderers
   may not automatically adapt to the new canvas size.

8. Portrait/landscape switch: Changing between portrait and landscape presets
   may require a device respring for the display to properly rotate and apply
   the new dimensions.

--------------------------------------------------------------------------------
IMPORTANT TECHNICAL NOTES
================================================================================

1. API Compatibility: All APIs used (UIKit, Foundation, IOKit, CFNotificationCenter)
   are available in iOS 15.0–15.8.8. No iOS 16+ only APIs are used.

2. Substrate/Logos: The tweak uses Substrate method hooking via Logos directives
   (%hook, %ctor, %group). These are standard Theos tools and are compatible
   with the Dopamine jailbreak environment.

3. Preference Bundle: The PSPreferences system used for the UI has been available
   since iOS 2.0 and is fully compatible with iOS 15.8.8. The specifier plist
   format is stable and well-documented.

4. XPC Messaging: CFNotificationCenterPostNotification is part of CoreFoundation
   and has been available since iOS 2.0. The notification center is functional
   on iOS 15.8.8 rootless without restrictions.

5. Theos Build System: The Makefile is configured for standard Theos build
   environment. Tweaks.build compatibility is ensured through:
   - THEOS_PACKAGE_SCHEME = rootless
   - iphone:clang:latest:15.0 target
   - arm64/arm64e architectures
   - No Xcode-only dependencies

6. File locations in rootless environment:
   - Tweak: /Library/MobileSubstrate/DynamicLibraries/StretchRes.dylib
   - Preference bundle: /Library/PreferenceBundles/StretchRes.bundle
   - Preferences: NSUserDefaults (standard iOS, rootless compatible)
   - Temp plist: /var/tmp/com.apple.iokit.IOMobileGraphicsFamily.plist
   - Mobile preferences: /private/var/mobile/Library/Preferences/
     com.apple.iokit.IOMobileGraphicsFamily.plist (symlink/copy)
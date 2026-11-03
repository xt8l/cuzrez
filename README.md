# StretchRes - iOS 15 Jailbreak Tweak

## Overview
StretchRes is a jailbreak tweak for iOS 15.0–15.8.8 that allows users to change their iPhone's screen resolution and aspect ratio to achieve a stretched-resolution effect.

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
The tweak modifies the `com.apple.iokit.IOMobileGraphicsFamily` preference plist with new canvas width and height values. After writing the plist, XPC messages are sent to restart `com.apple.cfprefsd.daemon` and `com.apple.backboard.TouchDeliveryPolicyServer` to pick up the new resolution settings.

**Note:** This implementation does NOT use the TCC exploit (CVE-2022-46689) or the `vm_unaligned_copy_switch_race` vulnerability. It relies solely on preference plist manipulation and XPC messaging, making it safer and compatible with iOS 15.8.8 without requiring kernel exploits.

## Installation
1. Compile the project using Theos
2. Install the resulting .deb package via Sileo, Installer, or dpkg
3. Enable the tweak in Settings > StretchRes
4. Select desired resolution and tap "Apply Resolution"

## Building
Compatible with Tweaks.build Theos environment. Set THEOS_PACKAGE_SCHEME=rootless for Dopamine rootless compatibility.

## License
See LICENSE for details."# cuzrez" 

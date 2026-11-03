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

# Preference bundle setup - compatible with Tweaks.build
StretchRes_BUNDLE_NAME = StretchRes
StretchRes_BUNDLE_FILES = Root.plist
StretchRes_INSTALL_PATH = /Library/PreferenceBundles
StretchRes_FRAMEWORKS = UIKit
StretchRes_PRIVATE_FRAMEWORKS = Preferences

after-tweak-install::
	$(ECHO_NOTICE) "StretchRes build complete. Package ready for Tweaks.build."
	$(THEOS_MAKE_PATH)/bin/activate
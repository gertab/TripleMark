include theos/makefiles/common.mk

export ARCHS = armv7 arm64
BUNDLE_NAME = tripplemarkprefs
tripplemarkprefs_FILES = tripplemarkprefs.mm
tripplemarkprefs_INSTALL_PATH = /Library/PreferenceBundles
tripplemarkprefs_FRAMEWORKS = UIKit
tripplemarkprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/tripplemarkprefs.plist$(ECHO_END)

include theos/makefiles/common.mk

export ARCHS = armv7 arm64
BUNDLE_NAME = TripleMarkPrefs
TripleMarkPrefs_FILES = TripleMarkPrefs.mm
TripleMarkPrefs_INSTALL_PATH = /Library/PreferenceBundles
TripleMarkPrefs_FRAMEWORKS = UIKit
TripleMarkPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TripleMarkPrefs.plist$(ECHO_END)

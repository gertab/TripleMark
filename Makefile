include theos/makefiles/common.mk

export ARCHS = armv7 arm64
TWEAK_NAME = TripleMark
TripleMark_FILES = Tweak.xm
TripleMark_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += triplemarkprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

include theos/makefiles/common.mk

TWEAK_NAME = TrippleMark
TrippleMark_FILES = Tweak.xm
TrippleMark_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += tripplemarkprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

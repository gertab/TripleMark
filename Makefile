include theos/makefiles/common.mk

TWEAK_NAME = TrippleMark
TrippleMark_FILES = Tweak.xm
TrippleMark_FRAMEWORKS = firmware (>= 7.0)
#, UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

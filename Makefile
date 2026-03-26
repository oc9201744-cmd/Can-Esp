export THEOS = /var/theos

ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Blackshark

Blackshark_FRAMEWORKS = IOKit UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController
Blackshark_EXTRA_FRAMEWORKS = JRMemory

Blackshark_CFLAGS = -fno-lto -fobjc-arc -Wno-deprecated-declarations -fvisibility=hidden -fpermissive -fexceptions -w \
                    -F$(THEOS_PROJECT_DIR) \
                    -I$(THEOS_PROJECT_DIR)/Dolphins \
                    -I$(THEOS_PROJECT_DIR)/Dolphins/lib

Blackshark_CCFLAGS = -fno-lto -std=c++17 -fno-rtti -fno-exceptions -DNDEBUG -fvisibility=hidden -fpermissive -fexceptions -w \
                     -F$(THEOS_PROJECT_DIR) \
                     -I$(THEOS_PROJECT_DIR)/Dolphins \
                     -I$(THEOS_PROJECT_DIR)/Dolphins/lib

Blackshark_LDFLAGS = -L$(THEOS_PROJECT_DIR)/Dolphins/lib -ldobby -lc++ -F$(THEOS_PROJECT_DIR)

Blackshark_USE_SUBSTRATE = 0

Blackshark_FILES = Dolphins/Dolphins.mm \
                   $(wildcard Dolphins/View/*.m) \
                   $(wildcard Dolphins/Module/*.mm) \
                   $(wildcard Dolphins/utils/*.mm) \
                   $(wildcard Dolphins/utils/*.cpp) \
                   $(wildcard Dolphins/View/*.mm) \
                   $(wildcard Dolphins/View/CustomView/*.mm) \
                   $(wildcard Dolphins/imgui/*.cpp) \
                   $(wildcard Dolphins/imgui/*.mm)

include $(THEOS_MAKE_PATH)/tweak.mk

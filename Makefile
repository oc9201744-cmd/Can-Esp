export THEOS = /var/theos
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Blackshark

# Framework Tanımlamaları
# JRMemory'yi EXTRA_FRAMEWORKS'e ekledik
Blackshark_FRAMEWORKS = IOKit UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController
Blackshark_EXTRA_FRAMEWORKS = JRMemory

# Path Tanımlamaları (-F framework yolu, -L library yolu için)
Blackshark_CFLAGS = -fno-lto -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -fvisibility=hidden -Wc++11-narrowing -Wno-narrowing -Wundefined-bool-conversion -Wreturn-stack-address -Wno-error=format-security -fpermissive -fexceptions -w -s -Werror -Wall -F$(THEOS_PROJECT_DIR)

Blackshark_CCFLAGS = -fno-lto -std=c++17 -fno-rtti -fno-exceptions -DNDEBUG -fvisibility=hidden -Wc++11-narrowing -Wno-narrowing -Wundefined-bool-conversion -Wreturn-stack-address -Wno-error=format-security -fpermissive -fexceptions -w -s -Werror -Wall -F$(THEOS_PROJECT_DIR)

# LDFLAGS: Dobby kütüphanesini ve JRMemory framework yolunu bağlar
Blackshark_LDFLAGS = -L$(THEOS_PROJECT_DIR)/Dolphins/lib -ldobby -lc++ -F$(THEOS_PROJECT_DIR)

# Substrate'i devre dışı bırak (Dobby kullanıldığı için)
Blackshark_USE_SUBSTRATE = 0

# Dosya Listesi
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

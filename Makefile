export THEOS=/var/theos
ARCHS = arm64
# arm64e gerekiyorsa ekle
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
# THEOS_PACKAGE_SCHEME = rootless  <-- JB-specific, non-JB için kaldırıldı

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Blackshark

Blackshark_FRAMEWORKS = IOKit UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController

# substrate kaldırıldı → libdobby.a kullanılıyor
Blackshark_LDFLAGS = -L$(THEOS_PROJECT_DIR)/Dolphins/lib -ldobby -lc++

# tweak.mk'nin substrate'i otomatik linklemesini engelle
Blackshark_USE_SUBSTRATE = 0

Blackshark_CCFLAGS = -fno-lto -std=c++17 -fno-rtti -fno-exceptions -DNDEBUG -fvisibility=hidden -Wc++11-narrowing -Wno-narrowing -Wundefined-bool-conversion -Wreturn-stack-address -Wno-error=format-security -fvisibility=hidden -fpermissive -fexceptions -w -s -Wno-error=format-security -fvisibility=hidden -Werror -fpermissive -Wall -fexceptions

Blackshark_CFLAGS = -fno-lto -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -fvisibility=hidden -Wc++11-narrowing -Wno-narrowing -Wundefined-bool-conversion -Wreturn-stack-address -Wno-error=format-security -fvisibility=hidden -fpermissive -fexceptions -w -s -Wno-error=format-security -fvisibility=hidden -Werror -fpermissive -Wall -fexceptions

Blackshark_FILES = Dolphins/Dolphins.mm $(wildcard Dolphins/View/*.m) $(wildcard Dolphins/Module/*.mm) $(wildcard Dolphins/utils/*.mm) $(wildcard Dolphins/utils/*.cpp) $(wildcard Dolphins/View/*.mm) $(wildcard Dolphins/View/CustomView/*.mm) $(wildcard Dolphins/imgui/*.cpp) $(wildcard Dolphins/imgui/*.mm)

include $(THEOS_MAKE_PATH)/tweak.mk

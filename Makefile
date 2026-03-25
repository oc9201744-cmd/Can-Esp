# Theos path
THEOS = /var/theos

# arm64e'yi kaldırıyoruz çünkü kütüphaneler desteklemiyor
ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Blackshark

# Framework ve Linker Ayarları
Blackshark_FRAMEWORKS = IOKit UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController
Blackshark_EXTRA_FRAMEWORKS = JRMemory

# Path Ayarları
Blackshark_CFLAGS = -fno-lto -fobjc-arc -Wno-deprecated-declarations -fvisibility=hidden -fpermissive -fexceptions -w -I$(THEOS_PROJECT_DIR)/Dolphins -I$(THEOS_PROJECT_DIR)/Dolphins/utils -I$(THEOS_PROJECT_DIR)/Dolphins/View
Blackshark_CCFLAGS = -fno-lto -std=c++17 -fno-rtti -fno-exceptions -DNDEBUG -fvisibility=hidden -fpermissive -fexceptions -w -I$(THEOS_PROJECT_DIR)/Dolphins -I$(THEOS_PROJECT_DIR)/Dolphins/utils -I$(THEOS_PROJECT_DIR)/Dolphins/View

# LDFLAGS - Dobby (eğer varsa)
Blackshark_LDFLAGS = -lc++

# Substrate kullanma
Blackshark_USE_SUBSTRATE = 0

# Dosya Listesi
Blackshark_FILES = Dolphins/Dolphins.mm \
                   $(wildcard Dolphins/View/*.m) \
                   $(wildcard Dolphins/View/*.mm) \
                   $(wildcard Dolphins/utils/*.m) \
                   $(wildcard Dolphins/utils/*.mm) \
                   $(wildcard Dolphins/utils/*.cpp)

# Eğer Module klasörü varsa ekle
ifeq ($(wildcard Dolphins/Module),)
    # Module klasörü yoksa uyarı verme
else
    Blackshark_FILES += $(wildcard Dolphins/Module/*.mm) \
                        $(wildcard Dolphins/Module/*.cpp)
endif

# Eğer imgui klasörü varsa ekle
ifeq ($(wildcard Dolphins/imgui),)
    # imgui klasörü yoksa uyarı verme
else
    Blackshark_FILES += $(wildcard Dolphins/imgui/*.cpp) \
                        $(wildcard Dolphins/imgui/*.mm)
endif

# CustomView varsa ekle
ifeq ($(wildcard Dolphins/View/CustomView),)
    # CustomView yoksa uyarı verme
else
    Blackshark_FILES += $(wildcard Dolphins/View/CustomView/*.mm) \
                        $(wildcard Dolphins/View/CustomView/*.m)
endif

include $(THEOS_MAKE_PATH)/tweak.mk

# Derleme sonrası temizlik
after-all::
	@echo "✅ Blackshark derlemesi tamamlandı!"
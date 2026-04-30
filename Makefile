export TARGET = iphone:clang:latest:15.0
export SDK_PATH = $(THEOS)/sdks/iPhoneOS17.5.sdk
export SYSROOT = $(SDK_PATH)
export ARCHS = arm64

export libcolorpicker_ARCHS = arm64
export libFLEX_ARCHS = arm64

export Alderis_XCODEOPTS = LD_DYLIB_INSTALL_NAME=@rpath/Alderis.framework/Alderis
export Alderis_XCODEFLAGS = DYLIB_INSTALL_NAME_BASE=/Library/Frameworks BUILD_LIBRARY_FOR_DISTRIBUTION=YES ARCHS="$(ARCHS)"
export libcolorpicker_LDFLAGS = -F$(TARGET_PRIVATE_FRAMEWORK_PATH) -install_name @rpath/libcolorpicker.dylib

export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks -I$(THEOS_PROJECT_DIR)/Tweaks/RemoteLog -I$(THEOS_PROJECT_DIR)/Tweaks/FixHeaders
export ADDITIONAL_OBJCCFLAGS = -include $(THEOS_PROJECT_DIR)/Tweaks/FixHeaders/FixForward.h

ifneq ($(JAILBROKEN),1)
export DEBUGFLAG = -ggdb -Wno-unused-command-line-argument -L$(THEOS_OBJ_DIR) -F$(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install/Library/Frameworks
MODULES = jailed
endif

ifndef YOUTUBE_VERSION
YOUTUBE_VERSION := 21.17.3
endif

ifndef UYOU_VERSION
UYOU_VERSION := 3.0.4
endif

TWEAK_NAME = uYouEnhanced
PACKAGE_NAME = $(TWEAK_NAME)
PACKAGE_VERSION = $(YOUTUBE_VERSION)-$(UYOU_VERSION)

DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube
INSTALL_TARGET_PROCESSES = YouTube

$(TWEAK_NAME)_FILES := $(wildcard Sources/*.xm) $(wildcard Sources/*.x) $(wildcard Sources/*.m)
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation AVFoundation AVKit Photos Accelerate CoreMotion GameController VideoToolbox Security
$(TWEAK_NAME)_LIBRARIES = bz2 c++ iconv z

# Sửa lỗi chí mạng: Dùng dấu nháy đơn bảo vệ chuỗi phiên bản cho Clang
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-but-set-variable -DTWEAK_VERSION='@"$(PACKAGE_VERSION)"'

# Dồn dòng để tránh lỗi khoảng trắng (space) sau dấu gạch chéo (\)
$(TWEAK_NAME)_INJECT_DYLIBS = Tweaks/uYou/Library/MobileSubstrate/DynamicLibraries/uYou.dylib $(THEOS_OBJ_DIR)/libFLEX.dylib $(THEOS_OBJ_DIR)/iSponsorBlock.dylib $(THEOS_OBJ_DIR)/YTABConfig.dylib $(THEOS_OBJ_DIR)/YTIcons.dylib $(THEOS_OBJ_DIR)/YouGroupSettings.dylib $(THEOS_OBJ_DIR)/YouLoop.dylib $(THEOS_OBJ_DIR)/YouMute.dylib $(THEOS_OBJ_DIR)/YouPiP.dylib $(THEOS_OBJ_DIR)/YouQuality.dylib $(THEOS_OBJ_DIR)/YouSlider.dylib $(THEOS_OBJ_DIR)/YouSpeed.dylib $(THEOS_OBJ_DIR)/YouTimeStamp.dylib $(THEOS_OBJ_DIR)/YouTubeDislikesReturn.dylib $(THEOS_OBJ_DIR)/DontEatMyContent.dylib $(THEOS_OBJ_DIR)/YTHoldForSpeed.dylib $(THEOS_OBJ_DIR)/YTUHD.dylib $(THEOS_OBJ_DIR)/YTVideoOverlay.dylib $(THEOS_OBJ_DIR)/YTweaks.dylib $(THEOS_OBJ_DIR)/ShareFix.dylib

$(TWEAK_NAME)_EMBED_LIBRARIES = $(THEOS_OBJ_DIR)/libcolorpicker.dylib
$(TWEAK_NAME)_EMBED_FRAMEWORKS = $(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install_Alderis.xcarchive/Products/var/jb/Library/Frameworks/Alderis.framework
$(TWEAK_NAME)_EMBED_BUNDLES = $(wildcard Bundles/*.bundle)
$(TWEAK_NAME)_EMBED_EXTENSIONS = $(wildcard Extensions/*.appex)

$(TWEAK_NAME)_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS)/makefiles/common.mk

ifneq ($(JAILBROKEN),1)
SUBPROJECTS += Tweaks/Alderis Tweaks/DontEatMyContent Tweaks/FLEXing/libflex Tweaks/iSponsorBlock Tweaks/Return-YouTube-Dislikes Tweaks/YTABConfig Tweaks/YouGroupSettings Tweaks/YTIcons Tweaks/YouLoop Tweaks/YouMute Tweaks/YouPiP Tweaks/YouQuality Tweaks/YouSlider Tweaks/YouSpeed Tweaks/YouTimeStamp Tweaks/YTHoldForSpeed Tweaks/YTUHD Tweaks/YTVideoOverlay Tweaks/YTweaks ShareFix
include $(THEOS_MAKE_PATH)/aggregate.mk
endif

include $(THEOS_MAKE_PATH)/tweak.mk

REMOVE_EXTENSIONS = 1
CODESIGN_IPA = 0

UYOU_PATH = Tweaks/uYou
UYOU_DEB = $(UYOU_PATH)/com.miro.uyou_$(UYOU_VERSION)_iphoneos-arm.deb
UYOU_DYLIB = $(UYOU_PATH)/Library/MobileSubstrate/DynamicLibraries/uYou.dylib
UYOU_BUNDLE = $(UYOU_PATH)/Library/Application\ Support/uYouBundle.bundle

internal-clean::
	rm -rf $(UYOU_PATH)/*

ifneq ($(JAILBROKEN),1)
before-all::
	@if [ ! -f $(UYOU_DEB) ]; then rm -rf $(UYOU_PATH)/*; curl -L "https://www.dropbox.com/scl/fi/01vvu5lm8nkkicrznku9v/com.miro.uyou_$(UYOU_VERSION)_iphoneos-arm.deb?rlkey=efgz7po8kqqvha8doplk1s3ky&dl=1" -o $(UYOU_DEB); fi
	@if [ ! -f $(UYOU_DYLIB) ] || [ ! -d $(UYOU_BUNDLE) ]; then tar -xf $(UYOU_DEB) -C $(UYOU_PATH); tar -xf $(UYOU_PATH)/data.tar* -C $(UYOU_PATH); fi
else
before-package::
	mkdir -p "$(THEOS_STAGING_DIR)/Library/Application Support"
	cp -r Localizations/uYouPlus.bundle "$(THEOS_STAGING_DIR)/Library/Application Support/"
endif

after-stage::
	@echo "===> Đang tự động tìm vị trí Info.plist..."
	$(eval INFO_PATH := $(shell find $(THEOS_STAGING_DIR) -name "Info.plist" | head -n 1))
	$(eval APP_DIR := $(shell dirname "$(INFO_PATH)"))

	@if [ -f "$(INFO_PATH)" ]; then \
		echo "Đã tìm thấy tại: $(INFO_PATH)"; \
		/usr/libexec/PlistBuddy -c "Print :NSLocalNetworkUsageDescription" "$(INFO_PATH)" >/dev/null 2>&1 || \
		/usr/libexec/PlistBuddy -c "Add :NSLocalNetworkUsageDescription string 'Allow access to local network for casting'" "$(INFO_PATH)"; \
		/usr/libexec/PlistBuddy -c "Print :NSBonjourServices" "$(INFO_PATH)" >/dev/null 2>&1 || \
		/usr/libexec/PlistBuddy -c "Add :NSBonjourServices array" "$(INFO_PATH)"; \
		/usr/libexec/PlistBuddy -c "Print :NSBonjourServices" "$(INFO_PATH)" | grep -q "_googlecast._tcp" || \
		/usr/libexec/PlistBuddy -c "Add :NSBonjourServices:0 string _googlecast._tcp" "$(INFO_PATH)"; \
		/usr/libexec/PlistBuddy -c "Print :NSBonjourServices" "$(INFO_PATH)" | grep -q "_googlezone._tcp" || \
		/usr/libexec/PlistBuddy -c "Add :NSBonjourServices:1 string _googlezone._tcp" "$(INFO_PATH)"; \
		echo "Info.plist patched OK"; \
		\
		echo "===> Ép file entitlements vào: $(APP_DIR)"; \
		cp cyan.entitlements "$(APP_DIR)/cyan.entitlements"; \
	else \
		echo "CẢNH BÁO: Vẫn không tìm thấy Info.plist. Kiểm tra lại cấu trúc file IPA."; \
	fi

XBUILD=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
PROJECT=ALCameraViewController.xcodeproj
SCHEME=CameraViewController
DERIVEDDATAPATH=build
BUILD_ROOT=$(DERIVEDDATAPATH)/Build/Products
VALID_ARCHS="armv7 armv7s arm64 i386 x86_64"
CONFIGURATION=Release

all: clean $(SCHEME).framework

$(SCHEME)-iphonesimulator:
	$(XBUILD) -project $(PROJECT) -scheme $(SCHEME) -sdk iphonesimulator -configuration $(CONFIGURATION) VALID_ARCHS=$(VALID_ARCHS) ONLY_ACTIVE_ARCH=NO EFFECTIVE_PLATFORM_NAME="-iphonesimulator" -derivedDataPath $(DERIVEDDATAPATH) clean build

$(SCHEME)-iphoneos:
	$(XBUILD) -project $(PROJECT) -scheme $(SCHEME) -sdk iphoneos -configuration $(CONFIGURATION) ONLY_ACTIVE_ARCH=NO -derivedDataPath $(DERIVEDDATAPATH) clean build

$(SCHEME).framework: $(SCHEME)-iphonesimulator $(SCHEME)-iphoneos
	mkdir $@
	cp -R $(BUILD_ROOT)/$(CONFIGURATION)-iphoneos/$(SCHEME).framework/* $@
	rm $@/$(SCHEME)
	lipo -create -output $@/$(SCHEME) $(BUILD_ROOT)/$(CONFIGURATION)-iphoneos/$(SCHEME).framework/$(SCHEME) $(BUILD_ROOT)/$(CONFIGURATION)-iphonesimulator/$(SCHEME).framework/$(SCHEME)	
	cp -R $(BUILD_ROOT)/$(CONFIGURATION)-iphonesimulator/$(SCHEME).framework/Modules/$(SCHEME).swiftmodule/* $@/Modules/$(SCHEME).swiftmodule/

clean:
	rm -Rf build
	rm -Rf $(SCHEME).framework

.PHONY: all

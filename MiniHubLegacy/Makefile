ARCHS = armv7
TARGET = iphone:clang:9.2:9.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = MiniHub
MiniHub_FILES = main.m AppDelegate.m MiniHubViewController.m
MiniHub_FRAMEWORKS = UIKit Foundation AVFoundation
MiniHub_CFLAGS = -fobjc-arc
MiniHub_RESOURCE_DIRS = Resources

include $(THEOS_MAKE_PATH)/application.mk

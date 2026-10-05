ARCHS = armv7
TARGET = iphone:9.2:9.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = MiniHub
MiniHub_FILES = main.m AppDelegate.m MiniHubViewController.m
MiniHub_FRAMEWORKS = UIKit Foundation
MiniHub_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk

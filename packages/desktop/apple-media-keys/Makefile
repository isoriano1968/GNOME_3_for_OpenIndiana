#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2026 isoriano1968
#

# GNOME media-key defaults for Apple keyboards on illumos: Super (Cmd) +
# F7-F12 = previous, play/pause, next, mute, volume down, volume up.  The
# Magic Keyboard sends its media keys as plain F-keys and illumos (usbkbm,
# boot protocol) does not see the fn bit, so plain F-keys cannot be both;
# FS-UAE needs F11/F12.  Only local files (files/), no upstream source, built
# like oi-userland's database/mysql-common.  See notes/imac2019-network.md.

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		apple-media-keys
COMPONENT_VERSION=	1.0
COMPONENT_SUMMARY=	GNOME media keys on Super+F7-F12 for Apple keyboards
COMPONENT_FMRI=		desktop/gnome/apple-media-keys
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Sessions
COMPONENT_LICENSE=	CDDL
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

include $(WS_MAKE_RULES)/prep-download.mk
include $(WS_MAKE_RULES)/justmake.mk
include $(WS_MAKE_RULES)/ips.mk

PATH=$(PATH.gnu)

download::

$(BUILD_DIR)/.prep: Makefile $(COMPONENT_NAME).p5m
	$(MKDIR) -p "$(@D)"
	$(TOUCH) $@

prep::	$(BUILD_DIR)/.prep

clean::
	$(RM) -r $(BUILD_DIR)

clobber:: clean

build:: $(BUILD_DIR)/.prep

install: $(BUILD_DIR)/.prep

test: $(NO_TESTS)

REQUIRED_PACKAGES += gnome/gnome-settings-daemon

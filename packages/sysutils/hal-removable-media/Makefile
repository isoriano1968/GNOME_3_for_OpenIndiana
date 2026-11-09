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

# D-Bus policy that lets desktop users (group staff) call HAL's Volume and
# Storage interfaces: mount, unmount and eject of removable media from the
# desktop (gvfs HAL volume monitor, Files, the dock).  See
# files/oi-hal-removable-media.conf for why OpenIndiana needs it.

BUILD_BITS=		NO_ARCH
BUILD_STYLE=		pkg

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		hal-removable-media
COMPONENT_VERSION=	1.0
COMPONENT_SUMMARY=	D-Bus policy: desktop users may mount and unmount removable media through HAL
COMPONENT_PROJECT_URL=	https://github.com/isoriano1968/GNOME_3_for_OpenIndiana
COMPONENT_FMRI=		system/hal/removable-media-policy
COMPONENT_CLASSIFICATION=	System/Hardware
COMPONENT_LICENSE=	CDDL-1.0
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

include $(WS_MAKE_RULES)/common.mk

COMPONENT_POST_INSTALL_ACTION += \
	$(INSTALL) -D -m 0444 $(COMPONENT_DIR)/files/oi-hal-removable-media.conf \
	    $(PROTO_DIR)/etc/dbus-1/system.d/oi-hal-removable-media.conf ;

REQUIRED_PACKAGES += service/hal
REQUIRED_PACKAGES += system/library/dbus

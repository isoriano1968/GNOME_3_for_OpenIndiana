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
# Copyright 2024 Geoff Weiss
#

# OpenIndiana project: oi-userland's library/gjs (d87ae8ac6) with SPARC
# support.  In this repo it builds on SPARC only: x86 keeps OI's
# library/desktop/gjs from openindiana.org, which the working x86 GNOME 3
# uses (the guard below stops an x86 build).  SPARC: gcc 13, and
# patches/20-sparc-addr32.sparc, which links gjs-console and the test
# programs with the ADDR32 capability that libmozjs-140 requires there
# (library/mozjs-140, notes/gnome3-sparc.md).

BUILD_STYLE = meson
USE_DEFAULT_TEST_TRANSFORMS = yes

ifeq ($(shell uname -p),sparc)
# OpenIndiana SPARC: gcc 13 is the newest there.
GCC_VERSION = 13
endif
include ../../../make-rules/shared-macros.mk

ifeq ($(MACH),i386)
$(error library/gjs from this repo is for SPARC; x86 uses OI's package)
endif
ifeq ($(MACH),sparc)
ADDITIONAL_PATCHES += patches/20-sparc-addr32.sparc
endif

COMPONENT_NAME =		gjs
HUMAN_VERSION =			1.90.1
COMPONENT_SUMMARY =		GNOME Javascript bindings
COMPONENT_ARCHIVE_HASH =	\
	sha256:05ceaa80f48e3782e5c44938572fad863e02b8c4a6c55657a99aa81db8ce9efa
COMPONENT_PROJECT_URL =		https://wiki.gnome.org/Projects/Gjs
COMPONENT_FMRI =		library/desktop/gjs
COMPONENT_CLASSIFICATION =	Desktop (GNOME)/Libraries
COMPONENT_LICENSE =		BSD-3-Clause, CC-BY-3.0, CC0-1.0, GPL-2.0+, GPL-3.0+, LGPL-2.0+, LGPL-3.0+, MIT, MPL-1.1, MPL-2.0
COMPONENT_LICENSE_FILE =	COPYING

include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

# GNU msgfmt is needed
PATH=$(PATH.gnu)

# need for locale_t
CFLAGS += $(XPG7MODE)

CONFIGURE_OPTIONS += -Dprofiler=disabled
CONFIGURE_OPTIONS += -Dinstalled_tests=false

# Testing needs an X server
TEST_REQUIRED_PACKAGES += x11/server/xvfb
COMPONENT_PRE_TEST_ACTION += /usr/bin/Xvfb :1 >/dev/null 2>&1 &
COMPONENT_TEST_ENV += DISPLAY=:1
COMPONENT_POST_TEST_ACTION += /usr/bin/pkill -x Xvfb ;

# Auto-generated dependencies
REQUIRED_PACKAGES += $(GXX_RUNTIME_PKG)
REQUIRED_PACKAGES += $(READLINE_PKG)
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/mozjs-140
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/libffi
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += x11/library/libx11

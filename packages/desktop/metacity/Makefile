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

# Metacity 3.50.0, the X11 window manager (with its own compositor) of the
# GNOME Flashback session; the GNOME 45 generation, next to our
# gnome-session 45 and gnome-settings-daemon 45.  Vulkan off: no Vulkan
# driver on OpenIndiana; the XRender compositor is used.
# FMRI as OpenIndiana's obsolete GNOME 2 Metacity (2.30.3), which this one
# supersedes.

BUILD_BITS=		64
BUILD_STYLE=		configure

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		metacity
HUMAN_VERSION=		3.50.0
COMPONENT_SUMMARY=	Metacity, the window manager of GNOME Flashback
COMPONENT_ARCHIVE_HASH=	\
	sha256:18e9b106438d46394e4148bcb83acc6367312be54559cdb564e270c1ccaeb60f
COMPONENT_FMRI=		gnome/window-manager/metacity
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Window Managers
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

# illumos: the strict standard mode hides stack_t etc. that system headers
# (libgtop's procfs, kvm) need; -D_REENTRANT for GLib's per-thread errno
CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS -D_REENTRANT

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"
CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	--disable-static
CONFIGURE_OPTIONS +=	--disable-vulkan
# Auto-generated dependencies
REQUIRED_PACKAGES += gnome/accessibility/at-spi2-core
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/gtk3
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += library/desktop/startup-notification
REQUIRED_PACKAGES += library/desktop/xdg/libcanberra
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/libgtop
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += x11/library/libice
REQUIRED_PACKAGES += x11/library/libsm
REQUIRED_PACKAGES += x11/library/libx11
REQUIRED_PACKAGES += x11/library/libxcomposite
REQUIRED_PACKAGES += x11/library/libxcursor
REQUIRED_PACKAGES += x11/library/libxdamage
REQUIRED_PACKAGES += x11/library/libxext
REQUIRED_PACKAGES += x11/library/libxfixes
REQUIRED_PACKAGES += x11/library/libxinerama
REQUIRED_PACKAGES += x11/library/libxpresent
REQUIRED_PACKAGES += x11/library/libxrandr
REQUIRED_PACKAGES += x11/library/libxrender
REQUIRED_PACKAGES += x11/library/libxres

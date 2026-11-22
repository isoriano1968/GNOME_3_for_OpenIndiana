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

# xdg-desktop-portal-gnome 47.3, the GNOME backend of xdg-desktop-portal.
# Its FileChooser hands the dialog to Nautilus (org.gnome.Nautilus
# implements org.freedesktop.impl.portal.FileChooser), so Chromium and
# Electron apps get GNOME's own file dialog. Built as FreeBSD's x11/xdg-
# desktop-portal-gnome: no systemd unit, D-Bus session activation
# (patches/01).

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		xdg-desktop-portal-gnome
HUMAN_VERSION=		47.3
COMPONENT_REVISION=	2
COMPONENT_SUMMARY=	xdg-desktop-portal-gnome - GNOME backend for xdg-desktop-portal
COMPONENT_PROJECT_URL=	https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome
COMPONENT_ARCHIVE_HASH=	\
	sha256:9f6e4b14b583367c915e9494764f27cb84927faa3f9e6e018b93bbbcf3361e44
COMPONENT_FMRI=		library/desktop/xdg/xdg-desktop-portal-gnome
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Libraries
COMPONENT_LICENSE=	LGPL-2.1-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS
# Threaded: without _REENTRANT, illumos' errno is one global variable and
# another thread's failed call overwrites it (xdg-desktop-portal rev 1 refused
# every call: an ENOENT for /proc/PID/cgroup read back as ENOTTY).
CFLAGS +=		-D_REENTRANT

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Dsystemd=disabled
CONFIGURE_OPTIONS +=	-Dsystemduserunitdir=no

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/desktop/gtk4
REQUIRED_PACKAGES += library/desktop/libadwaita
REQUIRED_PACKAGES += library/desktop/gnome-desktop
REQUIRED_PACKAGES += library/desktop/xdg/xdg-desktop-portal
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/graphene
REQUIRED_PACKAGES += system/library/fontconfig
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += x11/library/libx11

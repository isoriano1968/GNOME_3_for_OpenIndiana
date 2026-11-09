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

# Eye of GNOME (Image Viewer) 45.4, the bug-fix release of the 45.2 that
# Solaris 11.4 ships (solaris-userland components/gnome/eog @9d7a655, no
# patches there). GTK3, libhandy, libpeas-1. As Solaris: no libportal.
# OpenIndiana has no exempi, so no XMP metadata.

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		eog
HUMAN_VERSION=		45.4
COMPONENT_SUMMARY=	Eye of GNOME - GNOME image viewer
COMPONENT_PROJECT_URL=	https://wiki.gnome.org/Apps/EyeOfGnome
COMPONENT_ARCHIVE_HASH=	\
	sha256:b50f321c70ac64af7bcaa5b4460dc675b3ca60fdad385616f3ac7b770e0666fe
COMPONENT_FMRI=		image/viewer/eog
COMPONENT_CLASSIFICATION=	Applications/Graphics and Imaging
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/eog/45/eog-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS
CFLAGS +=		$(CPP_XPG6MODE)

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Dlibportal=false
CONFIGURE_OPTIONS +=	-Dxmp=false
CONFIGURE_OPTIONS +=	-Dgtk_doc=false
CONFIGURE_OPTIONS +=	-Dinstalled_tests=false

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += gnome/config/gsettings-desktop-schemas
REQUIRED_PACKAGES += image/library/libexif
REQUIRED_PACKAGES += image/library/libjpeg8-turbo
REQUIRED_PACKAGES += image/library/librsvg
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/gobject/gobject-introspection
REQUIRED_PACKAGES += library/desktop/gtk3
REQUIRED_PACKAGES += library/libhandy
REQUIRED_PACKAGES += library/desktop/libpeas
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/desktop/gnome-desktop
REQUIRED_PACKAGES += library/lcms2
REQUIRED_PACKAGES += library/zlib
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += x11/library/libx11

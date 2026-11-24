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

# Cheese 44.1, GNOME's webcam application (photos, videos, effects), and
# libcheese. GTK 3, clutter, clutter-gst and clutter-gtk (OI), GStreamer's
# camerabin (gst-plugins-bad) and v4l2src (gst-plugins-good; usbvc(4D) with
# the V4L2 extensions of ports/usbvc-v4l2). Videos are WebM (vp8enc,
# webmmux). No gtk-doc.

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		cheese
HUMAN_VERSION=		44.1
COMPONENT_SUMMARY=	Cheese - take photos and videos with your webcam
COMPONENT_PROJECT_URL=	https://gitlab.gnome.org/GNOME/cheese
COMPONENT_ARCHIVE_HASH=	\
	sha256:5f2185c4c99e54ddf2b8baf60c82819950e54952e132e8639875f3edcbf8f68e
COMPONENT_FMRI=		media/cheese
COMPONENT_CLASSIFICATION=	Applications/Sound and Video
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/cheese/44/cheese-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS
# gcc 14: errors in libcheese (cheese-flash.c) and Vala's generated C, as
# elsewhere in oi-userland
CFLAGS +=		-Wno-error=incompatible-pointer-types
CFLAGS +=		-Wno-error=int-conversion

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Dgtk_doc=false
CONFIGURE_OPTIONS +=	-Dtests=false

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

# Auto-generated dependencies
REQUIRED_PACKAGES += library/audio/gstreamer
REQUIRED_PACKAGES += library/audio/gstreamer/plugin/base
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/clutter
REQUIRED_PACKAGES += library/desktop/clutter/clutter-gst
REQUIRED_PACKAGES += library/desktop/clutter/clutter-gtk
REQUIRED_PACKAGES += library/desktop/cogl
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/gnome-desktop
REQUIRED_PACKAGES += library/desktop/gtk3
REQUIRED_PACKAGES += library/desktop/xdg/libcanberra
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += x11/library/libx11

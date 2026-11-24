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
# Copyright 2016-2017 Aurelien Larcher.  All rights reserved.
# Copyright 2019 Michal Nowak
# Copyright 2021 Tim Mooney.  All rights reserved.
# Copyright 2022-2023 Niklas Poslovski
#

# OpenIndiana project: oi-userland's encumbered/gst-plugins-bad (2cadaa12)
# built with -D_REENTRANT, so that <errno.h> gives the per-thread errno
# (___errno()) instead of the global errno, which hls, shm, curl,
# ipcpipeline, sndfile, resindvd, closedcaption and festival read on
# GStreamer's streaming threads (notes/gstreamer-errno.md).  Patch 04 and
# -Dva=enabled build the VA-API plugin (va: vah264dec, vah265dec, ... on
# Mesa's radeonsi) and libgstva on illumos' DRM render nodes, without gudev.
# COMPONENT_REVISION 1 is one above OI's.

BUILD_STYLE= meson
USE_DEFAULT_TEST_TRANSFORMS = yes

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gst-plugins-bad
COMPONENT_VERSION=	1.28.9
COMPONENT_REVISION=	1
COMPONENT_SUMMARY=      GNOME streaming media framework plugins
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=      $(COMPONENT_SRC).tar.xz
COMPONENT_ARCHIVE_HASH=	sha256:4a4e0b7bf84f868378c48f143a7ac3a98923b488a5b74f1a35ba46bc3c43f6b1
COMPONENT_PROJECT_URL=  https://gstreamer.freedesktop.org
COMPONENT_ARCHIVE_URL=	$(COMPONENT_PROJECT_URL)/src/$(COMPONENT_NAME)/$(COMPONENT_ARCHIVE)
COMPONENT_FMRI=         library/audio/gstreamer/plugin/bad
COMPONENT_CLASSIFICATION=	System/Multimedia Libraries
COMPONENT_LICENSE=	LGPL-2.1-only
COMPONENT_LICENSE_FILE= COPYING

include $(WS_MAKE_RULES)/encumbered.mk
include $(WS_MAKE_RULES)/common.mk

# Per-thread errno (see the top of this file).
CPPFLAGS += -D_REENTRANT

# VA-API on DRM render nodes (patch 04); no gudev on illumos.
CONFIGURE_OPTIONS += -Dva=enabled
CONFIGURE_OPTIONS += -Ddrm=enabled
CONFIGURE_OPTIONS += -Dudev=disabled
# libdrm lives in /usr/lib/xorg/amd64 (as in library/graphics/libva).
LDFLAGS += -Wl,-R/usr/lib/xorg/$(MACH64)

CONFIGURE_OPTIONS += -Dexamples=disabled
CONFIGURE_OPTIONS += -Dopenexr=enabled
CONFIGURE_OPTIONS += -Dintrospection=enabled
CONFIGURE_OPTIONS += -Dgpl=enabled
CONFIGURE_OPTIONS += -Dspandsp=disabled
# if someone can weigh in on the fdk-aac license, adding fdk-aac might be
# be nice.
# Openh264 has no licensing issues but needs some porting
CONFIGURE_OPTIONS += -Dpackage-origin="https://github.com/OpenIndiana/oi-userland"

# Dynamic library version number
SOVER := 0.$(shell printf '%02s%02s' $(wordlist 2,3,$(subst ., ,$(COMPONENT_VERSION)))).0
SOVER_RE = $(subst .,\.,$(SOVER))

# Replace library version number by SOVER
GENERATE_EXTRA_CMD += | $(GSED) -e 's/$(SOVER_RE)/$$(SOVER)/'

# SOVER is needed for manifest processing
PKG_MACROS += SOVER=$(SOVER)

# Build dependencies
REQUIRED_PACKAGES += system/header/header-drm
# Introspection
REQUIRED_PACKAGES += library/desktop/gobject/gobject-introspection

# Auto-generated dependencies
REQUIRED_PACKAGES += $(GCC_RUNTIME_PKG)
REQUIRED_PACKAGES += $(GXX_RUNTIME_PKG)
REQUIRED_PACKAGES += $(OPENSSL_PKG)
REQUIRED_PACKAGES += audio/faac
REQUIRED_PACKAGES += audio/faad2
REQUIRED_PACKAGES += compress/bzip2
REQUIRED_PACKAGES += image/library/librsvg
REQUIRED_PACKAGES += image/library/openjpeg
REQUIRED_PACKAGES += image/zbar
REQUIRED_PACKAGES += library/audio/gstreamer
REQUIRED_PACKAGES += library/audio/gstreamer/plugin/base
REQUIRED_PACKAGES += library/audio/libdca
REQUIRED_PACKAGES += library/audio/libgsm
REQUIRED_PACKAGES += library/audio/openal
REQUIRED_PACKAGES += library/audio/soundtouch
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/json-glib
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/imath
REQUIRED_PACKAGES += library/lcms2
REQUIRED_PACKAGES += library/libqrencode
REQUIRED_PACKAGES += library/libsndfile
REQUIRED_PACKAGES += library/libwebp
REQUIRED_PACKAGES += library/libxml2
REQUIRED_PACKAGES += library/neon
REQUIRED_PACKAGES += library/nettle
REQUIRED_PACKAGES += library/openexr
REQUIRED_PACKAGES += library/opus
REQUIRED_PACKAGES += library/orc
REQUIRED_PACKAGES += library/video/libass
REQUIRED_PACKAGES += library/video/libde265
REQUIRED_PACKAGES += library/video/libdvdnav
REQUIRED_PACKAGES += library/video/libdvdread
REQUIRED_PACKAGES += library/video/x265
REQUIRED_PACKAGES += library/video/x265-43
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += video/rtmpdump
REQUIRED_PACKAGES += web/curl
REQUIRED_PACKAGES += x11/library/libx11
REQUIRED_PACKAGES += library/graphics/libva
REQUIRED_PACKAGES += x11/library/libdrm

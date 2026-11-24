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
# Copyright 2016-2018 Aurelien Larcher.  All rights reserved.
# Copyright 2019 Michal Nowak
# Copyright 2021 Tim Mooney.  All rights reserved.
# Copyright 2022-2023 Niklas Poslovski
#

# OpenIndiana project: oi-userland's encumbered/gst-plugins-ugly (2cadaa12)
# built with -D_REENTRANT, so that <errno.h> gives the per-thread errno
# (___errno()) instead of the global errno, which cdio and dvdread read on
# GStreamer's streaming threads (notes/gstreamer-errno.md).
# COMPONENT_REVISION 1 is one above OI's.

BUILD_STYLE= meson
USE_DEFAULT_TEST_TRANSFORMS= yes

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gst-plugins-ugly
COMPONENT_VERSION=	1.28.9
COMPONENT_REVISION=	1
COMPONENT_SUMMARY=      GNOME streaming media framework plugins
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=      $(COMPONENT_SRC).tar.xz
COMPONENT_ARCHIVE_HASH=	sha256:550a52536962186f5488e06b5c08f31ae0f18400aee32a3385156d31cb4b1189
COMPONENT_PROJECT_URL=  https://gstreamer.freedesktop.org
COMPONENT_ARCHIVE_URL=	$(COMPONENT_PROJECT_URL)/src/$(COMPONENT_NAME)/$(COMPONENT_ARCHIVE)
COMPONENT_FMRI=         library/audio/gstreamer/plugin/ugly
COMPONENT_CLASSIFICATION=System/Multimedia Libraries
COMPONENT_LICENSE=	LGPL-2.1-only
COMPONENT_LICENSE_FILE= COPYING

include $(WS_MAKE_RULES)/encumbered.mk
include $(WS_MAKE_RULES)/common.mk

# Per-thread errno (see the top of this file).
CPPFLAGS += -D_REENTRANT

# no introspection or examples here
CONFIGURE_OPTIONS += -Dorc=enabled
CONFIGURE_OPTIONS += -Dpackage-origin="https://github.com/OpenIndiana/oi-userland"
CONFIGURE_OPTIONS += -Dgpl=enabled

# Auto-generated dependencies
REQUIRED_PACKAGES += library/audio/gstreamer
REQUIRED_PACKAGES += library/audio/gstreamer/plugin/base
REQUIRED_PACKAGES += library/audio/liba52
REQUIRED_PACKAGES += library/audio/libcdio
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/video/libdvdread
REQUIRED_PACKAGES += library/video/libmpeg2
REQUIRED_PACKAGES += library/video/x264
REQUIRED_PACKAGES += system/library

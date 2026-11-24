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

# Showtime 48.1, GNOME's video player (GNOME 48 release; 49 and later need
# GTK 4.18 and libadwaita 1.8, OpenIndiana has 4.16 and 1.6). Python,
# PyGObject, GTK 4, libadwaita and GstPlay; the picture comes from
# gtk4paintablesink (multimedia/gst-plugins-rs here), hardware decoding from
# gst-plugins-bad's va plugin.  OpenIndiana's PyGObject is for Python 3.9
# only, Showtime is written for 3.10: patches/01-python39.patch.

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		showtime
HUMAN_VERSION=		48.1
COMPONENT_REVISION=	1
COMPONENT_SUMMARY=	Showtime - GNOME video player
COMPONENT_PROJECT_URL=	https://gitlab.gnome.org/GNOME/showtime
COMPONENT_ARCHIVE_HASH=	\
	sha256:1b22202dbe540440797d5a065030c29c242b210e3d4ec5ceb42e320ecc544ab9
COMPONENT_FMRI=		media/showtime
COMPONENT_CLASSIFICATION=	Applications/Sound and Video
COMPONENT_LICENSE=	GPL-3.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/showtime/48/showtime-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Dprofile=release

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

# #!/usr/bin/python3 -> $(PYTHON) (3.9, where PyGObject is)
PYTHON_SCRIPTS +=	usr/bin/showtime

# meson installs the modules with install_data, without byte-compiling them;
# the manifest transforms expect a .pyc for each .py
COMPONENT_POST_INSTALL_ACTION += \
	$(RM) -r $(PROTO_DIR)/usr/lib/python$(PYTHON_VERSION)/site-packages/showtime/__pycache__ \
	    $(PROTO_DIR)/usr/lib/python$(PYTHON_VERSION)/site-packages/showtime/logging/__pycache__; \
	$(PYTHON) -m compileall -q -s $(PROTO_DIR) -p / $(PROTO_DIR)/usr/lib/python$(PYTHON_VERSION)/site-packages/showtime;

# build dependency (blueprint UI files)
REQUIRED_PACKAGES += developer/blueprint-compiler
# Auto-generated dependencies
REQUIRED_PACKAGES.python += library/python/pygobject
REQUIRED_PACKAGES.python += runtime/python

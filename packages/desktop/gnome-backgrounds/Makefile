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

# GNOME's wallpapers, 47.0 (Solaris 11.4: 41.0 plus Solaris branding, which
# OpenIndiana replaces with its own os-backgrounds). Images and the
# background XML files for GNOME Settings only.

BUILD_BITS=		NO_ARCH
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-backgrounds
HUMAN_VERSION=		47.0
COMPONENT_SUMMARY=	GNOME default wallpapers
COMPONENT_PROJECT_URL=	https://gitlab.gnome.org/GNOME/gnome-backgrounds
COMPONENT_ARCHIVE_HASH=	\
	sha256:874a4a39c4261736f6a854722833400b612441c4681aa5982d90b15abc9c91fd
COMPONENT_FMRI=		image/gnome-backgrounds
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Theming
COMPONENT_LICENSE=	CC-BY-SA-3.0
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/gnome-backgrounds/47/gnome-backgrounds-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"


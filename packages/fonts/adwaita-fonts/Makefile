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

# Adwaita Sans and Adwaita Mono, GNOME's interface and monospace fonts since
# GNOME 48: org.gnome.desktop.interface font-name 'Adwaita Sans 11' and
# monospace-font-name 'Adwaita Mono 11' (gsettings-desktop-schemas 50.1 on
# OI).  Without them fontconfig falls back to some other font, and
# gnome-terminal looks broken.  50.0 matches the schemas; SIL OFL 1.1.
# patches/01-fontsdir.patch: into /usr/share/fonts/TrueType/adwaita like
# OI's other fonts (upstream installs to <datadir>/fonts/Adwaita).

BUILD_BITS=		NO_ARCH
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		adwaita-fonts
HUMAN_VERSION=		50.0
COMPONENT_SUMMARY=	Adwaita Sans and Adwaita Mono, the GNOME interface fonts
COMPONENT_PROJECT_URL=	https://gitlab.gnome.org/GNOME/adwaita-fonts
COMPONENT_ARCHIVE_HASH=	\
	sha256:4c927fbfeec1c503801ba510c2c94e0054c82c522cf7ba0d3be5d4d41fcf5c86
COMPONENT_FMRI=		system/font/truetype/adwaita
COMPONENT_CLASSIFICATION=	System/Fonts
COMPONENT_LICENSE=	OFL-1.1
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/$(COMPONENT_NAME)/$(firstword $(subst ., ,$(HUMAN_VERSION)))/$(COMPONENT_NAME)-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

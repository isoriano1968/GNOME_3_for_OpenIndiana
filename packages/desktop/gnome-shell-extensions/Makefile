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

# GNOME Shell Extensions 45.2, the extensions GNOME itself maintains for
# Shell 45 (upstream's "default" set: Removable Drive Menu, Places, Apps
# menu, Window List, ...).  Removable Drive Menu is the Shell's eject
# button: plain GNOME 45 shows mounted USB disks nowhere in the top bar.
# files/20_gnome-shell-extensions.gschema.override turns it on by default
# (see docs/removable-media-eject.md).  No GNOME Classic session
# (classic_mode stays off).

BUILD_BITS=		NO_ARCH
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-shell-extensions
HUMAN_VERSION=		45.2
COMPONENT_SUMMARY=	GNOME Shell Extensions - extensions maintained by the GNOME project
COMPONENT_ARCHIVE_HASH=	\
	sha256:ee32f6387a2d18adbff7a956689bc747866b4a8712d73790c002abeae4ccaaaf
COMPONENT_FMRI=		gnome/gnome-shell/extensions
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Sessions
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CONFIGURE_OPTIONS +=	-Dextension_set=default
CONFIGURE_OPTIONS +=	-Dclassic_mode=false

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

COMPONENT_POST_INSTALL_ACTION += \
	$(INSTALL) -m 0444 \
	    $(COMPONENT_DIR)/files/20_gnome-shell-extensions.gschema.override \
	    $(PROTO_DIR)/usr/share/glib-2.0/schemas/ ;

# Run-time
REQUIRED_PACKAGES += gnome/gnome-shell

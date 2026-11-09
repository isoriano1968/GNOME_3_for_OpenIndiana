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

# gnome-settings-daemon 45.1 as in Solaris 11.4 (solaris-userland
# components/gnome/gnome-settings-daemon @9d7a655), X11 only, with Solaris'
# patches (02-rpath: NSS in /usr/lib/mps/64, as on OI).

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-settings-daemon
HUMAN_VERSION=		45.1
COMPONENT_SUMMARY=	GNOME Settings Daemon
COMPONENT_ARCHIVE_HASH=	\
	sha256:c62bfec9817eee5b83ebe901a9286189a67eb5ff033c5dd41506574f822bf090
COMPONENT_FMRI=		gnome/gnome-settings-daemon
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Sessions
COMPONENT_LICENSE=	GPL-2.0-or-later AND LGPL-2.1-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	--sysconfdir=$(ETCDIR)
CONFIGURE_OPTIONS +=	-Dgudev=false
CONFIGURE_OPTIONS +=	-Dnetwork_manager=false
CONFIGURE_OPTIONS +=	-Drfkill=false
CONFIGURE_OPTIONS +=	-Dwayland=false
CONFIGURE_OPTIONS +=	-Dwwan=false
CONFIGURE_OPTIONS +=	-Dudev_dir=''
CONFIGURE_OPTIONS +=	-Dsystemd=false
CONFIGURE_OPTIONS +=	-Dalsa=false

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += gnome/config/gsettings-desktop-schemas
REQUIRED_PACKAGES += library/audio/pulseaudio
REQUIRED_PACKAGES += library/desktop/geoclue
REQUIRED_PACKAGES += library/desktop/geocode-glib-2
REQUIRED_PACKAGES += library/desktop/gnome-desktop
REQUIRED_PACKAGES += library/desktop/gtk3
REQUIRED_PACKAGES += library/desktop/libgweather
REQUIRED_PACKAGES += library/desktop/xdg/libcanberra
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/gnome/gcr-4
REQUIRED_PACKAGES += library/libnotify
REQUIRED_PACKAGES += library/print/cups-libs
REQUIRED_PACKAGES += service/image/colord
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += system/library/mozilla-nss
REQUIRED_PACKAGES += system/library/polkit
REQUIRED_PACKAGES += system/upower
REQUIRED_PACKAGES += library/desktop/p11-kit
REQUIRED_PACKAGES += system/library/fontconfig
REQUIRED_PACKAGES += x11/library/libx11
REQUIRED_PACKAGES += x11/library/libxext
REQUIRED_PACKAGES += x11/library/libxfixes
REQUIRED_PACKAGES += x11/library/libxi

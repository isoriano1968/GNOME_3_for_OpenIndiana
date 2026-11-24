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

# GNOME Flashback 3.50.0: the GNOME 3 session without GNOME Shell (and so
# without SpiderMonkey and a GL compositor), with gnome-panel and Metacity,
# on our gnome-session 45 and gnome-settings-daemon 45 (ConsoleKit, X11).
# patches/01-systemd-optional.patch: libsystemd only routes started
# programs' output to the journal and finds the logind session; it becomes
# optional.  Session files for a ConsoleKit session (no systemd user
# session); no Compiz session.

BUILD_BITS=		64
BUILD_STYLE=		configure

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-flashback
HUMAN_VERSION=		3.50.0
COMPONENT_SUMMARY=	GNOME Flashback, the GNOME session without GNOME Shell
COMPONENT_ARCHIVE_HASH=	\
	sha256:d04c434822022c9fa7e60874e5c8cd2060c8f3c0703c19f2b4032be254272afe
COMPONENT_FMRI=		gnome/gnome-flashback
# 1: /etc/pam.d/gnome-flashback for the screen lock
COMPONENT_REVISION=	1
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Sessions
COMPONENT_LICENSE=	GPL-3.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

# illumos: the strict standard mode hides stack_t etc. that system headers
# (libgtop's procfs, kvm) need; -D_REENTRANT for GLib's per-thread errno
CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS -D_REENTRANT

# the patch changes configure.ac and Makefile.am files
COMPONENT_PREP_ACTION +=	(cd $(@D) && PATH="$(PATH)" $(AUTORECONF) -fi) ;

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"
CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	--disable-static
CONFIGURE_OPTIONS +=	--without-systemd
CONFIGURE_OPTIONS +=	--disable-systemd-session
CONFIGURE_OPTIONS +=	--without-compiz-session

# the screen lock needs a PAM service file (files/gnome-flashback.pam)
COMPONENT_POST_INSTALL_ACTION += \
	$(MKDIR) $(PROTO_DIR)/etc/pam.d ; \
	$(INSTALL) -m 0644 $(COMPONENT_DIR)/files/gnome-flashback.pam \
	    $(PROTO_DIR)/etc/pam.d/gnome-flashback ;
# Auto-generated dependencies
REQUIRED_PACKAGES += gnome/accessibility/at-spi2-core
REQUIRED_PACKAGES += gnome/gnome-panel
REQUIRED_PACKAGES += library/audio/pulseaudio
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/gnome-desktop
REQUIRED_PACKAGES += library/desktop/gtk3
REQUIRED_PACKAGES += library/desktop/libgdm
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += library/desktop/xdg/libcanberra
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += shell/ksh93
REQUIRED_PACKAGES += system/input-method/ibus
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += system/library/polkit
REQUIRED_PACKAGES += x11/library/libx11
REQUIRED_PACKAGES += x11/library/libxcb
REQUIRED_PACKAGES += x11/library/libxext
REQUIRED_PACKAGES += x11/library/libxfixes
REQUIRED_PACKAGES += x11/library/libxi
REQUIRED_PACKAGES += x11/library/libxkbfile
REQUIRED_PACKAGES += x11/library/libxrandr
REQUIRED_PACKAGES += x11/library/libxxf86vm

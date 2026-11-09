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

# gdm 45.0.1 as in Solaris 11.4 (solaris-userland components/gnome/gdm
# @9d7a655, with all 29 of its patches, which the gdm sources need on
# illumos).  Two packages:
#   library/desktop/libgdm       libgdm, Gdm-1.0 GIR/typelib, headers and the
#                                org.gnome.login-screen schema (gnome-shell's
#                                login and unlock dialogs need them);
#   system/display-manager/gdm   the display manager: daemon, session
#                                worker, greeter session, SMF service
#                                (installed disabled next to lightdm).
# OpenIndiana differences (patches 0030-0032):
#   - the greeter's PAM service: Solaris uses user_attr pam_policy, which
#     illumos lacks; the greeter uses OI's existing gdm-autologin stack;
#   - ConsoleKit's ck-get-x11-display-device is in /usr/libexec on OI;
#   - PAM_TTY for every session without systemd (illumos pam_unix_session
#     needs it; 0032);
#   - the gdm user and group (uid/gid 50) already come with OI (SUNWcs), so
#     the manifest does not create them.

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gdm
HUMAN_VERSION=		45.0.1
COMPONENT_SUMMARY=	GNOME Display Manager (GDM)
COMPONENT_ARCHIVE_HASH=	\
	sha256:6572578c05e3c6569d6ed269f7de2aaf3a035657654586d8243907bb7a6ffa85
COMPONENT_FMRI=		system/display-manager/gdm
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Sessions
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	gdm.license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/gdm/45/gdm-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS
# Solaris' gdm patches use Solaris' non-const PAM prototypes; illumos has
# both and gives these with _PAM_LEGACY_NONCONST.
CFLAGS +=		-D_PAM_LEGACY_NONCONST
# bind() & co. (XDMCP) are in libsocket/libnsl on illumos
LDFLAGS +=		-lsocket -lnsl

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBDIR)/gdm
CONFIGURE_OPTIONS +=	--sysconfdir=$(ETCDIR)
CONFIGURE_OPTIONS +=	--localstatedir=$(VARDIR)
CONFIGURE_OPTIONS +=	-Dsolaris=true
CONFIGURE_OPTIONS +=	-Dselinux=disabled
CONFIGURE_OPTIONS +=	-Dipv6=true
CONFIGURE_OPTIONS +=	-Dgdm-xsession=true
CONFIGURE_OPTIONS +=	-Dlibaudit=disabled
CONFIGURE_OPTIONS +=	-Dsystemdsystemunitdir=no
CONFIGURE_OPTIONS +=	-Dsystemduserunitdir=no
CONFIGURE_OPTIONS +=	-Dsystemd-journal=false
CONFIGURE_OPTIONS +=	-Dwayland-support=false
CONFIGURE_OPTIONS +=	-Dplymouth=disabled
CONFIGURE_OPTIONS +=	-Dgroup=gdm
CONFIGURE_OPTIONS +=	-Ddefault-path='$(USRBINDIR):$(USRSBINDIR)'
CONFIGURE_OPTIONS +=	-Dxauth-dir=/tmp
CONFIGURE_OPTIONS +=	-Dinitial-vt=7

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"
COMPONENT_BUILD_ENV +=	PATH="$(GNUBIN):$(PATH)"
COMPONENT_INSTALL_ENV +=	PATH="$(GNUBIN):$(PATH)"

# SMF service (disabled; lightdm stays the display manager until switched)
COMPONENT_POST_INSTALL_ACTION += \
	$(INSTALL) -D -m 0444 $(COMPONENT_DIR)/files/gdm.xml \
	    $(PROTO_DIR)/lib/svc/manifest/application/graphical-login/gdm.xml ; \
	$(INSTALL) -D -m 0555 $(COMPONENT_DIR)/files/svc-gdm \
	    $(PROTO_DIR)/lib/svc/method/svc-gdm ;

REQUIRED_PACKAGES += library/desktop/gobject/gobject-introspection
REQUIRED_PACKAGES += text/itstool
REQUIRED_PACKAGES += library/desktop/gtk3
REQUIRED_PACKAGES += library/desktop/xdg/libcanberra
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/xdg/consolekit
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/accountsservice
REQUIRED_PACKAGES += SUNWcs
REQUIRED_PACKAGES += shell/ksh93
REQUIRED_PACKAGES += system/library/dbus
REQUIRED_PACKAGES += x11/server/xorg
REQUIRED_PACKAGES += x11/library/libx11
REQUIRED_PACKAGES += x11/library/libxau
REQUIRED_PACKAGES += x11/library/libxcb
REQUIRED_PACKAGES += x11/library/libxdmcp
REQUIRED_PACKAGES += gnome/gnome-session
REQUIRED_PACKAGES += gnome/gnome-shell
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += system/library/fontconfig

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

# HAL's hal-storage-mount and hal-storage-unmount from illumos-gate with
# patches/0001-NNNNN-hal-storage-tools-treat-FUSE-mounts-ntfs-3g-as.patch
# (the same file as ports/hal-fuse-mounts/upstream, the illumos-gate
# submission).  hald matches mnttab entries to volumes by device number,
# which a FUSE mount (ntfs-3g, exfat) does not carry, so HAL never sees such
# a volume as mounted: Unmount() fails ("According to HAL, the volume is not
# mounted"), so the desktop's eject button fails, and Mount() mounts a
# mounted NTFS partition a second time.  The patch makes both tools look for
# the device name in mnttab as well (ntfs-3g records /dev/dsk names with
# system/file-system/ntfsprogs 2026.9.28 revision 1 from oi-gnome).
# Installed as /usr/lib/hal/oi/hal-storage-{mount,unmount}, next to
# illumos' own in /usr/lib/hal; hald runs them once HALD_RUNNER_PATH is
# /usr/lib/hal/oi (see system/hal/probe-storage-gpt).  32-bit like illumos'
# own (libpolkit is 32-bit only on OpenIndiana).

BUILD_BITS=		32
BUILD_STYLE=		justmake

include ../../../make-rules/shared-macros.mk

ILLUMOS_COMMIT=		b1c424a261b16b9c81280c0eb6de8b2f9f4ffacb

COMPONENT_NAME=		hal-storage-fuse
COMPONENT_VERSION=	0.5.8.1
COMPONENT_SUMMARY=	HAL mount and unmount helpers that recognize FUSE mounts (illumos hal-storage-*, patched)
COMPONENT_PROJECT_URL=	https://illumos.org/
COMPONENT_SRC=		illumos-gate-$(ILLUMOS_COMMIT)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	\
	sha256:6ab3fc7adbad261af3c3f6a967c2588758ce1c13b2f786cf524714bd0c345d64
COMPONENT_ARCHIVE_URL=	https://github.com/illumos/illumos-gate/archive/$(ILLUMOS_COMMIT).tar.gz
COMPONENT_FMRI=		system/hal/storage-fuse
COMPONENT_CLASSIFICATION=	System/Hardware
COMPONENT_LICENSE=	AFL-2.1 OR GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/common.mk

HAL_SRC=		$(SOURCE_DIR)/usr/src/cmd/hal
HAL_CPPFLAGS=		-DPACKAGE_DATA_DIR=\"/usr/share\" \
			-DPACKAGE_BIN_DIR=\"/usr/bin\" \
			-DPACKAGE_LIBEXEC_DIR=\"/usr/lib/hal\" \
			-DPACKAGE_SCRIPT_DIR=\"/usr/lib/hal\" \
			-DPACKAGE_LOCALSTATEDIR=\"/var\" \
			-DPACKAGE_SYSCONF_DIR=\"/etc\" \
			-DPACKAGE_VERSION=\"0.5.8\" \
			-DHAVE_POLKIT -DDBUS_API_SUBJECT_TO_CHANGE -Dsun \
			-I/usr/include/dbus-1.0 -I/usr/lib/dbus-1.0/include \
			-I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include \
			-I/usr/include/hal -I/usr/include/libpolkit \
			-I$(HAL_SRC)/utils -I$(HAL_SRC)/tools -I$(HAL_SRC)/hald
HAL_LIBS=		-ldbus-1 -lglib-2.0 -lhal -lhal-storage -lbsm -lpolkit

COMPONENT_BUILD_ACTION = \
	$(MKDIR) $(@D) ; \
	for p in mount unmount ; do \
	    $(CC) $(CC_BITS) -std=gnu99 $(CFLAGS) $(HAL_CPPFLAGS) \
		-o $(@D)/hal-storage-$$p $(HAL_SRC)/tools/hal-storage-$$p.c \
		$(HAL_SRC)/tools/hal-storage-shared.c $(HAL_SRC)/utils/adt_data.c \
		$(LDFLAGS) $(HAL_LIBS) || exit 1 ; \
	done

COMPONENT_INSTALL_ACTION = \
	$(INSTALL) -D -m 0555 $(BUILD_DIR_32)/hal-storage-mount \
	    $(PROTO_DIR)/usr/lib/hal/oi/hal-storage-mount ; \
	$(INSTALL) -D -m 0555 $(BUILD_DIR_32)/hal-storage-unmount \
	    $(PROTO_DIR)/usr/lib/hal/oi/hal-storage-unmount

REQUIRED_PACKAGES += library/glib2/32
REQUIRED_PACKAGES += service/hal
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/libdbus/32
REQUIRED_PACKAGES += system/library/policykit
REQUIRED_PACKAGES += system/library/libdbus

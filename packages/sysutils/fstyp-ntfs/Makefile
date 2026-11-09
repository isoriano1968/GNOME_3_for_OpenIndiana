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

# libfstyp module for NTFS (files/fstyp-ntfs.c, our own code), installed as
# /usr/lib/fs/ntfs-3g/fstyp.so.1.  ntfsprogs ships only a shell script as
# /usr/lib/fs/ntfs-3g/fstyp: fstyp(8) runs it, but libfstyp, which HAL's
# hald-probe-volume uses, loads only fstyp.so.1 modules, so HAL never
# identified NTFS volumes ("fstyp ident or get_attr failed").  32-bit like
# hald-probe-volume and illumos' own modules (pcfs, hsfs ...).  Read-only:
# boot sector plus the $Volume record for label, version and clean flag.

BUILD_BITS=		32
BUILD_STYLE=		pkg

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		fstyp-ntfs
COMPONENT_VERSION=	1.0
COMPONENT_SUMMARY=	libfstyp module for NTFS (lets HAL identify NTFS volumes)
COMPONENT_PROJECT_URL=	https://github.com/isoriano1968/GNOME_3_for_OpenIndiana
COMPONENT_FMRI=		system/file-system/fstyp-ntfs
COMPONENT_CLASSIFICATION=	System/File System
COMPONENT_LICENSE=	CDDL-1.0
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

include $(WS_MAKE_RULES)/common.mk

COMPONENT_POST_INSTALL_ACTION += \
	$(MKDIR) $(BUILD_DIR_32) ; \
	$(CC) $(CC_BITS) $(CFLAGS) -shared -fPIC -Wall \
	    -o $(BUILD_DIR_32)/fstyp.so.1 $(COMPONENT_DIR)/files/fstyp-ntfs.c \
	    $(LDFLAGS) -lnvpair -lc ; \
	$(INSTALL) -D -m 0555 $(BUILD_DIR_32)/fstyp.so.1 \
	    $(PROTO_DIR)/usr/lib/fs/ntfs-3g/fstyp.so.1 ;

REQUIRED_PACKAGES += system/file-system/ntfsprogs
REQUIRED_PACKAGES += system/library

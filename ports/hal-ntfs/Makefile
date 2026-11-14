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

# hal-ntfs: OpenIndiana's service/hal with the removable-media fixes of
# branch hal-ntfs (patches/0001-0004, illumos-gate submissions):
#
#   0001 hal ignores NTFS partitions on MBR disks (is_dos_drive lacks FDISK_IFS)
#   0002 hal cannot automount or unmount NTFS (ntfs-3g) partitions on MBR disks
#   0003 hal never mounts volumes on GPT disks (probe-storage leaves
#        vtoc_slices FALSE)
#   0004 hald does not see FUSE mounts of whole-slice volumes (match
#        block.device too)
#   0005 hal automounts EFI system partitions (volume.partition.type for
#        GPT + an ignore rule in 20-storage-methods.fdi)
#   0006 hal offers ZFS pool members (rpool) as volumes (ignore rule)
#
# Pristine source: the illumos-gate snapshot the installed OS build was made
# from (pkg contents -m service/hal: illumos-gate.info.git-rev).  The eleven
# programs these patches change are rebuilt out of tree, 32-bit as
# OpenIndiana ships them (a 64-bit HAL needs 64-bit libfstyp plugins and
# libpolkit first: notes/macpro-2013/open-topics-2026-11-13.md, 2.4), with the
# flags of usr/src/cmd/hal/Makefile.hal.  Everything else of the package
# (fdi files, scripts, SMF manifests, licences, dependencies) is
# OpenIndiana's own service/hal of that OS build, fetched with pkgrecv --raw.
# The package is service/hal at $(OSNET_VERSION).1 in our publisher, so pkg
# replaces the stock one and an osnet update stops until this is rebuilt.
#
#   gmake / gmake check / gmake publish / gmake clean   (GNU make, on OI)
#
# For a new OS build: set OSNET_VERSION and GATE_COMMIT (from pkg contents -m
# service/hal), the archive hash, then gmake clean publish.

COMPONENT_NAME=		hal-ntfs
OSNET_VERSION=		0.5.11,5.11-2026.0.0.23395
GATE_COMMIT=		586678ac1bcbd77644a6ec4dac7f79d676cfb4ec
COMPONENT_SRC=		illumos-gate-$(GATE_COMMIT)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	\
	sha256:ad278ac9dcb58e92e0a441a5a302c25692ca4c1ee435d7464b79858c04e40acf
COMPONENT_ARCHIVE_URL=	\
	https://github.com/illumos/illumos-gate/archive/$(GATE_COMMIT).tar.gz
# The publication installed on that build (pkg list -v service/hal).
PKG_TIMESTAMP=		20261110T223555Z
OI_REPO=		https://pkg.openindiana.org/hipster/
# .1: patches 0001-0004; .2: + 0005 (EFI system partitions ignored);
# .3: + 0006 (ZFS pool members ignored)
PKG_VERSION=		$(OSNET_VERSION).3
GATE_SHORT=		$(shell echo $(GATE_COMMIT) | cut -c1-10)

ARCHIVE_DIR?=		$(HOME)/src/oi-userland/archives
BUILD_DIR=		$(CURDIR)/build
SRC_DIR=		$(BUILD_DIR)/$(COMPONENT_SRC)
S=			$(SRC_DIR)/usr/src
H=			$(S)/cmd/hal
OUT=			$(BUILD_DIR)/bin
RAW_DIR=		$(BUILD_DIR)/raw
PROTO=			$(BUILD_DIR)/proto
REPO?=			$(HOME)/oi-repo
GTAR=			/usr/bin/gtar
GPATCH=			/usr/bin/gpatch

# usr/src/cmd/hal/Makefile.hal (HAL_CONFIG/DBUS/GLIB_CPPFLAGS), CSTD_GNU99,
# 32-bit; the gate's CERRWARN for hal as -Wno-* (no -Werror out of tree).
CC=		/usr/gcc/14/bin/gcc -m32 -std=gnu99 -O2
CWARN=		-Wall -Wno-unused-variable -Wno-unused-value -Wno-parentheses \
		-Wno-address -Wno-unused-function -Wno-pointer-sign
CPPFLAGS=	-DPACKAGE_DATA_DIR='"/usr/share"' \
		-DPACKAGE_OLD_DATA_DIR='"/usr/lib"' \
		-DPACKAGE_BIN_DIR='"/usr/bin"' \
		-DPACKAGE_LIBEXEC_DIR='"/usr/lib/hal"' \
		-DPACKAGE_SCRIPT_DIR='"/usr/lib/hal"' \
		-DPACKAGE_LOCALSTATEDIR='"/var"' \
		-DPACKAGE_SYSCONF_DIR='"/etc"' \
		-DPACKAGE_LOCALE_DIR='"/usr/lib/locale"' \
		-DPACKAGE_VERSION='"0.5.8"' \
		-DPACKAGE_STRING='"hal 0.5.8"' \
		-DHALD_PID_FILE='"/var/run/hald/pid"' \
		-DHALD_SOCKET_DIR='"/var/run/hald"' \
		-DHAVE_ASPRINTF -DHAVE_POLKIT \
		-DHWDATA_DIR='"/usr/share/hwdata"' \
		-DHAL_USER='"daemon"' -DHAL_GROUP='"daemon"' \
		-DDBUS_API_SUBJECT_TO_CHANGE \
		-DDBUS_SYSTEMD_DIR='"/etc/dbus-1/system.d"' \
		-DTEXT_DOMAIN='"SUNW_OST_OSCMD"' \
		-I/usr/include/dbus-1.0 -I/usr/lib/dbus-1.0/include \
		-I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include \
		-I/usr/include/hal -I/usr/include/libpolkit \
		-I$(H)/hald -I$(H)/hald/solaris -I$(H)/utils -I$(H)/tools
# <sys/hexdump.h>, <sys/ilstr.h>: kernel-private headers that system/header
# does not ship; taken from the same snapshot, searched after /usr/include.
CPPFLAGS+=	-idirafter $(S)/uts/common

HALD_SRCS=	hald_marshal.c device.c device_info.c device_store.c hald.c \
		hald_dbus.c hald_runner.c ids.c logger.c property.c util.c \
		util_helper.c util_pm.c solaris/devinfo.c \
		solaris/devinfo_ieee1394.c solaris/devinfo_misc.c \
		solaris/devinfo_pci.c solaris/devinfo_storage.c \
		solaris/devinfo_usb.c solaris/hotplug.c solaris/osspec.c \
		solaris/sysevent.c solaris/devinfo_acpi.c solaris/devinfo_cpu.c
HALD_LIBS=	-lc -lm -ldbus-1 -ldbus-glib-1 -lglib-2.0 -lgobject-2.0 \
		-ldevinfo -lsysevent -lnvpair -lkstat -lcfgadm -lexpat
STORAGE_LIBS=	-lc -ldbus-1 -lglib-2.0 -lhal -lhal-storage -lbsm
METHOD_PROGS=	hal-storage-closetray hal-storage-eject hal-storage-mount \
		hal-storage-unmount
CLEANUP_PROGS=	hal-storage-cleanup-mountpoint \
		hal-storage-cleanup-all-mountpoints
PROGS=		hald hald-probe-storage hald-probe-volume $(METHOD_PROGS) \
		hal-storage-zpool-export hal-storage-zpool-import $(CLEANUP_PROGS)

all: $(BUILD_DIR)/.built

$(ARCHIVE_DIR)/$(COMPONENT_ARCHIVE):
	mkdir -p $(ARCHIVE_DIR)
	/usr/bin/curl -fL -o $@.part $(COMPONENT_ARCHIVE_URL)
	mv $@.part $@

$(BUILD_DIR)/.unpacked: $(ARCHIVE_DIR)/$(COMPONENT_ARCHIVE)
	test "sha256:`/usr/bin/digest -a sha256 $<`" = \
	    "$(COMPONENT_ARCHIVE_HASH)" || \
	    { echo "$<: wrong sha256" >&2; exit 1; }
	rm -rf $(SRC_DIR)
	mkdir -p $(BUILD_DIR)
	$(GTAR) -xzf $< -C $(BUILD_DIR) \
	    $(COMPONENT_SRC)/usr/src/cmd/hal \
	    $(COMPONENT_SRC)/usr/src/common/hexdump \
	    $(COMPONENT_SRC)/usr/src/common/ilstr \
	    $(COMPONENT_SRC)/usr/src/uts/common/sys/hexdump.h \
	    $(COMPONENT_SRC)/usr/src/uts/common/sys/ilstr.h
	touch $@

$(BUILD_DIR)/.patched: $(BUILD_DIR)/.unpacked $(wildcard patches/*.patch)
	for p in patches/*.patch; do \
		echo "== $$p"; \
		$(GPATCH) -d $(SRC_DIR) -p1 -N --no-backup-if-mismatch < $$p || exit 1; \
	done
	touch $@

$(BUILD_DIR)/.built: $(BUILD_DIR)/.patched
	mkdir -p $(OUT)
	cd $(H)/hald && \
	    glib-genmarshal --prefix=hald_marshal hald_marshal.list --header > hald_marshal.h && \
	    glib-genmarshal --prefix=hald_marshal hald_marshal.list --body > hald_marshal.c && \
	    $(CC) $(CWARN) $(CPPFLAGS) -o $(OUT)/hald $(HALD_SRCS) \
		$(S)/common/hexdump/hexdump.c $(S)/common/ilstr/ilstr.c $(HALD_LIBS)
	cd $(H)/probing/storage && \
	    $(CC) $(CWARN) $(CPPFLAGS) -o $(OUT)/hald-probe-storage probe-storage.c \
		$(H)/utils/cdutils.c $(H)/utils/fsutils.c $(H)/hald/logger.c \
		-lc -ldbus-1 -lhal -ladm -lefi
	cd $(H)/probing/volume && \
	    $(CC) $(CWARN) $(CPPFLAGS) -o $(OUT)/hald-probe-volume probe-volume.c \
		$(H)/utils/cdutils.c $(H)/utils/fsutils.c $(H)/hald/logger.c \
		-lc -ldbus-1 -lhal -lfstyp -lnvpair -ladm -lefi
	cd $(H)/tools && for p in $(METHOD_PROGS); do \
	    $(CC) $(CWARN) $(CPPFLAGS) -o $(OUT)/$$p $$p.c hal-storage-shared.c \
		$(H)/utils/adt_data.c $(STORAGE_LIBS) -lpolkit || exit 1; \
	done
	cd $(H)/tools && for c in export import; do \
	    $(CC) $(CWARN) $(CPPFLAGS) -DZPOOL_SUBCMD="\"$$c\"" \
		-o $(OUT)/hal-storage-zpool-$$c hal-storage-zpool.c \
		hal-storage-shared.c $(H)/utils/adt_data.c \
		$(STORAGE_LIBS) -lpolkit || exit 1; \
	done
	cd $(H)/tools && for p in $(CLEANUP_PROGS); do \
	    $(CC) $(CWARN) $(CPPFLAGS) -o $(OUT)/$$p $$p.c hal-storage-shared.c \
		$(H)/utils/adt_data.c $(STORAGE_LIBS) || exit 1; \
	done
	touch $@

FDI=		etc/hal/fdi/policy/10osvendor/20-storage-methods.fdi

# Each program must resolve all its libraries on this system.
check: $(BUILD_DIR)/.built
	@for p in $(PROGS); do \
		/usr/bin/file $(OUT)/$$p | grep -q "ELF 32-bit" || \
		    { echo "$$p: not a 32-bit ELF"; exit 1; }; \
		if /usr/bin/ldd $(OUT)/$$p | grep "not found"; then \
		    echo "$$p: unresolved library"; exit 1; fi; \
	done
	@echo "check: $(words $(PROGS)) programs, 32-bit, all libraries found"

# OpenIndiana's service/hal of this OS build: its manifest and payloads.
$(BUILD_DIR)/.raw:
	rm -rf $(RAW_DIR)
	mkdir -p $(RAW_DIR)
	/usr/bin/pkgrecv -s $(OI_REPO) --raw -d $(RAW_DIR) \
	    service/hal@$(OSNET_VERSION):$(PKG_TIMESTAMP)
	test `ls -d $(RAW_DIR)/service%2Fhal/* | wc -l` -eq 1
	touch $@

# The manifest: OpenIndiana's, with our version, the rebuilt programs taken
# from $(PROTO) by path (hashes dropped), and the fstyp-ntfs dependency (HAL
# identifies NTFS through libfstyp's ntfs-3g module).
publish: check $(BUILD_DIR)/.raw
	rm -rf $(PROTO)
	mkdir -p $(PROTO)/usr/lib/hal
	for p in $(PROGS); do cp $(OUT)/$$p $(PROTO)/usr/lib/hal/$$p; done
	mkdir -p $(PROTO)/`dirname $(FDI)`
	cp $(H)/fdi/policy/10osvendor/20-storage-methods.fdi $(PROTO)/$(FDI)
	m=`ls -d $(RAW_DIR)/service%2Fhal/*/manifest` && \
	/usr/bin/perl ../oi-republish-manifest.pl --version "$(PKG_VERSION)" \
	    --human "$(GATE_SHORT)+hal-ntfs" \
	    --what "the NTFS, GPT, FUSE and EFI automount fixes of branch hal-ntfs" \
	    --replace "$(PROGS:%=usr/lib/hal/%) $(FDI)" \
	    --depend system/file-system/fstyp-ntfs < $$m > $(BUILD_DIR)/manifest
	/usr/bin/pkglint $(BUILD_DIR)/manifest
	r=`ls -d $(RAW_DIR)/service%2Fhal/*` && \
	/usr/bin/pkgsend -s $(REPO) publish -d $(PROTO) -d $$r \
	    --fmri-in-manifest $(BUILD_DIR)/manifest

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all check clean publish

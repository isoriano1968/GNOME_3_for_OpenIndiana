/*
 * This file and its contents are supplied under the terms of the
 * Common Development and Distribution License ("CDDL"), version 1.0.
 * You may only use this file in accordance with the terms of version
 * 1.0 of the CDDL.
 *
 * A full copy of the text of the CDDL should have accompanied this
 * source.  A copy of the CDDL is also available via the Internet at
 * http://www.illumos.org/license/CDDL.
 */

/*
 * Copyright 2026 isoriano1968
 */

/*
 * libfstyp module for NTFS, installed as /usr/lib/fs/ntfs-3g/fstyp.so.1 so
 * that the type is called "ntfs-3g" (the name `mount -F` needs).
 *
 * ntfsprogs ships only a shell script as /usr/lib/fs/ntfs-3g/fstyp, which
 * the fstyp(8) command runs but libfstyp (and so HAL's hald-probe-volume)
 * does not: without this module HAL never identifies an NTFS volume and
 * nothing mounts it.  Self-contained, read-only: it reads the boot sector
 * and the $Volume record (MFT record 3) for the label, version and clean
 * flag.  No libntfs-3g, which OpenIndiana ships 64-bit only while
 * hald-probe-volume is 32-bit.
 */

#include <sys/types.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <libnvpair.h>
#include <libfstyp_module.h>

#define	NTFS_SECTOR	512
#define	NTFS_ATTR_END	0xffffffffU
#define	NTFS_ATTR_VOLUME_NAME	0x60U
#define	NTFS_ATTR_VOLUME_INFO	0x70U
#define	NTFS_VOLUME_IS_DIRTY	0x0001U
#define	NTFS_MAX_RECORD	(64 * 1024)

struct fstyp_ntfs {
	int		fd;
	off64_t		offset;
	nvlist_t	*attr;

	uint16_t	bytes_per_sector;
	uint32_t	cluster_size;
	uint64_t	mft_lcn;
	uint32_t	record_size;
	uint64_t	serial;

	char		label[256];
	int		have_label;
	int		major, minor;
	int		have_version;
	int		dirty;
};

static uint16_t
le16(const uint8_t *p)
{
	return ((uint16_t)(p[0] | (p[1] << 8)));
}

static uint32_t
le32(const uint8_t *p)
{
	return ((uint32_t)p[0] | ((uint32_t)p[1] << 8) |
	    ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24));
}

static uint64_t
le64(const uint8_t *p)
{
	return ((uint64_t)le32(p) | ((uint64_t)le32(p + 4) << 32));
}

static int
read_at(struct fstyp_ntfs *h, off64_t off, void *buf, size_t len)
{
	ssize_t n = pread64(h->fd, buf, len, h->offset + off);

	return (n == (ssize_t)len ? 0 : -1);
}

/* UTF-16LE (BMP and surrogate pairs) to UTF-8 */
static void
utf16le_to_utf8(const uint8_t *in, size_t nchars, char *out, size_t outlen)
{
	size_t i, o = 0;

	for (i = 0; i < nchars; i++) {
		uint32_t c = le16(in + 2 * i);

		if (c >= 0xd800 && c < 0xdc00 && i + 1 < nchars) {
			uint32_t c2 = le16(in + 2 * (i + 1));
			if (c2 >= 0xdc00 && c2 < 0xe000) {
				c = 0x10000 + ((c - 0xd800) << 10) +
				    (c2 - 0xdc00);
				i++;
			}
		}
		if (c < 0x80) {
			if (o + 1 >= outlen)
				break;
			out[o++] = (char)c;
		} else if (c < 0x800) {
			if (o + 2 >= outlen)
				break;
			out[o++] = (char)(0xc0 | (c >> 6));
			out[o++] = (char)(0x80 | (c & 0x3f));
		} else if (c < 0x10000) {
			if (o + 3 >= outlen)
				break;
			out[o++] = (char)(0xe0 | (c >> 12));
			out[o++] = (char)(0x80 | ((c >> 6) & 0x3f));
			out[o++] = (char)(0x80 | (c & 0x3f));
		} else {
			if (o + 4 >= outlen)
				break;
			out[o++] = (char)(0xf0 | (c >> 18));
			out[o++] = (char)(0x80 | ((c >> 12) & 0x3f));
			out[o++] = (char)(0x80 | ((c >> 6) & 0x3f));
			out[o++] = (char)(0x80 | (c & 0x3f));
		}
	}
	out[o] = '\0';
}

/* Read the $Volume record and pick out the label, version and dirty flag. */
static void
read_volume_record(struct fstyp_ntfs *h)
{
	uint8_t *rec;
	uint16_t usa_ofs, usa_count, attrs;
	uint32_t i, pos;
	off64_t off;

	if (h->record_size < NTFS_SECTOR || h->record_size > NTFS_MAX_RECORD)
		return;
	if ((rec = malloc(h->record_size)) == NULL)
		return;
	off = (off64_t)h->mft_lcn * h->cluster_size + 3 * h->record_size;
	if (read_at(h, off, rec, h->record_size) != 0 ||
	    memcmp(rec, "FILE", 4) != 0)
		goto out;

	/* undo the update sequence (fixups) at the end of each sector */
	usa_ofs = le16(rec + 4);
	usa_count = le16(rec + 6);
	if (usa_count < 1 ||
	    usa_ofs + 2 * (uint32_t)usa_count > h->record_size ||
	    (uint32_t)(usa_count - 1) * h->bytes_per_sector > h->record_size)
		goto out;
	for (i = 1; i < usa_count; i++) {
		uint8_t *end = rec + i * h->bytes_per_sector - 2;
		if (memcmp(end, rec + usa_ofs, 2) != 0)
			goto out;
		memcpy(end, rec + usa_ofs + 2 * i, 2);
	}

	attrs = le16(rec + 0x14);
	for (pos = attrs; pos + 0x18 <= h->record_size; ) {
		uint32_t type = le32(rec + pos);
		uint32_t len = le32(rec + pos + 4);
		uint32_t vlen, voff;

		if (type == NTFS_ATTR_END || len < 0x18 ||
		    pos + len > h->record_size)
			break;
		if (rec[pos + 8] == 0) {	/* resident */
			vlen = le32(rec + pos + 0x10);
			voff = le16(rec + pos + 0x14);
			if (voff + vlen > len)
				break;
			if (type == NTFS_ATTR_VOLUME_NAME && vlen > 0) {
				utf16le_to_utf8(rec + pos + voff, vlen / 2,
				    h->label, sizeof (h->label));
				h->have_label = (h->label[0] != '\0');
			} else if (type == NTFS_ATTR_VOLUME_INFO &&
			    vlen >= 12) {
				h->major = rec[pos + voff + 8];
				h->minor = rec[pos + voff + 9];
				h->have_version = 1;
				h->dirty = (le16(rec + pos + voff + 10) &
				    NTFS_VOLUME_IS_DIRTY) != 0;
			}
		}
		pos += len;
	}
out:
	free(rec);
}

int
fstyp_mod_init(int fd, off64_t offset, fstyp_mod_handle_t *handle)
{
	struct fstyp_ntfs *h;

	if ((h = calloc(1, sizeof (struct fstyp_ntfs))) == NULL)
		return (FSTYP_ERR_NOMEM);
	h->fd = fd;
	h->offset = offset;
	*handle = (fstyp_mod_handle_t)h;
	return (0);
}

void
fstyp_mod_fini(fstyp_mod_handle_t handle)
{
	struct fstyp_ntfs *h = (struct fstyp_ntfs *)handle;

	if (h->attr != NULL)
		nvlist_free(h->attr);
	free(h);
}

int
fstyp_mod_ident(fstyp_mod_handle_t handle)
{
	struct fstyp_ntfs *h = (struct fstyp_ntfs *)handle;
	uint8_t bs[NTFS_SECTOR];
	uint8_t spc;
	int8_t cpr;

	if (read_at(h, 0, bs, sizeof (bs)) != 0)
		return (FSTYP_ERR_IO);
	if (memcmp(bs + 3, "NTFS    ", 8) != 0 ||
	    bs[510] != 0x55 || bs[511] != 0xaa)
		return (FSTYP_ERR_NO_MATCH);

	h->bytes_per_sector = le16(bs + 0x0b);
	spc = bs[0x0d];
	if (h->bytes_per_sector < 256 || h->bytes_per_sector > 4096 ||
	    (h->bytes_per_sector & (h->bytes_per_sector - 1)) != 0 ||
	    spc == 0)
		return (FSTYP_ERR_NO_MATCH);
	/* sectors per cluster: values above 0x80 are a negative shift */
	if (spc <= 0x80)
		h->cluster_size = (uint32_t)spc * h->bytes_per_sector;
	else
		h->cluster_size = 1U << (256 - spc);
	h->mft_lcn = le64(bs + 0x30);
	cpr = (int8_t)bs[0x40];
	if (cpr > 0)
		h->record_size = (uint32_t)cpr * h->cluster_size;
	else if (cpr < 0 && cpr > -31)
		h->record_size = 1U << (-cpr);
	else
		return (FSTYP_ERR_NO_MATCH);
	h->serial = le64(bs + 0x48);
	return (0);
}

int
fstyp_mod_get_attr(fstyp_mod_handle_t handle, nvlist_t **attrp)
{
	struct fstyp_ntfs *h = (struct fstyp_ntfs *)handle;
	char buf[64];

	if (h->attr == NULL) {
		if (nvlist_alloc(&h->attr, NV_UNIQUE_NAME_TYPE, 0) != 0)
			return (FSTYP_ERR_NOMEM);
		read_volume_record(h);

		(void) nvlist_add_boolean_value(h->attr, "gen_clean",
		    h->dirty ? B_FALSE : B_TRUE);
		(void) snprintf(buf, sizeof (buf), "%016llX",
		    (unsigned long long)h->serial);
		(void) nvlist_add_string(h->attr, "gen_guid", buf);
		if (h->have_version) {
			(void) snprintf(buf, sizeof (buf), "%d.%d",
			    h->major, h->minor);
			(void) nvlist_add_string(h->attr, "gen_version", buf);
		}
		if (h->have_label) {
			(void) nvlist_add_string(h->attr, "gen_volume_label",
			    h->label);
		}
	}
	*attrp = h->attr;
	return (0);
}

int
fstyp_mod_dump(fstyp_mod_handle_t handle, FILE *fout, FILE *ferr)
{
	struct fstyp_ntfs *h = (struct fstyp_ntfs *)handle;

	(void) ferr;
	(void) fprintf(fout, "bytes per sector: %u\n", h->bytes_per_sector);
	(void) fprintf(fout, "cluster size: %u\n", h->cluster_size);
	(void) fprintf(fout, "MFT cluster: %llu\n",
	    (unsigned long long)h->mft_lcn);
	(void) fprintf(fout, "MFT record size: %u\n", h->record_size);
	return (0);
}

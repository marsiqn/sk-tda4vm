/* SPDX-License-Identifier: GPL-2.0+ */
/*
 * Copyright (C) 2019 Texas Instruments Incorporated - http://www.ti.com
 *
 * Environment variable definitions for DFU on TI K3 SoCs.
 *
 */

#ifndef __TI_DFU_H
#define __TI_DFU_H

#define DFU_ALT_INFO_MMC \
	"dfu_alt_info_mmc=" \
	"boot part 1 1;" \
	"rootfs part 1 2;" \
	"tiboot3.bin fat 1 1;" \
	"tispl.bin fat 1 1;" \
	"u-boot.img fat 1 1;" \
	"uEnv.txt fat 1 1;" \
	"sysfw.itb fat 1 1\0"

#define DFU_ALT_INFO_EMMC \
	"dfu_alt_info_emmc=" \
	"rawemmc raw 0 0x800000 mmcpart 1;" \
	"rootfs part 0 1 mmcpart 0;" \
	"tiboot3.bin.raw raw 0x0 0x400 mmcpart 1;" \
	"tispl.bin.raw raw 0x400 0x1000 mmcpart 1;" \
	"u-boot.img.raw raw 0x1400 0x2000 mmcpart 1;" \
	"u-env.raw raw 0x3400 0x100 mmcpart 1;" \
	"sysfw.itb.raw raw 0x3600 0x800 mmcpart 1\0"

#define DFU_ALT_INFO_EMMC_COMBINED \
	"dfu_alt_info_emmc=" \
	"rawemmc raw 0 0x800000 mmcpart 1;" \
	"rootfs part 0 1 mmcpart 0;" \
	"tiboot3.bin.raw raw 0x0 0x800 mmcpart 1;" \
	"tispl.bin.raw raw 0x800 0x1000 mmcpart 1;" \
	"u-boot.img.raw raw 0x1800 0x2000 mmcpart 1;" \
	"u-env.raw raw 0x3800 0x100 mmcpart 1\0"

#define DFU_ALT_INFO_OSPI \
	"dfu_alt_info_ospi=" \
	"tiboot3.bin raw 0x0 0x080000;" \
	"tispl.bin raw 0x080000 0x200000;" \
	"u-boot.img raw 0x280000 0x400000;" \
	"u-boot-env raw 0x680000 0x020000;" \
	"sysfw.itb raw 0x6c0000 0x100000;" \
	"rootfs raw 0x800000 0x3800000\0"

#define DFU_ALT_INFO_OSPI_COMBINED \
	"dfu_alt_info_ospi=" \
	"tiboot3.bin raw 0x0 0x100000;" \
	"tispl.bin raw 0x100000 0x200000;" \
	"u-boot.img raw 0x300000 0x400000;" \
	"u-boot-env raw 0x700000 0x020000;" \
	"rootfs raw 0x800000 0x3800000\0"

#define DFU_ALT_INFO_RAM \
	"dfu_alt_info_ram=" \
	"tispl.bin ram 0x80080000 0x200000;" \
	"u-boot.img ram 0x81000000 0x400000\0" \

#define DFU_ALT_INFO_OSPI_NAND \
	"dfu_alt_info_ospi_nand=" \
	"tiboot3.bin raw 0x0 0x080000;" \
	"tispl.bin raw 0x080000 0x200000;" \
	"u-boot.img raw 0x280000 0x400000;" \
	"u-boot-env raw 0x680000 0x040000;" \
	"rootfs raw 0x2000000 0x5fc0000;" \
	"phypattern raw 0x7fc0000 0x40000\0"

#define DFU_ALT_INFO_GPMC_NAND \
       "dfu_alt_info_gpmc_nand=" \
       "tiboot3.bin raw 0x0 0x00200000;" \
       "tispl.bin raw 0x00200000 0x00200000;" \
       "tiboot3.backup raw 0x00400000 0x00200000;"\
       "u-boot.img raw 0x00600000 0x00400000;" \
       "u-boot-env raw 0x00a00000 0x00040000;" \
       "u-boot-env.backup raw 0x00a40000 0x00040000;" \
       "file-system raw 0x00a80000 0x3f580000\0" \

#endif /* __TI_DFU_H */

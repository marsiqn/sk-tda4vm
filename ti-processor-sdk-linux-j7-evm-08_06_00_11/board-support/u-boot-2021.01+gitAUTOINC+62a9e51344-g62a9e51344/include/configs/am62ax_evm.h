/* SPDX-License-Identifier: GPL-2.0+ */
/*
 * Configuration header file for K3 AM62Ax SoC family
 *
 * Copyright (C) 2022 Texas Instruments Incorporated - https://www.ti.com/
 */

#ifndef __CONFIG_AM62AX_EVM_H
#define __CONFIG_AM62AX_EVM_H

#include <linux/sizes.h>
#include <config_distro_bootcmd.h>
#include <environment/ti/mmc.h>
#include <environment/ti/k3_rproc.h>
#include <environment/ti/k3_dfu.h>

#define CONFIG_SYS_BOOTM_LEN		SZ_64M

/* DDR Configuration */
#define CONFIG_SYS_SDRAM_BASE1		0x880000000

#ifdef CONFIG_SYS_K3_SPL_ATF
#define CONFIG_SPL_FS_LOAD_PAYLOAD_NAME	"tispl.bin"
#endif

#if defined(CONFIG_TARGET_AM62A7_A53_EVM)
#define CONFIG_SPL_MAX_SIZE		SZ_1M
#define CONFIG_SYS_INIT_SP_ADDR         (CONFIG_SPL_TEXT_BASE + SZ_4M)
#else
#define CONFIG_SPL_MAX_SIZE		CONFIG_SYS_K3_MAX_DOWNLODABLE_IMAGE_SIZE
/*
 * Maximum size in memory allocated to the SPL BSS. Keep it as tight as
 * possible (to allow the build to go through), as this directly affects
 * our memory footprint. The less we use for BSS the more we have available
 * for everything else.
 */
#define CONFIG_SPL_BSS_MAX_SIZE		0x3000
/*
 * Link BSS to be within SPL in a dedicated region located near the top of
 * the MCU SRAM, this way making it available also before relocation. Note
 * that we are not using the actual top of the MCU SRAM as there is a memory
 * location allocated for Device Manager data and some memory filled in by
 * the boot ROM that we want to read out without any interference from the
 * C context.
 */
#define CONFIG_SPL_BSS_START_ADDR	(0x43c3e000 -\
					 CONFIG_SPL_BSS_MAX_SIZE)
/* Set the stack right below the SPL BSS section */
#define CONFIG_SYS_INIT_SP_ADDR         0x43c3a7f0
/* Configure R5 SPL post-relocation malloc pool in DDR */
#define CONFIG_SYS_SPL_MALLOC_START    0x84000000
#define CONFIG_SYS_SPL_MALLOC_SIZE     SZ_16M
#endif

#define PARTS_DEFAULT \
	/* Linux partitions */ \
	"name=rootfs,start=0,size=-,uuid=${uuid_gpt_rootfs}\0" \

/* U-Boot general configuration */
#define EXTRA_ENV_AM62A7_BOARD_SETTINGS					\
	"default_device_tree=" CONFIG_DEFAULT_DEVICE_TREE ".dtb\0"	\
	"findfdt="							\
		"setenv name_fdt ${default_device_tree};"		\
		"setenv fdtfile ${name_fdt}\0"				\
	"name_kern=Image\0"						\
	"console=ttyS2,115200n8\0"					\
	"args_all=setenv optargs earlycon=ns16550a,mmio32,0x02800000 "	\
		"${mtdparts}\0"						\
	"run_kern=booti ${loadaddr} ${rd_spec} ${fdtaddr}\0"

/* U-Boot MMC-specific configuration */
#define EXTRA_ENV_AM62A7_BOARD_SETTINGS_MMC				\
	"boot=mmc\0"							\
	"mmcdev=1\0"							\
	"bootpart=1:2\0"						\
	"bootdir=/boot\0"						\
	"rd_spec=-\0"							\
	"init_mmc=run args_all args_mmc\0"				\
	"get_fdt_mmc=load mmc ${bootpart} ${fdtaddr} ${bootdir}/${name_fdt}\0" \
	"get_overlay_mmc="						\
		"fdt address ${fdtaddr};"				\
		"fdt resize 0x100000;"					\
		"for overlay in $name_overlays;"			\
		"do;"							\
		"load mmc ${bootpart} ${dtboaddr} ${bootdir}/${overlay} && "	\
		"fdt apply ${dtboaddr};"				\
		"done;\0"						\
	"get_kern_mmc=load mmc ${bootpart} ${loadaddr} "		\
		"${bootdir}/${name_kern}\0"				\
	"get_fit_mmc=load mmc ${bootpart} ${addr_fit} "			\
		"${bootdir}/${name_fit}\0"				\
	"partitions=" PARTS_DEFAULT

#define EXTRA_ENV_AM62A7_BOARD_SETTINGS_OSPI_NAND				\
	"nbootpart=ospi.rootfs\0"					\
	"nbootvolume=ubi0:rootfs\0"					\
	"bootdir=/boot\0"						\
	"rd_spec=-\0"							\
	"ubi_init=ubi part ${nbootpart}; ubifsmount ${nbootvolume};\0"	\
	"args_ospi_nand=setenv bootargs console=${console} "			\
		"${optargs} ubi.mtd=${nbootpart} "			\
		"root=${nbootvolume} rootfstype=ubifs\0"			\
	"init_ospi_nand=run args_all args_ospi_nand ubi_init\0"			\
	"get_fdt_ospi_nand=ubifsload ${fdtaddr} ${bootdir}/${fdtfile};\0"	\
	"get_overlay_ospi_nand="						\
		"fdt address ${fdtaddr};"				\
		"fdt resize 0x100000;"					\
		"for overlay in $name_overlays;"			\
		"do;"							\
		"ubifsload ${dtboaddr} ${bootdir}/${overlay} && "	\
		"fdt apply ${dtboaddr};"				\
		"done;\0"						\
	"get_kern_ospi_nand=ubifsload ${loadaddr} ${bootdir}/${name_kern}\0"	\
	"get_fit_ospi_nand=ubifsload ${addr_fit} ${bootdir}/${name_fit}\0"

#if defined(CONFIG_TARGET_AM62A7_A53_EVM)
#if defined(DEFAULT_RPROCS)
#undef DEFAULT_RPROCS
#endif
#define DEFAULT_RPROCS	""						\
		"0 /lib/firmware/am62a-mcu-r5f0_0-fw "			\
		"1 /lib/firmware/am62a-c71_0-fw "
#endif

#define EXTRA_ENV_DFUARGS \
	DFU_ALT_INFO_MMC \
	DFU_ALT_INFO_EMMC \
	DFU_ALT_INFO_RAM \
	DFU_ALT_INFO_OSPI \
	DFU_ALT_INFO_OSPI_NAND

/* Incorporate settings into the U-Boot environment */
#define CONFIG_EXTRA_ENV_SETTINGS					\
	DEFAULT_LINUX_BOOT_ENV						\
	DEFAULT_FIT_TI_ARGS						\
	DEFAULT_MMC_TI_ARGS						\
	EXTRA_ENV_AM62A7_BOARD_SETTINGS					\
	EXTRA_ENV_AM62A7_BOARD_SETTINGS_MMC				\
	EXTRA_ENV_AM62A7_BOARD_SETTINGS_OSPI_NAND			\
	EXTRA_ENV_RPROC_SETTINGS					\
	EXTRA_ENV_DFUARGS

/* Now for the remaining common defines */
#include <configs/ti_armv7_common.h>

/* MMC ENV related defines */
#ifdef CONFIG_ENV_IS_IN_MMC
#define CONFIG_SYS_MMC_ENV_DEV		0
#define CONFIG_SYS_MMC_ENV_PART		1
#endif

#endif /* __CONFIG_AM62A7_EVM_H */

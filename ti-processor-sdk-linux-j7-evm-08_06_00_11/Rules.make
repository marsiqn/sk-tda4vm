#platform
PLATFORM=j7-evm
SOC = j721e
SOC_TYPE ?= gp

#defconfig
DEFCONFIG=tisdk_j7-evm_defconfig

#Architecture
ARCH=aarch64

#u-boot machine
UBOOT_MACHINE=j721e_evm_a72_config

#Points to the root of the TI SDK
export TI_SDK_PATH=/home/marsqian/work/sk-tda4vm/github/sk-tda4vm/ti-processor-sdk-linux-j7-evm-08_06_00_11

#root of the target file system for installing applications
DESTDIR ?=__DESTDIR__

#Points to the root of the Linux libraries and headers matching the
#demo file system.
export LINUX_DEVKIT_PATH=$(TI_SDK_PATH)/linux-devkit

#Cross compiler prefix
export CROSS_COMPILE=$(LINUX_DEVKIT_PATH)/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-

#Default CC value to be used when cross compiling.  This is so that the
#GNU Make default of "cc" is not used to point to the host compiler
export CC=$(CROSS_COMPILE)gcc --sysroot=$(SDK_PATH_TARGET)

#Location of environment-setup file
export ENV_SETUP=$(LINUX_DEVKIT_PATH)/environment-setup

#The directory that points to the SDK kernel source tree
LINUXKERNEL_INSTALL_DIR=$(TI_SDK_PATH)/board-support/linux-5.10.162+gitAUTOINC+76b3e88d56-g76b3e88d56

CFLAGS=

#Strip modules when installing to conserve disk space
INSTALL_MOD_STRIP=1

SDK_PATH_TARGET=$(TI_SDK_PATH)/linux-devkit/sysroots/aarch64-linux/

# Set EXEC_DIR to install example binaries.
# This will be configured with the setup.sh script.
EXEC_DIR ?=__EXEC_DIR__

# Add CROSS_COMPILE and UBOOT_MACHINE for the R5
export CROSS_COMPILE_ARMV7=$(LINUX_DEVKIT_PATH)/sysroots/x86_64-arago-linux/usr/bin/arm-none-linux-gnueabihf-
UBOOT_MACHINE_R5=j721e_evm_r5_config

# Root of the boot partition to install boot binaries
BOOTFS ?= __BOOTFS__

export TI_SECURE_DEV_PKG=$(TI_SDK_PATH)/board-support/core-secdev-k3

ifneq ($(SOC_TYPE),gp)
	UBOOT_MACHINE=j721e_hs_evm_a72_config
	UBOOT_MACHINE_R5=j721e_hs_evm_r5_config
	SYSFW_SOC ?= j721e_sr1_1
endif


MAKE_JOBS=8

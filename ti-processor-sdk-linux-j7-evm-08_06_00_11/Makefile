-include Rules.make

MAKE_JOBS ?= 1

all: arm-benchmarks am-sysinfo oprofile-example cryptodev ti-img-rogue-driver u-boot-spl-jacinto sysfw-image-jacinto linux-jacinto linux-dtbs-jacinto 
clean: arm-benchmarks_clean am-sysinfo_clean oprofile-example_clean cryptodev_clean ti-img-rogue-driver_clean u-boot-spl-jacinto_clean sysfw-image-jacinto_clean linux-jacinto_clean linux-dtbs-jacinto_clean 
install: arm-benchmarks_install am-sysinfo_install oprofile-example_install cryptodev_install ti-img-rogue-driver_install u-boot-spl-jacinto_install sysfw-image-jacinto_install linux-jacinto_install linux-dtbs-jacinto_install 

# arm-benchmarks build targets
arm-benchmarks:
	@echo =============================
	@echo    Building ARM Benchmarks
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*arm-benchmarks*"`; make CC="$(CC)"

arm-benchmarks_clean:
	@echo =============================
	@echo    Cleaning ARM Benchmarks
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*arm-benchmarks*"`; make clean

arm-benchmarks_install:
	@echo ==============================================
	@echo   Installing ARM Benchmarks - Release version
	@echo ==============================================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*arm-benchmarks*"`; make install

arm-benchmarks_install_debug:
	@echo ============================================
	@echo   Installing ARM Benchmarks - Debug Version
	@echo ============================================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*arm-benchmarks*"`; make install_debug
# am-sysinfo build targets
am-sysinfo:
	@echo =============================
	@echo    Building AM Sysinfo
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*am-sysinfo*"`; make CC="$(CC)"

am-sysinfo_clean:
	@echo =============================
	@echo    Cleaning AM Sysinfo
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*am-sysinfo*"`; make clean

am-sysinfo_install:
	@echo ===============================================
	@echo     Installing AM Sysinfo - Release version
	@echo ===============================================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*am-sysinfo*"`; make install

am-sysinfo_install_debug:
	@echo =============================================
	@echo     Installing AM Sysinfo - Debug version
	@echo =============================================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*am-sysinfo*"`; make install_debug
# oprofile-example build targets
oprofile-example:
	@echo =============================
	@echo    Building OProfile Example
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*oprofile-example*"`; make CC="$(CC)"

oprofile-example_clean:
	@echo =============================
	@echo    Cleaning OProfile Example
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*oprofile-example*"`; make clean

oprofile-example_install:
	@echo =============================================
	@echo     Installing OProfile Example - Debug version
	@echo =============================================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*oprofile-example*"`; make install
cryptodev: linux
	@echo ================================
	@echo      Building cryptodev-linux
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "cryptodev*"`; \
	make ARCH=arm64 KERNEL_DIR=$(LINUXKERNEL_INSTALL_DIR)

cryptodev_clean:
	@echo ================================
	@echo      Cleaning cryptodev-linux
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "cryptodev*"`; \
	make ARCH=arm64 KERNEL_DIR=$(LINUXKERNEL_INSTALL_DIR) clean

cryptodev_install:
	@echo ================================
	@echo      Installing cryptodev-linux
	@echo ================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "cryptodev*"`; \
	make ARCH=arm64  KERNEL_DIR=$(LINUXKERNEL_INSTALL_DIR)  INSTALL_MOD_PATH=$(DESTDIR) PREFIX=$(SDK_PATH_TARGET) INSTALL_MOD_STRIP=$(INSTALL_MOD_STRIP) install

# ti-img-rogue-driver
ti-img-rogue-driver: linux
	@echo =====================================
	@echo     Building ti-img-rogue-driver
	@echo =====================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "ti-img-rogue-driver*" -type d`; \
	make ARCH=arm64 KERNELDIR=${LINUXKERNEL_INSTALL_DIR} RGX_BVNC="22.104.208.318" BUILD=release PVR_BUILD_DIR=j721e_linux WINDOW_SYSTEM=wayland

ti-img-rogue-driver_clean:
	@echo ====================================
	@echo     Cleaning ti-img-rogue-driver
	@echo ====================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "ti-img-rogue-driver*" -type d`; \
	make ARCH=arm64 KERNELDIR=${LINUXKERNEL_INSTALL_DIR} RGX_BVNC="22.104.208.318" BUILD=release PVR_BUILD_DIR=j721e_linux WINDOW_SYSTEM=wayland clean

ti-img-rogue-driver_install:
	@echo ====================================
	@echo     Installing ti-img-rogue-driver
	@echo ====================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "ti-img-rogue-driver*" -type d`; \
	cd binary_j721e_linux_wayland_release/target_aarch64/kbuild; \
	make -C ${LINUXKERNEL_INSTALL_DIR} INSTALL_MOD_PATH=${DESTDIR} INSTALL_MOD_STRIP=${INSTALL_MOD_STRIP} M=`pwd` modules_install

u-boot-spl-jacinto: u-boot
u-boot-spl-jacinto_clean: u-boot_clean
u-boot-spl-jacinto_install: u-boot_install

ifneq ($(SOC_TYPE),gp)
UBOOT_BIN_SUFFIX=.signed
UBOOT_IMAGE_SUFFIX=_HS
UBOOT_BUILD_DIR=u-boot_hs_build
else
UBOOT_BIN_SUFFIX=
UBOOT_IMAGE_SUFFIX=
UBOOT_BUILD_DIR=u-boot_build
endif

UBOOT_ATF=$(TI_SDK_PATH)/board-support/prebuilt-images/bl31.bin$(UBOOT_BIN_SUFFIX)
UBOOT_TEE=$(TI_SDK_PATH)/board-support/prebuilt-images/bl32.bin$(UBOOT_BIN_SUFFIX)
UBOOT_DM=$(TI_SDK_PATH)/board-support/prebuilt-images/ipc_echo_testb_mcu1_0_release_strip.xer5f$(UBOOT_BIN_SUFFIX)

UBOOT_A72_BUILD_DIR=$(TI_SDK_PATH)/board-support/$(UBOOT_BUILD_DIR)/a72
UBOOT_R5_BUILD_DIR=$(TI_SDK_PATH)/board-support/$(UBOOT_BUILD_DIR)/r5

u-boot: u-boot-a72 u-boot-r5
ifneq ($(SOC_TYPE),gp)
	@echo "===================== WARNING ======================"
	@echo "If using dorprocboot=1 in u-boot, the remote core firmwares will need to be signed for HS platforms."
	@echo "Use following procedure to sign any binary"
	@echo "$(TI_SECURE_DEV_PKG)/scripts/secure-binary-image.sh <input-file-name> <output-file-name>"
	@echo "Install the signed firmware and appropriate softlinks at /lib/firmware. For example:"
	@echo "    cd <ROOTFS>/lib/firmware"
	@echo "    $(TI_SECURE_DEV_PKG)/scripts/secure-binary-image.sh pdk-ipc/ipc_echo_test_mcu1_1_release_strip.xer5f pdk-ipc/ipc_echo_test_mcu1_1_release_strip.xer5f.signed"
	@echo "    ln -sfn /lib/firmware/pdk-ipc/ipc_echo_test_mcu1_1_release_strip.xer5f.signed j7-mcu-r5f0_1-fw-sec"
	@echo "===================================================="
endif

u-boot_clean: u-boot-a72_clean u-boot-r5_clean

u-boot-a72:
	@echo ===================================
	@echo    Building U-boot for A72
	@echo ===================================
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE) \
		 $(UBOOT_MACHINE) O=$(UBOOT_A72_BUILD_DIR)
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE) \
		CONFIG_MKIMAGE_DTC_PATH=$(UBOOT_A72_BUILD_DIR)/scripts/dtc/dtc \
		ATF=$(UBOOT_ATF) TEE=$(UBOOT_TEE) DM=$(UBOOT_DM) \
		O=$(UBOOT_A72_BUILD_DIR)


u-boot-a72_clean:
	@echo ===================================
	@echo    Cleaning U-boot for A72
	@echo ===================================
	$(MAKE) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE) \
		O=$(UBOOT_A72_BUILD_DIR) distclean
	@rm -rf $(UBOOT_A72_BUILD_DIR)

u-boot-r5:
	@echo ===================================
	@echo    Building U-boot for R5
	@echo ===================================
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE_ARMV7) \
		 $(UBOOT_MACHINE_R5) O=$(UBOOT_R5_BUILD_DIR)
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE_ARMV7) \
		O=$(UBOOT_R5_BUILD_DIR)
	$(MAKE) sysfw-image

u-boot-r5_clean:
	@echo ===================================
	@echo    Cleaning U-boot for R5
	@echo ===================================
	$(MAKE) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE_ARMV7) \
		O=$(UBOOT_R5_BUILD_DIR) distclean
	$(MAKE) sysfw-image_clean
	@rm -rf $(UBOOT_R5_BUILD_DIR)

u-boot_stage:
	mkdir -p $(TI_SDK_PATH)/board-support/built-images
	cp $(UBOOT_A72_BUILD_DIR)/tispl.bin$(UBOOT_IMAGE_SUFFIX) $(TI_SDK_PATH)/board-support/built-images/tispl.bin
	cp $(UBOOT_A72_BUILD_DIR)/u-boot.img$(UBOOT_IMAGE_SUFFIX) $(TI_SDK_PATH)/board-support/built-images/u-boot.img
	cp $(UBOOT_R5_BUILD_DIR)/tiboot3.bin $(TI_SDK_PATH)/board-support/built-images/tiboot3.bin
	$(MAKE) sysfw-image_stage

u-boot_install: u-boot_stage
	@echo ===================================
	@echo    Installing U-boot
	@echo ===================================
	@if [ -z $(BOOTFS) ] || [ ! -d $(BOOTFS) ] ; then \
		echo "The extracted boot filesystem directory doesn't exist."; \
		echo "Please try again with BOOTFS=<boot-filesystem-dir>"; \
		exit 1; \
	fi
	cp $(TI_SDK_PATH)/board-support/built-images/tispl.bin $(BOOTFS)
	cp $(TI_SDK_PATH)/board-support/built-images/u-boot.img $(BOOTFS)
	cp $(TI_SDK_PATH)/board-support/built-images/tiboot3.bin $(BOOTFS)
	$(MAKE) sysfw-image_install 


sysfw-image-jacinto: sysfw-image
sysfw-image-jacinto_clean: sysfw-image_clean
sysfw-image-jacinto_install: sysfw-image_install


SYSFW_SOC ?= $(SOC)
SOC_TYPE ?= gp
SYSFW_CONFIG ?= evm

SYSFW_PREFIX = "fs"
ifeq ($(SOC), $(filter $(SOC), am65x))
SYSFW_PREFIX = "sci"
endif


SYSFW_MAKEARGS = SYSFW_DIR=$(TI_SDK_PATH)/board-support/prebuilt-images SCIFS=$(SYSFW_PREFIX) SOC=$(SYSFW_SOC) SOC_TYPE=$(SOC_TYPE) CONFIG=$(SYSFW_CONFIG)

SBL_PATH ?= $(UBOOT_R5_BUILD_DIR)/spl/u-boot-spl.bin
ifeq ($(SOC), $(filter $(SOC), j721e am65x))
override SBL_PATH = ""
endif

# Depend on linux-dtbs for the dtc utility
sysfw-image:
	@echo =============================
	@echo    Building SYSFW Image
	@echo =============================
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/k3-image-gen-* \
		SBL=$(SBL_PATH) $(SYSFW_MAKEARGS) CROSS_COMPILE=$(CROSS_COMPILE_ARMV7)

sysfw-image_clean:
	@echo =============================
	@echo    Cleaning SYSFW Image
	@echo =============================
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/k3-image-gen-* \
		$(SYSFW_MAKEARGS) clean

sysfw-image_stage:
	mkdir -p $(TI_SDK_PATH)/board-support/built-images
ifeq ($(SBL_PATH),"")
	cp $(TI_SDK_PATH)/board-support/k3-image-gen-*/sysfw.itb $(TI_SDK_PATH)/board-support/built-images/sysfw.itb
else
	cp $(TI_SDK_PATH)/board-support/k3-image-gen-*/tiboot3.bin $(TI_SDK_PATH)/board-support/built-images/tiboot3.bin
endif

sysfw-image_install: sysfw-image_stage
	@echo =============================
	@echo   Installing SYSFW Image
	@echo =============================
	@if [ ! -d $(BOOTFS) ] ; then \
		echo "The extracted boot filesystem directory doesn't exist."; \
		echo "Please try again with BOOTFS=<boot-filesystem>"; \
		exit 1; \
	fi
ifeq ($(SBL_PATH),"")
	cp $(TI_SDK_PATH)/board-support/built-images/sysfw.itb $(BOOTFS)
else
	cp $(TI_SDK_PATH)/board-support/built-images/tiboot3.bin $(BOOTFS)
endif
	
# Kernel build targets
linux-jacinto: linux
linux-jacinto_clean: linux_clean
linux-jacinto_install: linux_install

linux: linux-dtbs
	@echo =================================
	@echo     Building the Linux Kernel
	@echo =================================
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) $(DEFCONFIG)
	$(MAKE) -j $(MAKE_JOBS) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE)  Image
	$(MAKE) -j $(MAKE_JOBS) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) modules

linux_stage: linux-dtbs_stage
	mkdir -p $(TI_SDK_PATH)/board-support/built-images
ifneq ($(SOC_TYPE),gp)
	$(TI_SECURE_DEV_PKG)/scripts/secure-binary-image.sh $(LINUXKERNEL_INSTALL_DIR)/arch/arm64/boot/Image $(TI_SDK_PATH)/board-support/built-images/Image.sec
	cp $(TI_SDK_PATH)/board-support/prebuilt-images/fitImage.its $(TI_SDK_PATH)/board-support/built-images
	cd $(TI_SDK_PATH)/board-support/built-images; \
	mkimage -f fitImage.its -r fitImage
else
	cp $(LINUXKERNEL_INSTALL_DIR)/arch/arm64/boot/Image $(TI_SDK_PATH)/board-support/built-images
endif

linux_install: linux_stage linux-dtbs_install
	@echo ===================================
	@echo     Installing the Linux Kernel
	@echo ===================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	install -d $(DESTDIR)/boot
ifneq ($(SOC_TYPE),gp)
	install $(TI_SDK_PATH)/board-support/built-images/fitImage $(DESTDIR)/boot
else
	install $(TI_SDK_PATH)/board-support/built-images/Image $(DESTDIR)/boot
endif
	install $(LINUXKERNEL_INSTALL_DIR)/vmlinux $(DESTDIR)/boot
	install $(LINUXKERNEL_INSTALL_DIR)/System.map $(DESTDIR)/boot
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(DESTDIR) INSTALL_MOD_STRIP=$(INSTALL_MOD_STRIP) modules_install

linux_clean:
	@echo =================================
	@echo     Cleaning the Linux Kernel
	@echo =================================
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) mrproper

# Kernel DTB build targets
linux-dtbs-jacinto: linux-dtbs
linux-dtbs-jacinto_clean: linux-dtbs_clean
linux-dtbs-jacinto_install: linux-dtbs_install

linux-dtbs:
	@echo =====================================
	@echo     Building the Linux Kernel DTBs
	@echo =====================================
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) $(DEFCONFIG)
	@for DTB in      ti/k3-j721e-common-proc-board.dtb     ti/k3-j721e-proc-board-tps65917.dtb     ti/k3-j721e-common-proc-board-infotainment.dtbo     ti/k3-j721e-cpb-csi2-ov5640.dtbo     ti/k3-j721e-fpdlink-cpb-fusion.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-0.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-1.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-2.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-3.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-0.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-1.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-2.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-3.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-0.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-1.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-2.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-3.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-0.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-1.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-2.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-3.dtbo     ti/k3-j721e-sk.dtb     ti/k3-j721e-fpdlink-sk-fusion.dtbo     ti/k3-j721e-sk-csi2-ov5640.dtbo     ti/k3-j721e-sk-rpi-cam-imx219.dtbo      ti/k3-j721e-vision-apps.dtbo     ti/k3-j721e-edgeai-apps.dtbo     ti/k3-j721e-sk-rpi-hdr-ehrpwm.dtbo ; do \
		$(MAKE) -j $(MAKE_JOBS) -C $(LINUXKERNEL_INSTALL_DIR) DTC_FLAGS=-@ ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) $$DTB; \
	done

linux-dtbs_stage:
	mkdir -p $(TI_SDK_PATH)/board-support/built-images
ifneq ($(SOC_TYPE),gp)
	@for DTB in      ti/k3-j721e-common-proc-board.dtb     ti/k3-j721e-proc-board-tps65917.dtb     ti/k3-j721e-common-proc-board-infotainment.dtbo     ti/k3-j721e-cpb-csi2-ov5640.dtbo     ti/k3-j721e-fpdlink-cpb-fusion.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-0.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-1.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-2.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-3.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-0.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-1.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-2.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-3.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-0.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-1.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-2.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-3.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-0.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-1.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-2.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-3.dtbo     ti/k3-j721e-sk.dtb     ti/k3-j721e-fpdlink-sk-fusion.dtbo     ti/k3-j721e-sk-csi2-ov5640.dtbo     ti/k3-j721e-sk-rpi-cam-imx219.dtbo      ti/k3-j721e-vision-apps.dtbo     ti/k3-j721e-edgeai-apps.dtbo     ti/k3-j721e-sk-rpi-hdr-ehrpwm.dtbo ; do \
		$(TI_SECURE_DEV_PKG)/scripts/secure-binary-image.sh $(LINUXKERNEL_INSTALL_DIR)/arch/arm64/boot/dts/$$DTB $(TI_SDK_PATH)/board-support/built-images/$$(basename $$DTB).sec; \
	done
else
	@for DTB in      ti/k3-j721e-common-proc-board.dtb     ti/k3-j721e-proc-board-tps65917.dtb     ti/k3-j721e-common-proc-board-infotainment.dtbo     ti/k3-j721e-cpb-csi2-ov5640.dtbo     ti/k3-j721e-fpdlink-cpb-fusion.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-0.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-1.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-2.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-3.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-0.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-1.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-2.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-3.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-0.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-1.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-2.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-3.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-0.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-1.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-2.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-3.dtbo     ti/k3-j721e-sk.dtb     ti/k3-j721e-fpdlink-sk-fusion.dtbo     ti/k3-j721e-sk-csi2-ov5640.dtbo     ti/k3-j721e-sk-rpi-cam-imx219.dtbo      ti/k3-j721e-vision-apps.dtbo     ti/k3-j721e-edgeai-apps.dtbo     ti/k3-j721e-sk-rpi-hdr-ehrpwm.dtbo ; do \
		cp $(LINUXKERNEL_INSTALL_DIR)/arch/arm64/boot/dts/$$DTB $(TI_SDK_PATH)/board-support/built-images; \
	done
endif

linux-dtbs_install: linux-dtbs_stage
ifeq ($(SOC_TYPE),gp)
	@echo =======================================
	@echo     Installing the Linux Kernel DTBs
	@echo =======================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	install -d $(DESTDIR)/boot
	@for DTB in      ti/k3-j721e-common-proc-board.dtb     ti/k3-j721e-proc-board-tps65917.dtb     ti/k3-j721e-common-proc-board-infotainment.dtbo     ti/k3-j721e-cpb-csi2-ov5640.dtbo     ti/k3-j721e-fpdlink-cpb-fusion.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-0.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-1.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-2.dtbo     ti/k3-j721e-fpdlink-imx390-cm-0-3.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-0.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-1.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-2.dtbo     ti/k3-j721e-fpdlink-imx390-cm-1-3.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-0.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-1.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-2.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-0-3.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-0.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-1.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-2.dtbo     ti/k3-j721e-fpdlink-imx390-rcm-1-3.dtbo     ti/k3-j721e-sk.dtb     ti/k3-j721e-fpdlink-sk-fusion.dtbo     ti/k3-j721e-sk-csi2-ov5640.dtbo     ti/k3-j721e-sk-rpi-cam-imx219.dtbo      ti/k3-j721e-vision-apps.dtbo     ti/k3-j721e-edgeai-apps.dtbo     ti/k3-j721e-sk-rpi-hdr-ehrpwm.dtbo ; do \
		install -m 0644 $(TI_SDK_PATH)/board-support/built-images/$$(basename $$DTB) $(DESTDIR)/boot/; \
	done
endif

linux-dtbs_clean:
	@echo =======================================
	@echo     Cleaning the Linux Kernel DTBs
	@echo =======================================
	@echo "Nothing to do"


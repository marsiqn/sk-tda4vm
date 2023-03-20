.. _foundational-components-atf:

ARM Trusted Firmware-A
========================================
.. rubric:: Overview

Trusted Firmware-A (TF-A) provides a reference implementation of secure world
software for Armv7-A and Armv8-A, including a Secure Monitor executing at
Exception Level 3 (EL3).

ATF is used as the initial start code on ARMv8-A cores for all K3 platforms.
After setting up the initial core state and applying any needed errata fixes
it sets up itself as the EL3 monitor handler. After this is installs the secure
world software (OP-TEE) and passes execution on to either the Linux kernel or U-Boot
in the non-secure world.

.. rubric:: Getting the ATF Source Code

::

    $ git clone https://git.trustedfirmware.org/TF-A/trusted-firmware-a.git
    $ git checkout 1309c6c805190bd376c0561597653f3f8ecd0f58

.. rubric:: Getting Security Dev Tool
    
::
    
    $ git clone https://git.ti.com/git/security-development-tools/core-secdev-k3.git -b master
    $ export TI_SECURE_DEV_PKG=`pwd`/core-secdev-k3

.. rubric:: Building ATF

.. ifconfig:: CONFIG_part_variant in ('AM64X', 'AM62X')

    ::

        $ export TFA_DIR=<path-to-arm-trusted-firmware>

    ::

        on GP
        $ cd $TFA_DIR
        $ make ARCH=aarch64 CROSS_COMPILE=aarch64-none-linux-gnu- PLAT=k3 TARGET_BOARD=lite SPD=opteed

    ::

        on HS
        $ cd $TFA_DIR
        $ make ARCH=aarch64 CROSS_COMPILE=aarch64-none-linux-gnu- PLAT=k3 TARGET_BOARD=lite SPD=opteed

        Sign the output binary (bl31.bin) located in: $TFA_DIR/build/k3/lite/release
        $ {TI_SECURE_DEV_PKG}/scripts/secure-binary-image.sh $TFA_DIR/build/k3/lite/release/bl31.bin $TFA_DIR/build/k3/lite/release/bl31.bin.signed

.. ifconfig:: CONFIG_part_variant in ('J721S2')

    ::

        on GP
        $ make CROSS_COMPILE=aarch64-none-linux-gnu- ARCH=aarch64 PLAT=k3 TARGET_BOARD=generic SPD=opteed K3_USART=0x8

    ::

        on HS
        $ make CROSS_COMPILE=aarch64-none-linux-gnu- ARCH=aarch64 PLAT=k3 TARGET_BOARD=generic SPD=opteed K3_USART=0x8
        ${TI_SECURE_DEV_PKG}/scripts/secure-binary-image.sh ./build/k3/generic/release/bl31.bin ./build/k3/generic/release/bl31.bin.signed

.. ifconfig:: CONFIG_part_variant in ('J784S4')

    ::

        on GP
        $ make CROSS_COMPILE=aarch64-none-linux-gnu- ARCH=aarch64 PLAT=k3 TARGET_BOARD=j784s4 SPD=opteed K3_USART=0x8

    ::

        on HS
        $ make CROSS_COMPILE=aarch64-none-linux-gnu- ARCH=aarch64 PLAT=k3 TARGET_BOARD=j784s4 SPD=opteed K3_USART=0x8
        ${TI_SECURE_DEV_PKG}/scripts/secure-binary-image.sh ./build/k3/generic/release/bl31.bin ./build/k3/generic/release/bl31.bin.signed

.. ifconfig:: CONFIG_part_variant not in ('AM64X', 'J721S2', 'AM62X', 'J784S4')

    ::
        
        on GP
        $ make CROSS_COMPILE=aarch64-linux-gnu- PLAT=k3 TARGET_BOARD=generic SPD=opteed

    ::

        on HS
        $ make CROSS_COMPILE=aarch64-linux-gnu- PLAT=k3 TARGET_BOARD=generic SPD=opteed
        ${TI_SECURE_DEV_PKG}/scripts/secure-binary-image.sh ./build/k3/generic/release/bl31.bin ./build/k3/generic/release/bl31.bin.signed

.. rubric:: Default load locations

.. ifconfig:: CONFIG_part_family in ('AM64X_family')

    +---------------------------+------------+
    | ATF image                 | 0x701c0000 |
    +---------------------------+------------+
    | OP-TEE image              | 0x9e800000 |
    +---------------------------+------------+
    | U-Boot/Linux kernel image | 0x80080000 |
    +---------------------------+------------+
    | DTB                       | 0x82000000 |
    +---------------------------+------------+

.. ifconfig:: CONFIG_part_family not in ('AM64X_family')
 
    +---------------------------+------------+
    | ATF image                 | 0x70000000 |
    +---------------------------+------------+
    | OP-TEE image              | 0x9e800000 |
    +---------------------------+------------+
    | U-Boot/Linux kernel image | 0x80080000 |
    +---------------------------+------------+
    | DTB                       | 0x82000000 |
    +---------------------------+------------+

.. ifconfig:: CONFIG_part_family in ('AM64X_family', 'AM62X_family')

    To change the default load address of these binaries, an adress has to be changed in several source trees. The following
    is an example for AM64x family devices. Other family devices might not at the moment have binman dtsi files associated with
    them but they could in the future.

    +-----------------------------------------------------+------------------+-----------------------+---------------------+---------------+-------------------+----------+----------------------------------------+
    | Source                                              | ATF              | OPTEE                 |  A53 SPL            | A53 U-Boot    | DTB               | kernel   | Comments                               |
    +=====================================================+==================+=======================+=====================+===============+===================+==========+========================================+
    | <atf>/plat/ti/k3/board/lite/board.mk                |                  | BL32_BASE             | PRELOADED_BL33_BASE |               | K3_HW_CONFIG_BASE |          | Change K3_HW_CONFIG_BASE for           |
    |                                                     |                  |                       |                     |               |                   |          | u-boot a53 skip case                   |
    +-----------------------------------------------------+------------------+-----------------------+---------------------+---------------+-------------------+----------+----------------------------------------+
    | <optee>/core/arch/arm/plat-k3/conf.mk               |                  | CFG_TZDRAM_START      |                     |               |                   |          |                                        |
    +-----------------------------------------------------+------------------+-----------------------+---------------------+---------------+-------------------+----------+----------------------------------------+
    | <uboot>/configs/am64x_evm_r5_defconfig              | K3_ATF_LOAD_ADDR |                       |                     |               |                   |          |                                        |
    +-----------------------------------------------------+------------------+-----------------------+---------------------+---------------+-------------------+----------+----------------------------------------+
    | <uboot>/configs/am64x_evm_a53_defconfig             |                  |                       | SPL_TEXT_BASE       | SYS_TEXT_BASE |                   |          | SYS_TEXT_BASE can be set in defconfig, |
    |                                                     |                  |                       |                     |               |                   |          | has default value in Kconfig           |
    +-----------------------------------------------------+------------------+-----------------------+---------------------+---------------+-------------------+----------+----------------------------------------+
    | <uboot/linux>/arch/arm/dts/k3-am642*.dts files      |                  | reserved-memory nodes |                     |               |                   |          |                                        |
    +-----------------------------------------------------+------------------+-----------------------+---------------------+---------------+-------------------+----------+----------------------------------------+
    | <uboot>/arch/arm/dts/k3-am642-evm-binman.dtsi file  |                  | tee nodes             | uboot nodes         | uboot nodes   |                   |          |                                        |
    +-----------------------------------------------------+------------------+-----------------------+---------------------+---------------+-------------------+----------+----------------------------------------+
    | <uboot>/include/configs/ti_armv7_common.h           |                  |                       |                     |               | fdtaddr           | loadaddr | If not defined here, u-boot            |
    |                                                     |                  |                       |                     |               |                   |          | will pick any adress                   |
    +-----------------------------------------------------+------------------+-----------------------+---------------------+---------------+-------------------+----------+----------------------------------------+
    | uEnv.txt                                            |                  |                       |                     |               | fdtaddr           | loadaddr | Overwrite the u-boot environment       |
    |                                                     |                  |                       |                     |               |                   |          | variables                              |
    +-----------------------------------------------------+------------------+-----------------------+---------------------+---------------+-------------------+----------+----------------------------------------+
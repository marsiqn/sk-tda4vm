.. include:: /replacevars.rst.inc

.. _foundational-components-optee:

OP-TEE
======

.. rubric:: Overview

OP-TEE is a Trusted Execution Environment (TEE) designed as a companion to a
non-secure Linux kernel running on Arm Cortex-A cores using the TrustZone technology.

- Furthur information about it can be found at: https://optee.readthedocs.io/en/latest/general/about.html
- Official OP-TEE documentation: https://optee.readthedocs.io/en/latest
- OP-TEE advisory listing: https://github.com/OP-TEE/optee_os/security/advisories

The OP-TEE binary (bl32.bin/tee-pager_v2.bin) is bundled into tispl.bin and the following are the instructions to build it.

.. rubric:: Getting the OP-TEE Source Code

.. parsed-literal::

    $ git clone https://github.com/OP-TEE/optee_os.git
    $ git checkout 8e74d47616a20eaa23ca692f4bbbf917a236ed94

.. rubric:: Getting Security Dev Tool

.. parsed-literal::

    $ git clone https://git.ti.com/git/security-development-tools/core-secdev-k3.git -b master
    $ export TI_SECURE_DEV_PKG=`pwd`/core-secdev-k3

.. rubric:: Building OP-TEE

.. ifconfig:: CONFIG_part_variant in ('J721S2')

    .. parsed-literal::

        $ export CFG_CONSOLE_UART=0x8

* On GP

.. parsed-literal::

    $ make CROSS_COMPILE64=aarch64-none-linux-gnu- PLATFORM=k3-\ |__OPTEE_PLATFORM_FLAVOR__| CFG_ARM64_core=y

* With debug parameters

.. parsed-literal::

    $ make CROSS_COMPILE64=aarch64-none-linux-gnu- PLATFORM=k3-\ |__OPTEE_PLATFORM_FLAVOR__| CFG_ARM64_core=y CFG_TEE_CORE_LOG_LEVEL=2 CFG_TEE_CORE_DEBUG=y

* Sign image for HS

.. parsed-literal::

    $ {TI_SECURE_DEV_PKG}/scripts/secure-binary-image.sh ./out/arm-plat-k3/core/tee-pager_v2.bin ./out/arm-plat-k3/core/tee-pager_v2.bin.signed


.. rubric:: Secure Storage with RPMB (For HS)

OP-TEE provides secure storage functionality. TI SoCs with HS configuration have a
KEK embedded in them that is programmed across OP-TEE instances that are distributed
in a derived manner. Each HS device has its own signing key which is different from other
HS devices.

For enabling RPMB support along with secure storage, additional flags need to be passed to
the build instructions. The information for the flags can be found here.
https://optee.readthedocs.io/en/latest/architecture/secure_storage.html

There is a hybrid mode in which both the flags i.e `CFG_REE_FS=y` and `CFG_RPMB_FS=y` are enabled.
This mode stores the state of the Secure Storage directory in RPMB partition to check for the
integrity of the data present in it. It is the recommended way.

E.g. For enabling hybrid mode of RPMB along with REE_FS

.. ifconfig:: CONFIG_part_variant in ('J721S2')

    .. parsed-literal::

        $ export CFG_CONSOLE_UART=0x8

.. parsed-literal::

    $ make CROSS_COMPILE64=aarch64-linux-gnu- PLATFORM=k3-\ |__OPTEE_PLATFORM_FLAVOR__| CFG_ARM64_core=y CFG_REE_FS=y CFG_RPMB_FS=y
    $ {TI_SECURE_DEV_PKG}/scripts/secure-binary-image.sh ./out/arm-plat-k3/core/tee-pager_v2.bin ./out/arm-plat-k3/core/tee-pager_v2.bin.signed

OPTEE-client also needs to be updated to enable the use of real
emmc instead of the virtual emmc that is enabled by default

.. rubric:: Getting OP-TEE Client source code

::

  $ git clone https://github.com/OP-TEE/optee_client

.. rubric:: Building OP-TEE Client with RPMB support

::

  $ make CROSS_COMPILE="aarch64-linux-gnu-" PLATFORM=k3 CFG_TEE_SUPP_LOG_LEVEL=2 RPMB_EMU=0 CFG_ARM64_core=y

Now update optee-client binary and libraries on your SD card with the generated ones
in `out/export/usr` folder

.. rubric:: Building u-boot with OP-TEE OS

If building for an HS device, tee-pager_v2.bin must be signed before it is packaged in tispl.bin. To sign the binary,
the script secure-binary-image.sh is called as shown above with the path to the newly built binary: tee-pager_v2.bin
(the first argument) and with the expected output binary path and name: tee-pager_v2.bin.signed (the second argument).
Once the binary is signed, continue with the HS boot instructions found here: :ref:`Build-U-Boot-label`.

Expected binary output

    - Generated binary: tee-pager_v2.bin
    - Binary saved saved in: <path-to-optee>/out/arm-plat-k3/core

Integrate binary output into U-boot

    - Go to u-boot folder <path-to-u-boot>
    - Re-build U-boot with A72/A53 instructions found under: :ref:`Build-U-Boot-label`, but with the TEE parameter pointing to the newly built tee-pager_v2.bin. i.e. TEE=<path-to-optee>/out/arm-plat-k3/core/tee-pager_v2.bin

.. note::

    tee-pager_v2.bin may be called bl32.bin in other documentation.

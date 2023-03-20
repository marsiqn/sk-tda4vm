OSPI/QSPI
------------------------------------

OSPI/QSPI is a serial peripheral interface like SPI the major difference
being the support for Octal/Quad read, uses 8/4 data lines for read compared to
2 lines used by the traditional SPI. This section documents how to write
files to the QSPI device and use it to load and then boot the Linux
Kernel using a root filesystem also found on QSPI. At this time, no
special builds of U-Boot are required to perform these operations on the
supported hardware. For simplicity we assume the files are being loaded
from an SD card. Using the network interface (if applicable) is
documented above.

.. note::

    Not all OSPI flashes can be supported. Users are recommended to check
    whether or not the OSPI flash part chosen for custom board designs meets all
    the criteria listed at https://e2e.ti.com/support/processors/f/791/t/946418


.. ifconfig:: CONFIG_part_variant in ('AM65X', 'J721E')

    ROM supports booting from OSPI from offset 0x0.

    **Flashing Images to OSPI**

    Below commands can be used to download tiboot3.bin, tispl.bin and
    u-boot.img over tftp and then flash it to OSPI at respective addresses.

    .. code-block:: console

      => sf probe
      => tftp ${loadaddr} tiboot3.bin
      => sf update $loadaddr 0x0 $filesize
      => tftp ${loadaddr} tispl.bin
      => sf update $loadaddr 0x80000 $filesize
      => tftp ${loadaddr} u-boot.img
      => sf update $loadaddr 0x280000 $filesize
      => tftp ${loadaddr} sysfw.itb
      => sf update $loadaddr 0x6C0000 $filesize

    **PHY Calibration**

    PHY calibration allows for higher read performance. To enable PHY, the PHY
    calibration pattern must be flashed to OSPI at the start of the last erase
    sector. For the Micron MT35XU512ABA flash, this lies at the address 0x3fe0000.

    Download the binary file containing the PHY pattern from :download:`here </files/ospi_phy_pattern>`.
    Below commands can be used to flash the PHY pattern, with the location of the
    pattern depending on which flash is being used:

    .. code-block:: console

       => sf probe
       => tftp ${loadaddr} ospi_phy_pattern
       => sf update $loadaddr 0x3fe0000 $filesize

    **Flash Layout for OSPI**

    .. code-block:: console

             0x0 +----------------------------+
                 |     ospi.tiboot3(512K)     |
                 |                            |
         0x80000 +----------------------------+
                 |     ospi.tispl(2M)         |
                 |                            |
        0x280000 +----------------------------+
                 |     ospi.u-boot(4M)        |
                 |                            |
        0x680000 +----------------------------+
                 |     ospi.env(128K)         |
                 |                            |
        0x6A0000 +----------------------------+
                 |   ospi.env.backup (128K)   |
                 |                            |
        0x6C0000 +----------------------------+
                 |      ospi.sysfw(1M)        |
                 |                            |
        0x7C0000 +----------------------------+
                 |      padding (256k)        |
        0x800000 +----------------------------+
                 |     ospi.rootfs(UBIFS)     |
                 |                            |
       0x3FE0000 +----------------------------+
                 |   ospi.phypattern (128k)   |
                 |                            |
                 +----------------------------+

    Kernel Image and DT are expected to be present in the /boot folder of UBIFS
    ospi.rootfs just like in SD card case. U-Boot looks for UBI volume named
    "rootfs" for rootfs.

    To boot kernel from OSPI, at the U-Boot prompt:

    .. code-block:: console

      => setenv boot ubi
      => boot

    **Writing to OSPI using DFU**

    Setup: Connect the Type C port (USB0 port) of EVM to ubuntu host PC. Make sure
    dfu-util tool is installed and USB0 port is in UFP/DRP mode: SW3[3:4] = 01 or 1x.

    ::

         #sudo apt-get install dfu-util

    From u-boot(for OSPI flash):

    ::

        U-Boot # env default -a
        U-Boot # setenv dfu_alt_info ${dfu_alt_info_ospi}; dfu 0 sf "0:0:25000000:0"

    From u-boot(for QSPI flash):

    ::

        U-Boot # env default -a
        U-Boot # setenv dfu_alt_info ${dfu_alt_info_ospi}; dfu 0 sf "1:0:40000000:0"

    From ubuntu PC: Using dfu-util utilities to flash the binares to OSPI/QSPI flash.

    ::

        # sudo dfu-util -l
        Copyright 2005-2009 Weston Schmidt, Harald Welte and OpenMoko Inc.
        Copyright 2010-2016 Tormod Volden and Stefan Schmidt
        This program is Free Software and has ABSOLUTELY NO WARRANTY
        Found DFU: [0451:6163] ver=0224, devnum=75, cfg=1, intf=0, path="1-5", alt=5, name="rootfs", serial="0000000000000110"
        Found DFU: [0451:6163] ver=0224, devnum=75, cfg=1, intf=0, path="1-5", alt=4, name="sysfw.itb", serial="0000000000000110"
        Found DFU: [0451:6163] ver=0224, devnum=75, cfg=1, intf=0, path="1-5", alt=3, name="u-boot-env", serial="0000000000000110"
        Found DFU: [0451:6163] ver=0224, devnum=75, cfg=1, intf=0, path="1-5", alt=2, name="u-boot.img", serial="0000000000000110"
        Found DFU: [0451:6163] ver=0224, devnum=75, cfg=1, intf=0, path="1-5", alt=1, name="tispl.bin", serial="0000000000000110"
        Found DFU: [0451:6163] ver=0224, devnum=75, cfg=1, intf=0, path="1-5", alt=0, name="tiboot3.bin", serial="0000000000000110""

    Flash the binaries to the respective regions using alternate interface
    number (alt=<x>).

    ::

        # sudo dfu-util -c 1 -i 0 -a 0 -D tiboot3.bin
        # sudo dfu-util -c 1 -i 0 -a 1 -D tispl.bin
        # sudo dfu-util -c 1 -i 0 -a 2 -D u-boot.img
        # sudo dfu-util -c 1 -i 0 -a 3 -D sysfw.itb

.. ifconfig:: CONFIG_part_variant in ('J7200')

    j7200 is largely similar to j721e and am654. the major differences are that it
    has the cypress s28hs512t flash and sysfw is bundled with tiboot3.bin.

    **flashing images to ospi**

    below commands can be used to download tiboot3.bin, tispl.bin and
    u-boot.img over tftp and then flash it to ospi at respective addresses.

    .. code-block:: console

      => sf probe
      => tftp ${loadaddr} tiboot3.bin
      => sf update $loadaddr 0x0 $filesize
      => tftp ${loadaddr} tispl.bin
      => sf update $loadaddr 0x100000 $filesize
      => tftp ${loadaddr} u-boot.img
      => sf update $loadaddr 0x300000 $filesize

    **phy calibration**

    phy calibration allows for higher read performance. to enable phy, the phy
    calibration pattern must be flashed to ospi at the start of the last erase
    sector. for the cypress s28hs512t flash, this lies at the address 0x3fc0000.

    download the binary file containing the phy pattern from :download:`here </files/ospi_phy_pattern>`.
    below commands can be used to flash the phy pattern, with the location of the
    pattern depending on which flash is being used:

    .. code-block:: console

       => sf probe
       => tftp ${loadaddr} ospi_phy_pattern
       => sf update $loadaddr 0x3fc0000 $filesize

    **flash layout for ospi**

    .. code-block:: console

             0x0 +----------------------------+
                 |     ospi.tiboot3(1m)       |
                 |                            |
        0x100000 +----------------------------+
                 |     ospi.tispl(2m)         |
                 |                            |
        0x300000 +----------------------------+
                 |     ospi.u-boot(4m)        |
                 |                            |
        0x700000 +----------------------------+
                 |     ospi.env(128k)         |
                 |                            |
        0x720000 +----------------------------+
                 |   ospi.env.backup(128k)    |
                 |                            |
        0x740000 +----------------------------+
                 |      padding (768k)        |
        0x800000 +----------------------------+
                 |     ospi.rootfs(ubifs)     |
                 |                            |
       0x3fc0000 +----------------------------+
                 |   ospi.phypattern (256k)   |
                 |                            |
                 +----------------------------+

    **Writing to OSPI using DFU**

    Setup: Connect the Type C port (USB0 port) of EVM to ubuntu host PC. Make sure
    dfu-util tool is installed and USB0 port is in UFP/DRP mode: SW3[3:4] = 01 or 1x.

    ::

         #sudo apt-get install dfu-util

    From u-boot:

    ::

        U-Boot # env default -a
        U-Boot # setenv dfu_alt_info ${dfu_alt_info_ospi}; dfu 0 sf "0:0:25000000:0"

    From ubuntu PC: Using dfu-util utilities to flash the binares to QSPI flash.

    ::

        # sudo dfu-util -l
        Copyright 2005-2009 Weston Schmidt, Harald Welte and OpenMoko Inc.
        Copyright 2010-2016 Tormod Volden and Stefan Schmidt
        This program is Free Software and has ABSOLUTELY NO WARRANTY
        Found DFU: [0451:6164] ver=0224, devnum=77, cfg=1, intf=0, path="1-5", alt=4, name="rootfs", serial="0000000000000005"
        Found DFU: [0451:6164] ver=0224, devnum=77, cfg=1, intf=0, path="1-5", alt=3, name="u-boot-env", serial="0000000000000005"
        Found DFU: [0451:6164] ver=0224, devnum=77, cfg=1, intf=0, path="1-5", alt=2, name="u-boot.img", serial="0000000000000005"
        Found DFU: [0451:6164] ver=0224, devnum=77, cfg=1, intf=0, path="1-5", alt=1, name="tispl.bin", serial="0000000000000005"
        Found DFU: [0451:6164] ver=0224, devnum=77, cfg=1, intf=0, path="1-5", alt=0, name="tiboot3.bin", serial="0000000000000005"

    Flash the binaries to the respective regions using alternate interface
    number (alt=<x>).

    ::

        # sudo dfu-util -c 1 -i 0 -a 0 -D tiboot3.bin
        # sudo dfu-util -c 1 -i 0 -a 1 -D tispl.bin
        # sudo dfu-util -c 1 -i 0 -a 2 -D u-boot.img

.. ifconfig:: CONFIG_part_variant in ('AM64X')

    AM64X has a cypress s28hs512t flash and sysfw is bundled with tiboot3.bin.

    **flashing images to ospi**

    below commands can be used to download tiboot3.bin, tispl.bin and
    u-boot.img over tftp and then flash it to ospi at respective addresses.

    .. code-block:: console

      => sf probe
      => tftp ${loadaddr} tiboot3.bin
      => sf update $loadaddr 0x0 $filesize
      => tftp ${loadaddr} tispl.bin
      => sf update $loadaddr 0x100000 $filesize
      => tftp ${loadaddr} u-boot.img
      => sf update $loadaddr 0x300000 $filesize

    **phy calibration**

    phy calibration allows for higher read performance. to enable phy, the phy
    calibration pattern must be flashed to ospi at the start of the last erase
    sector. for the cypress s28hs512t flash, this lies at the address 0x3fc0000.

    download the binary file containing the phy pattern from :download:`here </files/ospi_phy_pattern>`.
    below commands can be used to flash the phy pattern, with the location of the
    pattern depending on which flash is being used:

    .. code-block:: console

       => sf probe
       => tftp ${loadaddr} ospi_phy_pattern
       => sf update $loadaddr 0x3fc0000 $filesize

    **flash layout for ospi**

    .. code-block:: console

             0x0 +----------------------------+
                 |     ospi.tiboot3(1m)       |
                 |                            |
        0x100000 +----------------------------+
                 |     ospi.tispl(2m)         |
                 |                            |
        0x300000 +----------------------------+
                 |     ospi.u-boot(4m)        |
                 |                            |
        0x700000 +----------------------------+
                 |     ospi.env(128k)         |
                 |                            |
        0x720000 +----------------------------+
                 |   ospi.env.backup(128k)    |
                 |                            |
        0x740000 +----------------------------+
                 |      padding (768k)        |
        0x800000 +----------------------------+
                 |     ospi.rootfs(ubifs)     |
                 |                            |
       0x3fc0000 +----------------------------+
                 |   ospi.phypattern (256k)   |
                 |                            |
                 +----------------------------+

.. ifconfig:: CONFIG_part_variant in ('AM62X')

    AM62x Starter Kit (SK) has a Cypress S28HS512T flash and sysfw is bundled with tiboot3.bin.

    **Flashing images to OSPI**

    The instructions below can be used to download tiboot3.bin, tispl.bin and
    u-boot.img over TFTP and then flash each to OSPI at the respective addresses.

    .. code-block:: console

      => sf probe
      => tftp ${loadaddr} tiboot3.bin
      => sf update $loadaddr 0x0 $filesize
      => tftp ${loadaddr} tispl.bin
      => sf update $loadaddr 0x80000 $filesize
      => tftp ${loadaddr} u-boot.img
      => sf update $loadaddr 0x280000 $filesize

    **Phy calibration**

    Phy calibration allows for higher read performance. To enable phy, the phy
    calibration pattern must be flashed to OSPI at the start of the last erase
    sector. For the Cypress S28HS512T flash, this lies at the address 0x3fc0000.

    Download the binary file containing the phy pattern from :download:`here </files/ospi_phy_pattern>`.
    The commands below can be used to flash the phy pattern, with the location of the
    pattern depending on which flash is being used:

    .. code-block:: console

       => sf probe
       => tftp ${loadaddr} ospi_phy_pattern
       => sf update $loadaddr 0x3fc0000 $filesize

    **Flash layout for OSPI**

    .. code-block:: console

             0x0 +----------------------------+
                 |     ospi.tiboot3(512k)     |
                 |                            |
         0x80000 +----------------------------+
                 |     ospi.tispl(2m)         |
                 |                            |
        0x280000 +----------------------------+
                 |     ospi.u-boot(4m)        |
                 |                            |
        0x680000 +----------------------------+
                 |     ospi.env(128k)         |
                 |                            |
        0x6c0000 +----------------------------+
                 |   ospi.env.backup(128k)    |
                 |                            |
        0x740000 +----------------------------+
                 |      padding (768k)        |
        0x800000 +----------------------------+
                 |     ospi.rootfs(ubifs)     |
                 |                            |
       0x3fc0000 +----------------------------+
                 |   ospi.phypattern (256k)   |
                 |                            |
                 +----------------------------+

    **Enabling QSPI-NOR**

    To use QSPI-NOR Flash with the AM625x SoC, the following changes are needed to configure the bus-width
    to get 1-1-4 Mode working optimally. The OSPI module in the SoC is capable of
    supporting single, dual, quad (QSPI mode) or octal I/O instructions. Cypress s25hs512t QSPI-NOR
    Flash was tested to be working with the AM625x SoC after the following modifications in Device Tree.

    .. code-block:: text

        diff --git a/arch/arm/dts/k3-am625-sk.dts b/arch/arm/dts/k3-am625-sk.dts
        index bfe1e78ed895..980054144d20 100644
        --- a/arch/arm/dts/k3-am625-sk.dts
        +++ b/arch/arm/dts/k3-am625-sk.dts
        @@ -32,8 +32,8 @@
            flash@0{
                compatible = "jedec,spi-nor";
                reg = <0x0>;
        -       spi-tx-bus-width = <8>;
        -       spi-rx-bus-width = <8>;
        +       spi-tx-bus-width = <1>;
        +       spi-rx-bus-width = <4>;
                spi-max-frequency = <25000000>;
                cdns,tshsl-ns = <60>;
                cdns,tsd2d-ns = <60>;
        -- 
        2.25.1

    The reason for choosing tx-bus-width as 1 is due to the fact that writing to flashes is always a
    slow process and thus using multi I/O writes doesn't really offer much performance boost. Hence,
    writes always take place in 1S mode. However, reads can happen much faster and hence we allow for
    Quad Mode rx-bus-width.

.. ifconfig:: CONFIG_part_variant in ('J721S2')

    j721s2 is largely similar to j721e and am654. the major differences are that it
    has the cypress s28hs512t flash and sysfw is bundled with tiboot3.bin.

    **flashing images to ospi**

    below commands can be used to download tiboot3.bin, tispl.bin and
    u-boot.img over tftp and then flash it to ospi at respective addresses.

    .. code-block:: console

      => sf probe
      => tftp ${loadaddr} tiboot3.bin
      => sf update $loadaddr 0x0 $filesize
      => tftp ${loadaddr} tispl.bin
      => sf update $loadaddr 0x80000 $filesize
      => tftp ${loadaddr} u-boot.img
      => sf update $loadaddr 0x280000 $filesize

    **phy calibration**

    phy calibration allows for higher read performance. to enable phy, the phy
    calibration pattern must be flashed to ospi at the start of the last erase
    sector. for the cypress s28hs512t flash, this lies at the address 0x3fc0000.

    download the binary file containing the phy pattern from :download:`here </files/ospi_phy_pattern>`.
    below commands can be used to flash the phy pattern, with the location of the
    pattern depending on which flash is being used:

    .. code-block:: console

       => sf probe
       => tftp ${loadaddr} ospi_phy_pattern
       => sf update $loadaddr 0x3fc0000 $filesize

    **flash layout for ospi**

    .. code-block:: console

             0x0 +----------------------------+
                 |     ospi.tiboot3(1m)       |
                 |                            |
         0x80000 +----------------------------+
                 |     ospi.tispl(2m)         |
                 |                            |
        0x280000 +----------------------------+
                 |     ospi.u-boot(4m)        |
                 |                            |
        0x680000 +----------------------------+
                 |     ospi.env(128k)         |
                 |                            |
        0x6A0000 +----------------------------+
                 |   ospi.env.backup(128k)    |
                 |                            |
        0x6C0000 +----------------------------+
                 |      padding (1280k)       |
        0x800000 +----------------------------+
                 |     ospi.rootfs(ubifs)     |
                 |                            |
       0x3fc0000 +----------------------------+
                 |   ospi.phypattern (256k)   |
                 |                            |
                 +----------------------------+

.. ifconfig:: CONFIG_part_variant in ('J784S4')

    J784S4 is similar to J721S2, only difference being that OSPI is muxed
    externally between a NOR and a NAND flash through a physical switch.
    OSPI NOR and OSPI NAND can't be used at the same time, they need to be
    selected by changing a physical configuration switch on the EVM board
    before driver probes them. CONFIG SW2.1 should be in OFF state to use
    OSPI NOR, and in ON STATE for OSPI NAND.

    **Flashing images to OSPI NOR flash**

    Following commands can be used to download tiboot3.bin, tispl.bin and
    u-boot.img over tftp and then flash it to OSPI at respective addresses.

    .. code-block:: console

      => sf probe
      => tftp ${loadaddr} tiboot3.bin
      => sf update $loadaddr 0x0 $filesize
      => tftp ${loadaddr} tispl.bin
      => sf update $loadaddr 0x80000 $filesize
      => tftp ${loadaddr} u-boot.img
      => sf update $loadaddr 0x280000 $filesize

    **PHY calibration**

    PHY calibration allows for higher read performance. To enable PHY, the PHY
    calibration pattern must be flashed to ospi at the start of the last erase
    sector. For the cypress s28hs512t flash, this lies at the address 0x3fc0000.

    download the binary file containing the phy pattern from :download:`here </files/ospi_phy_pattern>`.
    below commands can be used to flash the phy pattern, with the location of the
    pattern depending on which flash is being used:

    .. code-block:: console

       => sf probe
       => tftp ${loadaddr} ospi_phy_pattern
       => sf update $loadaddr 0x3fc0000 $filesize

    **Flash layout for OSPI NOR**

    .. code-block:: console

             0x0 +----------------------------+
                 |     ospi.tiboot3(1m)       |
                 |                            |
         0x80000 +----------------------------+
                 |     ospi.tispl(2m)         |
                 |                            |
        0x280000 +----------------------------+
                 |     ospi.u-boot(4m)        |
                 |                            |
        0x680000 +----------------------------+
                 |     ospi.env(128k)         |
                 |                            |
        0x6A0000 +----------------------------+
                 |   ospi.env.backup(128k)    |
                 |                            |
        0x6C0000 +----------------------------+
                 |      padding (1280k)       |
        0x800000 +----------------------------+
                 |     ospi.rootfs(ubifs)     |
                 |                            |
       0x3fc0000 +----------------------------+
                 |   ospi.phypattern (256k)   |
                 |                            |
                 +----------------------------+

    **Writing to OSPI using DFU**

    Setup: Connect the Type C port (USB0 port) of EVM to ubuntu host PC. Make sure
    dfu-util tool is installed and USB0 port is in UFP/DRP mode: SW3[3:4] = 01 or 1x.

    ::

         #sudo apt-get install dfu-util

    From u-boot(for OSPI flash):

    ::

        U-Boot # env default -a
        U-Boot # setenv dfu_alt_info ${dfu_alt_info_ospi}; dfu 0 sf "0:0:25000000:0"

    From ubuntu PC: Using dfu-util utilities to flash the binares to OSPI/QSPI flash.

    ::

        # sudo dfu-util -l
        Copyright 2005-2009 Weston Schmidt, Harald Welte and OpenMoko Inc.
        Copyright 2010-2016 Tormod Volden and Stefan Schmidt
        This program is Free Software and has ABSOLUTELY NO WARRANTY

        Found DFU: [0451:6168] ver=0224, devnum=44, cfg=1, intf=0, path="1-3", alt=5, name="rootfs", serial="UNKNOWN"
        Found DFU: [0451:6168] ver=0224, devnum=44, cfg=1, intf=0, path="1-3", alt=4, name="sysfw.itb", serial="UNKNOWN"
        Found DFU: [0451:6168] ver=0224, devnum=44, cfg=1, intf=0, path="1-3", alt=3, name="u-boot-env", serial="UNKNOWN"
        Found DFU: [0451:6168] ver=0224, devnum=44, cfg=1, intf=0, path="1-3", alt=2, name="u-boot.img", serial="UNKNOWN"
        Found DFU: [0451:6168] ver=0224, devnum=44, cfg=1, intf=0, path="1-3", alt=1, name="tispl.bin", serial="UNKNOWN"
        Found DFU: [0451:6168] ver=0224, devnum=44, cfg=1, intf=0, path="1-3", alt=0, name="tiboot3.bin", serial="UNKNOWN"

    Flash the binaries to the respective regions using alternate interface
    number (alt=<x>).

    ::

        # sudo dfu-util -c 1 -i 0 -a 0 -D tiboot3.bin
        # sudo dfu-util -c 1 -i 0 -a 1 -D tispl.bin
        # sudo dfu-util -c 1 -i 0 -a 2 -D u-boot.img

.. ifconfig:: CONFIG_part_variant in ('Gen')

    Memory Layout of QSPI Flash

    ::

        +----------------+ 0x00000
        |      MLO       |
        |                |
        +----------------+ 0x040000
        |   u-boot.img   |
        |                |
        +----------------+ 0x140000
        |   DTB blob     |
        +----------------+ 0x1c0000
        |   u-boot env   |
        +----------------+ 0x1d0000
        |   u-boot env   |
        |    (backup)    |
        +----------------+ 0x1e0000
        |                |
        |     uImage     |
        |                |
        |                |
        +----------------+ 0x9e0000
        |                |
        |  other data    |
        |                |
        +----------------+

    .. rubric:: Writing to QSPI from U-Boot
       :name: writing-to-qspi-from-u-boot

    Note:

    -  From the U-Boot build, the **MLO** and **u-boot.img** files are the
       ones to be written.
    -  We load all files from an SD card in this example but they can just
       as easily be loaded via network (documented above) or other interface
       that exists.

    Writing MLO and u-boot.img binaries.

    For QSPI\_1 build U-Boot with ``dra7xx_evm_config``

    ::

        U-Boot # mmc rescan
        U-Boot # fatload mmc 0 ${loadaddr} MLO
        U-Boot # sf probe 0
        U-Boot # sf erase 0x00000 0x200000
        U-Boot # sf write ${loadaddr} 0x00000 ${filesize}
        U-Boot # fatload mmc 0 ${loadaddr} u-boot.img
        U-Boot # sf write ${loadaddr} 0x40000 ${filesize}

    change SW2[5:0] = 110110 for qspi boot.

    For QSPI\_4 build U-Boot with ``dra7xx_evm_qspiboot_config``

    ::

        U-Boot # mmc rescan
        U-Boot # fatload mmc 0 ${loadaddr} MLO
        U-Boot # sf probe 0
        U-Boot # sf erase 0x00000 0x200000
        U-Boot # sf write ${loadaddr} 0x00000 0x10000
        U-Boot # fatload mmc 0 ${loadaddr} u-boot.img
        U-Boot # sf write ${loadaddr} 0x40000 0x60000

    change SW2[5:0] = 110111 for qspi boot.

    |

    .. rubric:: Writing to QSPI using DFU
       :name: writing-to-qspi-using-dfu

    Setup: Connect the usb0 port of EVM to ubuntu host PC. Make sure
    dfu-util tool is installed.

    ::

         #sudo apt-get install dfu-util

    From u-boot:

    ::

        U-Boot # env default -a
        U-Boot # setenv dfu_alt_info ${dfu_alt_info_qspi}; dfu 0 sf "0:0:64000000:0"

    From ubuntu PC: Using dfu-util utilities to flash the binares to QSPI
    flash.

    ::

        # sudo dfu-util -l
        (C) 2005-2008 by Weston Schmidt, Harald Welte and OpenMoko Inc.
        (C) 2010-2011 Tormod Volden (DfuSe support)
        This program is Free Software and has ABSOLUTELY NO WARRANTY
        dfu-util does currently only support DFU version 1.0
        Found DFU: [0451:d022] devnum=0, cfg=1, intf=0, alt=0, name="MLO"
        Found DFU: [0451:d022] devnum=0, cfg=1, intf=0, alt=1, name="u-boot.img"
        Found DFU: [0451:d022] devnum=0, cfg=1, intf=0, alt=2, name="u-boot-spl-os"
        Found DFU: [0451:d022] devnum=0, cfg=1, intf=0, alt=3, name="u-boot-env"
        Found DFU: [0451:d022] devnum=0, cfg=1, intf=0, alt=4, name="u-boot-env.backup"
        Found DFU: [0451:d022] devnum=0, cfg=1, intf=0, alt=5, name="kernel"

    Flash the binaries to the respective regions using alternate interface
    number (alt=<x>).

    ::

        # sudo dfu-util -c 1 -i 0 -a 0 -D MLO
        # sudo dfu-util -c 1 -i 0 -a 1 -D u-boot.img
        # sudo dfu-util -c 1 -i 0 -a 2 -D <DTB-file>
        # sudo dfu-util -c 1 -i 0 -a 5 -D uImage

    .. rubric:: Booting from QSPI from u-boot
       :name: booting-from-qspi-from-u-boot

    The default environment does not contain a QSPI boot command. The
    following example uses the partition table found in the kernel.

    ::

        U-Boot # sf probe 0
        U-Boot # sf read ${loadaddr} 0x1e0000 0x800000
        U-Boot # sf read ${fdtaddr} 0x140000 0x80000
        U-Boot # setenv bootargs console=${console} root=/dev/mtdblock19 rootfstype=jffs2
        U-Boot # bootz ${loadaddr} - ${fdtaddr}

    .. rubric:: Booting from QSPI from SPL (Single stage or Falcon mode)
       :name: booting-from-qspi-from-spl-single-stage-or-falcon-mode

    In this boot mode SPL (first stage bootloader) directly boots the Linux
    kernel. Optionally, in order to enter into U-Boot, reset the board while
    keeping 'c' key on the serial terminal pressed. When falcon mode is
    enabled in U-Boot build (usually enabled by default), MLO checks if
    there is a valid uImage present at a defined offset. If uImage is
    present, it is booted directly. If valid uImage is not found, MLO falls
    back to booting u-boot.img.

    For QSPI single stage or Falcon mode, the CONFIG\_QSPI\_BOOT shall
    enabled.

    ::

        Menuconfig->Bood media
           [ ] Support for booting from NAND flash
           ..
           [*] Support for booting from QSPI flash
           [ ] Support for booting from SATA
           ...

    MLO, u-boot.img (optional), DTB, uImage are stored in QSPI flash memory.
    Refer the "Memory Layout" section for offset details. To flash binaries
    to QSPI, you can use
    `DFU <Foundational_Components_U-Boot.html#writing-to-qspi-using-dfu>`__,
    for example.

    The QSPI boot uses uImage. Build the kernel uImage. You will need to
    keep the U-Boot tool ``mkimage`` in your ``$PATH``

    ::

        # make uImage modules dtbs LOADADDR=80008000

    If kernel is not build with ``CONFIG_CMDLINE`` to set correct bootargs,
    then add the needed bootargs in chosen node in DTB file, using fdtput
    host utility. For example, for DRA74x EVM:

    ::

        # fdtput -v -t s arch/arm/boot/dts/dra7-evm.dtb "/chosen" bootargs "console=ttyO0,115200n8 root=<rootfs>"

    Set the environment variable "boot\_os" to 1.

    From u-boot prompt

    ::

        => setenv boot_os 1
        => saveenv

    Set the `board boot from
    QSPI <Foundational_Components_U-Boot.html#writing-to-qspi-from-u-boot>`__
    and reset the EVM. The SPL directly boots the kernel image from QSPI.

.. ifconfig:: CONFIG_part_variant in ('AM335X')

    SPI boot is supported on the following platforms:

    +--------------+-----------------------------------------------------------+
    | Board        | Config target                                             |
    +==============+===========================================================+
    | AM335x ICE   | am335x\_evm\_spiboot_defconfig                            |
    +--------------+-----------------------------------------------------------+

    ::

	    U-Boot # mmc rescan
	    U-Boot # sf probe 0
	    U-Boot # sf erase 0x0 0x100000
	    U-Boot # fatload mmc 0 ${loadaddr} MLO.byteswap
	    U-Boot # sf write ${loadaddr} 0x0 ${filesize}
	    U-Boot # fatload mmc 0 ${loadaddr} u-boot.img
	    U-Boot # sf write ${loadaddr} 0x20000 ${filesize}

    Note:

    -  AM335X ICE boots from SPI by default. To boot from SD card, erase the
       MLO partition:

    ::

	    U-Boot # sf erase 0x0 0x20000

.. ifconfig:: CONFIG_part_variant in ('AM437X')

    Using QSPI on AM43xx platforms is done as eXecute In Place and U-Boot is
    directly booted.

    .. rubric:: Writing to QSPI from U-Boot
       :name: writing-to-qspi-from-u-boot-1

    Note:

    -  From the U-Boot build the **u-boot.bin** file is the one to be
       written.
    -  We load all files from an SD card in this example but they can just
       as easily be loaded via network (documented above) or other interface
       that exists.

    ::

        U-Boot # mmc rescan
        U-Boot # fatload mmc 0 ${loadaddr} u-boot.bin
        U-Boot # sf probe 0
        U-Boot # sf erase 0x0 0x100000
        U-Boot # sf write ${loadaddr} 0x0 ${filesize}

    .. rubric:: Booting from QSPI
       :name: booting-from-qspi

    The default environment does not contain a QSPI boot command. The
    following example uses the partition table found in the kernel.

    ::

        U-Boot # sf probe 0
        U-Boot # sf read ${loadaddr} 0x1a0000 0x800000
        U-Boot # sf read ${fdtaddr} 0x100000 0x80000
        U-Boot # setenv bootargs console=${console} spi-ti-qspi.enable_qspi=1 root=/dev/mtdblock6 rootfstype=jffs2
        U-Boot # bootz ${loadaddr} - ${fdtaddr}

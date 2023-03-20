RemoteProc
------------

This section documents how to initialize, load, start and stop remote cores from U-Boot prompt.
Following remotecores support is available in U-boot:

-  Cortex-R5F in Lockstep more
-  Cortex-R5F in split mode
-  C66x DSP
-  C71x DSP

Initialization
^^^^^^^^^^^^^^^

U-Boot supports for initializing all the available remotecores in one go or
initialize individual core based on the DT alias id.

The below command will initialize all the available remote cores:

::

    => rproc init

The below command will initialize just the given remote core

::

   => rproc init <id>

The below command lists all the available/initialized remotecores in the system.

::

   => rproc list
   0 - Name:'r5f@41000000' type:'internal memory mapped' supports: load start stop reset
   1 - Name:'r5f@41400000' type:'internal memory mapped' supports: load start stop reset
   2 - Name:'r5f@5c00000' type:'internal memory mapped' supports: load start stop reset
   3 - Name:'r5f@5d00000' type:'internal memory mapped' supports: load start stop reset
   4 - Name:'r5f@5e00000' type:'internal memory mapped' supports: load start stop reset
   5 - Name:'r5f@5f00000' type:'internal memory mapped' supports: load start stop reset
   6 - Name:'dsp@4d80800000' type:'internal memory mapped' supports: load start stop reset
   7 - Name:'dsp@4d81800000' type:'internal memory mapped' supports: load start stop reset
   8 - Name:'dsp@64800000' type:'internal memory mapped' supports: load start stop reset


Loading
^^^^^^^^

Once Initialized, remotecores can be loaded with a relevant image. Make sure
image is loaded only after initializing the core.

::

    => load mmc 1:2 0x90000000 /lib/firmware/j7-main-r5f0_0-fw
    2536540 bytes read in 112 ms (21.6 MiB/s)
    => rproc load 2 0x90000000 0x${filesize}
    Load Remote Processor 2 with data@addr=0x90000000 2536540 bytes: Success!


Starting
^^^^^^^^^

Successfully loaded remotecore can be started using the following command.

::

    => rproc start 2

Stop
^^^^^

A running remotecore can be stopped using the following command.

::

    => rproc stop 2

Make sure all the commands are run in the above given sequence. Currently IPC
is not supported in U-boot.

HS Devices
^^^^^^^^^^

HS Devices by default use the secure firmware images present in the filesystem
for booting the remoteproc cores. Symlinks to these secure firmware images have
a suffix of `-sec` on them.

All the firmware images are authenticated while loading from U-boot.

Steps for signing and updating firmware images in filesystem.

.. rubric:: Getting Security Dev Tool

::

    $ git clone https://git.ti.com/git/security-development-tools/core-secdev-k3.git -b master
    $ export TI_SECURE_DEV_PKG=`pwd`/core-secdev-k3

.. rubric:: Signing the firmware

::

    $ ${TI_SECURE_DEV_PKG}/scripts/secure-binary-image.sh $FIRMWARE $FIRMWARE.signed

.. rubric:: Updating firmware image

::

    $ ln -vfs $FIRMWARE.signed /lib/firmware/j7-main-r5f0_0-fw-sec

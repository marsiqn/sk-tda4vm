*********************
IPC Low Level Driver
*********************

Overview
==================================

On AM64x/AM65X/Jacinto 7 platforms, a lower level IPC driver (IPC LLD) using rpmsg-based transport is included in the Processor SDK RTOS
release. Sample firmware binaries for all remote cores are located at <Processor SDK Linux root filesystem>/lib/firmware.
Jacinto 7/AM65X remote cores can be loaded by u-boot from the filesystem as part of the boot sequence. The Processor SDK Linux
release also supports loading the remote firmware by remoteproc kernel driver. The remote firmware demonstrates the interprocessor
communication between the cores - Linux to/from RTOS and RTOS to/from RTOS.

J721e u-boot can load the following cores:
 - all Main-R5Fs
 - C66x_1
 - C66x_2
 - C7x_1

Linux remoteproc kernel driver can support loading to all cores.

Please refer to the PDK IPC LLD documentation included with the Processor SDK RTOS release documentation for additional details.

Additionally, a ti_rpmsg_char utility library is available for Linux user-space applications. The library provides an easy means to
identify rpmsg character devies created by the Linux kernel rpmsg-char driver using the virtio-rpmsg-bus transport back-end.
The ti_rpmsg_char userspace library source code is located at https://git.ti.com/cgit/rpmsg/ti-rpmsg-char/.

For more details regarding the ti_rpmsg_char library, see the README at https://git.ti.com/cgit/rpmsg/ti-rpmsg-char/about/.

The ti-rpmsg-char repo also provides a user-space example called rpmsg-char-simple. The PDK IPC LLD "ipc_echo_test" firmwares can be used
as sample firmwares for testing along with rpmsg-char-simple. For information regarding the rpmsg-char-simple example,
see the README at https://git.ti.com/cgit/rpmsg/ti-rpmsg-char/tree/examples/README.

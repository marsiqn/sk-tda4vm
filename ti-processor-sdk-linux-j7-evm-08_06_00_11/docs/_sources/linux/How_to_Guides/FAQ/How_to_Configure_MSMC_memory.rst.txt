How to configure K3 MSMC memory for use as SRAM or L3 cache?
==================================================================

In Keystone devices, there exists on-chip memory at the MSMC interconnect.
This can be configured either as SRAM or as L3 cache.

Automotive ADAS applications, which use C7x, benefit a lot when the MSMC memory
is configured as SRAM. Alternatively, the CPU benchmark applications get performance
boost when the memory is configured as cache.

Typically, MSMC memory needs to be split between SRAM and cache with the split boundary
being aligned at 1MB. System firmware partitions SRAM between cache and SRAM at
the bootup based on the board config data structure.

Rebuild the system firmware image (sysfw.itb) with right board config to
change to desired behavior. Following are the steps to achieve this:

Modify the file **soc/j721e/evm/board-cfg.c** in **system-firmware-image-gen** repo
from the installer.

::

    /* boardcfg_msmc */
    .msmc = {
            .subhdr = {
                    .magic = BOARDCFG_MSMC_MAGIC_NUM,
                    .size = sizeof(struct boardcfg_msmc),
            },
            .msmc_cache_size = 0x0,
    },

Here, the msmc_cache_size variable can take values from 0x0 to 0xf, where 0x0
describes zero cache and 0xf describes full cache. Note that due to hardware
restriction, the total memory that gets configured as cache is rounded up to 1MB.

Following table describes an example of this for J721e platform.

+-----------------+-----------------------------------------------------------+
| msmc_cache_size | Description                                               |
+=================+===========================================================+
| 0x0             | All of MSMC memory (i.e. 8MB) configured as SRAM          |
+-----------------+-----------------------------------------------------------+
| 0x3             | 2MB of MSMC memory configured as cache, rest 6MB is SRAM  |
+-----------------+-----------------------------------------------------------+
| 0x6             | 3MB of MSMC memory configured as cache, rest 5MB is SRAM  |
+-----------------+-----------------------------------------------------------+
| 0xf             | All of MSMC memory (i.e. 8MB) configured as cache         |
+-----------------+-----------------------------------------------------------+

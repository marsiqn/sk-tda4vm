DFS
----

.. rubric:: Overview

Dynamic frequency scaling (DFS) is the ability of a part to modify
frequency it operates at based on need, user preference, or other
factors. MPU DFS is supported in the kernel by the cpufreq driver. All
supported SoCs use the generic cpufreq driver. The frequency at which
the MPU operates is selected by a driver called a governor. Each
governor has a different strategy for selecting the most appropriate
frequency. The following governors are available within the kernel:

-  **ondemand**: This governor samples the load of the cpu and scales it
   up aggressively in order to provide the proper amount of processing
   power.
-  **conservative**: This governor is similar to ondemand but uses a
   less aggressive method of increasing the the OPP of the MPU.
-  **performance**: This governor statically sets the OPP of the MPU to
   the highest possible frequency.
-  **powersave**: This governor statically sets the OPP of the MPU to
   the lowest possible frequency.
-  **userspace**: This governor allows the user to set the desired OPP
   using any value found within scaling\_available\_frequencies by
   echoing it into scaling\_setspeed.

More in depth documentation about each governor can be found in the
linux kernel documentation here:
https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt

By default, cpufreq, the cpufreq driver, and all of the standard
governors are enabled with the ondemand governor selected as the default
governor. To make changes, follow the instructions below.

.. rubric:: Source Location

drivers/cpufreq/cpufreq-dt.c

The OPP data itself is used by the cpufreq DT driver to scale frequencies
based on the governors.

.. rubric:: Kernel Configuration Options

The driver can be built into the kernel as a static module, dynamic
module, or both.

$ make menuconfig

Select CPU Power Management from the main menu.

::

       ...
       ...
       Boot options --->
       CPU Power Management --->
       Floating point emulation --->
       ...

Select CPU Frequency Scaling as shown here:

::

       ...
       ...
           CPU Frequency Scaling --->
       [*] CPU idle PM support
       ...

All relevant options are listed below:

::

        [*] CPU Frequency scaling
        <*>   CPU frequency translation statistics
        [*]     CPU frequency translation statistics details
              Default CPUFreq governor (userspace)  --->
        <*>   'performance' governor
        <*>   'powersave' governor
        -*-   'userspace' governor for userspace frequency scaling
        <*>   'ondemand' cpufreq policy governor
        <*>   'conservative' cpufreq governor
              *** CPU frequency scaling drivers ***
        <M>   Generic DT based cpufreq driver
        <M>   Generic DT based cpufreq driver using clk notifiers
        <*>    Texas Instruments CPUFreq support
       ...

.. rubric:: DT Configuration

The clock information and the operating-points table need to be added as
given in the example below.

::

    /* From arch/arm64/boot/dts/ti/k3-j7200.dtsi */

    cpus {
		#address-cells = <1>;
		#size-cells = <0>;
		cpu-map {
			cluster0: cluster0 {
				core0 {
					cpu = <&cpu0>;
				};

				core1 {
					cpu = <&cpu1>;
				};
			};

		};

		cpu0: cpu@0 {
			compatible = "arm,cortex-a72";
			reg = <0x000>;
			device_type = "cpu";
			enable-method = "psci";
			i-cache-size = <0xc000>;
			i-cache-line-size = <64>;
			i-cache-sets = <256>;
			d-cache-size = <0x8000>;
			d-cache-line-size = <64>;
			d-cache-sets = <256>;
			next-level-cache = <&L2_0>;
			clocks = <&k3_clks 202 2>;
			clock-names = "cpu";
			operating-points-v2 = <&cpu0_opp_table>;
			#cooling-cells = <2>; /* min followed by max */
		};

		cpu1: cpu@1 {
			compatible = "arm,cortex-a72";
			reg = <0x001>;
			device_type = "cpu";
			enable-method = "psci";
			i-cache-size = <0xc000>;
			i-cache-line-size = <64>;
			i-cache-sets = <256>;
			d-cache-size = <0x8000>;
			d-cache-line-size = <64>;
			d-cache-sets = <256>;
			next-level-cache = <&L2_0>;
			operating-points-v2 = <&cpu0_opp_table>;
			#cooling-cells = <2>; /* min followed by max */
			clocks = <&k3_clks 203 0>;
			clock-names = "cpu";
		};
	};

.. rubric:: Driver Usage

All of the standard governors are built-in to the kernel, and by default
the performance governor is selected. Performance governor sets the CPU
statically to the highest frequency within the borders of scaling_min_freq
and scaling_max_freq.

To view available governors,

::

    $ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
    conservative userspace powersave ondemand performance

To view current governor,

::

    $ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    ondemand

To set a governor,

::

    $ echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

To view current OPP (frequency in kHz)

::

    $ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
    2000000000

To view supported OPP's (frequency in kHz),

::

    $ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
    750000000 1000000000 1500000000 2000000000

To change OPP (can be done only for userspace governor. If governors
like ondemand is used, OPP change happens automatically based on the
system load)

::

    $ echo 1000000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed

|

.. rubric:: Operating Points
   :name: operating-points

Design: OPP term is derived from the usage in DVFS where they are a
pair of voltage frequency value. To keep compatibility with the DVFS
system, DFS uses same OPP tables with the voltages removed from the
table.

::

    /* From arch/arm64/boot/dts/ti/k3-j7200.dtsi */

	cpu0_opp_table: opp-table {
		compatible = "operating-points-v2";

		opp4-2000000000 {
			opp-hz = /bits/ 64 <2000000000>;
		};

		opp3-1500000000 {
			opp-hz = /bits/ 64 <1500000000>;
		};

		opp2-1000000000 {
			opp-hz = /bits/ 64 <1000000000>;
		};

		opp1-750000000 {
			opp-hz = /bits/ 64 <750000000>;
		};
	};

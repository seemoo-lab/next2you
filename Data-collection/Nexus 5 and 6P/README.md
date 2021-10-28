# CSI Collector: Nexus 5 and Nexus 6P

This folder contains the codebase, enabling channel state information (CSI) data collection with Nexus 5 and Nexus 6P smartphones,  for the paper "Next2You: Robust Copresence Detection Based on Channel State Information", by Mikhail Fomichev, Luis F. Abanto-Leon, Max Stiegler, Alejandro Molina, Jakob Link, Matthias Hollick, in ACM Transactions on Internet of Things, vol. 1, Issue 1, 2021.

## Getting Started

### Build and install the patched firmware on a Nexus 5 or Nexus 6P
On a linux machine (tested with Ubuntu 16.04) follow these steps:

1. Install some dependencies: `sudo apt-get install git gawk qpdf adb flex bison`  
**Only necessary for x86_64 systems**, install i386 libs:

    ```
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386
    ```

2. Clone the _nexmon_ repository: `git clone https://github.com/seemoo-lab/nexmon.git`

3. In the root directory of the repository: `cd nexmon`
    * Setup the build environment: `source setup_env.sh`
    * Compile some build tools and extract the ucode and flashpatches from the original firmware files: `make` 

4. Connect the smartphone, which must be rooted, have `su` installed and USB-Debugging enabled, via USB to the machine.

5. Install the _nexutil_ tool:
    * Change from the _nexmon_ root directory: `cd utilities/nexutil`
    * Compile and install _nexutil_: `make install`
    * Change back directory: `cd ../..`

6. Go to the *patches* folder of your target device:
    * Nexus 5: `cd patches/bcm4339/6_37_34_43/`
    * Nexus 6P: `cd patches/bcm4358/7_112_300_14_sta/`

7. Copy the _next2you_ patch folder of this repository: `cp -r next2you/Data-collection/Nexus\ 5\ and\ 6P/next2you/ .`

8. Generate a backup of the original firmware file: `make backup-firmware`

9. Compile and install the patched firmware on the smartphone: `make && make install-firmware`

**Note: Setup the build environment for each session. You only need to repeat steps 4, 5, 6, 8 and 9 to equip more smartphones.**

### Build and install the collector application on a Nexus 5 or Nexus 6P

Use an Android application building environment, e.g. Android Studio, to compile and install the collector application:

* The _CSIDataCollector_ directory of this repository holds the Android project for the Nexus 5.

* The _CSIDataCollector6P_ directory of this repository holds the Android project for the Nexus 6P.

## Authors

Max Stiegler and Jakob Link


## License

If not indicated in the code otherwise, the code is licensed under the Apache 2.0 - see [LICENSE](https://github.com/seemoo-lab/next2you/blob/main/LICENSE) for details.

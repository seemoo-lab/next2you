# CSI Collector: Raspberry Pi

This folder contains the codebase, enabling channel state information (CSI) data collection with Raspberry Pi 3 Model B+,  for the paper "Next2You: Robust Copresence Detection Based on Channel State Information", by Mikhail Fomichev, Luis F. Abanto-Leon, Max Stiegler, Alejandro Molina, Jakob Link, Matthias Hollick, in ACM Transactions on Internet of Things, vol. 1, Issue 1, 2021.

## Getting Started

### Build and install the patched firmware on a Raspberry Pi 3B+/4B

On a Raspberry Pi 3B+/4B running Raspbian/Raspberry Pi OS with kernel 4.19 or 5.4 follow these steps:

1. Update your Raspbian sources: `sudo apt-get update`.

2. Install some dependencies: `sudo apt install git bc libssl-dev libgmp3-dev gawk qpdf bison flex make autoconf libtool texinfo python3 python3-pip libatlas-base-dev`.

3. Install kernel-headers using [rpi-source](https://github.com/RPi-Distro/rpi-source):
    
    ```
    sudo wget https://raw.githubusercontent.com/RPi-Distro/rpi-source/master/rpi-source -O /usr/local/bin/rpi-source
    sudo chmod +x /usr/local/bin/rpi-source && /usr/local/bin/rpi-source -q --tag-update
    rpi-source
    ```

4. Clone the nexmon base repository: `git clone https://github.com/seemoo-lab/nexmon.git`.

5. Go into the root directory of the repository: `cd nexmon`.

6. Check if `/usr/lib/arm-linux-gnueabihf/libisl.so.10` exists, if not, compile it from source:  
    `cd buildtools/isl-0.10`, `./configure`, `make`, `sudo make install`, `sudo ln -s /usr/local/lib/libisl.so /usr/lib/arm-linux-gnueabihf/libisl.so.10`

7. Check if `/usr/lib/arm-linux-gnueabihf/libmpfr.so.4` exists, if not, compile it from source:  
    `cd buildtools/mpfr-3.1.4`, `autoreconf -f -i`, `./configure`, `make`, `sudo make install`, `sudo ln -s /usr/local/lib/libmpfr.so /usr/lib/arm-linux-gnueabihf/libmpfr.so.4`

8. Then setup the build environment for compiling firmware patches from the _nexmon_ root directory: `cd ../../../nexmon`:
    * Setup the build environment: `source setup_env.sh`.
    * Run `make` to extract ucode, templateram and flashpatches from the original firmwares.

9. Install the _nexutil_ tool:
    * Change from the nexmon root directory: `cd utilities/nexutil`
    * Compile and install nexutil: `sudo -E make install`
    * Change back directory: `cd ../..`

10. Navigate to the patches folder: `cd patches/bcm43455c0/7_45_189/`  
    and copy the _next2you_ patch folder of this repository: `cp -r next2you/Data-collection/Raspberry\ Pi/next2you/ .`

12. Enter the _next2you_ directory: `cd next2you`.

13. Install python requirements: `pip3 install -r requirements.txt`.

14. Make a backup of the original firmware: `make backup-firmware`.

15. Install the firmware and start collecting by running: `./run_exp.sh 2` to capture on channel 1/20, or `./run_exp.sh 5` for channel 157/80.

### Fetch collected data

Collected data can be found in `next2you/data/`.


## Author

Jakob Link <jlink@seemoo.tu-darmstadt.de>


## License

If not indicated in the code otherwise, the code is licensed under the Apache 2.0 - see [LICENSE](https://github.com/seemoo-lab/next2you/blob/main/LICENSE) for details.

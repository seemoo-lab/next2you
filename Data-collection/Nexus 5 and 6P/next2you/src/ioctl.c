/***************************************************************************
 *                                                                         *
 *          ###########   ###########   ##########    ##########           *
 *         ############  ############  ############  ############          *
 *         ##            ##            ##   ##   ##  ##        ##          *
 *         ##            ##            ##   ##   ##  ##        ##          *
 *         ###########   ####  ######  ##   ##   ##  ##    ######          *
 *          ###########  ####  #       ##   ##   ##  ##    #    #          *
 *                   ##  ##    ######  ##   ##   ##  ##    #    #          *
 *                   ##  ##    #       ##   ##   ##  ##    #    #          *
 *         ############  ##### ######  ##   ##   ##  ##### ######          *
 *         ###########    ###########  ##   ##   ##   ##########           *
 *                                                                         *
 *            S E C U R E   M O B I L E   N E T W O R K I N G              *
 *                                                                         *
 * Copyright (c) 2019 Matthias Schulz                                      *
 *                                                                         *
 * Permission is hereby granted, free of charge, to any person obtaining a *
 * copy of this software and associated documentation files (the           *
 * "Software"), to deal in the Software without restriction, including     *
 * without limitation the rights to use, copy, modify, merge, publish,     *
 * distribute, sublicense, and/or sell copies of the Software, and to      *
 * permit persons to whom the Software is furnished to do so, subject to   *
 * the following conditions:                                               *
 *                                                                         *
 * 1. The above copyright notice and this permission notice shall be       *
 *    include in all copies or substantial portions of the Software.       *
 *                                                                         *
 * 2. Any use of the Software which results in an academic publication or  *
 *    other publication which includes a bibliography must include         *
 *    citations to the nexmon project a) and the paper cited under b):     *
 *                                                                         *
 *    a) "Matthias Schulz, Daniel Wegemer and Matthias Hollick. Nexmon:    *
 *        The C-based Firmware Patching Framework. https://nexmon.org"     *
 *                                                                         *
 *    b) "Francesco Gringoli, Matthias Schulz, Jakob Link, and Matthias    *
 *        Hollick. Free Your CSI: A Channel State Information Extraction   *
 *        Platform For Modern Wi-Fi Chipsets. Accepted to appear in        *
 *        Proceedings of the 13th Workshop on Wireless Network Testbeds,   *
 *        Experimental evaluation & CHaracterization (WiNTECH 2019),       *
 *        October 2019."                                                   *
 *                                                                         *
 * 3. The Software is not used by, in cooperation with, or on behalf of    *
 *    any armed forces, intelligence agencies, reconnaissance agencies,    *
 *    defense agencies, offense agencies or any supplier, contractor, or   *
 *    research associated.                                                 *
 *                                                                         *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS *
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF              *
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  *
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY    *
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,    *
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE       *
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                  *
 *                                                                         *
 **************************************************************************/

#pragma NEXMON targetregion "patch"

#include <firmware_version.h>   // definition of firmware version macros
#include <debug.h>              // contains macros to access the debug hardware
#include <wrapper.h>            // wrapper definitions for functions that already exist in the firmware
#include <structs.h>            // structures that are used by the code in the firmware
#include <helper.h>             // useful helper functions
#include <patcher.h>            // macros used to craete patches such as BLPatch, BPatch, ...
#include <rates.h>              // rates used to build the ratespec for frame injection
#include <nexioctls.h>          // ioctls added in the nexmon patch
#include <version.h>            // version information
#include <argprintf.h>          // allows to execute argprintf to print into the arg buffer
#include <sendframe.h>
#include "../include/frame_structs.h"

struct mpdu_ac qosdata = {
    .frame_control  = 0x4288,
    .duration       = 0x0000,   // set elsewhere to 60ms
    .address1       = { 0xaa, 0xaa, 0x00, 0x0d, 0x0f, 0xff },   // set desired hw address here
    .address2       = { 0xaa, 0xaa, 0x00, 0x01, 0x02, 0x03 },
    .address3       = { 0x12, 0x34, 0x56, 0x65, 0x43, 0x21 },
    .sequence_control = 0x0010,
    .address4       = { 0x01, 0x00, 0x01, 0x00, 0x01, 0x00 },
    .qos_control    = 0x0007,
    .frame_body     = { 0xa0, 0x39, 0xf7, 'N', 'E', 'X', 'T', 'O', 'Y', 'O', 'U', 'N', 'E', 'X', 'T', 'O', 'Y', 'O', 'U', 'N', 'E', 'X', 'T', 'O', 'Y', 'O', 'U', 'N', 'E', 'X', 'T', 'O' },
    .fcs            = 0x00000000,   // calculated & set elsewhere
};

static void
exp_set_gains_by_index(struct phy_info *pi, int8 index)
{
    ac_txgain_setting_t gains = { 0 };
    wlc_phy_txpwrctrl_enable_acphy(pi, 0);
    wlc_phy_get_txgain_settings_by_index_acphy(pi, &gains, index);
    wlc_phy_txcal_txgain_cleanup_acphy(pi, &gains);
}

int8 pwr_index = 20;

int 
wlc_ioctl_hook(struct wlc_info *wlc, int cmd, char *arg, int len, void *wlc_if)
{
    int ret = IOCTL_ERROR;
    argprintf_init(arg, len);

    switch(cmd) {

        case 500: // set csi_collect
        {
            // deactivate scanning
            set_scansuppress(wlc, 1);
            // deactivate minimum power consumption
            set_mpc(wlc, 0);
            if (wlc->hw->up && len > 1) {
                wlc_bmac_write_shm(wlc->hw, 0x8b0 * 2, *(uint16 *) arg);
                ret = IOCTL_SUCCESS;
            }
            break;
        }

        case 504: // send a single broadcast message over 80MHz
        {
            sk_buff* p = pkt_buf_get_skb(wlc->osh, 64+202);
            if (p) {
                // set the retransmission settings
                set_intioctl(wlc, WLC_SET_LRL, 1);
                set_intioctl(wlc, WLC_SET_SRL, 1);
                // deactivate minimum power consumption
                set_mpc(wlc, 0);
                // set power
                struct phy_info *pi = wlc->hw->band->pi;
                exp_set_gains_by_index(pi, pwr_index);
                // pull to have space for d11txhdrs
                skb_pull(p, 202);
                memcpy(p->data, &qosdata, sizeof(qosdata));
                sendframe(wlc, p, 0, RATES_OVERRIDE_MODE | RATES_ENCODE_VHT | RATES_BW_80MHZ | RATES_VHT_MCS(0) | RATES_VHT_NSS(1));
                set_mpc(wlc, 1);
                ret = IOCTL_SUCCESS;
            }
            break;
        }

        case 505: // send a single broadcast message over 20MHz
        {
            sk_buff* p = pkt_buf_get_skb(wlc->osh, 64+202);
            if (p) {
                // set the retransmission settings
                set_intioctl(wlc, WLC_SET_LRL, 1);
                set_intioctl(wlc, WLC_SET_SRL, 1);
                // deactivate minimum power consumption
                set_mpc(wlc, 0);
                // set power
                struct phy_info *pi = wlc->hw->band->pi;
                exp_set_gains_by_index(pi, pwr_index);
                // pull to have space for d11txhdrs
                skb_pull(p, 202);
                memcpy(p->data, &qosdata, sizeof(qosdata));
                sendframe(wlc, p, 0, RATES_OVERRIDE_MODE | RATES_ENCODE_HT | RATES_BW_20MHZ | RATES_HT_MCS(0));
                set_mpc(wlc, 1);
                ret = IOCTL_SUCCESS;
            }
            break;
        }

        default:
            ret = wlc_ioctl(wlc, cmd, arg, len, wlc_if);
    }

    return ret;
}

__attribute__((at(0x1F3488, "", CHIP_VER_BCM4339, FW_VER_6_37_32_RC23_34_43_r639704)))
__attribute__((at(0x1F3230, "", CHIP_VER_BCM4358, FW_VER_7_112_300_14)))
GenericPatch4(wlc_ioctl_hook, wlc_ioctl_hook + 1);

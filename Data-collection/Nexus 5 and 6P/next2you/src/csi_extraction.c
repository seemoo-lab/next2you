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
#include <wrapper.h>            // wrapper definitions for functions that already exist in the firmware
#include <structs.h>            // structures that are used by the code in the firmware
#include <helper.h>             // useful helper functions
#include <patcher.h>            // macros used to craete patches such as BLPatch, BPatch, ...
#include <rxhdrlen.h>           // contains RX_HDR_LEN and RX_HDR_EXTRA
#include <nexioctls.h>          // ioctls added in the nexmon patch
#include <rates.h>

#define WL_RSSI_ANT_MAX     4   /* max possible rx antennas */

struct ethernet_ip_udp_header header = {
  .ethernet = {
    .dst = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF },
    .src = { 'N', 'E', 'X', 'M', 'O', 'N' },
    .type = 0x0008
  },
  .ip = {
    .version_ihl = 0x45,
    .dscp_ecn = 0x00,
    .total_length = 0x0000,
    .identification = 0x0100,
    .flags_fragment_offset = 0x0000,
    .ttl = 0x01, 
    .protocol = 0x11,
    .header_checksum = 0x0000,
    .src_ip.array = { 10, 10, 10, 10 },
    .dst_ip.array = { 255, 255, 255, 255 }
  },
  .udp = {
    .src_port = HTONS(5500),
    .dst_port = HTONS(5500),
    .len_chk_cov.length = 0x0000,
    .checksum = 0x0000
  }
};

/**
 * Calculates the IPv4 header checksum given the total IPv4 packet length.
 *
 * This checksum is specific to the packet format above. This is not a full
 * implementation of the checksum algorithm. Instead, as much as possible is
 * precalculated to reduce the amount of computation needed. This calculation
 * is accurate for total lengths up to 42457. 
 */
static inline uint16_t
calc_checksum(uint16_t total_len)
{
    return ~(17938 + header.ip.src_ip.array[0] * 256 + header.ip.src_ip.array[1] + header.ip.src_ip.array[2] * 256 + header.ip.src_ip.array[3] + total_len); // 23078 - 2570 - 2570 (ip src)
}

void
prepend_modified_ethernet_ipv4_udp_header(struct sk_buff *p)
{
    header.ip.total_length = htons(p->len + sizeof(struct ip_header) + sizeof(struct udp_header));
    header.ip.header_checksum = htons(calc_checksum(p->len + sizeof(struct ip_header) + sizeof(struct udp_header)));
    header.udp.len_chk_cov.length = htons(p->len + sizeof(struct udp_header));

    skb_push(p, sizeof(header));
    memcpy(p->data, &header, sizeof(header));
}

// header of csi frame coming from ucode
struct d11csihdr {
    uint16 RxFrameSize;                 /* 0x000 Set to 0x2 for CSI frames */
    uint16 NexmonExt;                   /* 0x002 */
    uint32 csi[];                       /* 0x004 Array of CSI data */
} __attribute__((packed));

// original hardware header
struct d11rxhdr {
    uint16 RxFrameSize;                 /* 0x000 Set to 0x2 for CSI frames */
    uint16 NexmonExt;                   /* 0x002 */
    uint16 PhyRxStatus_0;               /* 0x004 PhyRxStatus 15:0 */
    uint16 PhyRxStatus_1;               /* 0x006 PhyRxStatus 31:16 */
    uint16 PhyRxStatus_2;               /* 0x008 PhyRxStatus 47:32 */
    uint16 PhyRxStatus_3;               /* 0x00a PhyRxStatus 63:48 */
    uint16 PhyRxStatus_4;               /* 0x00c PhyRxStatus 79:64 */
    uint16 PhyRxStatus_5;               /* 0x00e PhyRxStatus 95:80 */
    uint16 RxStatus1;                   /* 0x010 MAC Rx Status */
    uint16 RxStatus2;                   /* 0x012 extended MAC Rx status */
    uint16 RxTSFTime;                   /* 0x014 RxTSFTime time of first MAC symbol + M_PHY_PLCPRX_DLY */
    uint16 RxChan;                      /* 0x016 gain code, channel radio code, and phy type */
} __attribute__((packed));

// header or regular frame coming from ucode
struct nexmon_d11rxhdr {
    struct d11rxhdr rxhdr;              /* 0x000 d11rxhdr */
    uint8 SrcMac[6];                    /* 0x018 source mac address */
} __attribute__((packed));

// header after process_frame_hook
struct wlc_d11rxhdr {
    struct d11rxhdr rxhdr;              /* 0x000 d11rxhdr */
    uint32  tsf_l;                      /* 0x018 TSF_L reading */
    int8    rssi;                       /* 0x01c computed instantaneous rssi in BMAC */
    int8    rxpwr0;                     /* 0x01d obsoleted, place holder for legacy ROM code. use rxpwr[] */
    int8    rxpwr1;                     /* 0x01e obsoleted, place holder for legacy ROM code. use rxpwr[] */
    int8    do_rssi_ma;                 /* 0x01f do per-pkt sampling for per-antenna ma in HIGH */
    int8    rxpwr[WL_RSSI_ANT_MAX];     /* 0x020 rssi for supported antennas */
    int8    rssi_qdb;                   /* 0x024 qdB portion of the computed rssi */
    uint8   PAD[2];                     /* 0x025 extra padding to fill up RX_HDR_EXTRA */
} __attribute__((packed));

struct csi_value_i16 {
    int16 i;
    int16 q;
} __attribute__((packed));

struct csi_udp_frame {
    struct ethernet_ip_udp_header hdrs;
    uint32 kk1;
    uint8 SrcMac[6];
    uint32 kk2;
    struct csi_value_i16 csi_values[];
} __attribute__((packed));

uint16 missing_csi_frames = 0;
uint16 inserted_csi_values = 0;
struct sk_buff *p_csi = 0;

struct int14 {signed int val:14;} __attribute__((packed));

void
create_new_csi_frame(struct wl_info *wl, struct sk_buff *p, struct wlc_d11rxhdr *wlc_rxhdr)
{
    struct osl_info *osh = wl->wlc->osh;

    missing_csi_frames = wlc_rxhdr->rxhdr.NexmonExt;

    // create new csi frame
    p_csi = pkt_buf_get_skb(osh, sizeof(struct csi_udp_frame) + missing_csi_frames * (RX_HDR_LEN * 2));
    inserted_csi_values = 0;

    struct csi_udp_frame *udpfrm = (struct csi_udp_frame *) p_csi->data;
    struct nexmon_d11rxhdr *ucodefrm = (struct nexmon_d11rxhdr *) p->data;

    udpfrm->kk1 = 0x11111111;
    udpfrm->kk2 = wlc_recv_compute_rspec(&wlc_rxhdr->rxhdr, p->data);
    // copy mac address to new udp frame
    memcpy(udpfrm->SrcMac, ucodefrm->SrcMac, sizeof(udpfrm->SrcMac));
}

void
process_frame_hook(struct sk_buff *p, struct wlc_d11rxhdr *wlc_rxhdr, struct wlc_hw_info *wlc_hw, int tsf_l)
{
    struct osl_info *osh = wlc_hw->wlc->osh;
    struct wl_info *wl = wlc_hw->wlc->wl;

    if (p_csi == 0) {
        if (wlc_rxhdr->rxhdr.RxFrameSize == 2) {
            pkt_buf_free_skb(osh, p, 0); // drop incoming csi frame
            return; // drop all csi frames, if no csi information required
        } else if (wlc_rxhdr->rxhdr.NexmonExt > 0) {
            create_new_csi_frame(wl, p, wlc_rxhdr);
        }
    } else {
        struct csi_udp_frame *udpfrm = (struct csi_udp_frame *) p_csi->data;
        if (wlc_rxhdr->rxhdr.RxFrameSize == 2) {
            struct d11csihdr *ucodecsifrm = (struct d11csihdr *) p->data;
            missing_csi_frames--;
            struct int14 sint14;
            int i;
            for (i = 0; i < wlc_rxhdr->rxhdr.NexmonExt; i++) {
                struct csi_value_i16 *val = &udpfrm->csi_values[inserted_csi_values];
                val->i = sint14.val = (ucodecsifrm->csi[i] >> 14) & 0x3fff;
                val->q = sint14.val = ucodecsifrm->csi[i] & 0x3fff;
                inserted_csi_values++;
            }
            if (missing_csi_frames == 0) {
                p_csi->len = sizeof(struct csi_udp_frame) + inserted_csi_values * sizeof(struct csi_value_i16);
                memcpy(header.ip.src_ip.array, &(udpfrm->SrcMac[2]), 4);
                skb_pull(p_csi, sizeof(struct ethernet_ip_udp_header));
                prepend_modified_ethernet_ipv4_udp_header(p_csi);
                //send answer to incoming CSI packages here
                wl->dev->chained->funcs->xmit(wl->dev, wl->dev->chained, p_csi);
                p_csi = 0;
            }
            pkt_buf_free_skb(osh, p, 0); // drop incoming csi frame
            return;
        } else {
            pkt_buf_free_skb(osh, p_csi, 0);
            if (wlc_rxhdr->rxhdr.NexmonExt > 0) {
                create_new_csi_frame(wl, p, wlc_rxhdr);
            }
        }
    }
    // only continue processing this frame, if it is not a csi frame
    wlc_rxhdr->tsf_l = tsf_l;
    wlc_phy_rssi_compute(wlc_hw->band->pi, wlc_rxhdr);
    wlc_recv(wlc_hw->wlc, p);
}

// hook to allow handling writing to the wlc_d11rxhdr on our own to avoid overwriting of additional information in d11rxhdr passed from the ucode
__attribute__((at(0x1AAFCC, "", CHIP_VER_BCM4339, FW_VER_6_37_32_RC23_34_43_r639704)))
__attribute__((at(0x1B2012, "", CHIP_VER_BCM4358, FW_VER_7_112_300_14)))
__attribute__((naked))
void
process_frame_prehook(void)
{
    asm(
        "mov r2, r4\n"              // 2 bytes: move wlc_hw pointer to r2
#if NEXMON_CHIP == CHIP_VER_BCM4339
        "ldr r0, [sp,0xC]\n"        // 4 bytes: load reference to p into r0
#else
        "ldr r0, [sp,0x8]\n"        // 4 bytes: load reference to p into r0
#endif
        "bl process_frame_hook\n"   // 4 bytes
        "nop\n"                     // 2 bytes: to overwrite existing instruction
        "nop\n"                     // 2 bytes: to overwrite existing instruction
        "nop\n"                     // 2 bytes: to overwrite existing instruction
        "nop\n"                     // 2 bytes: to overwrite existing instruction
        "nop\n"                     // 2 bytes: to overwrite existing instruction
#if NEXMON_CHIP == CHIP_VER_BCM4358
        "nop\n"                     // 2 bytes: to overwrite existing instruction
#endif
    );
}

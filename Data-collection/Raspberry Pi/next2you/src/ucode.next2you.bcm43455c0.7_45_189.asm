#include "/home/pi/nexmon/buildtools/b43-v3/debug/include/spr.inc"
#include "/home/pi/nexmon/buildtools/b43-v3/debug/include/shm.inc"
#include "/home/pi/nexmon/buildtools/b43-v3/debug/include/cond.inc"

#define phy_reg_read_to_shm_off(addr, base, offset) \
	mov	addr, r33                                   \
	calls	L66                                     \
	or	SPR_Ext_IHR_Data, 0x0, [base, offset]

#define phy_reg_read(addr, target)                  \
	mov	addr, r33                               \
	calls	L66                                     \
	or	SPR_Ext_IHR_Data, 0x0, target

#define phy_reg_write(addr,value)                   \
	mov	addr, r33                                   \
	mov	value, r34                                  \
	calls	L68

#define RX_HDR_BASE 0x8d0
#define RX_HDR_OFFSET(off)      (RX_HDR_BASE + off)
#define RX_HDR_RxFrameSize      RX_HDR_OFFSET(0)
#define RX_HDR_NexmonExt        RX_HDR_OFFSET(1)
#define RX_HDR_PhyRxStatus_0    RX_HDR_OFFSET(2)
#define RX_HDR_PhyRxStatus_1    RX_HDR_OFFSET(3)
#define RX_HDR_PhyRxStatus_2    RX_HDR_OFFSET(4)
#define RX_HDR_PhyRxStatus_3    RX_HDR_OFFSET(5)
#define RX_HDR_PhyRxStatus_4    RX_HDR_OFFSET(6)
#define RX_HDR_PhyRxStatus_5    RX_HDR_OFFSET(7)
#define RX_HDR_RxStatus1        RX_HDR_OFFSET(8)
#define RX_HDR_RxStatus2        RX_HDR_OFFSET(9)
#define RX_HDR_RxTSFTime        RX_HDR_OFFSET(10)
#define RX_HDR_RxChan           RX_HDR_OFFSET(11)

#define SPARE1          r58
#define SPARE2          r56
#define SPARE3          r55
#define SPARE4          r54
#define SPARE5          r48
#define SPARE6          r49
#define DUMP_CSI        r52

#define SHM_CSI_COLLECT     0x8B0
#define NSSMASK         	0x8a6
#define COREMASK        	0x8a7
#define CMP_SRC_MAC_0       0x8a8
#define CMP_SRC_MAC_1       0x8a9
#define CMP_SRC_MAC_2       0x8aa
#define CHUNKS          	0x8a0
#define TONES_LAST_CHUNK    0x8a1
#define RXCHAN          	0x8a2
#define CLEANDEAF       	0x8a3
#define FORCEDEAF       	0x8a4
#define CSICONFIGCACHE      0x8a5

#define N_CMP_SRC_MAC             0x888
#define CMP_SRC_MAC_0_0           0x889
#define CMP_SRC_MAC_0_1           0x88a
#define CMP_SRC_MAC_0_2           0x88b
#define CMP_SRC_MAC_1_0           0x88c
#define CMP_SRC_MAC_1_1           0x88d
#define CMP_SRC_MAC_1_2           0x88e
#define CMP_SRC_MAC_2_0           0x88f
#define CMP_SRC_MAC_2_1           0x890
#define CMP_SRC_MAC_2_2           0x891
#define CMP_SRC_MAC_3_0           0x892
#define CMP_SRC_MAC_3_1           0x893
#define CMP_SRC_MAC_3_2           0x894
#define APPLY_PKT_FILTER          0x898
#define PKT_FILTER_BYTE           0x899
#define SRC_MAC_CACHE_0           0x89a
#define SRC_MAC_CACHE_1           0x89b
#define SRC_MAC_CACHE_2           0x89c
#define SEQ_NUM_CACHE             0x89d
#define FIFODELAY                 0x89e

#define TIMESPUSHED     0x880
#define DEAFED          0x881
#define RELIFED         0x882

#define NCORES  1

%arch 15
%start entry

entry:
	mov	0x0, SPR_GPIO_OUT
	jmp	L894
L0:
	jnzx	0, 1, SPR_PHY_HDR_Parameter, 0x0, L1
	jmp	L1002
L1:
	jext	COND_PSM(0), L5
	jext	0x4C, L5
	jnzx	0, 4, r20, 0x0, L5
	jnzx	0, 7, r43, 0x0, L5
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L2
	jext	COND_PSM(0), L5
	jnzx	0, 8, r45, 0x0, L5
	jnzx	0, 6, r44, 0x0, L5
	jnzx	1, 0, r45, 0x0, L5
	jnzx	0, 0, [0xB89], 0x0, L5
	jzx	0, 1, [0xBA4], 0x0, L5
	jnzx	0, 10, [0xBA4], 0x0, L5
L2:
	jzx	0, 9, SPR_MAC_CMD, 0x0, L3
	or	[0xC46], 0x0, [0xC47]
	mov	0x200, SPR_MAC_CMD
L3:
	jnzx	0, 9, [SHM_HOST_FLAGS2], 0x0, L5
	mul	0x1F4, 0x8, r33
	mov	0xFFFF, SPR_MAC_MAX_NAP
	jne	r33, 0x0, L4
	or	SPR_PSM_0x5a, 0x0, SPR_MAC_MAX_NAP
L4:
	mov	0x2CE, SPR_BRWK0
	mov	0x56AF, SPR_BRWK1
	mov	0x7C04, SPR_BRWK2
	mov	0x608, SPR_BRWK3
	napv	0xC00
L5:
	je	[FORCEDEAF], 0, skipdeaf+
	mov	0, [FORCEDEAF]
	add	[DEAFED], 1, [DEAFED]
	calls	enable_carrier_search
skipdeaf:
	je	[CLEANDEAF], 0, skiprelife+
	mov	0, [CLEANDEAF]
	add	[RELIFED], 1, [RELIFED]
	calls	disable_carrier_search
skiprelife:
	mov	0x0, SPR_MAC_MAX_NAP
	jnext	EOI(0x19), L6
L6:
	jzx	0, 10, SPR_IFS_0x32, 0x0, L7
	or	SPR_TSF_WORD0, 0x0, [0xC2D]
L7:
	jzx	14, 0, [0x7A4], 0x0, L13
	mov	0x7A6, SPR_BASE4
L8:
	je	[0x00,off4], 0xFFFF, L12
	jzx	0, 8, spr29b, 0x0, L11
	srx	7, 8, spr293, 0x0, r37
	srx	7, 0, spr293, 0x0, r38
	jle	r37, r38, L9
	jge	[0x00,off4], r37, L10
	jl	[0x00,off4], r38, L10
	jmp	L11
L9:
	jl	[0x00,off4], r37, L11
	jge	[0x00,off4], r38, L11
L10:
	orx	6, 1, [0x00,off4], 0x1, r59
	orx	7, 8, r59, SPR_PSO_Control, SPR_PSO_Control
L11:
	mov	0xFFFF, [0x00,off4]
L12:
	xor	SPR_BASE4, 0x1, SPR_BASE4
	jnzx	0, 0, SPR_BASE4, 0x0, L8
L13:
	nap2
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L48
	jzx	0, 6, r63, 0x0, L14
	jdn	SPR_TSF_WORD0, [0xB1A], L14
	orx	0, 6, 0x0, r63, r63
	mov	0x0, [0xB0C]
L14:
	calls	L1123
	jzx	0, 9, r45, 0x0, L15
	jdn	SPR_TSF_WORD0, [0xB0F], L15
	orx	0, 9, 0x0, r45, r45
	jmp	L447
L15:
	je	[0xB39], 0x0, L18
	jnzx	0, 2, r63, 0x0, L48
	jnzx	0, 9, [0xBA5], 0x0, L16
	jnzx	0, 2, [0xBA4], 0x0, L17
L16:
	jdn	SPR_TSF_WORD0, [0xB39], L48
L17:
	orx	0, 2, 0x1, r45, r45
	calls	L1290
L18:
	jzx	0, 9, [SHM_HOST_FLAGS3], 0x0, L19
	jnzx	0, 3, [SHM_HOST_FLAGS3], 0x0, L20
L19:
	orx	2, 12, 0x0, r63, r63
	mov	0x0, [0xB40]
L20:
	sr	[0xB5E], 0x6, r34
	add	[0xB5D], r34, r35
	jl	SPR_TSF_WORD1, r35, L21
	or	[0xB5B], 0x0, [0xB56]
L21:
	orx	0, 10, 0x0, r63, r63
	je	[0xB55], 0x0, L22
	sub.	SPR_TSF_WORD0, [0xB55], r35
	subc	SPR_TSF_WORD1, [0xB59], r34
	jne	r34, 0x0, L22
	jge	r35, [0xB56], L22
	orx	0, 10, 0x1, r63, r63
L22:
	jzx	0, 11, r63, 0x0, L23
	sub	SPR_TSF_WORD0, [0xB37], r34
	jl	r34, [0xB36], L23
	orx	0, 11, 0x0, r63, r63
	mov	0x0, [0xB37]
L23:
	je	[0xB81], 0x0, L24
	mov	0x4E20, r33
	sub	SPR_TSF_WORD0, [0xB81], r34
	jl	r34, r33, L24
	mov	0x0, [0xB81]
	nand	[0xB84], 0x1, [0xB84]
L24:
	je	[0xB1F], 0x0, L27
	sub	SPR_TSF_WORD0, [0xB1F], r33
	jge	r33, [0xB18], L25
	je	[0xB2E], 0x0, L27
	sub	SPR_TSF_WORD0, [0xB2E], r33
	jge	r33, [0xB18], L26
	jmp	L27
L25:
	mov	0x0, [0xB20]
	mov	0x0, [0xB1F]
L26:
	mov	0x0, [0xB2E]
	mov	0x0, [0xB26]
	nand	[0xB84], 0x2, [0xB84]
L27:
	jzx	0, 6, r44, 0x0, L28
	jzx	0, 0, SPR_TXE0_CTL, 0x0, L28
	calls	L826
L28:
	jzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L29
	jnzx	0, 0, r45, 0x0, L48
	jne	[0xB21], 0x0, L48
L29:
	jnzx	0, 3, r45, 0x0, L30
	jzx	0, 3, [SHM_HOST_FLAGS3], 0x0, L36
L30:
	or	[0xB10], 0x0, r34
	jnzx	0, 0, [0xB5A], 0x0, L31
	or	[0xB26], 0x0, r33
	jge	r33, [0xB45], L46
	je	r33, 0x0, L31
	je	[0xB5F], 0x0, L31
	or	[0xB5F], 0x0, r34
L31:
	je	[0xB20], 0x0, L32
	sub	SPR_TSF_WORD0, [0xB20], r33
	orx	0, 8, 0x1, r63, r63
	add	r33, [0xB0D], r33
	jge	r33, r34, L46
L32:
	orx	0, 8, 0x0, r63, r63
	jzx	0, 8, r45, 0x0, L36
	je	[0xB0C], 0x0, L36
	sub	SPR_TSF_WORD0, [0xB14], r33
	add	[0xB0C], 0xA, r34
	jle	r33, r34, L33
	orx	0, 8, 0x0, r45, r45
	orx	0, 2, 0x0, [0xB84], [0xB84]
	mov	0x0, [0xB50]
	mov	0x0, [0xB0C]
	mov	0x0, [0xB4B]
	jmp	L36
L33:
	jl	[0xB0C], r33, L35
	sub	[0xB0C], r33, r33
	sr	[0xB0C], 0x1, r34
	jg	[0xB0D], r34, L34
	or	[0xB0D], 0x0, r34
L34:
	jges	r33, r34, L36
L35:
	jmp	L46
L36:
	jnzx	0, 3, r45, 0x0, L45
	jnzx	1, 1, [SHM_HOST_FLAGS5], 0x0, L44
	jzx	0, 1, r45, 0x0, L48
	jzx	0, 9, [SHM_HOST_FLAGS3], 0x0, L38
	je	[0xB23], 0x1, L38
	je	[0xB23], 0x4, L38
	je	[0xB1D], 0x0, L37
	jne	[0xB23], 0x43, L37
	sub	SPR_TSF_WORD0, [0xB17], r33
	sub	SPR_BTCX_RFACT_DUR_Timer, [0xB3D], r34
	sub	r33, r34, r33
	jls	r33, [0xB1D], L48
L37:
	jzx	0, 12, r63, 0x0, L44
L38:
	jnzx	0, 1, [SHM_HOST_FLAGS1], 0x0, L44
	je	[0xB2E], 0x0, L39
	jnzx	0, 0, [0xB5A], 0x0, L39
	or	[0xB30], 0x0, r59
	jg	[0xB26], r59, L48
	jnzx	0, 5, [0xB2C], 0x0, L39
	jmp	L44
L39:
	jnzx	0, 6, r45, 0x0, L40
	je	[0xB14], 0x0, L41
L40:
	je	[0xB23], 0x43, L48
	jmp	L44
L41:
	jnzx	0, 8, [SHM_HOST_FLAGS3], 0x0, L42
	jnzx	0, 12, [SHM_HOST_FLAGS3], 0x0, L43
L42:
	je	[0xB20], 0x0, L44
	jnzx	0, 2, [0xB6F], 0x0, L44
L43:
	sub	SPR_TSF_WORD0, [0xB17], r33
	sub	SPR_BTCX_RFACT_DUR_Timer, [0xB3D], r34
	sub	r33, r34, r33
	jges	r33, [0xB1E], L44
	jdnz	SPR_TSF_WORD0, [0xB19], L48
	jnzx	0, 4, r45, 0x0, L48
L44:
	jnzx	0, 0, [0xBA4], 0x0, L48
	jnzx	0, 0, [0xB89], 0x0, L48
	calls	L1297
	jmp	L48
L45:
	je	SPR_BTCX_CUR_RFACT_Timer, 0xFFFF, L44
	jzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L46
	jnzx	0, 4, r45, 0x0, L46
	jzx	0, 2, [SHM_HOST_FLAGS3], 0x0, L48
	jdn	SPR_TSF_WORD0, [0xB1A], L48
	jnand	0xFF, SPR_AQM_FIFO_Ready, L48
	jnzx	0, 8, r45, 0x0, L48
L46:
	jzx	0, 4, [0xB6F], 0x0, L47
	jnzx	0, 8, r45, 0x0, L47
	jmp	L44
L47:
	jnzx	1, 1, [SHM_HOST_FLAGS5], 0x0, L48
	jnzx	0, 6, r44, 0x0, L48
	jnzx	0, 1, [SHM_HOST_FLAGS1], 0x0, L48
	jnzx	0, 2, r45, 0x0, L48
	jnzx	0, 1, r63, 0x0, L48
	calls	L1311
L48:
	orx	0, 0, 0x0, SPR_PSM_COND, SPR_PSM_COND
	jnext	EOI(COND_TX_PHYERR), L49
L49:
	jext	EOI(0x39), L50
L50:
	jext	EOI(0x3A), L51
L51:
	mov	0x6000, SPR_TSF_GPT0_VALLO
	or	[SHM_DEFAULTIV], 0x0, SPR_TSF_GPT0_VALHI
	mov	0xC000, SPR_TSF_GPT0_STAT
	jnext	0x38, L806
	jext	0x33, L831
L52:
	jext	EOI(0x10), L266
	jext	EOI(0x11), L410
	jext	EOI(0x16), L787
	jext	0x12, L430
	jext	0x17, L786
L53:
	jext	EOI(COND_RX_FCS_GOOD), L544
L54:
	jext	EOI(COND_RX_IFS1), L818
	jext	COND_RX_COMPLETE, L801
	jext	EOI(0x07), L561
	jext	COND_RX_ATIMWINEND, L666
	jext	COND_RX_IFS2, L666
	jext	0x2A, L469
	calls	L1316
	calls	L1313
	calls	L1120
	calls	L1325
	jext	COND_4_C7, L0
	jext	EOI(COND_TX_FLUSH), L394
	jzx	0, 8, r44, 0x0, L56
	jzx	0, 2, SPR_IFS_STAT, 0x0, L56
L55:
	orx	1, 8, 0x0, r44, r44
	calls	L402
L56:
	jnzx	0, 11, SPR_MAC_IRQHI, 0x0, L57
	mov	0x5B2, r33
	calls	L66
	srx	0, 0, SPR_Ext_IHR_Data, 0x0, r34
	je	r34, [0x3F8], L57
	or	r34, 0x0, [0x3F8]
	mov	0x800, SPR_MAC_IRQHI
L57:
	jext	0x13, L516
L58:
	jzx	0, 3, SPR_IFS_STAT, 0x0, L59
	orx	0, 11, 0x0, r43, r43
L59:
	calls	L921
	calls	L1065
	jzx	0, 13, [SHM_HOST_FLAGS1], 0x0, L60
	jzx	0, 2, SPR_IFS_STAT, 0x0, L60
	jdn	SPR_TSF_WORD0, [0xC2B], L60
	mov	0x256, r33
	or	[SHM_RADAR], 0x0, r34
	calls	L68
L60:
	jext	COND_4_C4, L64
	jnext	EOI(COND_TX_UNDERFLOW), L63
	orx	0, 12, 0x1, SPR_BRC, SPR_BRC
	jnext	0x35, L62
	jgs	r8, 0x0, L61
	or	[SHM_DTIMP], 0x0, r8
L61:
	sub	r8, 0x1, r8
L62:
	jzx	0, 15, [SHM_HOST_FLAGS1], 0x0, L63
	orx	0, 7, 0x1, r44, r44
L63:
	jext	0x4C, L93
	calls	L1101
	js	0x3, SPR_MAC_CMD, L102
L64:
	jext	COND_TX_TBTTEXPIRE, L852
	jnand	SPR_TXE0_CTL, 0x1, L105
	jzx	0, 0, spr397, 0x0, L65
	orx	0, 2, 0x1, SPR_BRED2, SPR_BRED2
	jnext	EOI(COND_TX_DONE), L65
	nand	spr397, 0x5, spr397
	mov	0x20, SPR_MAC_CMD
L65:
	je	[0x3CA], 0x0, L141
	calls	L1424
	jmp	L141
L66:
	jnzx	0, 14, SPR_Ext_IHR_Address, 0x0, L66
	orx	1, 13, 0x3, r33, SPR_Ext_IHR_Address
L67:
	jnzx	0, 14, SPR_Ext_IHR_Address, 0x0, L67
	rets
L68:
	jnzx	0, 14, SPR_Ext_IHR_Address, 0x0, L68
	or	r34, 0x0, SPR_Ext_IHR_Data
	orx	1, 13, 0x2, r33, SPR_Ext_IHR_Address
	rets
L69:
	mov	0x1800, SPR_PSM_0x76
	mov	0x600, SPR_PSM_0x74
	orx	5, 8, 0x2F, r35, SPR_PSM_0x6a
L70:
	jnzx	0, 14, SPR_PSM_0x6a, 0x0, L70
	rets
	mov	0x1800, SPR_PSM_0x76
	mov	0x600, SPR_PSM_0x74
	orx	5, 8, 0x1F, r35, SPR_PSM_0x6a
L71:
	jnzx	0, 14, SPR_PSM_0x6a, 0x0, L71
	rets
L72:
	mov	0x14, [0x006]
	jnzx	0, 1, r1, 0x0, L73
	orx	11, 4, 0x0, r0, r0
	jzx	1, 0, r1, 0x0, L76
	mov	0xF0, r33
	add	r0, r33, SPR_BASE4
	mov	0xE0, r33
	add	r0, r33, SPR_BASE5
	mov	0x1, [0x864]
	jmp	L77
L73:
	mov	0x567, SPR_BASE3
	jnzx	0, 6, r0, 0x0, L75
	srx	2, 0, r0, 0x0, r33
	jzx	0, 0, r1, 0x0, L74
	srx	3, 0, r0, 0x0, r33
L74:
	sl	r33, 0x1, r34
	add	r33, r34, r33
	add	[0x056], r33, SPR_BASE3
L75:
	or	[0x02,off3], 0x0, SPR_BASE2
	or	[0x00,off2], 0x0, SPR_BASE2
	mov	0x1, [0x864]
	jmp	L78
L76:
	mov	0x110, r33
	add	r0, r33, SPR_BASE4
	mov	0x100, r33
	add	r0, r33, SPR_BASE5
	mov	0xC0, [0x006]
	mov	0x0, [0x864]
L77:
	or	[0x00,off4], 0x0, SPR_BASE2
	or	[0x00,off5], 0x0, SPR_BASE3
L78:
	rets
L79:
	orx	1, 1, SPR_TXE0_PHY_CTL, 0x0, SPR_TDCCTL
	jzx	0, 4, SPR_TXE0_PHY_CTL, 0x0, L80
	orx	0, 3, 0x1, SPR_TDCCTL, SPR_TDCCTL
L80:
	or	[0x03,off6], 0x0, SPR_TDC_PLCP0
	or	[0x04,off6], 0x0, SPR_TDC_PLCP1
	sub	SPR_AQM_Agg_Len_Low, 0x4, SPR_TDC_Frame_Length0
	jzx	0, 2, [0x0A,off0], 0x0, L81
	or	SPR_AQM_Agg_Len_Low, 0x0, SPR_TDC_Frame_Length0
	or	SPR_AQM_Agg_Len_High, 0x0, SPR_TDC_Frame_Length1
	jnzx	0, 0, SPR_TXE0_PHY_CTL, 0x0, L81
	or	[0x05,off6], 0x0, SPR_TDC_Frame_Length1
L81:
	jzx	0, 6, SPR_TXE0_PHY_CTL2, 0x0, L83
	jnzx	0, 0, SPR_TXE0_PHY_CTL, 0x0, L82
	orx	1, 12, 0x1, [0x04,off6], SPR_TDC_PLCP1
	jmp	L83
L82:
	orx	0, 3, 0x1, [0x03,off6], r33
	orx	2, 10, 0x1, r33, SPR_TDC_PLCP0
L83:
	orx	0, 0, 0x1, SPR_TDCCTL, SPR_TDCCTL
	rets
L84:
	sub	SPR_RXE_FRAMELEN, 0x4, r33
	or	SPR_RXE_Copy_Length, 0x0, r35
	jl	r33, r35, L85
	sr	r35, 0x1, r35
	jmp	L86
L85:
	sr	r33, 0x1, r35
L86:
	mov	0x7D9, r33
	add	r35, r33, r35
L87:
	orx	14, 0, SPR_BASE4, 0x0, r33
	jge	r33, r35, L91
	jnzx	0, 15, SPR_BASE4, 0x0, L88
	srx	7, 0, [0x00,off4], 0x0, r33
	srx	7, 8, [0x00,off4], 0x0, r34
	jmp	L89
L88:
	srx	7, 8, [0x00,off4], 0x0, r33
	srx	7, 0, [0x01,off4], 0x0, r34
L89:
	je	r33, r36, L90
	rr	r34, 0x1, r34
	add.	SPR_BASE4, r34, SPR_BASE4
	or	SPR_BASE4, 0x0, 0x0
	addc.	SPR_BASE4, 0x1, SPR_BASE4
	jmp	L87
L90:
	rr	r34, 0x1, r34
	add.	SPR_BASE4, r34, r33
	addc.	r33, 0x1, r33
	orx	14, 0, r33, 0x0, r33
	jle	r33, r35, L92
L91:
	mov	0xFFFF, r36
L92:
	rets
L93:
	orx	0, 0, 0x0, r63, r63
	jnand	0xE3, SPR_BRC, L0
	jnext	0x34, L95
	jext	0x35, L95
L94:
	mov	0x1008, r33
	nand	SPR_BRC, r33, SPR_BRC
	jmp	L0
L95:
	jzx	1, 0, SPR_MAC_CMD, 0x0, L94
	orx	0, 2, 0x1, [0xB6E], [0xB6E]
	calls	L826
	orx	2, 0, 0x1, SPR_BRC, SPR_BRC
	jzx	0, 7, r44, 0x0, L96
	mov	0x3E8, SPR_TME_VAL14
	mov	0xC44, SPR_TME_VAL18
	orx	2, 13, r41, SPR_TME_VAL18, SPR_TME_VAL18
	calls	L134
	jmp	L101
L96:
	or	[0x066], 0x0, SPR_TXE0_PHY_CTL
	or	[0x067], 0x0, SPR_TXE0_PHY_CTL1
	or	[0x068], 0x0, SPR_TXE0_PHY_CTL2
	mov	0x20, r18
	mov	0x24, SPR_TXE0_TS_LOC
	or	[SHM_BTSFOFF], 0x0, SPR_TSF_0x3a
	jext	0x43, L99
	orx	0, 3, 0x1, SPR_BRC, SPR_BRC
	mov	0x4, SPR_MAC_IRQLO
	mov	0x0, SPR_TSF_RANDOM
	jext	0x34, L100
	orx	0, 7, 0x0, r20, r20
	or	SPR_IFS_BKOFFTIME, 0x0, r15
	or	r5, 0x0, r16
	jzx	0, 0, SPR_TSF_0x0e, 0x0, L97
	orx	0, 11, 0x0, SPR_BRC, SPR_BRC
	orx	0, 2, 0x1, 0x0, SPR_MAC_CMD
L97:
	orx	14, 1, r3, 0x1, r33
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L98
	orx	14, 1, [0x131], 0x1, r33
L98:
	and	SPR_TSF_RANDOM, r33, SPR_IFS_BKOFFTIME
L99:
	jext	0x34, L100
	mov	0x4D95, SPR_TXE0_CTL
	jmp	L0
L100:
	jzx	0, 15, [SHM_HOST_FLAGS1], 0x0, L101
	mov	0x4181, SPR_TXE0_CTL
	jmp	L0
L101:
	and	SPR_TSF_RANDOM, [0x151], SPR_IFS_BKOFFTIME
	mov	0x4993, SPR_TXE0_CTL
	jmp	L0
L102:
	jnand	0x20, SPR_BRC, L0
	srx	1, 8, r20, 0x0, r33
	orx	1, 0, r33, 0x0, SPR_MAC_CMD
	mov	0x2, SPR_MAC_IRQLO
	srx	1, 0, SPR_MAC_CMD, 0x0, r33
	orx	1, 8, r33, r20, r20
	jmp	L0
	rets
L103:
	mov	0x3, r35
	jnzx	0, 1, r20, 0x0, L104
	mov	0x0, r35
L104:
	mov	0x1720, r33
	calls	L66
	orx	1, 0, r35, SPR_Ext_IHR_Data, r34
	calls	L68
	mov	0x173E, r33
	calls	L66
	orx	0, 12, r35, SPR_Ext_IHR_Data, r34
	orx	1, 4, 0x0, r34, r34
	calls	L68
	orx	0, 6, r35, r44, r44
	rets
L105:
	jnzx	0, 7, SPR_TXE0_STATUS, 0x0, L0
	jzx	0, 15, [SHM_HOST_FLAGS3], 0x0, L106
	jand	SPR_AQM_FIFO_Ready, 0x8, L106
	je	[SHM_TXFCUR], 0x3, L106
	calls	L826
	mov	0x3, [SHM_TXFCUR]
	jmp	L186
L106:
	jnand	0x1F, SPR_BRC, L0
	calls	L1104
	calls	L1376
	jzx	0, 5, [SHM_HOST_FLAGS4], 0x0, L108
	or	SPR_TSF_WORD0, 0x0, r33
	srx	15, 8, r33, SPR_TSF_WORD1, r35
	jnzx	0, 4, r63, 0x0, L107
	add	[0x03E], r35, [0x86F]
	orx	0, 4, 0x1, r63, r63
L107:
	jdpz	r35, [0x86F], L109
L108:
	jzx	0, 12, [0x01,off0], 0x0, L110
	srx	7, 8, SPR_TSF_WORD0, 0x0, r33
	orx	7, 8, SPR_TSF_WORD1, r33, r33
	jdnz	r33, [0x08,off0], L110
L109:
	calls	L826
	orx	3, 4, 0x5, [0x09,off0], [0x09,off0]
	add	[0x86F], 0x4, [0x86F]
	jmp	L250
L110:
	calls	L251
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L111
	jext	0x15, L0
	jnand	SPR_AQM_FIFO_Ready, 0x30, L0
	and	SPR_AQM_FIFO_Ready, 0xF, r0
	je	r0, [0x16E], L0
	calls	L826
	jmp	L5
L111:
	jzx	0, 3, SPR_AQM_FIFO_Ready, 0x0, L0
	je	[SHM_TXFCUR], 0x3, L0
	calls	L826
	mov	0x3, [SHM_TXFCUR]
	calls	L112
	jmp	L5
L112:
	or	[SHM_TXFCUR], 0x0, SPR_TXE0_SELECT
	orx	3, 0, [SHM_TXFCUR], 0x0, SPR_TXE0_FIFO_PRI_RDY
	mov	0x5B4, r33
	mul	[SHM_TXFCUR], 0x20, 0x0
	add	r33, SPR_PSM_0x5a, SPR_BASE0
	jnzx	0, 0, [0x0A,off0], 0x0, L116
	mov	0x0, r50
	sl	SPR_BASE0, 0x1, SPR_TXE0_AGGFIFO_CMD
	mov	0x14, SPR_TXE0_FIFO_Write_Pointer
	orx	8, 7, 0x102, r50, SPR_TXE0_FIFO_Head
L113:
	jnext	0x18, L113
L114:
	jext	0x18, L114
	orx	0, 0, 0x1, [0x0A,off0], [0x0A,off0]
	or	SPR_TSF_WORD0, 0x0, [0x0D,off0]
	or	SPR_TSF_WORD1, 0x0, [0x0E,off0]
	or	[SHM_SFFBLIM], 0x0, [0x1C,off0]
	jzx	0, 8, [0x01,off0], 0x0, L115
	or	[SHM_LFFBLIM], 0x0, [0x1C,off0]
L115:
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L116
	jg	[SHM_TXFCUR], 0x3, L116
	add	0x180, [SHM_TXFCUR], SPR_BASE4
	srx	3, 4, [0x00,off4], 0x0, [0x1C,off0]
	jzx	0, 8, [0x01,off0], 0x0, L116
	srx	3, 12, [0x00,off4], 0x0, [0x1C,off0]
L116:
	rets
L117:
	srx	7, 0, [0x04,off0], 0x0, SPR_WEP_IV_Key
	add	SPR_WEP_IV_Key, 0x8, r35
	sub	[0x05,off0], 0x4, r34
	jle	r35, r34, L118
	or	r34, 0x0, r35
L118:
	srx	3, 2, [0x01,off0], 0x0, [0x674]
	srx	7, 8, [0x04,off0], 0x0, r34
	mov	0x7C, [0x1E,off0]
	mov	0x14, SPR_TXE0_FIFO_Read_Pointer
	jzx	0, 0, [0x01,off0], 0x0, L120
	mov	0x14, [0x1E,off0]
	calls	L133
	mov	0x3, SPR_SHMDMA_Control
L119:
	jnzx	0, 0, SPR_SHMDMA_Control, 0x0, L119
	jge	r34, r35, L125
	sub	r35, r34, SPR_TXE0_FIFO_Write_Pointer
	mov	0xD5C, r33
	add	r33, r34, SPR_TXE0_AGGFIFO_CMD
	jmp	L122
L120:
	add	0x68, r35, SPR_TXE0_FIFO_Write_Pointer
	jle	r34, r35, L121
	add	0x68, r34, SPR_TXE0_FIFO_Write_Pointer
L121:
	mov	0xCF4, SPR_TXE0_AGGFIFO_CMD
L122:
	orx	8, 7, 0x103, 0x0, SPR_TXE0_FIFO_Head
L123:
	jnext	0x18, L123
L124:
	jext	0x18, L124
L125:
	mov	0xC2E, SPR_BASE4
	srx	2, 4, [0x6A2], 0x0, r38
	add	SPR_BASE4, r38, SPR_BASE4
	srx	7, 0, [0x00,off4], 0x0, [0x1F,off0]
	mov	0x0, r33
	jzx	0, 4, [0x02,off0], 0x0, L126
	srx	7, 8, [0x00,off4], 0x0, r33
	add	r33, SPR_WEP_IV_Key, r33
	jne	r38, 0x2, L126
	sr	SPR_WEP_IV_Key, 0x1, r35
	mov	0x6AE, SPR_BASE4
	add	SPR_BASE4, r35, SPR_BASE4
	or	[0x3D6], 0x0, r35
	jne	[0x02,off4], r35, L249
L126:
	jl	r34, r33, L128
	jnzx	0, 0, [0x01,off0], 0x0, L127
	add	[0x1E,off0], r34, [0x1E,off0]
L127:
	orx	7, 8, r34, [0x1E,off0], [0x1E,off0]
	jmp	L130
L128:
	add	[0x1E,off0], r33, [0x1E,off0]
	jzx	0, 0, [0x01,off0], 0x0, L129
	sub	[0x1E,off0], r34, [0x1E,off0]
L129:
	orx	7, 8, r33, [0x1E,off0], [0x1E,off0]
L130:
	jnzx	0, 0, [0x01,off0], 0x0, L132
	jzx	0, 1, [0x01,off0], 0x0, L131
	calls	L133
	mov	0x1, SPR_SHMDMA_Control
	jmp	L132
L131:
	mov	0xFFFF, [0x674]
L132:
	calls	L136
	rets
L133:
	srx	3, 2, [0x01,off0], 0x0, r33
	mul	r33, [SHM_ACKCTSPHYCTL], r33
	mov	0x67A, SPR_SHMDMA_SHM_Address
	sr	SPR_PSM_0x5a, 0x1, SPR_SHMDMA_TXDC_Address
	add	r34, 0x68, r33
	add	r33, 0x3, r33
	nand	r33, 0x3, r33
	sr	r33, 0x1, SPR_SHMDMA_Xfer_Cnt
	rets
L134:
	mov	0xE, r2
	orx	10, 5, r2, [0x4CB], SPR_TX_PLCP_HT_Sig0
	or	[0x4CC], 0x0, SPR_TX_PLCP_HT_Sig1
	orx	1, 14, r41, 0x5, SPR_TXE0_PHY_CTL
	orx	2, 0, 0x0, [0x4D1], SPR_TXE0_PHY_CTL1
L135:
	mov	0x31, r18
	mov	0xFFFF, SPR_TME_MASK12
	mov	0xC4, SPR_TME_VAL12
	mov	0x3EE0, SPR_TME_VAL16
	or	[0x3C8], 0x0, SPR_TME_VAL20
	calls	L1004
	rets
L136:
	mov	0x0, spr21f
	mov	0x67A, SPR_BASE6
	jzx	0, 1, [0x02,off0], 0x0, L137
	orx	1, 4, 0x0, [0x0B,off0], [0x0B,off0]
	jmp	L139
L137:
	srx	1, 4, [0x0B,off0], 0x0, r33
	jl	spr22f, [0x1C,off0], L138
	jne	r33, 0x0, L138
	jnzx	0, 5, [0x682], 0x0, L138
	mov	0x1, r33
	orx	1, 4, 0x1, [0x0B,off0], [0x0B,off0]
L138:
	mul	r33, 0xA, 0x0
	or	SPR_PSM_0x5a, 0x0, r33
	add	SPR_BASE6, r33, SPR_BASE6
L139:
	mov	0x4A0, SPR_BASE1
	jnzx	0, 6, [0x08,off6], 0x0, L140
	srx	2, 12, [0x682], 0x0, r33
	sl	r33, 0x4, r33
	add	[0x40C], r33, SPR_BASE1
L140:
	or	SPR_BASE1, 0x0, [0x0F,off0]
	rets
L141:
	je	[0x874], 0x0, L143
	or	SPR_TSF_WORD0, 0x0, r34
	jdp	SPR_TSF_WORD1, [0xCA9], L142
	jdn	SPR_TSF_WORD1, [0xCA9], L5
	jle	r34, [0x875], L5
L142:
	mov	0x0, [0x874]
L143:
	jnand	0x2F, SPR_BRC, L0
	jext	EOI(0x10), L266
	jext	COND_4_C4, L170
	calls	L1049
	jnzx	0, 15, [0xBA5], 0x0, L144
	jzx	0, 13, [0xBA5], 0x0, L144
	srx	0, 2, [0xB9E], 0x0, r36
	srx	0, 12, [0xBA4], 0x0, r34
	je	r34, r36, L144
	orx	0, 12, r36, [0xBA4], [0xBA4]
	mov	0x40, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, r35
	orx	0, 5, r36, r35, r35
	mov	0xC0, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	r35, 0x0, SPR_BTCX_ECI_Data
L144:
	jzx	0, 5, [0xB9E], 0x0, L145
	jnzx	0, 10, [0xBA4], 0x0, L145
	jzx	0, 8, [0xBA4], 0x0, L145
	orx	0, 8, 0x0, [0xBA4], [0xBA4]
	add	SPR_TSF_WORD1, 0x2, [0xBC9]
	mov	0xD00, r34
	mov	0xA0, r33
	mov	0x8000, SPR_PSM_0x6e
	mov	0x9, SPR_PSM_0x6c
	calls	L1475
	je	[0xB92], 0x0, L145
	add	SPR_TSF_WORD0, [0xB92], [0xB93]
	orx	0, 14, 0x1, [0xBA4], [0xBA4]
L145:
	jdn	SPR_TSF_WORD1, [0xBC9], L146
	orx	0, 8, 0x1, [0xBA4], [0xBA4]
L146:
	je	[0xB93], 0x0, L147
	jdn	[0xB93], SPR_TSF_WORD0, L147
	mov	0x80, SPR_MAC_IRQHI
	mov	0x0, [0xB93]
L147:
	jnzx	0, 0, [0xBA5], 0x0, L148
	jzx	0, 0, [0xBA4], 0x0, L166
	jmp	L154
L148:
	srx	0, 3, [0xB9E], 0x0, r33
	srx	0, 15, [0xBA4], 0x0, r34
	je	r33, 0x0, L149
	je	r33, r34, L149
	orx	0, 15, r33, [0xBA4], [0xBA4]
	mov	0xE, r35
	calls	L1373
	or	SPR_TSF_WORD0, 0x0, r34
	srx	15, 10, r34, SPR_TSF_WORD1, r35
	add	r35, [0xB98], [0xB97]
L149:
	je	[0xB97], 0x0, L150
	or	SPR_TSF_WORD0, 0x0, r33
	srx	15, 10, r33, SPR_TSF_WORD1, r35
	jdn	r35, [0xB97], L150
	mov	0x0, [0xB97]
	jzx	0, 15, [0xBA4], 0x0, L150
	orx	0, 15, 0x0, [0xBA4], [0xBA4]
	mov	0x6, r35
	calls	L1373
L150:
	je	[0xBAE], 0x0, L151
	je	[0xBAD], 0x0, L151
	jdn	SPR_TSF_WORD0, [0xBAD], L151
	orx	0, 1, 0x1, [0xBA4], [0xBA4]
	mov	0x0, [0xBAD]
	mov	0x0, [0xBA6]
	mov	0x0, [0xBB0]
	orx	0, 2, 0x0, [0xBA4], [0xBA4]
L151:
	jnzx	0, 2, r45, 0x0, L153
	jnzx	0, 1, r45, 0x0, L153
	jzx	0, 7, [0xBA5], 0x0, L152
	orx	0, 9, 0x1, [0xBA5], [0xBA5]
	jmp	L153
L152:
	orx	0, 9, 0x0, [0xBA5], [0xBA5]
	srx	0, 8, [0xBA5], 0x0, r33
	orx	0, 10, r33, [0xBA5], [0xBA5]
L153:
	srx	0, 11, [0xBA4], 0x0, r33
	orx	0, 10, r33, [0xBA4], [0xBA4]
	jnzx	0, 1, [0xBA5], 0x0, L154
	jzx	0, 1, [0xBA4], 0x0, L155
	jzx	0, 0, [0xBA4], 0x0, L166
L154:
	orx	0, 0, 0x0, [0xBA4], [0xBA4]
	calls	L1297
	jmp	L166
L155:
	jnzx	0, 8, SPR_IFS_STAT, 0x0, L156
	jzx	0, 1, r20, 0x0, L156
	calls	L1381
L156:
	or	[0xB70], 0x0, r33
	or	[0xB1B], 0x0, r34
	jl	r33, [0xB8C], L157
	jnzx	0, 2, [0xB6E], 0x0, L158
L157:
	jl	r34, [0xBC5], L159
	jzx	0, 11, r45, 0x0, L159
L158:
	jnzx	0, 4, [0xBA4], 0x0, L159
	mov	0x1, r36
	calls	L1370
L159:
	jzx	0, 5, [0xBA4], 0x0, L160
	jdn	SPR_TSF_WORD0, [0xBB5], L160
	jext	COND_4_C6, L160
	orx	0, 5, 0x0, [0xBA4], [0xBA4]
	calls	L1374
L160:
	jnzx	0, 9, [0xBA5], 0x0, L166
	jzx	0, 10, [0xBA5], 0x0, L162
	je	[0xBA9], 0x0, L166
	jdn	SPR_TSF_WORD0, [0xBA9], L166
	je	[0xBBA], 0x0, L166
	jdpz	SPR_TSF_WORD0, [0xBBA], L161
	jnzx	2, 0, r45, 0x0, L166
	calls	L1389
	jmp	L166
L161:
	mov	0x0, [0xBA9]
	mov	0x0, [0xBBA]
	calls	L1387
	orx	0, 0, 0x0, [0xBA4], [0xBA4]
	jmp	L166
L162:
	je	[0xBA9], 0x0, L164
	jdn	SPR_TSF_WORD0, [0xBA9], L164
	jnzx	0, 1, r45, 0x0, L163
	jnzx	0, 2, r45, 0x0, L163
	calls	L1389
	jmp	L166
L163:
	mov	0x0, [0xBA9]
	orx	0, 0, 0x1, [0xBA4], [0xBA4]
	jmp	L166
L164:
	je	[0xBAA], 0x0, L166
	jdn	SPR_TSF_WORD0, [0xBAA], L166
	jnzx	0, 7, [0xB6E], 0x0, L165
	jzx	0, 2, r45, 0x0, L165
	calls	L1390
	jmp	L166
L165:
	mov	0x0, [0xBAA]
	orx	0, 0, 0x0, [0xBA4], [0xBA4]
L166:
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L169
	jnzx	0, 2, r45, 0x0, L167
	jzx	0, 1, r45, 0x0, L169
	calls	L1274
	jzx	0, 1, r45, 0x0, L169
	jmp	L0
L167:
	jzx	0, 1, r45, 0x0, L168
	jzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L169
	jzx	0, 9, [SHM_HOST_FLAGS3], 0x0, L169
	jnzx	0, 12, r63, 0x0, L169
L168:
	calls	L1247
	jmp	L0
L169:
	calls	L1104
L170:
	calls	L1376
	jl	SPR_TXE0_0x78, 0x2, L172
	or	[SHM_TXFCUR], 0x0, r33
	or	[SHM_TXFCUR], 0x0, r34
	jext	COND_4_C4, L171
	jnext	0x15, L174
	jnzx	0, 2, SPR_IFS_STAT, 0x0, L174
	jg	[SHM_TXFCUR], 0x3, L172
	mov	0x3, r34
L171:
	sl	0x1, r34, r35
	jnand	SPR_AQM_FIFO_Ready, r35, L173
	sub	r34, 0x1, r34
	jles	r33, r34, L171
L172:
	orx	0, 4, 0x0, SPR_BRC, SPR_BRC
	jmp	L0
L173:
	je	r33, r34, L186
	or	r34, 0x0, [SHM_TXFCUR]
	or	r34, 0x0, [0x165]
	mul	r34, 0x10, r33
	add	0x120, SPR_PSM_0x5a, [0x166]
	calls	L1087
	jmp	L186
L174:
	mov	0x0, SPR_TSF_0x2a
	jzx	0, 2, SPR_IFS_STAT, 0x0, L175
	orx	0, 11, 0x0, r43, r43
L175:
	jext	COND_4_C4, L172
	or	[0x05F], 0x0, r38
	jnext	0x71, L176
	jand	SPR_AQM_FIFO_Ready, 0x20, L0
	mov	0x5, [SHM_TXFCUR]
	jmp	L186
L176:
	jnext	0x35, L181
	jzx	0, 6, [SHM_HOST_FLAGS2], 0x0, L177
	jnand	SPR_AQM_FIFO_Ready, 0x10, L178
L177:
	jnext	COND_INTERMEDIATE, L181
	jnand	SPR_AQM_FIFO_Ready, 0x10, L178
	jne	[SHM_MCASTCOOKIE], 0xFFFF, L5
	jmp	L179
L178:
	mov	0x4, [SHM_TXFCUR]
	jmp	L186
L179:
	jext	0x34, L180
	jne	r38, [0x05E], L180
	jzx	0, 2, SPR_MAC_CMD, 0x0, L944
L180:
	orx	0, 11, 0x0, SPR_BRC, SPR_BRC
L181:
	jzx	0, 15, [0x7A4], 0x0, L183
	jand	SPR_AQM_FIFO_Ready, 0x20, L183
	mov	0x7C3, r59
	add	[0x7A9], 0x5, r38
	jl	r38, r59, L182
	mov	0x7AA, r38
L182:
	je	r38, [0x7A8], L0
	mov	0x5, [SHM_TXFCUR]
	jmp	L186
L183:
	je	r38, [0x05E], L184
	jls	r39, 0x3, L188
	jzx	3, 0, SPR_AQM_FIFO_Ready, 0x0, L188
L184:
	jzx	0, 2, SPR_MAC_CMD, 0x0, L944
	jzx	3, 0, SPR_AQM_FIFO_Ready, 0x0, L944
	calls	L1080
	or	[0x165], 0x0, [0x161]
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L185
	calls	L1087
L185:
	or	[0x161], 0x0, [SHM_TXFCUR]
	jmp	L186
L186:
	jnext	COND_4_C4, L187
	jzx	0, 0, [0x0A,off0], 0x0, L187
	calls	L136
	jmp	L195
L187:
	calls	L112
	jmp	L191
L188:
	mov	0x14, r18
	or	[0x05E], 0x0, SPR_BASE4
	je	[SHM_PRMAXTIME], 0x0, L189
	sl	[0x04,off4], 0x8, r33
	sub	SPR_TSF_WORD0, r33, r33
	jle	r33, [SHM_PRMAXTIME], L189
	jmp	L515
L189:
	or	[0x014], 0x0, r33
	jg	[0x865], r33, L515
	orx	2, 0, 0x4, SPR_BRC, SPR_BRC
	srx	1, 0, [0x03,off4], 0x0, r1
	srx	6, 8, [0x03,off4], 0x0, r0
	calls	L72
	or	[0x05E], 0x0, SPR_BASE4
	or	[0x00,off4], 0x0, SPR_TME_VAL16
	or	[0x01,off4], 0x0, SPR_TME_VAL18
	or	[0x02,off4], 0x0, SPR_TME_VAL20
	or	[0x04,off3], 0x0, SPR_TX_PLCP_HT_Sig0
	or	[0x05,off3], 0x0, SPR_TX_PLCP_HT_Sig1
	or	[0x03,off2], 0x0, SPR_TME_VAL14
	orx	1, 0, r1, [SHM_TXFIFO_SIZE01], SPR_TXE0_PHY_CTL
	srx	2, 8, [SHM_CHAN], 0x0, SPR_TXE0_PHY_CTL1
	or	[0x068], 0x0, SPR_TXE0_PHY_CTL2
	mov	0xC0, r33
	jge	SPR_BASE3, [SHM_CCKDIRECT], L190
	mov	0x14, r33
L190:
	add	r33, [0x01B], r33
	add	r33, [0x00,off3], SPR_TSF_0x3a
	jmp	L237
L191:
	calls	L117
	srx	1, 0, [0x6A2], 0x0, [0x4C9]
	jnzx	0, 3, [0x0B,off0], 0x0, L246
	calls	L251
	or	[0x03,off0], 0x0, r33
	jne	[SHM_CHAN], r33, L192
	jmp	L193
L192:
	orx	3, 4, 0x4, [0x09,off0], [0x09,off0]
	jmp	L250
L193:
	or	[0x07,off6], 0x0, r40
	orx	0, 6, 0x0, [0x0A,off0], [0x0A,off0]
	jzx	0, 0, [SHM_HOST_FLAGS1], 0x0, L195
	js	0x3, [0x06,off6], L195
	jnext	0x13, L195
	orx	0, 6, 0x1, [0x0A,off0], [0x0A,off0]
	mov	0x7627, r33
	mul	[0x07,off6], r33, r40
	srx	1, 0, [0x06,off6], 0x0, r36
	orx	1, 14, r36, [0x00,off6], [0x00,off6]
	srx	2, 8, [SHM_CHAN], 0x0, r33
	sr	r33, r36, r33
	orx	2, 0, r33, [0x01,off6], [0x01,off6]
	js	0x3, [0x00,off6], L194
	jand	0x2, [0x00,off6], L195
	orx	0, 7, r36, [0x03,off6], [0x03,off6]
	jmp	L195
L194:
	orx	1, 0, r36, [0x03,off6], [0x03,off6]
L195:
	srx	1, 0, [0x00,off6], 0x0, r1
	or	[0x00,off6], 0x0, SPR_TXE0_PHY_CTL
	or	[0x02,off6], 0x0, SPR_TXE0_PHY_CTL2
	or	[0x00,off1], 0x0, r33
	orx	4, 10, r33, [0x01,off6], SPR_TXE0_PHY_CTL1
	srx	5, 3, [0x01,off6], 0x0, r36
	jzx	0, 6, [0x0A,off0], 0x0, L196
	srx	0, 2, [0x06,off6], 0x0, r33
	orx	0, 3, r33, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	srx	5, 3, [0x06,off6], 0x0, r36
	je	r33, 0x0, L205
	orx	5, 0, r36, [0x09,off6], [0x09,off6]
	srx	5, 9, [0x06,off6], 0x0, r36
L196:
	jzx	0, 3, SPR_TXE0_PHY_CTL, 0x0, L205
	jzx	0, 6, [0x08,off6], 0x0, L197
	or	[0x01,off1], 0x0, r33
	or	[0x02,off1], 0x0, r34
	jne	r33, [0x6B0], L198
	or	[0x03,off1], 0x0, r33
	jne	r34, [0x6B1], L198
	jne	r33, [0x6B2], L198
L197:
	srx	1, 14, [0x00,off6], 0x0, r33
	srx	1, 12, [0x00,off1], 0x0, r34
	jle	r33, r34, L199
	jnzx	0, 6, [0x08,off6], 0x0, L198
	orx	1, 4, 0x1, [0x0A,off0], [0x0A,off0]
L198:
	orx	0, 8, 0x0, [0x00,off1], [0x00,off1]
L199:
	srx	0, 8, [0x00,off1], 0x0, r33
	orx	0, 3, r33, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	je	r33, 0x0, L204
	orx	7, 6, [0x2EC], SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	jnzx	0, 6, [0x08,off6], 0x0, L206
	srx	7, 8, [0x05,off1], 0x0, r34
	orx	7, 6, r34, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	mov	0x7F, r34
	jzx	0, 4, [0x05,off1], 0x0, L203
	mov	0x410, SPR_BASE4
	jnzx	0, 0, SPR_TXE0_PHY_CTL, 0x0, L200
	srx	2, 0, [0x02,off6], 0x0, r33
	srx	1, 3, [0x02,off6], 0x0, r35
	jzx	0, 14, [0x05,off6], 0x0, L202
	jmp	L201
L200:
	srx	3, 0, [0x02,off6], 0x0, r33
	jg	r33, 0x7, L203
	srx	2, 4, [0x02,off6], 0x0, r35
	jzx	0, 10, [0x04,off6], 0x0, L202
L201:
	add	SPR_BASE4, 0x8, SPR_BASE4
L202:
	je	r35, 0x0, L203
	add	SPR_BASE4, r33, SPR_BASE4
	or	[0x00,off4], 0x0, r34
L203:
	mov	0x431, r33
	calls	L68
	jmp	L206
L204:
	srx	5, 0, [0x09,off6], 0x0, r36
	srx	0, 6, [0x09,off6], 0x0, r33
	orx	0, 6, r33, SPR_TXE0_PHY_CTL2, SPR_TXE0_PHY_CTL2
L205:
	orx	5, 3, r36, SPR_TXE0_PHY_CTL1, SPR_TXE0_PHY_CTL1
L206:
	or	[0x03,off6], 0x0, r0
	jne	r1, 0x3, L207
	or	[0x02,off6], 0x0, r0
L207:
	jzx	0, 14, [0x01,off0], 0x0, L208
	jext	COND_4_C4, L227
	jnand	[0x01,off0], 0x200, L208
	or	[0x6B0], 0x0, SPR_PMQ_pat_0
	or	[0x6B1], 0x0, SPR_PMQ_pat_1
	or	[0x6B2], 0x0, SPR_PMQ_pat_2
	mov	0x4, SPR_PMQ_control_low
L208:
	orx	1, 2, 0x0, [0x0A,off0], [0x0A,off0]
	jzx	0, 1, SPR_TXE0_PHY_CTL, 0x0, L214
	orx	0, 2, r1, [0x0A,off0], [0x0A,off0]
	jnzx	0, 2, [0x02,off0], 0x0, L214
	jzx	0, 6, [0x01,off0], 0x0, L214
	jext	0x15, L213
	jzx	0, 10, [0x01,off0], 0x0, L209
	jnzx	0, 11, r43, 0x0, L213
	orx	0, 11, 0x0, r43, r43
L209:
	jnzx	0, 6, SPR_TXE0_FIFO_DEF1, 0x0, L213
	srx	9, 0, SPR_TXE0_FIFO_Frame_Count, 0x0, r34
	srx	7, 0, [0x6A3], 0x0, r33
	jzx	1, 4, [0x0B,off0], 0x0, L210
	srx	7, 8, [0x6A3], 0x0, r33
L210:
	jge	r34, r33, L213
	jnzx	0, 6, [SHM_HOST_FLAGS3], 0x0, L5
	sl	0x1, [SHM_TXFCUR], r33
	jnand	r33, SPR_TXE0_0x5e, L5
	jle	0x0, 0x1, L211
L211:
	jle	0x0, 0x1, L212
L212:
	jnand	r33, SPR_TXE0_0x5e, L5
L213:
	orx	1, 2, 0x3, [0x0A,off0], [0x0A,off0]
L214:
	calls	L1401
	jnzx	6, 0, SPR_AQM_Agg_Stats, 0x0, L215
	mov	0x0, [0xCAE]
	jmp	L174
L215:
	calls	L79
	or	[0x6AF], 0x0, [0x675]
	mov	0x0, r2
	jnzx	0, 0, [0x6B0], 0x0, L218
	calls	L72
	or	[0x03,off2], 0x0, r2
	srx	5, 2, [0x6AE], 0x0, r18
	je	r18, 0x21, L216
	jzx	0, 3, [0x0A,off0], 0x0, L217
L216:
	or	[0x08,off2], 0x0, r2
L217:
	jnzx	0, 10, [0x6AE], 0x0, L218
	jnzx	0, 0, [0x6B0], 0x0, L218
	je	r18, 0x29, L218
	or	r2, 0x0, [0x675]
L218:
	jnzx	0, 6, [0x08,off6], 0x0, L221
	jzx	0, 3, [0x00,off6], 0x0, L221
	jnzx	0, 5, [0x0A,off0], 0x0, L221
	jnzx	0, 4, [0x0A,off0], 0x0, L220
	jne	[0x40D], 0xFFFF, L219
	jzx	0, 8, [0x00,off1], 0x0, L220
	jmp	L221
L219:
	or	SPR_TSF_WORD0, 0x0, r33
	srx	15, 2, r33, SPR_TSF_WORD1, r33
	jdnz	r33, [0x01,off1], L221
	add	r33, [0x40D], [0x01,off1]
L220:
	orx	1, 4, 0x1, [0x0A,off0], [0x0A,off0]
	orx	0, 8, 0x0, [0x00,off1], [0x00,off1]
	jmp	L405
L221:
	jext	0x15, L227
	jzx	0, 14, [0x01,off0], 0x0, L227
	jzx	0, 10, [0x01,off0], 0x0, L222
	jnzx	0, 11, r43, 0x0, L227
L222:
	jzx	0, 0, [0xBA5], 0x0, L225
	jnzx	0, 1, [0xBA4], 0x0, L225
	jnzx	0, 9, [0xBA5], 0x0, L225
	jnzx	0, 1, [0xBA5], 0x0, L225
	jnzx	0, 12, [0xBA5], 0x0, L223
	jzx	0, 2, [0xBA4], 0x0, L223
	jext	COND_NEED_RESPONSEFR, L223
	orx	0, 0, 0x0, SPR_TXE0_CTL, SPR_TXE0_CTL
	jmp	L0
L223:
	jzx	0, 10, [0xBA5], 0x0, L224
	je	[0xBB9], 0x0, L224
	jdnz	SPR_TSF_WORD0, [0xBB9], L226
L224:
	jnzx	0, 2, [0xBA4], 0x0, L226
L225:
	jnzx	0, 2, [0x08,off6], 0x0, L382
L226:
	jzx	1, 0, r1, 0x0, L227
	jnzx	0, 3, [0x08,off6], 0x0, L391
L227:
	sub	SPR_AQM_Agg_Len_Low, 0x4, SPR_WEP_WKey
	orx	2, 0, 0x4, [0x0B,off0], [0x0B,off0]
	or	[0x00,off6], 0x0, r1
	jzx	0, 14, [0x01,off0], 0x0, L231
	jext	COND_4_C4, L233
L228:
	jnzx	0, 9, [0x01,off0], 0x0, L231
L229:
	jnzx	0, 2, SPR_PMQ_control_low, 0x0, L229
	jnzx	0, 0, [0x6B0], 0x0, L230
	jand	SPR_PMQ_control_high, 0x1FC, L231
	jnand	SPR_PMQ_dat_or, 0x6, L247
	jnzx	0, 5, SPR_PMQ_dat_or, 0x0, L248
	jmp	L231
L230:
	jext	COND_INTERMEDIATE, L231
	jnzx	0, 1, SPR_PMQ_0x0e, 0x0, L247
L231:
	jnzx	0, 4, [0x0A,off0], 0x0, L258
L232:
	jnzx	0, 0, SPR_TDCCTL, 0x0, L232
	add	[0x3D3], SPR_TDC_TX_Time, [0x3D3]
	add	r2, SPR_TDC_TX_Time, [0x404]
L233:
	or	SPR_TDC_PLCP0, 0x0, [0x3FE]
	or	SPR_TDC_PLCP1, 0x0, [0x3FF]
	or	[0x05,off6], 0x0, [0x400]
	jnext	0x15, L234
	jg	[0x404], SPR_TSF_0x2a, L174
L234:
	jnzx	1, 0, [0x0B,off0], 0x0, L236
	srx	5, 2, [0x6AE], 0x0, r18
	srx	2, 4, [0x6A2], 0x0, r38
	je	r38, 0x0, L236
	srx	5, 8, [0x6A2], 0x0, r1
	sl	r1, 0x3, r1
	add	[SHM_KTP], r1, SPR_BASE5
	jne	r38, 0x2, L235
	mov	0x87A, r1
	mov	0x6A6, SPR_BASE2
	add	SPR_BASE2, 0x5, SPR_BASE4
	calls	L1029
	mov	0x878, SPR_BASE5
L235:
	je	r38, 0x7, L236
	mov	0x100, SPR_WEP_0x48
	or	[0x00,off5], 0x0, SPR_WEP_0x4a
	or	[0x01,off5], 0x0, SPR_WEP_0x4a
	or	[0x02,off5], 0x0, SPR_WEP_0x4a
	or	[0x03,off5], 0x0, SPR_WEP_0x4a
	or	[0x04,off5], 0x0, SPR_WEP_0x4a
	or	[0x05,off5], 0x0, SPR_WEP_0x4a
	or	[0x06,off5], 0x0, SPR_WEP_0x4a
	or	[0x07,off5], 0x0, SPR_WEP_0x4a
L236:
	calls	L1004
L237:
	orx	1, 0, [0x864], SPR_TXE0_PHY_CTL, r1
	calls	L1025
	orx	11, 3, r33, 0x0, SPR_TXE0_TIMEOUT
	jzx	0, 0, [0x06C], 0x0, L238
	orx	12, 0, [0x06D], 0x0, SPR_TXE0_TIMEOUT
L238:
	jne	r18, 0x14, L239
	mov	0x491D, SPR_TXE0_CTL
	mov	0x18, SPR_TXE0_TS_LOC
	jmp	L0
L239:
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L240
	jnzx	0, 15, [0x01,off0], 0x0, L240
	jext	0x15, L241
L240:
	jnext	COND_4_C4, L242
L241:
	orx	1, 8, 0x3, SPR_TXE0_0x76, SPR_TXE0_0x76
	mov	0x4001, r17
	jmp	L265
L242:
	jzx	0, 15, [SHM_HOST_FLAGS3], 0x0, L243
	je	[SHM_TXFCUR], 0x3, L241
L243:
	mov	0x481D, r17
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L244
	jge	[SHM_TXFCUR], 0x4, L244
	sl	[SHM_TXFCUR], 0x4, r33
	add	0x120, r33, SPR_BASE4
	jg	[0x04,off4], 0x1, L244
	orx	1, 1, 0x1, r17, r17
L244:
	jne	r18, 0x24, L245
	mov	0x6E1D, r17
L245:
	jmp	L255
L246:
	orx	3, 4, 0x3, [0x09,off0], [0x09,off0]
	jmp	L250
L247:
	orx	3, 4, 0x1, [0x09,off0], [0x09,off0]
	jmp	L250
L248:
	orx	3, 4, 0x8, [0x09,off0], [0x09,off0]
	jmp	L250
L249:
	orx	3, 4, 0x9, [0x09,off0], [0x09,off0]
L250:
	orx	0, 3, 0x1, [0x0B,off0], [0x0B,off0]
	jmp	L447
L251:
	mul	[0x4C9], 0xC, r34
	mov	0x747, r34
	add	r34, SPR_PSM_0x5a, SPR_BASE4
	jne	[0x6AE], 0x80, L252
	jdn	SPR_TSF_WORD0, [0x698], L0
L252:
	jnzx	0, 0, [0x02,off4], 0x0, L254
	jnzx	0, 2, [0x02,off4], 0x0, L253
	jzx	0, 7, [0x02,off4], 0x0, L254
	je	[0x04,off4], 0x0, L254
	sl	0x1, [0x4C9], r33
	jand	[0x73A], r33, L254
L253:
	calls	L826
	orx	3, 4, 0x7, [0x09,off0], [0x09,off0]
	nap2
	jmp	L250
L254:
	rets
L255:
	jext	COND_TX_TBTTEXPIRE, L852
	jzx	0, 10, [0x01,off0], 0x0, L257
	jzx	0, 11, r43, 0x0, L257
	mov	0x4001, r17
	jzx	0, 15, [0x01,off0], 0x0, L256
	mov	0x8007, r17
L256:
	add	[0x042], 0x1, [0x042]
	or	[0x042], 0x0, [0xBD1]
	jmp	L258
L257:
	mov	0x1, [0x042]
	jzx	0, 0, [SHM_HOST_FLAGS1], 0x0, L258
	srx	2, 11, [SHM_CHAN], 0x0, r34
	srx	1, 14, SPR_TXE0_PHY_CTL, 0x0, r33
	sub	r34, 0x2, r34
	jne	r33, r34, L258
	jext	0x13, L258
	orx	1, 8, 0x1, SPR_TXE0_0x76, SPR_TXE0_0x76
L258:
	jzx	0, 0, [0x06C], 0x0, L259
	mov	0x4007, r17
L259:
	jl	[SHM_TXFCUR], 0x4, L260
	and	SPR_TSF_RANDOM, [0x131], SPR_IFS_BKOFFTIME
	jmp	L265
L260:
	srx	5, 2, [0x6AE], 0x0, r59
	jne	r59, 0x20, L261
	and	SPR_TSF_RANDOM, [0x151], SPR_IFS_BKOFFTIME
	jmp	L265
L261:
	jne	r59, 0x34, L262
	and	SPR_TSF_RANDOM, [0x141], SPR_IFS_BKOFFTIME
	jmp	L265
L262:
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L264
	sub	[0x164], SPR_IFS_0x0e, SPR_IFS_BKOFFTIME
	jzx	0, 0, SPR_TSF_0x0e, 0x0, L263
	or	[0x162], 0x0, SPR_BASE5
	jgs	SPR_IFS_BKOFFTIME, [0x04,off5], L263
	calls	L1027
L263:
	jges	SPR_IFS_BKOFFTIME, 0x0, L265
	mov	0x0, SPR_IFS_BKOFFTIME
	jmp	L265
L264:
	jne	SPR_IFS_BKOFFTIME, 0x0, L265
	jnzx	0, 3, SPR_IFS_STAT, 0x0, L265
	calls	L1028
L265:
	or	r17, 0x0, SPR_TXE0_CTL
	jmp	L0
L266:
	mov	0x7, SPR_TXBA_Control
	and	[SHM_TSSI_CCK_HI], 0xF, SPR_IFS_CTL_SEL_PRICRS
	add.	[0x3C0], SPR_IFS_0x0e, [0x3C0]
	addc	[0x3C1], 0x0, [0x3C1]
	calls	L1423
	nand	SPR_BRC, 0x280, SPR_BRC
	mov	0x0, r14
	orx	0, 4, 0x0, r63, r63
	orx	0, 6, 0x1, 0x0, SPR_WEP_CTL
	mov	0x121, r33
	nand	r44, r33, r44
	jzx	0, 0, [0xBA5], 0x0, L268
	jnzx	0, 1, [0xBA4], 0x0, L268
	je	r18, 0x35, L267
	je	r18, 0x25, L267
	jmp	L268
L267:
	calls	L1374
L268:
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L271
	jne	r18, 0x10, L269
	calls	L1309
L269:
	jne	r18, 0x31, L271
	jzx	0, 10, [0xBA5], 0x0, L270
	jnzx	0, 7, [0xB6E], 0x0, L270
	jnzx	0, 6, [0xBA4], 0x0, L271
L270:
	jzx	0, 0, r45, 0x0, L271
	jzx	0, 0, SPR_BTCX_Stat, 0x0, L271
	sub	SPR_TSF_WORD0, [0xB17], r33
	sub	[0xB0B], r33, r33
	jls	r33, 0x41, L271
	calls	L1097
L271:
	orx	0, 11, 0x0, r43, r43
	jne	[0x042], 0x1, L272
	or	SPR_TSF_WORD0, 0x0, [0x043]
L272:
	orx	0, 5, 0x1, SPR_BRC, SPR_BRC
	nand	SPR_PSM_COND, 0x82, SPR_PSM_COND
	jext	EOI(0x07), L273
L273:
	orx	0, 4, 0x1, SPR_IFS_CTL, SPR_IFS_CTL
	or	[SHM_TXFCUR], 0x0, SPR_TXE0_FIFO_PRI_RDY
	mov	0x0, r50
	mov	0x0, spr21e
	calls	L1120
	orx	0, 7, 0x0, r63, r63
	jnzx	1, 0, SPR_TXE0_PHY_CTL, 0x0, L274
	orx	0, 7, 0x1, r63, r63
L274:
	mov	0x0, SPR_TXE0_0x70
	mov	0x0, SPR_TXE0_WM1
	jnext	COND_PSM(1), L275
	orx	1, 7, 0x3, SPR_WEP_CTL, SPR_WEP_CTL
	orx	7, 8, 0x0, SPR_TXE0_WM0, SPR_TXE0_WM0
	mov	0xB, SPR_TXE0_0x70
	or	SPR_AQM_MPDU_Len_FIFO, 0x0, SPR_WEP_WKey
	jne	[0xB07], 0x1, L334
	jmp	L332
L275:
	mov	0x0, SPR_TXE0_WM0
	add	[0x070], 0x1, [0x070]
	or	SPR_TSF_WORD0, 0x0, [0xCAF]
	je	r18, 0xB5, L276
	jne	r18, 0x15, L280
L276:
	jext	COND_NEED_RESPONSEFR, L279
	je	r18, 0x15, L277
	add	[0x3DB], 0x1, [0x3DB]
	mov	0x858, SPR_SHMDMA_SHM_Address
	mov	0x16, SPR_MAC_Header_From_SHM_Length
	mov	0xB, SPR_SHMDMA_Xfer_Cnt
	mov	0xC5, r14
	jmp	L278
L277:
	add	[0x3D8], 0x1, [0x3D8]
	mov	0x848, SPR_SHMDMA_SHM_Address
	mov	0x13, SPR_MAC_Header_From_SHM_Length
	mov	0xA, SPR_SHMDMA_Xfer_Cnt
L278:
	mov	0x5, SPR_SHMDMA_Control
	mov	0x800B, SPR_TX_Serial_Control
	add	[0x02,off1], 0x1, [0x02,off1]
	orx	0, 7, 0x1, SPR_PSM_COND, SPR_PSM_COND
	je	r18, 0xB5, L370
	jmp	L315
L279:
	mov	0x8009, SPR_TX_Serial_Control
	add	[0x3D9], 0x1, [0x3D9]
	or	[0x0F,off0], 0x0, SPR_BASE1
	orx	2, 10, SPR_TXE0_PHY_CTL1, [0x06,off1], [0x06,off1]
	mov	0x320, SPR_TXE0_TIMEOUT
	mov	0xFFFF, r18
	mov	0x38, r14
	jmp	L370
L280:
	je	r18, 0x52, L281
	jnext	COND_NEED_RESPONSEFR, L300
L281:
	je	r18, 0xC5, L282
	jne	r18, 0x3C, L283
	or	[0x4A2], 0x0, SPR_MAC_Header_From_SHM_Length
	add	SPR_MAC_Header_From_SHM_Length, 0x1, r33
	mov	0x4A4, SPR_SHMDMA_SHM_Address
	sr	r33, 0x1, SPR_SHMDMA_Xfer_Cnt
	mov	0x5, SPR_SHMDMA_Control
	mov	0x800F, SPR_TX_Serial_Control
	add	[0x3DA], 0x1, [0x3DA]
	jmp	L315
L282:
	orx	0, 8, 0x1, r44, r44
	mov	0x3FC0, SPR_TXE0_WM0
	calls	L534
	mov	0x0, r34
	mov	0x10, SPR_TXE0_FIFO_Write_Pointer
	calls	L543
	mov	0x8001, SPR_TX_Serial_Control
	add	[0x3DC], 0x1, [0x3DC]
	jmp	L315
L283:
	jne	r18, 0x25, L287
L284:
	jnzx	0, 0, SPR_TXBA_Control, 0x0, L284
	mov	0x8000, SPR_TXBA_Data_Select
	or	SPR_TXBA_Data_Select, 0x0, 0x0
	or	SPR_TXBA_Data, 0x0, SPR_TME_VAL32
	or	SPR_TXBA_Data_Select, 0x0, 0x0
	or	SPR_TXBA_Data, 0x0, SPR_TME_VAL34
	or	SPR_TXBA_Data_Select, 0x0, 0x0
	or	SPR_TXBA_Data, 0x0, SPR_TME_VAL36
	or	SPR_TXBA_Data_Select, 0x0, 0x0
	or	SPR_TXBA_Data, 0x0, SPR_TME_VAL38
	je	SPR_TME_VAL32, 0x0, L285
	sl	SPR_TXBA_Data, 0x4, SPR_TME_VAL30
L285:
	mov	0xFF80, SPR_TXE0_WM0
	mov	0xF, SPR_TXE0_WM1
	jzx	0, 1, [SHM_HOST_FLAGS2], 0x0, L286
	jzx	0, 0, [0x03,off1], 0x0, L286
	jzx	0, 1, SPR_AQM_FIFO_Ready, 0x0, L286
	orx	0, 6, 0x1, SPR_TXE0_WM0, SPR_TXE0_WM0
	mov	0x2, SPR_TME_MASK12
	mov	0x2, SPR_TME_VAL12
	add	[0xCB4], 0x1, [0xCB4]
	orx	0, 11, 0x1, r43, r43
L286:
	mov	0x0, SPR_TXE0_FIFO_Head
	mov	0x0, r34
	mov	0x1C, SPR_TXE0_FIFO_Write_Pointer
	calls	L543
	mov	0x8001, SPR_TX_Serial_Control
	add	[0x0AB], 0x1, [0x0AB]
	jmp	L315
L287:
	jne	r18, 0x29, L288
	mov	0x980, r34
	mov	0x10, SPR_TXE0_FIFO_Write_Pointer
	calls	L543
	mov	0x8001, SPR_TX_Serial_Control
	jmp	L291
L288:
	je	r18, 0x52, L289
	jne	r18, 0x12, L292
L289:
	jnzx	0, 11, SPR_TME_VAL12, 0x0, L290
	add	r9, 0x1, r9
L290:
	orx	11, 4, r9, 0x0, SPR_TME_VAL34
	srx	2, 8, [0x788], 0x0, r38
	mul	0x18, r38, 0x0
	add	0x2C, SPR_PSM_0x5a, r34
	mov	0x18, SPR_TXE0_FIFO_Write_Pointer
	calls	L543
	mov	0x8001, SPR_TX_Serial_Control
	add	[0x074], 0x1, [0x074]
L291:
	mov	0xC0, SPR_TXE0_WM0
	mov	0x2, SPR_TXE0_WM1
	jnzx	0, 6, r44, 0x0, L374
	jzx	0, 0, r45, 0x0, L374
	orx	1, 13, 0x3, r63, r63
	jmp	L369
L292:
	srx	0, 6, r20, 0x0, r34
	je	[0x40B], 0x0, L293
	or	[0x40B], 0x0, r34
	sr	[0x73A], r34, r34
L293:
	jnzx	0, 12, r63, 0x0, L294
	je	[0xB39], 0x0, L295
L294:
	mov	0x1, r34
L295:
	orx	0, 12, r34, SPR_TME_VAL12, SPR_TME_VAL12
	calls	L534
	jnzx	0, 7, [0xB6E], 0x0, L296
	jnzx	0, 6, [0xBA4], 0x0, L297
L296:
	je	[0xB39], 0x0, L297
	add	SPR_TME_VAL14, [0xB3F], SPR_TME_VAL14
L297:
	mov	0x7C0, SPR_TXE0_WM0
	mov	0x0, r34
	mov	0xA, SPR_TXE0_FIFO_Write_Pointer
	jzx	0, 2, [0xC47], 0x0, L298
	orx	2, 11, 0x7, SPR_TXE0_WM0, SPR_TXE0_WM0
	or	SPR_TME_VAL12, 0x0, SPR_TME_VAL22
	mov	0x0, SPR_TME_VAL24
	mov	0x0, SPR_TME_VAL26
	orx	5, 2, 0x1D, SPR_TME_VAL12, SPR_TME_VAL12
	add	SPR_TXE0_FIFO_Write_Pointer, 0x6, SPR_TXE0_FIFO_Write_Pointer
	or	[0xC53], 0x0, SPR_TXE0_0x70
	or	[0xC55], 0x1, SPR_TXE0_0x72
	or	[0xC54], 0x0, SPR_TXE0_0x7e
L298:
	calls	L543
	mov	0x8001, SPR_TX_Serial_Control
	je	r18, 0x35, L299
	add	[0x072], 0x1, [0x072]
	jmp	L315
L299:
	add	[0x073], 0x1, [0x073]
	jmp	L315
L300:
	jnext	COND_NEED_BEACON, L316
	je	r18, 0x31, L297
	orx	0, 3, 0x0, SPR_BRC, SPR_BRC
	add	[0x075], 0x1, [0x075]
	jnext	0x34, L311
	mov	0x0, r34
	jgs	r8, 0x0, L301
	srx	0, 4, SPR_AQM_FIFO_Ready, 0x0, r34
	orx	0, 11, r34, SPR_BRC, SPR_BRC
L301:
	orx	0, 1, 0x1, SPR_TXE0_AUX, SPR_TXE0_AUX
	jnzx	0, 8, r20, 0x0, L302
	mov	0x482, r33
	jmp	L303
L302:
	mov	0x202, r33
L303:
	je	[SHM_DTIMP], 0x0, L311
	add	r33, [SHM_TIMBPOS], r33
	mov	0x844, SPR_BASE4
	orx	1, 0, 0x2, r33, SPR_TXE0_0x64
L304:
	jnzx	0, 1, SPR_TXE0_0x64, 0x0, L304
	or	SPR_TXE0_Template_Data_Low, 0x0, [0x844]
	or	SPR_TXE0_Template_Data_High, 0x0, [0x845]
	add	SPR_TXE0_0x64, 0x6, SPR_TXE0_0x64
L305:
	jnzx	0, 1, SPR_TXE0_0x64, 0x0, L305
	or	SPR_TXE0_Template_Data_Low, 0x0, [0x846]
	or	SPR_TXE0_Template_Data_High, 0x0, [0x847]
	jnand	r33, 0x2, L307
	jnand	r33, 0x1, L306
	orx	7, 0, r8, [0x00,off4], [0x00,off4]
	orx	0, 0, r34, [0x01,off4], [0x01,off4]
	jmp	L309
L306:
	orx	7, 8, r8, [0x00,off4], [0x00,off4]
	orx	0, 8, r34, [0x01,off4], [0x01,off4]
	jmp	L309
L307:
	jnand	r33, 0x1, L308
	orx	7, 0, r8, [0x01,off4], [0x01,off4]
	orx	0, 0, r34, [0x02,off4], [0x02,off4]
	jmp	L309
L308:
	orx	7, 8, r8, [0x01,off4], [0x01,off4]
	orx	0, 8, r34, [0x02,off4], [0x02,off4]
L309:
	or	[0x00,off4], 0x0, SPR_TXE0_Template_Data_Low
	or	[0x01,off4], 0x0, SPR_TXE0_Template_Data_High
	orx	1, 0, 0x1, r33, SPR_TXE0_0x64
L310:
	jnzx	0, 0, SPR_TXE0_0x64, 0x0, L310
	or	[0x02,off4], 0x0, SPR_TXE0_Template_Data_Low
	or	[0x03,off4], 0x0, SPR_TXE0_Template_Data_High
	add	SPR_TXE0_0x64, 0x5, SPR_TXE0_0x64
L311:
	orx	0, 1, 0x1, SPR_TXE0_WM1, SPR_TXE0_WM1
	add	r9, 0x1, r9
	orx	11, 4, r9, 0x0, SPR_TME_VAL34
	mov	0x200, r34
	sub	[SHM_BTL0], 0x0, SPR_TXE0_FIFO_Write_Pointer
	jnzx	0, 8, r20, 0x0, L312
	mov	0x480, r34
	sub	[SHM_BTL1], 0x0, SPR_TXE0_FIFO_Write_Pointer
L312:
	calls	L543
	mov	0x8000, SPR_TX_Serial_Control
	orx	0, 7, 0x1, r20, r20
	orx	0, 12, 0x0, SPR_BRC, SPR_BRC
	jext	0x34, L313
	jnzx	0, 0, SPR_TSF_0x0e, 0x0, L314
	or	r15, 0x0, SPR_IFS_BKOFFTIME
	mov	0x0, r15
	or	r16, 0x0, r5
	or	r3, 0x0, r16
	jmp	L314
L313:
	or	r3, 0x0, r5
	jnzx	0, 0, SPR_TSF_0x0e, 0x0, L314
	and	SPR_TSF_RANDOM, r5, SPR_IFS_BKOFFTIME
L314:
	mov	0x8, SPR_MAC_IRQLO
	orx	0, 5, 0x1, r20, r20
	jmp	L373
L315:
	jzx	0, 9, r43, 0x0, L374
	orx	0, 10, 0x1, r43, r43
	mov	0x0, SPR_TXE0_CTL
	mov	0x0, SPR_IFS_CTL1
	calls	L828
	jmp	L469
L316:
	jext	0x42, L317
	jne	[SHM_TXFCUR], 0x7, L320
	orx	0, 2, 0x1, SPR_BRC, SPR_BRC
L317:
	add	r39, 0x1, r39
	jne	[0x865], 0x0, L318
	add	r9, 0x1, r9
	jmp	L319
L318:
	orx	0, 11, 0x1, 0x0, SPR_TME_VAL12
	orx	0, 11, 0x1, 0x0, SPR_TME_MASK12
	or	SPR_TXE0_WM0, 0x40, SPR_TXE0_WM0
L319:
	orx	11, 4, r9, 0x0, SPR_TME_VAL34
	orx	0, 1, 0x1, SPR_TXE0_WM1, SPR_TXE0_WM1
	mov	0x780, r33
	or	SPR_TXE0_WM0, r33, SPR_TXE0_WM0
	mov	0x700, r34
	or	[SHM_PRTLEN], 0x0, SPR_TXE0_FIFO_Write_Pointer
	calls	L543
	mov	0x8001, SPR_TX_Serial_Control
	jmp	L369
L320:
	mov	0x0, r39
	jge	[SHM_TXFCUR], 0x4, L321
	orx	0, 7, 0x1, SPR_PSM_COND, SPR_PSM_COND
L321:
	orx	0, 0, 0x1, r44, r44
	jzx	0, 7, [0x02,off0], 0x0, L323
	jne	r18, 0x20, L322
	orx	0, 15, 0x0, SPR_TSF_GPT1_STAT, SPR_TSF_GPT1_STAT
	sl	[0x4C9], 0x2, r33
	mov	0x777, SPR_BASE5
	add	SPR_BASE5, r33, SPR_BASE5
	add.	SPR_TSF_WORD0, [0x00,off5], SPR_TME_VAL36
	addc.	SPR_TSF_WORD1, [0x01,off5], SPR_TME_VAL38
	addc.	SPR_TSF_WORD2, [0x02,off5], SPR_TME_VAL40
	addc	SPR_TSF_WORD3, [0x03,off5], SPR_TME_VAL42
	or	SPR_TXE0_WM1, 0x3C, SPR_TXE0_WM1
	jmp	L323
L322:
	or	SPR_TSF_WORD0, 0x0, SPR_TME_VAL44
	or	SPR_TSF_WORD1, 0x0, SPR_TME_VAL46
	or	SPR_TXE0_WM1, 0xC0, SPR_TXE0_WM1
L323:
	jand	0x3, [0x0B,off0], L326
	sl	r18, 0x2, SPR_TME_VAL12
	mov	0xFFFF, SPR_TME_MASK12
	or	[0x3D3], 0x0, SPR_TME_VAL14
	mov	0xC0, SPR_TXE0_WM0
	mov	0x7C, SPR_TXE0_FIFO_Read_Pointer
	jzx	0, 0, [0x01,off0], 0x0, L324
	mov	0x14, SPR_TXE0_FIFO_Read_Pointer
L324:
	jzx	0, 0, [0x0B,off0], 0x0, L325
	orx	1, 8, 0x3, SPR_TXE0_WM0, SPR_TXE0_WM0
	mov	0x3EE0, SPR_TME_VAL16
	mov	0x44, SPR_TME_VAL18
	add	SPR_TXE0_FIFO_Read_Pointer, 0x6, SPR_TXE0_FIFO_Read_Pointer
	mov	0xA, SPR_TXE0_FIFO_Write_Pointer
	orx	8, 7, 0x10B, r50, SPR_TXE0_FIFO_Head
	mov	0x8001, SPR_TX_Serial_Control
	jmp	L375
L325:
	add	[0x071], 0x1, [0x071]
	mov	0x10, SPR_TXE0_FIFO_Write_Pointer
	orx	8, 7, 0x10B, r50, SPR_TXE0_FIFO_Head
	mov	0x8001, SPR_TX_Serial_Control
	mov	0x31, r14
	jmp	L355
L326:
	jnext	COND_4_C4, L327
	add	[0x0A9], 0x1, [0x0A9]
L327:
	mov	0x0, [0x13,off0]
	srx	7, 0, [0x04,off0], 0x0, SPR_WEP_IV_Key
	add	SPR_WEP_IV_Key, 0xC, SPR_WEP_IV_Key
	mov	0x0, SPR_TME_VAL12
	mov	0x0, SPR_TME_MASK12
	srx	0, 0, [0x02,off0], 0x0, r33
	xor	r33, 0x1, r33
	orx	0, 14, r33, SPR_TXE0_CTL, SPR_TXE0_CTL
	jnext	COND_PSM(7), L329
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L329
	jzx	0, 0, [SHM_HOST_FLAGS4], 0x0, L328
	sub	[SHM_SLOTT], 0x2, SPR_IFS_slot
	orx	7, 8, 0x2, SPR_IFS_slot, SPR_IFS_slot
L328:
	jext	0x15, L329
	or	[0x162], 0x0, SPR_BASE5
	add	[0x08,off5], 0x1, [0x08,off5]
	je	[0x00,off5], 0x0, L329
	or	SPR_TSF_WORD0, 0x0, SPR_TSF_0x24
	or	[0x00,off5], 0x0, SPR_TSF_0x2a
L329:
	jne	[0x042], 0x1, L330
	je	[0xBD1], 0x0, L330
	mov	0xC1A, SPR_BASE5
	sub	[0xBD1], 0x1, r33
	and	r33, 0x7, r33
	add	SPR_BASE5, r33, SPR_BASE5
	add	[0x00,off5], 0x1, [0x00,off5]
L330:
	jzx	0, 2, [0x0A,off0], 0x0, L336
	jzx	0, 3, [0x0A,off0], 0x0, L331
	orx	0, 1, 0x1, SPR_PSM_COND, SPR_PSM_COND
L331:
	or	SPR_AQM_MPDU_Len_FIFO, 0x0, SPR_WEP_WKey
	srx	6, 0, SPR_AQM_Agg_Stats, 0x0, r33
	mov	0xBD1, SPR_BASE4
	add	SPR_BASE4, r33, SPR_BASE4
	add	[0x00,off4], 0x1, [0x00,off4]
	add	[0x07C], 0x1, [0x07C]
	or	r33, 0x0, [0xB07]
	add	[0x07D], r33, [0x07D]
	mov	0xA, SPR_TXE0_0x70
	jne	[0xB07], 0x1, L334
L332:
	orx	0, 3, 0x0, SPR_TXE0_0x70, SPR_TXE0_0x70
	jzx	0, 0, SPR_TXE0_PHY_CTL, 0x0, L333
	srx	2, 12, SPR_TDC_VHT_MAC_PAD, 0x0, r33
	srx	11, 0, SPR_TDC_VHT_MAC_PAD, 0x0, SPR_TXE0_0x7e
	orx	2, 8, r33, SPR_TXE0_0x70, SPR_TXE0_0x70
L333:
	mov	0x7, SPR_TXE0_SELECT
L334:
	srx	5, 0, SPR_AQM_IDX_FIFO, 0x0, r50
	sl	SPR_WEP_WKey, 0x4, SPR_TXE0_0x72
	srx	1, 12, SPR_WEP_WKey, 0x0, r33
	orx	1, 2, r33, SPR_TXE0_0x72, SPR_TXE0_0x72
	jzx	0, 2, [0x02,off0], 0x0, L335
	or	SPR_TXE0_0x72, 0x1, SPR_TXE0_0x72
L335:
	je	[0xB07], 0x1, L336
	add	SPR_WEP_WKey, 0x7, r33
	nand	r33, 0x3, r33
	jge	r33, SPR_AQM_Min_MPDU_Length, L336
	sub	SPR_AQM_Min_MPDU_Length, r33, r34
	sr	r34, 0x2, SPR_TXE0_0x7e
L336:
	jnzx	0, 0, SPR_TXE0_0x70, 0x0, L337
	calls	L538
L337:
	jl	SPR_AQM_TX_Control_FIFO, [0x13,off0], L338
	or	SPR_AQM_TX_Control_FIFO, 0x0, [0x13,off0]
	or	r50, 0x0, [0x14,off0]
L338:
	orx	0, 11, 0x0, SPR_TME_VAL12, SPR_TME_VAL12
	je	SPR_AQM_TX_Control_FIFO, 0x0, L339
	srx	1, 0, r18, 0x0, r33
	je	r33, 0x1, L340
	orx	0, 11, 0x1, SPR_TME_VAL12, SPR_TME_VAL12
L339:
	orx	0, 11, 0x1, SPR_TME_MASK12, SPR_TME_MASK12
L340:
	jzx	0, 1, [SHM_HOST_FLAGS2], 0x0, L341
	or	[0x042], 0x0, r33
	jl	r33, [0x069], L341
	orx	0, 0, 0x1, SPR_TME_VAL12, SPR_TME_VAL12
	orx	0, 0, 0x1, SPR_TME_MASK12, SPR_TME_MASK12
	add	[0xCB3], 0x1, [0xCB3]
L341:
	jnzx	0, 7, SPR_TXE0_WM0, 0x0, L342
	or	[0x675], 0x0, SPR_TME_VAL14
	orx	0, 7, 0x1, SPR_TXE0_WM0, SPR_TXE0_WM0
L342:
	srx	2, 4, [0x6A2], 0x0, r38
	jzx	0, 4, [0x02,off0], 0x0, L348
	jne	r50, 0x0, L343
	sl	[0x3D4], 0x4, [0x07,off0]
L343:
	je	r38, 0x5, L344
	jne	r38, 0x2, L347
L344:
	mov	0x6A8, SPR_BASE4
	sr	SPR_WEP_IV_Key, 0x1, r33
	add	SPR_BASE4, r33, SPR_BASE4
	je	r38, 0x2, L345
	add.	[0x3D5], r50, [0x00,off4]
	jmp	L346
L345:
	add.	[0x3D5], r50, r33
	orx	7, 0, r33, [0x01,off4], [0x01,off4]
	sr	r33, 0x8, r33
	orx	7, 0, r33, [0x00,off4], [0x00,off4]
L346:
	addc.	[0x3D6], 0x0, [0x02,off4]
	addc	[0x3D7], 0x0, [0x03,off4]
L347:
	add	[0x3D4], r50, r33
	orx	11, 4, r33, [0x6B9], [0x6B9]
	jmp	L351
L348:
	jzx	0, 11, [0x01,off0], 0x0, L351
	jnzx	0, 11, SPR_TME_VAL12, 0x0, L350
	jzx	0, 14, [0x01,off0], 0x0, L349
	add	r9, 0x1, r9
L349:
	orx	11, 4, r9, [0x6B9], [0x07,off0]
L350:
	or	[0x07,off0], 0x0, SPR_TME_VAL34
	orx	0, 1, 0x1, SPR_TXE0_WM1, SPR_TXE0_WM1
	jzx	0, 8, [0x02,off0], 0x0, L351
	orx	3, 4, 0x2, [0xC47], [0xC47]
	or	[0xC49], 0x0, SPR_TME_VAL14
	orx	0, 7, 0x1, SPR_TXE0_WM0, SPR_TXE0_WM0
L351:
	mov	0x1, SPR_TX_Serial_Control
	srx	7, 0, [0x1E,off0], 0x0, SPR_TXE0_FIFO_Read_Pointer
	jzx	7, 8, [0x1E,off0], 0x0, L353
	srx	7, 8, [0x1E,off0], 0x0, SPR_MAC_Header_From_SHM_Length
	jnext	COND_PSM(1), L352
	sl	r50, 0x4, r34
	add	[0x07,off0], r34, [0x6B9]
L352:
	orx	0, 1, 0x1, SPR_TX_Serial_Control, SPR_TX_Serial_Control
	mov	0x6AE, SPR_SHMDMA_SHM_Address
	add	SPR_MAC_Header_From_SHM_Length, 0x1, r33
	sr	r33, 0x1, SPR_SHMDMA_Xfer_Cnt
	mov	0x5, SPR_SHMDMA_Control
	sub	SPR_WEP_WKey, 0x4, r33
	jne	SPR_MAC_Header_From_SHM_Length, r33, L353
	orx	0, 3, 0x1, SPR_TX_Serial_Control, SPR_TX_Serial_Control
	jmp	L354
L353:
	orx	8, 7, 0x109, r50, SPR_TXE0_FIFO_Head
L354:
	orx	0, 15, 0x1, SPR_TX_Serial_Control, SPR_TX_Serial_Control
L355:
	srx	0, 9, SPR_MAC_CTLHI, 0x0, r33
	je	[0x4C9], 0x0, L356
	or	[0x4C9], 0x0, r33
	sr	[0x73A], r33, r33
	jmp	L357
L356:
	jnext	COND_4_C4, L357
	srx	0, 6, r20, 0x0, r33
L357:
	or	r33, 0x0, r34
	jnzx	0, 12, r63, 0x0, L358
	je	[0xB39], 0x0, L359
L358:
	mov	0x1, r34
L359:
	jnzx	1, 0, r18, 0x0, L360
	je	r18, 0x34, L360
	mov	0x0, r34
	mov	0x0, r33
L360:
	jne	[0x4C9], 0x0, L361
	orx	0, 6, r33, r20, r20
L361:
	orx	0, 3, r33, [0x09,off0], [0x09,off0]
	orx	0, 12, r34, SPR_TME_VAL12, SPR_TME_VAL12
	orx	0, 12, 0x1, SPR_TME_MASK12, SPR_TME_MASK12
	orx	0, 6, 0x1, SPR_TXE0_WM0, SPR_TXE0_WM0
	je	r14, 0x31, L370
	srx	1, 0, r18, 0x0, r33
	je	r33, 0x1, L367
	jne	[SHM_TXFCUR], 0x4, L364
	or	[SHM_MCASTCOOKIE], 0x0, r34
	jne	r34, 0xFFFF, L362
	srx	9, 0, SPR_TXE0_FIFO_Frame_Count, 0x0, r33
	je	r33, 0x1, L363
L362:
	jne	r34, [0x06,off0], L364
L363:
	orx	0, 11, 0x0, SPR_BRC, SPR_BRC
	orx	0, 13, 0x0, SPR_TME_VAL12, SPR_TME_VAL12
	orx	0, 13, 0x1, SPR_TME_MASK12, SPR_TME_MASK12
L364:
	jnzx	0, 4, SPR_WEP_CTL, 0x0, L367
	je	r38, 0x0, L367
	or	r38, 0x0, SPR_WEP_CTL
	srx	5, 8, [0x6A2], 0x0, r0
	sl	r0, 0x3, r0
	jne	r38, 0x2, L365
	jzx	0, 13, [0x01,off0], 0x0, L366
	orx	0, 13, 0x1, SPR_WEP_CTL, SPR_WEP_CTL
	mov	0x108, SPR_WEP_0x48
	add	r0, [0x059], SPR_BASE5
	or	[0x00,off5], 0x0, SPR_WEP_0x4a
	or	[0x01,off5], 0x0, SPR_WEP_0x4a
	or	[0x02,off5], 0x0, SPR_WEP_0x4a
	or	[0x03,off5], 0x0, SPR_WEP_0x4a
L365:
	jne	r38, 0x7, L366
	add	[SHM_KTP], r0, SPR_BASE5
	calls	L1033
L366:
	orx	4, 4, 0x11, SPR_WEP_CTL, SPR_WEP_CTL
L367:
	jnext	0x71, L368
	jne	r18, 0x24, L368
	jzx	0, 0, [0x6B0], 0x0, L368
	orx	0, 11, 0x1, SPR_BRC, SPR_BRC
L368:
	mov	0x0, SPR_TSF_RANDOM
	jext	COND_4_C7, L379
	jzx	0, 7, [0x01,off0], 0x0, L372
L369:
	add	[0x0A8], 0x1, [0x0A8]
L370:
	orx	0, 7, 0x1, SPR_BRC, SPR_BRC
	jne	r14, 0x0, L371
	mov	0x25, r14
	je	r18, 0x21, L371
	jext	COND_PSM(1), L371
	mov	0x35, r14
L371:
	jge	[SHM_TXFCUR], 0x7, L374
	jzx	0, 6, [0x08,off6], 0x0, L374
	or	[0x0F,off0], 0x0, SPR_BASE1
	je	r14, 0x31, L374
	mov	0x442, r33
	mov	0xA, r34
	calls	L68
	mov	0x443, r33
	srx	4, 0, [0x00,off1], 0x0, r34
	calls	L68
	orx	0, 8, 0x0, [0x00,off1], [0x00,off1]
	jmp	L374
L372:
	orx	0, 2, 0x1, r43, r43
	or	r3, 0x0, r5
	calls	L1027
L373:
	mov	0x0, r12
	mov	0x0, r13
L374:
	jnext	COND_4_C7, L375
	orx	0, 15, 0x1, SPR_TXE0_TIMEOUT, SPR_TXE0_TIMEOUT
L375:
	jnzx	0, 4, SPR_WEP_CTL, 0x0, L376
	mov	0x10, SPR_WEP_CTL
L376:
	mov	0x0, SPR_IFS_CTL1
	or	r18, 0x0, r21
	jne	SPR_TXE0_FIFO_PRI_RDY, 0x7, L377
	orx	0, 6, 0x1, r21, r21
L377:
	jne	[0xC36], 0x0, L378
	or	r18, 0x0, [0xC43]
L378:
	jnext	COND_PSM(1), L380
L379:
	jext	EOI(0x16), L787
	jext	EOI(0x17), L789
	calls	L1120
	calls	L1325
	jnext	EOI(0x11), L379
	jmp	L410
L380:
	jzx	0, 7, r43, 0x0, L381
	orx	0, 15, 0x1, SPR_TSF_GPT2_STAT, SPR_TSF_GPT2_STAT
L381:
	jmp	L0
L382:
	orx	2, 0, 0x2, [0x0B,off0], [0x0B,off0]
	mov	0x2D, r18
L383:
	orx	1, 0, [0x08,off6], 0x4, SPR_TXE0_PHY_CTL
	srx	0, 4, [0x08,off6], 0x0, r33
	orx	0, 4, r33, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	srx	0, 0, [0x08,off6], 0x0, [0x864]
	srx	3, 8, [0x08,off6], 0x0, r33
	mov	0x100, SPR_BASE4
	mov	0xC0, [0x006]
	jzx	0, 0, [0x08,off6], 0x0, L384
	mov	0xE0, SPR_BASE4
	mov	0x14, [0x006]
L384:
	add	SPR_BASE4, r33, SPR_BASE4
	or	[0x00,off4], 0x0, SPR_BASE3
	or	[0x00,off4], 0x0, SPR_BASE2
	srx	2, 8, [SHM_CHAN], 0x0, r34
	orx	2, 0, r34, [0x07,off3], SPR_TXE0_PHY_CTL1
	jnzx	0, 0, [0x08,off6], 0x0, L386
	je	r18, 0x31, L385
	or	[0x0C,off3], 0x0, SPR_TX_PLCP_HT_Sig0
	or	[0x0D,off3], 0x0, SPR_TX_PLCP_HT_Sig1
	jmp	L390
L385:
	or	[0x01,off3], 0x0, SPR_TX_PLCP_HT_Sig0
	or	[0x02,off3], 0x0, SPR_TX_PLCP_HT_Sig1
	jmp	L390
L386:
	jzx	0, 15, [SHM_HOST_FLAGS1], 0x0, L387
	or	r41, 0x0, r34
	orx	2, 0, 0x0, SPR_TXE0_PHY_CTL1, SPR_TXE0_PHY_CTL1
	jmp	L388
L387:
	orx	2, 0, [0x01,off6], SPR_TXE0_PHY_CTL1, SPR_TXE0_PHY_CTL1
	srx	1, 14, [0x00,off6], 0x0, r34
L388:
	orx	1, 14, r34, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	or	[0x01,off3], 0x0, SPR_TX_PLCP_HT_Sig0
	je	r18, 0x31, L389
	orx	10, 5, 0x14, [0x01,off3], SPR_TX_PLCP_HT_Sig0
L389:
	mov	0x0, SPR_TX_PLCP_HT_Sig1
L390:
	add	r2, [SHM_EDCFSTAT], [0x3D3]
	add	r2, [0x03,off3], r2
	je	r18, 0x31, L228
	or	[0x3D3], 0x0, r33
	add	r33, [0x03,off3], [0x3D3]
	add	r2, [0x09,off3], r2
	jmp	L228
L391:
	orx	2, 0, 0x1, [0x0B,off0], [0x0B,off0]
	mov	0x31, r18
	jmp	L383
L392:
	jnzx	0, 0, SPR_MHP_Addr1_Low, 0x0, L393
	jnext	COND_PSM(5), L745
	add	[0x3DE], 0x1, [0x3DE]
L393:
	jnext	0x62, L745
	srx	5, 8, SPR_AMT_Match1, 0x0, r34
	add	0x334, r34, SPR_BASE4
	jzx	0, 12, [0x00,off4], 0x0, L745
	srx	2, 13, [0x00,off4], 0x0, r34
	sl	r34, 0x4, r34
	add	[0x40C], r34, SPR_BASE4
	orx	0, 8, 0x1, r44, r44
	or	SPR_BASE4, 0x0, [0x4B4]
	mov	0x442, r33
	or	[0x07,off4], 0x0, r34
	calls	L68
	mov	0x444, r33
	or	[0x08,off4], 0x0, r34
	calls	L68
	mov	0x445, r33
	calls	L66
	orx	0, 14, 0x0, SPR_Ext_IHR_Data, r34
	calls	L68
	calls	L1016
	orx	0, 0, 0x0, SPR_MHP_Addr2_Low, [0x4A6]
	or	SPR_MHP_Addr2_Mid, 0x0, [0x4A7]
	or	SPR_MHP_Addr2_High, 0x0, [0x4A8]
	or	[0x09,off4], 0x0, [0x4AC]
	or	[0x0A,off4], 0x0, [0x4AD]
	or	[0x0B,off4], 0x0, [0x4AE]
	or	SPR_BASE2, 0x0, [0x4A3]
	jne	r19, 0x15, L745
	or	[0x0B,off1], 0x0, [0x4B2]
	srx	5, 2, [0x0B,off1], 0x0, [0x4AF]
	jmp	L745
L394:
	add	[0x3DF], 0x1, [0x3DF]
	jzx	0, 8, r44, 0x0, L0
	or	[0x4B4], 0x0, SPR_BASE4
	jzx	0, 0, SPR_RXE_PHYRXSTAT0, 0x0, L395
	srx	2, 10, [0x7D9], 0x0, r33
	srx	2, 3, [0x08,off4], 0x0, r34
	orx	2, 3, r33, [0x08,off4], [0x08,off4]
	jmp	L396
L395:
	srx	3, 3, [0x7D9], 0x0, r33
	srx	1, 2, [0x08,off4], 0x0, r34
	orx	1, 2, r33, [0x08,off4], [0x08,off4]
L396:
	or	[0x40F], 0x0, r35
	jge	r33, [0x40F], L397
	or	r33, 0x0, r35
L397:
	jzx	0, 0, SPR_RXE_PHYRXSTAT0, 0x0, L398
	orx	2, 0, r35, [0x08,off4], [0x08,off4]
	jmp	L399
L398:
	orx	1, 0, r35, [0x08,off4], [0x08,off4]
L399:
	jne	r34, r33, L55
	or	[0x08,off4], 0x0, [0x4B1]
	mov	0x447, r33
	calls	L66
	srx	1, 14, SPR_Ext_IHR_Data, 0x0, r37
	jzx	0, 0, SPR_RXE_PHYRXSTAT0, 0x0, L400
	orx	1, 6, r37, [0x4B1], [0x4B1]
	mov	0x15, [0x4B0]
	mov	0x1D, [0x4A2]
	jmp	L401
L400:
	orx	0, 4, r37, [0x4B1], [0x4B1]
	or	SPR_TSF_WORD0, 0x0, [0x4B2]
	or	SPR_TSF_WORD1, 0x0, [0x4B3]
	mov	0x607, [0x4B0]
	mov	0x20, [0x4A2]
L401:
	calls	L826
	mov	0x448, r33
	calls	L66
	srx	12, 0, SPR_Ext_IHR_Data, 0x0, SPR_TX_BF_Rpt_Length
	or	[0x4A3], 0x0, SPR_BASE2
	or	[0x7DE], 0x0, [0x4A9]
	or	[0x7DF], 0x0, [0x4AA]
	or	[0x7E0], 0x0, [0x4AB]
	or	[0x01,off2], 0x0, SPR_TX_PLCP_HT_Sig0
	mov	0x1, [0x864]
	calls	L1018
	add	SPR_TX_BF_Rpt_Length, [0x4A2], r33
	add	r33, 0x4, r33
	orx	10, 5, r33, SPR_TX_PLCP_HT_Sig0, SPR_TX_PLCP_HT_Sig0
	sr	r33, 0xB, r33
	orx	4, 0, r33, [0x02,off2], SPR_TX_PLCP_HT_Sig1
	mov	0x3C, r18
	orx	2, 0, 0x2, SPR_BRC, SPR_BRC
	jmp	L241
L402:
	mov	0x100, SPR_TX_BF_Control
	mov	0x443, r33
	mov	0x20, r34
	calls	L68
	mov	0x0, r34
	calls	L68
	mov	0x439, r33
	mov	0xC, r34
	calls	L68
	mov	0x3, r34
	calls	L68
	mov	0x0, SPR_TX_BF_Control
	rets
L403:
	jext	COND_PSM(5), L404
	jzx	0, 0, [0x05,off1], 0x0, L747
L404:
	jnext	0x63, L881
	or	[0x7A2], 0x0, SPR_BASE4
	orx	0, 3, 0x1, [0x02,off4], [0x02,off4]
	jext	COND_PSM(5), L521
	jmp	L666
L405:
	or	[0x02,off2], 0x0, SPR_TX_PLCP_HT_Sig1
	orx	10, 5, 0x1A, [0x01,off2], SPR_TX_PLCP_HT_Sig0
	mov	0x85A, SPR_BASE4
	mov	0xB5, r18
	jne	[0x04,off1], 0x15, L406
	mov	0x15, r18
	orx	10, 5, 0x17, [0x01,off2], SPR_TX_PLCP_HT_Sig0
	mov	0x84A, SPR_BASE4
	sl	[0x0C,off1], 0x8, [0x850]
	srx	7, 8, [0x0C,off1], 0x0, [0x851]
L406:
	srx	1, 14, [0x00,off6], 0x0, r33
	orx	1, 14, r33, 0x5, SPR_TXE0_PHY_CTL
	orx	1, 12, r33, [0x00,off1], [0x00,off1]
	srx	2, 0, [0x01,off6], 0x0, r33
	orx	2, 0, r33, [0x07,off2], SPR_TXE0_PHY_CTL1
	or	[0x6B0], 0x0, [0x00,off4]
	or	[0x6B1], 0x0, [0x01,off4]
	or	[0x6B2], 0x0, [0x02,off4]
	jne	r18, 0xB5, L407
	add	SPR_BASE4, 0x3, SPR_BASE4
L407:
	or	[0x6B3], 0x0, [0x03,off4]
	or	[0x6B4], 0x0, [0x04,off4]
	or	[0x6B5], 0x0, [0x05,off4]
	orx	5, 2, [0x03,off1], 0x0, [0x06,off4]
	or	SPR_TX_PLCP_HT_Sig0, 0x0, r0
	calls	L1004
	mov	0x481D, r17
	jmp	L228
L408:
	jnext	COND_PSM(5), L409
	jnext	COND_4_C7, L409
	jne	r19, r14, L409
	add	[0x3E0], 0x1, [0x3E0]
	mov	0x43C, r33
	mov	0x3, r34
	calls	L68
	orx	0, 15, 0x0, SPR_TXE0_TIMEOUT, SPR_TXE0_TIMEOUT
	orx	0, 9, 0x0, SPR_BRC, SPR_BRC
	jext	EOI(0x2A), L409
L409:
	jmp	L747
L410:
	jzx	0, 0, [0xBA5], 0x0, L411
	jnzx	0, 1, [0xBA4], 0x0, L411
L411:
	jzx	0, 3, SPR_TXE0_0x70, 0x0, L412
	sub	[0xB07], 0x1, [0xB07]
	add	spr21e, 0x1, spr21e
	jmp	L274
L412:
	mov	0x7, SPR_TXE0_SELECT
	jzx	0, 13, [SHM_HOST_FLAGS1], 0x0, L413
	mov	0x256, r33
	mov	0xE0, r34
	calls	L68
	or	SPR_TSF_WORD0, 0x0, [0xC2B]
L413:
	orx	0, 5, 0x0, SPR_BRC, SPR_BRC
	mov	0x0, SPR_WEP_CTL
	jnzx	0, 10, [0x6AE], 0x0, L414
	orx	0, 4, 0x0, SPR_BRC, SPR_BRC
L414:
	jext	EOI(0x16), L787
	jext	EOI(0x17), L789
	jext	COND_NEED_RESPONSEFR, L421
	je	r18, 0x52, L5
	je	r18, 0xB5, L5
	jne	r18, 0x15, L420
L415:
	orx	0, 1, 0x1, SPR_BRC, SPR_BRC
	or	[0x0F,off0], 0x0, SPR_BASE4
	orx	13, 0, 0x3, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	srx	7, 8, [0x2EC], 0x0, r33
	jzx	1, 1, [0x05,off4], 0x0, L416
	or	[0x2ED], 0x0, r33
	jnzx	0, 1, [0x05,off4], 0x0, L416
	sr	r33, 0x8, r33
L416:
	orx	7, 6, r33, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	orx	7, 8, r33, [0x05,off4], [0x05,off4]
	orx	2, 2, [0x05,off4], 0x0, r33
	mov	0x420, SPR_BASE4
	add	SPR_BASE4, r33, SPR_BASE4
	orx	2, 0, SPR_TXE0_PHY_CTL1, [0x00,off4], SPR_TXE0_PHY_CTL1
	or	[0x01,off4], 0x0, SPR_TXE0_PHY_CTL2
	srx	1, 14, SPR_TXE0_PHY_CTL, 0x0, r33
	jnzx	0, 0, SPR_TXE0_PHY_CTL, 0x0, L417
	orx	0, 7, r33, [0x03,off4], [0x03,off4]
	mov	0x4B5, SPR_BASE5
	jmp	L418
L417:
	orx	1, 0, r33, [0x03,off4], [0x03,off4]
	mov	0x4B9, SPR_BASE5
	sl	r33, 0x1, r33
	add	SPR_BASE5, r33, SPR_BASE5
	or	[0x00,off5], 0x0, SPR_TX_PLCP_VHT_SigB0
	or	[0x01,off5], 0x0, SPR_TX_PLCP_VHT_SigB1
	mov	0x4B7, SPR_BASE5
L418:
	or	[0x02,off4], 0x0, SPR_TX_PLCP_Sig0
	mov	0x0, SPR_TX_PLCP_Sig1
	or	[0x03,off4], 0x0, SPR_TX_PLCP_HT_Sig0
	or	[0x00,off5], 0x0, SPR_TX_PLCP_HT_Sig1
	or	[0x01,off5], 0x0, SPR_TX_PLCP_HT_Sig2
	add	SPR_TSF_0x40, 0xA, r34
L419:
	jdn	SPR_TSF_WORD0, r34, L419
	orx	1, 8, 0x3, SPR_TXE0_0x76, SPR_TXE0_0x76
	mov	0x1, SPR_TXE0_CTL
	jmp	L0
L420:
	jnext	COND_NEED_BEACON, L423
	orx	0, 7, 0x0, r44, r44
L421:
	orx	1, 0, 0x0, SPR_BRC, SPR_BRC
	mov	0x0, [0xCA8]
	je	r18, 0xC5, L0
	jne	r18, 0x3C, L422
	calls	L402
L422:
	jmp	L5
L423:
	jzx	0, 0, [0x06C], 0x0, L425
	orx	0, 2, 0x1, r46, r46
	jzx	0, 8, [0x06C], 0x0, L424
	sub.	[0x06E], 0x1, [0x06E]
	subc	[0x06F], 0x0, [0x06F]
	jne	[0x06E], 0x0, L424
	jne	[0x06F], 0x0, L424
	mov	0x0, [0x06C]
	jmp	L448
L424:
	mov	0x0, r11
	jmp	L426
L425:
	mov	0x1, r33
	calls	L904
L426:
	jext	COND_4_C7, L5
	jzx	0, 0, [0x0B,off0], 0x0, L427
	mov	0x0, SPR_TXE0_CTL
	orx	0, 4, 0x1, SPR_BRC, SPR_BRC
	orx	0, 0, 0x0, [0x0B,off0], [0x0B,off0]
	add	[0x072], 0x1, [0x072]
	jmp	L141
L427:
	or	[0x042], 0x0, r33
	jge	r33, [SHM_MAXBFRAMES], L447
	sub	SPR_TSF_WORD0, [0x043], r33
	jg	r33, [0x041], L447
	orx	0, 11, 0x1, r43, r43
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L428
	jnzx	1, 1, [SHM_HOST_FLAGS5], 0x0, L428
	jnzx	0, 8, [SHM_HOST_FLAGS3], 0x0, L428
L428:
	jzx	0, 0, [0xBA5], 0x0, L429
	jnzx	0, 1, [0xBA4], 0x0, L429
	jzx	0, 14, [0xBA5], 0x0, L429
	jne	r18, 0x10, L429
	orx	0, 5, 0x1, [0xBA4], [0xBA4]
	add	SPR_TSF_WORD0, [0xBB6], [0xBB5]
	jnzx	0, 4, [0xBA4], 0x0, L429
	mov	0x1, r36
	calls	L1370
L429:
	jmp	L447
L430:
	mov	0x0, SPR_IFS_med_busy_ctl
	jand	[0xC47], 0x6, L431
	calls	L1481
L431:
	jnzx	0, 4, r43, 0x0, L438
	orx	0, 4, 0x1, r43, r43
	or	SPR_TSF_WORD0, 0x0, [0x867]
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L433
	je	SPR_IFS_0x0e, 0x0, L433
	orx	0, 8, 0x0, r43, r43
	jnext	COND_PSM(7), L432
	orx	0, 8, 0x1, r43, r43
L432:
	or	[0x162], 0x0, SPR_BASE5
	calls	L1072
L433:
	jnext	COND_PSM(7), L435
	jg	r40, [0x06B], L435
	or	[0x052], 0x0, r34
	jzx	1, 0, SPR_TXE0_PHY_CTL, 0x0, L434
	or	[0x05A], 0x0, r34
L434:
	je	r34, 0x0, L435
	sr	SPR_IFS_if_tx_duration, 0x4, r33
	mul	r33, r34, r33
	jg	[0x874], SPR_PSM_0x5a, L435
	or	SPR_PSM_0x5a, 0x0, [0x874]
	add.	[0x874], SPR_TSF_WORD0, [0x875]
	addc	r33, SPR_TSF_WORD1, [0xCA9]
	or	SPR_PSM_0x5a, r33, [0x874]
L435:
	jzx	0, 7, r43, 0x0, L436
	mov	0x4000, SPR_TSF_GPT2_STAT
L436:
	add.	[0x3B4], SPR_IFS_if_tx_duration, [0x3B4]
	addc	[0x3B5], 0x0, [0x3B5]
	mov	0x1F1, r33
	calls	L66
	jzx	0, 12, SPR_Ext_IHR_Data, 0x0, L437
	mov	0x164, r33
	calls	L66
	orx	0, 15, 0x1, SPR_Ext_IHR_Data, r34
	calls	L68
	orx	0, 15, 0x0, SPR_Ext_IHR_Data, r34
	calls	L68
L437:
	or	[SHM_TSSI_CCK_HI], 0x0, SPR_IFS_CTL_SEL_PRICRS
	mov	0x40, SPR_IFS_CTL1
	jzx	0, 8, SPR_IFS_STAT, 0x0, L438
	mov	0x0, SPR_IFS_CTL1
L438:
	jzx	0, 0, [0xBA5], 0x0, L440
	jnzx	0, 1, [0xBA4], 0x0, L440
	jne	r18, 0x10, L440
	jnzx	0, 15, [0xBA4], 0x0, L439
	orx	0, 15, 0x1, [0xBA4], [0xBA4]
	mov	0xE, r35
	calls	L1373
	or	SPR_TSF_WORD0, 0x0, r34
	srx	15, 10, r34, SPR_TSF_WORD1, r35
	add	r35, [0xB98], [0xB97]
L439:
	jzx	0, 14, [0xBA5], 0x0, L440
	jnzx	0, 4, [0xBA4], 0x0, L440
	mov	0x1, r36
	calls	L1370
L440:
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L446
	jzx	0, 6, r44, 0x0, L441
	calls	L1111
L441:
	jne	r21, 0x75, L442
	orx	0, 10, 0x0, r45, r45
L442:
	jne	r21, 0x60, L444
	jzx	0, 4, r44, 0x0, L443
	orx	0, 4, 0x0, r44, r44
	jmp	L444
L443:
	mov	0x0, [0xB70]
	mul	[0x4C9], 0xC, r34
	mov	0x747, r34
	add	r34, SPR_PSM_0x5a, SPR_BASE4
	jzx	0, 8, [0x02,off4], 0x0, L444
	mov	0x0, [0xB1B]
	jnzx	0, 11, [SHM_HOST_FLAGS1], 0x0, L444
	orx	0, 0, 0x1, r63, r63
L444:
	jzx	0, 0, r45, 0x0, L445
	jne	r21, 0x71, L445
	calls	L1283
L445:
	calls	L1123
L446:
	calls	L1465
	orx	0, 4, 0x0, r43, r43
	jext	EOI(0x12), L5
L447:
	jzx	0, 0, [0x0A,off0], 0x0, L466
	mov	0x0, [0x14,off0]
L448:
	jnext	COND_PSM(6), L449
	orx	0, 2, 0x1, [0x09,off0], [0x09,off0]
	mov	0x0, r0
	jmp	L452
L449:
	or	SPR_AQM_Upd_BA0, 0x0, [0x7E6]
	or	SPR_AQM_Upd_BA1, 0x0, [0x7E7]
	or	SPR_AQM_Upd_BA2, 0x0, [0x7E8]
	or	SPR_AQM_Upd_BA3, 0x0, [0x7E9]
	or	[0x14,off0], 0x0, SPR_AQM_Max_IDX
	calls	L1391
	jzx	0, 3, [0x02,off0], 0x0, L451
	jnzx	3, 4, [0x09,off0], 0x0, L451
	jne	[0x7E6], SPR_AQM_Upd_BA0, L450
	jne	[0x7E7], SPR_AQM_Upd_BA1, L450
	jne	[0x7E8], SPR_AQM_Upd_BA2, L450
	je	[0x7E9], SPR_AQM_Upd_BA3, L451
L450:
	calls	L1421
L451:
	orx	0, 8, 0x1, SPR_TXE0_FIFO_PRI_RDY, SPR_TXE0_FIFO_PRI_RDY
L452:
	jzx	0, 15, [0x7A4], 0x0, L453
	jne	[SHM_TXFCUR], 0x5, L453
	or	[0x7A9], 0x0, SPR_BASE4
	or	[0x15,off0], 0x0, [0x04,off4]
	or	[0x0C,off0], 0x0, [0x03,off4]
	sr	[0x07,off0], 0x4, [0x02,off4]
	or	[0x06,off0], 0x0, [0x01,off4]
	jmp	L454
L453:
	mov	0x87, SPR_TX_STATUS0
	or	[0x18,off0], 0x0, SPR_TX_STATUS1
	or	[0x17,off0], 0x0, SPR_TX_STATUS1
	or	[0x16,off0], 0x0, SPR_TX_STATUS1
	or	[0x15,off0], 0x0, SPR_TX_STATUS1
	or	[0x0C,off0], 0x0, SPR_TX_STATUS1
	sr	[0x07,off0], 0x4, SPR_TX_STATUS1
	or	[0x06,off0], 0x0, SPR_TX_STATUS1
L454:
	mov	0x0, [0x12,off0]
	mov	0x0, [0x13,off0]
	mov	0x0, [0x14,off0]
	mov	0x0, [0x15,off0]
	mov	0x0, [0x16,off0]
	mov	0x0, [0x17,off0]
	mov	0x0, [0x18,off0]
	mov	0x0, [0x0C,off0]
L455:
	jnzx	0, 8, SPR_TXE0_FIFO_PRI_RDY, 0x0, L455
	jext	COND_PSM(6), L456
	or	SPR_AQM_Cons_Control, 0x0, r0
L456:
	orx	6, 8, r0, [0x09,off0], [0x09,off0]
	jnzx	0, 13, SPR_MAC_CTLHI, 0x0, L463
	jzx	0, 15, [0x7A4], 0x0, L458
	jne	[SHM_TXFCUR], 0x5, L458
	orx	0, 0, 0x1, [0x09,off0], [0x00,off4]
	add	[0x7A9], 0x5, [0x7A9]
	mov	0x7C3, r59
	jl	[0x7A9], r59, L457
	mov	0x7AA, [0x7A9]
L457:
	mov	0x80, spr342
	jmp	L463
L458:
	mov	0x0, SPR_TX_STATUS0
	orx	1, 0, 0x3, [0x09,off0], SPR_TX_STATUS1
	mov	0xDEAD, r33
	jge	[SHM_TXFCUR], 0x4, L460
	sub.	SPR_TSF_WORD0, [0x0D,off0], r33
	subc	SPR_TSF_WORD1, [0x0E,off0], r34
	je	r34, 0x0, L459
	mov	0xFFFF, r33
L459:
	srx	3, 7, [0x0A,off0], 0x0, r34
L460:
	mov	0x87, SPR_TX_STATUS0
	jnzx	0, 11, [SHM_HOST_FLAGS2], 0x0, L461
	or	SPR_TSF_WORD0, 0x0, SPR_TX_STATUS1
	or	r33, 0x0, SPR_TX_STATUS1
	jmp	L462
L461:
	or	[0xCAF], 0x0, SPR_TX_STATUS1
	or	[0x0D,off0], 0x0, SPR_TX_STATUS1
L462:
	or	[0x7E9], 0x0, SPR_TX_STATUS1
	or	[0x7E8], 0x0, SPR_TX_STATUS1
	or	[0x7E7], 0x0, SPR_TX_STATUS1
	or	[0x7E6], 0x0, SPR_TX_STATUS1
	or	[0x10,off0], 0x0, r33
	orx	7, 8, [0x11,off0], r33, SPR_TX_STATUS1
	orx	3, 2, r34, 0x1, SPR_TX_STATUS1
L463:
	mov	0x0, [0x10,off0]
	mov	0x0, [0x11,off0]
	sub	[0x1B,off0], r0, [0x1B,off0]
	jges	[0x1B,off0], 0x0, L464
	mov	0x0, [0x1B,off0]
	mov	0x0, [0x19,off0]
L464:
	jzx	0, 4, [0x02,off0], 0x0, L465
	jzx	0, 14, [0x01,off0], 0x0, L465
	add	[0x3D4], r0, [0x3D4]
	add.	[0x3D5], r0, [0x3D5]
	addc.	[0x3D6], 0x0, [0x3D6]
	addc	[0x3D7], 0x0, [0x3D7]
L465:
	jext	COND_PSM(6), L467
	jnzx	0, 10, [0x6AE], 0x0, L466
	orx	12, 3, 0x0, [0x0B,off0], [0x0B,off0]
L466:
	mov	0x0, [0x0A,off0]
	orx	0, 0, 0x0, r44, r44
L467:
	orx	0, 2, 0x0, [0x09,off0], [0x09,off0]
	nand	SPR_PSM_COND, 0x42, SPR_PSM_COND
	jext	COND_4_C4, L141
	jzx	0, 2, r46, 0x0, L468
	or	SPR_BASE0, 0x0, SPR_BASE4
	srx	3, 0, SPR_TXE0_FIFO_PRI_RDY, 0x0, r36
	sr	0x1, r36, r36
	calls	L843
	orx	0, 2, 0x0, r46, r46
L468:
	jmp	L5
L469:
	orx	0, 2, 0x1, SPR_BRED0, SPR_BRED0
	or	SPR_BRED0, 0x0, 0x0
	jext	EOI(COND_RX_IFS2), L470
L470:
	jnext	COND_4_C7, L504
	jext	0x45, L504
	jext	COND_4_C6, L504
	orx	1, 1, 0x2, r43, r43
	orx	0, 7, 0x0, SPR_BRC, SPR_BRC
	calls	L402
	jnext	EOI(0x2A), L471
	add	SPR_TSF_WORD0, 0x320, [0xC2B]
	add	[0x09A], 0x1, [0x09A]
	orx	0, 1, 0x1, r43, r43
	jmp	L472
L471:
	jext	COND_4_C9, L472
	jext	EOI(COND_PHY1), L506
L472:
	jnzx	0, 0, r45, 0x0, L473
	jnzx	0, 13, r63, 0x0, L475
	jmp	L476
L473:
	orx	0, 0, 0x0, r45, r45
	jnzx	0, 1, [0xBA4], 0x0, L474
	orx	0, 6, 0x0, [0xBA4], [0xBA4]
	jzx	0, 2, [0xBA4], 0x0, L474
	jzx	0, 0, [0xBA4], 0x0, L474
	calls	L1286
	orx	0, 7, 0x0, SPR_BRC, SPR_BRC
	jmp	L0
L474:
	or	[0xB35], 0x0, r33
	jl	[0xB21], r33, L0
	mov	0x0, [0xB21]
	calls	L1285
L475:
	orx	0, 7, 0x0, SPR_BRC, SPR_BRC
	orx	0, 13, 0x0, r63, r63
	jmp	L0
L476:
	jzx	0, 2, [0xBA4], 0x0, L477
	jge	r11, 0x6, L478
L477:
	jand	r44, 0x30, L480
L478:
	orx	0, 4, 0x0, r44, r44
	add	[0xB04], 0x1, [0xB04]
	jzx	0, 0, r44, 0x0, L480
	or	[0xB05], 0x0, r33
	jl	[0xB04], r33, L479
	mov	0x0, [0xB04]
	orx	3, 4, 0x6, [0x09,off0], [0x09,off0]
	jmp	L250
L479:
	mov	0xFFFF, r33
	calls	L904
L480:
	orx	0, 9, 0x0, SPR_BRC, SPR_BRC
	add.	[0x3C4], SPR_IFS_if_tx_duration, [0x3C4]
	addc	[0x3C5], 0x0, [0x3C5]
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L481
	mov	0x0, SPR_TSF_0x2a
	add	0x180, [SHM_TXFCUR], SPR_BASE4
L481:
	orx	0, 4, 0x0, SPR_BRC, SPR_BRC
	je	r14, 0xC5, L482
	jne	r14, 0x38, L483
L482:
	or	[0x0F,off0], 0x0, SPR_BASE5
	srx	7, 0, [0x40E], 0x0, r33
	jl	[0x02,off5], r33, L0
	orx	1, 4, 0x2, [0x0A,off0], [0x0A,off0]
	mov	0x0, [0x02,off5]
	jmp	L0
L483:
	jne	r21, 0x54, L484
	add	[0x0A4], 0x1, [0x0A4]
	orx	0, 2, 0x0, SPR_BRC, SPR_BRC
	jmp	L5
L484:
	jnext	COND_PSM(1), L485
	jzx	0, 2, [0x08,off6], 0x0, L485
	je	r14, 0x25, L488
L485:
	jnext	COND_PHY1, L486
	jzx	0, 1, r43, 0x0, L487
L486:
	orx	14, 1, r5, 0x1, r5
	and	r5, r4, r5
L487:
	je	r14, 0x31, L489
L488:
	jnzx	0, 8, [0x01,off0], 0x0, L493
L489:
	or	r6, 0x0, r35
	or	[SHM_SFFBLIM], 0x0, r36
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L490
	jg	SPR_BASE4, 0x183, L490
	srx	3, 0, [0x00,off4], 0x0, r35
	srx	3, 4, [0x00,off4], 0x0, r36
L490:
	jl	r11, r36, L491
	calls	L917
L491:
	add	r12, 0x1, r12
	jne	r12, r35, L492
	or	r3, 0x0, r5
L492:
	jnand	[0xC47], 0x60, L497
	jge	r11, r35, L497
	jmp	L503
L493:
	or	r7, 0x0, r35
	or	[SHM_LFFBLIM], 0x0, r36
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L494
	jg	SPR_BASE4, 0x183, L494
	srx	3, 8, [0x00,off4], 0x0, r35
	srx	3, 12, [0x00,off4], 0x0, r36
L494:
	jl	r11, r36, L495
	calls	L917
L495:
	add	r13, 0x1, r13
	jne	r13, r35, L496
	or	r3, 0x0, r5
L496:
	jl	r11, r35, L503
L497:
	orx	0, 6, 0x0, SPR_PSM_COND, SPR_PSM_COND
	jext	EOI(0x2A), L498
L498:
	jne	r18, 0x24, L499
	or	[0x6B0], 0x0, SPR_PMQ_pat_0
	or	[0x6B1], 0x0, SPR_PMQ_pat_1
	or	[0x6B2], 0x0, SPR_PMQ_pat_2
	mov	0x8, SPR_PMQ_dat
	mov	0x2, SPR_PMQ_control_low
	jmp	L447
L499:
	or	r3, 0x0, r5
	jne	r14, 0x31, L500
	srx	1, 2, [0x0A,off0], 0x0, r33
	jne	r33, 0x3, L500
	add	[0x12,off0], 0x1, [0x12,off0]
	add	[0x0A7], 0x1, [0x0A7]
	orx	3, 8, 0x0, [0x09,off0], [0x09,off0]
	or	[0x13,off0], 0x0, r11
	add	r11, [0x12,off0], r11
	jge	r11, r35, L500
	mov	0x25, r14
	calls	L917
	jmp	L503
L500:
	calls	L1027
	srx	5, 7, SPR_AQM_Agg_Stats, 0x0, r33
	je	[0x13,off0], 0x0, L501
	jge	r33, [0x14,off0], L502
L501:
	or	r33, 0x0, [0x14,off0]
L502:
	orx	0, 3, 0x1, [0x0B,off0], [0x0B,off0]
	jmp	L448
L503:
	calls	L1027
L504:
	jext	EOI(0x2A), L505
L505:
	jext	COND_PSM(6), L447
	jmp	L5
L506:
	add.	[0x3C2], SPR_IFS_if_tx_duration, [0x3C2]
	addc	[0x3C3], 0x0, [0x3C3]
	jnzx	0, 0, [0x06C], 0x0, L5
	or	r3, 0x0, r5
	jnext	COND_PSM(7), L507
	jzx	0, 6, [0x02,off0], 0x0, L507
	sr	r3, 0x1, r5
L507:
	calls	L1027
	je	r14, 0xC5, L415
	jne	r14, 0x38, L508
	or	[0x0F,off0], 0x0, SPR_BASE5
	or	[0x00,off5], 0x100, [0x00,off5]
	orx	1, 4, 0x0, [0x0A,off0], [0x0A,off0]
	add	[0x03,off5], 0x1, [0x03,off5]
	mov	0x0, [0x02,off5]
	jmp	L5
L508:
	je	r14, 0x31, L512
	jext	0x42, L509
	jzx	0, 6, [0x08,off6], 0x0, L509
	jnzx	0, 8, [0x4A0], 0x0, L509
	or	[0x6B0], 0x0, [0x4A1]
	or	[0x6B1], 0x0, [0x4A2]
	or	[0x6B2], 0x0, [0x4A3]
	orx	1, 12, r47, [0x4A0], [0x4A0]
	or	[0x4A0], 0x100, [0x4A0]
L509:
	mov	0x0, r12
	jext	0x42, L514
	jzx	0, 10, [0x01,off0], 0x0, L511
	or	[SHM_MAXBFRAMES], 0x0, r33
	jge	[0x042], r33, L511
	sub	SPR_TSF_WORD0, [0x043], r33
	jg	r33, [0x041], L511
	jzx	0, 1, [SHM_HOST_FLAGS2], 0x0, L510
	jnzx	0, 1, [0x03,off1], 0x0, L511
L510:
	orx	0, 11, 0x1, r43, r43
L511:
	jzx	0, 8, [0x01,off0], 0x0, L513
	mov	0x0, r13
	jmp	L513
L512:
	mov	0x0, r12
	add	[0x11,off0], 0x1, [0x11,off0]
	orx	3, 8, 0x0, [0x09,off0], [0x09,off0]
	jmp	L141
L513:
	orx	0, 15, 0x1, [0x09,off0], [0x09,off0]
	jmp	L1393
L514:
	add	[0x0A5], 0x1, [0x0A5]
L515:
	orx	0, 2, 0x0, SPR_BRC, SPR_BRC
	mov	0x0, [0x865]
	add	[0x05E], 0x5, [0x05E]
	mov	0x5B4, r33
	jl	[0x05E], r33, L5
	mov	0x578, [0x05E]
	jmp	L5
L516:
	js	0x300, SPR_TXE0_0x76, L517
	calls	L826
	jmp	L141
L517:
	jzx	0, 10, SPR_IFS_0x32, 0x0, L58
	jext	EOI(0x13), L58
L518:
	mov	0x25, r18
	mov	0x20, r33
	mov	0xFFFF, SPR_TME_MASK34
	or	[0x05,off1], 0x0, SPR_TME_VAL22
	or	[0x06,off1], 0x0, SPR_TME_VAL24
	or	[0x07,off1], 0x0, SPR_TME_VAL26
	mov	0x0, SPR_TME_VAL14
	or	[0x08,off2], 0x0, r34
	jges	r34, [0x04,off1], L519
	sub	[0x04,off1], r34, SPR_TME_VAL14
L519:
	jne	[0x864], 0x0, L523
	or	[0x0A,off2], 0x0, SPR_TX_PLCP_HT_Sig0
	or	[0x0B,off2], 0x0, SPR_TX_PLCP_HT_Sig1
	mov	0x0, SPR_TME_VAL14
	jmp	L525
L520:
	mov	0x14, r33
	mov	0xC4, SPR_TME_VAL22
	mov	0x0, SPR_TME_VAL24
	mov	0x0, SPR_TME_VAL26
	jmp	L523
L521:
	jext	COND_PSM(2), L666
L522:
	mov	0xE, r33
L523:
	or	[0x02,off2], 0x0, SPR_TX_PLCP_HT_Sig1
	je	[0x864], 0x1, L524
	or	[0x01,off2], 0x0, SPR_TX_PLCP_HT_Sig0
	jmp	L525
L524:
	orx	10, 5, r33, [0x01,off2], SPR_TX_PLCP_HT_Sig0
	jmp	L525
	orx	7, 8, r33, [0x00,off1], SPR_TX_PLCP_HT_Sig0
	mov	0x700, SPR_TX_PLCP_HT_Sig1
	mov	0x0, SPR_TX_PLCP_HT_Sig2
L525:
	nand	SPR_MHP_Addr2_Low, 0x1, SPR_TME_VAL16
	or	SPR_MHP_Addr2_Mid, 0x0, SPR_TME_VAL18
	or	SPR_MHP_Addr2_High, 0x0, SPR_TME_VAL20
	calls	L1018
	jext	COND_PSM(2), L692
	je	r19, 0x21, L531
	mov	0xFFFF, SPR_TME_MASK12
	je	r19, 0xB5, L526
	je	r19, 0x2D, L527
	mov	0xD4, SPR_TME_VAL12
	mov	0x35, r18
	je	r19, 0x29, L531
	jmp	L529
L526:
	mov	0xC5, r18
	mov	0x74, SPR_TME_VAL12
	jmp	L528
L527:
	mov	0x31, r18
	mov	0xC4, SPR_TME_VAL12
L528:
	jnzx	3, 0, SPR_TSF_0x02, 0x0, L745
	jnzx	0, 0, SPR_NAV_STAT, 0x0, L745
L529:
	or	[0x03,off2], 0x0, r33
	jne	r19, 0xB5, L530
	or	[0x09,off2], 0x0, r33
L530:
	sub	r33, [0x006], r33
	jgs	r33, [0x04,off1], L531
	sub	[0x04,off1], r33, SPR_TME_VAL14
	jmp	L532
L531:
	mov	0x0, SPR_TME_VAL14
	jnext	0x71, L532
	orx	0, 15, 0x1, SPR_TME_VAL14, SPR_TME_VAL14
L532:
	jext	0x2A, L822
	jzx	0, 15, SPR_TXE0_TIMEOUT, 0x0, L533
	orx	0, 2, 0x1, SPR_BRED0, SPR_BRED0
	jmp	L822
L533:
	orx	2, 0, 0x2, SPR_BRC, SPR_BRC
	mov	0x4001, r17
	je	r19, 0xB5, L785
	je	r19, 0x2D, L745
	jext	COND_RX_IFS2, L666
	jmp	L0
L534:
	jles	SPR_TME_VAL14, 0x0, L537
	sub	SPR_TME_VAL14, [0x006], SPR_TME_VAL14
	jzx	0, 4, SPR_TXE0_PHY_CTL, 0x0, L536
	sr	[0x006], 0x1, r33
	jand	SPR_TXE0_PHY_CTL, 0x2, L535
	or	[0x86D], 0x0, r33
L535:
	add	SPR_TME_VAL14, r33, SPR_TME_VAL14
L536:
	jges	SPR_TME_VAL14, 0x0, L537
	mov	0x0, SPR_TME_VAL14
L537:
	rets
L538:
	srx	0, 3, SPR_TXE0_PHY_CTL, 0x0, r33
	or	[0x3FE], 0x0, SPR_TX_PLCP_HT_Sig0
	or	[0x3FF], 0x0, SPR_TX_PLCP_HT_Sig1
	or	[0x400], 0x0, SPR_TX_PLCP_HT_Sig2
	add	[0x3DD], r33, [0x3DD]
	jzx	0, 1, SPR_TXE0_PHY_CTL, 0x0, L542
	jnzx	0, 4, SPR_TXE0_PHY_CTL, 0x0, L539
	orx	10, 5, SPR_TDC_VHT_L_Sig_Len, [0x4CB], SPR_TX_PLCP_Sig0
	srx	0, 11, SPR_TDC_VHT_L_Sig_Len, 0x0, SPR_TX_PLCP_Sig1
L539:
	jnzx	0, 0, SPR_TXE0_PHY_CTL, 0x0, L541
	xor	r33, 0x1, r33
	orx	0, 11, 0x0, SPR_TX_PLCP_HT_Sig1, SPR_TX_PLCP_HT_Sig1
	jnext	COND_PSM(1), L540
	orx	0, 11, 0x1, SPR_TX_PLCP_HT_Sig1, SPR_TX_PLCP_HT_Sig1
L540:
	orx	0, 8, r33, SPR_TX_PLCP_HT_Sig1, SPR_TX_PLCP_HT_Sig1
	jmp	L542
L541:
	or	SPR_TDC_VHT_Sig_B0, 0x0, SPR_TX_PLCP_VHT_SigB0
	or	SPR_TDC_VHT_Sig_B1, 0x0, SPR_TX_PLCP_VHT_SigB1
	orx	0, 0, r33, SPR_TX_PLCP_HT_Sig2, SPR_TX_PLCP_HT_Sig2
L542:
	rets
L543:
	mov	0x7, SPR_TXE0_FIFO_PRI_RDY
	srx	6, 8, r34, 0x0, SPR_TXE0_FIFO_Head
	srx	7, 0, r34, 0x0, SPR_TXE0_FIFO_Read_Pointer
	orx	8, 7, 0x10B, SPR_TXE0_FIFO_Head, SPR_TXE0_FIFO_Head
	rets
L544:
	jzx	0, 3, SPR_BRPO0, 0x0, L551
	orx	1, 12, 0x0, r45, r45
	jzx	0, 6, SPR_BTCX_Transmit_Control, 0x0, L545
	orx	0, 13, 0x1, r45, r45
L545:
	add.	[0x3C0], SPR_IFS_0x0e, [0x3C0]
	addc	[0x3C1], 0x0, [0x3C1]
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L546
	orx	0, 8, 0x0, r43, r43
	calls	L1072
L546:
	jnzx	3, 0, SPR_IFS_0x4a, 0x0, L547
	and	[SHM_TSSI_CCK_HI], 0xFF, SPR_IFS_CTL_SEL_PRICRS
	or	[SHM_TSSI_CCK_HI], 0x0, SPR_IFS_CTL_SEL_PRICRS
	orx	0, 4, 0x1, SPR_IFS_CTL, SPR_IFS_CTL
	jmp	L54
L547:
	jzx	0, 0, spr397, 0x0, L548
	jzx	0, 0, [0x3C9], 0x0, L548
	mov	0xC000, SPR_TSF_GPT2_STAT
L548:
	mov	0x0, SPR_IFS_med_busy_ctl
	mov	0x8, [0xC24]
	srx	7, 0, SPR_IFS_0x4a, 0x0, [0xCAB]
	orx	0, 3, 0x0, SPR_BRPO0, SPR_BRPO0
	orx	0, 0, 0x0, r46, r46
	mov	0x1F0, r33
	calls	L66
	srx	4, 0, SPR_Ext_IHR_Data, 0x0, r33
	jne	r33, 0xE, L549
	orx	0, 0, 0x1, r46, r46
L549:
	jzx	0, 7, r43, 0x0, L550
	orx	0, 15, 0x1, SPR_TSF_GPT2_STAT, SPR_TSF_GPT2_STAT
L550:
	jmp	L0
L551:
	calls	L1465
	orx	0, 13, 0x0, r45, r45
	jzx	0, 0, spr397, 0x0, L552
	jzx	0, 1, [0x3C9], 0x0, L552
	mov	0xC000, SPR_TSF_GPT2_STAT
L552:
	jzx	0, 7, SPR_RXE_0x1a, 0x0, L555
	je	[0xCAB], 0x0, L555
	or	[0xCAA], 0x0, r33
	mov	0x3EE, SPR_BASE4
	jnand	[0xCAB], r33, L554
	mov	0xC, r33
	jzx	0, 9, [SHM_CHAN], 0x0, L553
	mov	0x3, r33
L553:
	mov	0x3F2, SPR_BASE4
	jnand	r33, [0xCAB], L554
	mov	0x3F0, SPR_BASE4
L554:
	add.	[0x00,off4], SPR_IFS_med_busy_ctl, [0x00,off4]
	addc	[0x01,off4], 0x0, [0x01,off4]
L555:
	mov	0x8, [0xC24]
	jzx	0, 7, spr2b0, 0x0, L557
	srx	2, 0, spr2b0, 0x0, r34
	jle	r34, 0x3, L557
	mov	0x2, [0xC24]
	jext	COND_PSM(5), L557
	jext	COND_RX_RAMATCH, L557
	je	r42, 0x1, L556
	mov	0x4, [0xC24]
	jmp	L557
L556:
	mov	0x1, [0xC24]
L557:
	calls	L1069
	jnzx	0, 11, SPR_IFS_STAT, 0x0, L558
	orx	0, 3, 0x1, SPR_BRPO0, SPR_BRPO0
	jzx	0, 2, r63, 0x0, L558
	orx	0, 2, 0x0, r63, r63
	je	[0xB39], 0x0, L558
	add	SPR_TSF_WORD0, [0xB38], [0xB39]
L558:
	or	[SHM_TSSI_CCK_HI], 0x0, SPR_IFS_CTL_SEL_PRICRS
	jzx	0, 7, r43, 0x0, L559
	mov	0x4000, SPR_TSF_GPT2_STAT
L559:
	jnzx	0, 7, SPR_RXE_0x1a, 0x0, L5
	add	[0x087], 0x1, [0x087]
	orx	0, 4, 0x1, SPR_IFS_CTL, SPR_IFS_CTL
	jzx	0, 0, spr397, 0x0, L560
	jzx	0, 5, [0x3C9], 0x0, L560
	mov	0xC000, SPR_TSF_GPT2_STAT
L560:
	jzx	0, 0, r46, 0x0, L5
	add	[0x0AC], 0x1, [0x0AC]
	jmp	L5
L561:
	mov	0, DUMP_CSI
	jnzx	0, 2, SPR_RXE_FIFOCTL1, 0x0, L0
	mov	0x145, r33
	calls	L66
	sra	SPR_Ext_IHR_Data, 0x8, r62
	orx	3, 8, 0x1, [0x86A], [0x86A]
	mov	0x146, r33
	calls	L66
	sra	SPR_Ext_IHR_Data, 0x8, r34
	jls	r34, r62, L562
	or	r34, 0x0, r62
	orx	3, 8, 0x4, [0x86A], [0x86A]
L562:
	sl	SPR_Ext_IHR_Data, 0x8, r34
	sra	r34, 0x8, r34
	jls	r34, r62, L563
	or	r34, 0x0, r62
	orx	3, 8, 0x2, [0x86A], [0x86A]
L563:
	mov	0x1F1, r33
	calls	L66
	jzx	0, 12, SPR_Ext_IHR_Data, 0x0, L564
	calls	L1428
	add	[0x0AD], 0x1, [0x0AD]
	jmp	L821
L564:
	add	[0x088], 0x1, [0x088]
	jext	COND_NEED_RESPONSEFR, L821
	orx	1, 8, 0x3, SPR_TXE0_0x76, SPR_TXE0_0x76
	jzx	0, 0, SPR_TXE0_CTL, 0x0, L565
	orx	0, 0, 0x0, r45, r45
L565:
	mov	0x0, SPR_TXE0_CTL
	mov	0x7D9, SPR_BASE1
	mov	0xFFFF, [0xC7F]
	jzx	14, 0, [0x7A4], 0x0, L566
	jne	SPR_Received_Frame_Count, 0x0, L566
	orx	0, 0, 0x1, SPR_PSO_Control, SPR_PSO_Control
L566:
	jext	COND_4_C7, L567
	orx	2, 0, 0x0, SPR_BRC, SPR_BRC
L567:
	or	SPR_TSF_WORD0, 0x0, r30
	or	SPR_TSF_WORD1, 0x0, r29
	or	SPR_TSF_WORD2, 0x0, r28
	or	SPR_TSF_WORD3, 0x0, r27
	srx	2, 10, SPR_RXE_ENCODING, 0x0, r23
	or	r23, 0x0, [RX_HDR_PhyRxStatus_0]
	mov	0x143, r33
	calls	L66
	srx	3, 12, SPR_Ext_IHR_Data, 0x0, r33
	mov	0x2, r47
	je	r33, 0xF, L568
	mov	0x1, r47
	je	r33, 0x3, L568
	je	r33, 0xC, L568
	mov	0x0, r47
L568:
	mov	0x164, r33
	calls	L66
	orx	0, 7, 0x1, SPR_Ext_IHR_Data, r34
	jne	r47, 0x2, L569
	orx	0, 7, 0x0, r34, r34
L569:
	calls	L68
	or	r33, 0x0, [0xCAB]
	jnand	r33, [0xCAA], L570
	add	[0x3E3], 0x1, [0x3E3]
	calls	L1428
L570:
	mov	0x158, r33
	calls	L66
	jzx	0, 11, SPR_Ext_IHR_Data, 0x0, L572
	mov	0xB2, r34
	jne	r23, 0x3, L571
	jzx	0, 13, SPR_Ext_IHR_Data, 0x0, L571
	jzx	1, 4, SPR_Ext_IHR_Data, 0x0, L571
	mov	0xA5, r34
	jzx	0, 5, SPR_Ext_IHR_Data, 0x0, L571
	mov	0x8F, r34
L571:
	mov	0x2B2, r33
	calls	L68
L572:
	jzx	0, 13, [SHM_HOST_FLAGS1], 0x0, L573
	mov	0x256, r33
	mov	0xE0, r34
	calls	L68
	or	SPR_TSF_WORD0, 0x0, [0xC2B]
L573:
	or	[SHM_CHAN], 0x0, [RX_HDR_RxChan]
	or	SPR_TSF_0x3e, 0x0, [RX_HDR_RxTSFTime]
	orx	1, 5, [0x856], 0x0, [RX_HDR_RxStatus2]
	mov	0x0, [RX_HDR_RxStatus1]
	mov	0x0, r22
	orx	4, 6, 0x0, spr29f, spr29f
	jnzx	0, 12, SPR_RXE_0x1a, 0x0, L574
	add	[0x0AE], 0x1, [0x0AE]
	jmp	L804
L574:
	mov	0x0, SPR_WEP_CTL
	mov	0x6, SPR_RXE_0x54
	orx	6, 6, 0x1, 0x0, SPR_RXE_FIFOCTL1
	mov	0x244, SPR_BRWK0
	mov	0x7000, SPR_BRWK1
	mov	0x0, SPR_BRWK2
	mov	0x0, SPR_BRWK3
L575:
	jext	COND_RX_COMPLETE, L801
	calls	L1325
	calls	L1120
	napv	0xC00
	jnext	EOI(COND_RX_IFS2), L575
	jl	SPR_RXE_FRAMELEN, 0x6, L821
	or	[0x00A], 0x0, SPR_RXE_Copy_Length
	sl	[0x4CD], 0x3, SPR_IFS_0x06
	je	r23, 0x3, L581
	je	r23, 0x2, L580
	je	r23, 0x1, L578
	sl	[0x51D], 0x3, SPR_IFS_0x06
	mov	0xB000, r33
	jnzx	0, 0, [0x00,off1], 0x0, L576
	orx	2, 12, [0x00,off1], 0x0, r33
L576:
	mul	r33, [0x01,off1], r26
	jzx	0, 6, [0x00,off1], 0x0, L577
	add	r26, [0x01,off1], r26
	jzx	0, 15, [0x00,off1], 0x0, L577
	sub	r26, 0x1, r26
L577:
	jnzx	3, 12, r26, 0x0, L821
	jmp	L581
L578:
	srx	10, 5, [0x00,off1], 0x0, r33
	orx	0, 11, [0x01,off1], r33, r26
	jext	0x3B, L581
	jg	r26, [0x010], L579
	jnzx	0, 3, [0x00,off1], 0x0, L581
L579:
	mov	0x2, SPR_IFS_0x06
	calls	L1044
	jmp	L821
L580:
	srx	7, 8, [0x00,off1], 0x0, r33
	orx	7, 8, [0x01,off1], r33, r26
L581:
	orx	0, 2, 0x0, SPR_BRED0, SPR_BRED0
	orx	2, 2, 0x0, SPR_PSM_COND, SPR_PSM_COND
	mov	0x640, r33
	or	SPR_BRC, r33, SPR_BRC
	jzx	0, 9, SPR_RXE_ENCODING, 0x0, L587
L582:
	jzx	0, 15, SPR_RXE_0x56, 0x0, L584
	jzx	0, 14, SPR_RXE_0x1a, 0x0, L583
	add	[0x09C], 0x1, [0x09C]
	jmp	L804
L583:
	calls	L1120
	calls	L1325
	jmp	L582
L584:
	mov	0x40, SPR_RXE_Copy_Length
L585:
	jnzx	0, 15, SPR_RXE_0x56, 0x0, L800
	jext	COND_PSM(2), L586
	jnzx	0, 14, SPR_RXE_0x56, 0x0, L586
	orx	0, 2, 0x1, SPR_PSM_COND, SPR_PSM_COND
L586:
	srx	13, 0, SPR_RXE_0x56, 0x0, r26
L587:
	jl	r26, 0xE, L800
	mov	0x3FF0, r33
	jg	r26, r33, L800
	or	r26, 0x0, SPR_WEP_WKey
	and	[RX_HDR_RxStatus1], 0x2, [RX_HDR_RxStatus1]
	orx	2, 0, 0x6, [RX_HDR_RxStatus2], [RX_HDR_RxStatus2]
	orx	0, 0, 0x0, r20, r20
	orx	0, 8, 0x0, r44, r44
	srx	13, 0, SPR_RXE_0x56, 0x0, SPR_RXE_0x54
	or	r22, 0x106, r33
	sl	r33, 0x5, SPR_RXE_FIFOCTL1
	or	SPR_RXE_FIFOCTL1, 0x0, 0x0
	mov	0x0, SPR_DAGG_CTL2
L588:
	jnzx	0, 0, SPR_MHP_Status, 0x0, L589
	jnext	COND_RX_IFS2, L588
L589:
spin:
	jext	COND_RX_IFS2, skip+
	calls	L1120
	calls	L1325
	jl	SPR_RXE_FRAMELEN, (6 + 24), spin-
	jne	[SHM_CSI_COLLECT], 1, skip+
	je	r23, 0x0, skip+
	je	[APPLY_PKT_FILTER], 0, nopktfilt+
	and	[3,off1], 0x00ff, SPARE1
	jne	SPARE1, [PKT_FILTER_BYTE], skip+
nopktfilt:
	je	[N_CMP_SRC_MAC], 0, nomacfilter+
	mov	[CMP_SRC_MAC_0_0], SPARE2
	jne	[5,off1], SPARE2, skip+
nomacfilter:
	or	[5,off1], 0x0, [SRC_MAC_CACHE_0]
	or	[6,off1], 0x0, [SRC_MAC_CACHE_1]
	or	[7,off1], 0x0, [SRC_MAC_CACHE_2]
	or	[14,off1], 0x0, [SEQ_NUM_CACHE]
	mov	1, DUMP_CSI
skip:
	srx	5, 1, SPR_MHP_Status, 0x0, SPR_WEP_IV_Key
	add	SPR_WEP_IV_Key, 0x6, SPR_WEP_IV_Key
	srx	0, 1, SPR_WEP_IV_Key, 0x0, r1
	jl	SPR_RXE_FRAMELEN, 0x10, L665
	jext	COND_PSM(4), L595
	or	SPR_MHP_Addr2_Low, 0x0, SPR_PMQ_pat_0
	or	SPR_MHP_Addr2_Mid, 0x0, SPR_PMQ_pat_1
	or	SPR_MHP_Addr2_High, 0x0, SPR_PMQ_pat_2
	mov	0x4, SPR_PMQ_control_low
	srx	5, 2, SPR_MHP_FC, 0x0, r19
	srx	1, 2, SPR_MHP_FC, 0x0, r42
	jne	r19, 0x1D, L590
	srx	5, 2, SPR_MHP_CFG, 0x0, r19
	je	r19, 0x35, L590
	orx	5, 2, r19, 0x1, r19
L590:
	jzx	0, 0, SPR_AMT_Status, 0x0, L590
	orx	0, 5, 0x0, SPR_PSM_COND, SPR_PSM_COND
	jnext	0x61, L591
	srx	5, 0, SPR_AMT_Match1, 0x0, r33
	add	0x334, r33, SPR_BASE4
	jnzx	0, 2, [0x00,off4], 0x0, L591
	orx	0, 5, 0x1, SPR_PSM_COND, SPR_PSM_COND
L591:
	or	SPR_PSM_COND, 0x0, 0x0
	mov	0xFFFF, [0x40B]
	mov	0xFFFF, [0x7A2]
	jnext	COND_PSM(5), L592
	srx	5, 0, SPR_AMT_Match1, 0x0, r33
	jmp	L594
L592:
	jnext	0x62, L593
	srx	5, 8, SPR_AMT_Match1, 0x0, r33
	jmp	L594
L593:
	jnext	0x63, L595
	srx	5, 0, SPR_AMT_Match2, 0x0, r33
L594:
	add	0x334, r33, SPR_BASE4
	srx	1, 8, [0x00,off4], 0x0, [0x40B]
	mov	0x747, [0x7A2]
	mul	[0x40B], 0xC, r34
	add	[0x7A2], SPR_PSM_0x5a, [0x7A2]
L595:
	jzx	0, 7, SPR_MHP_QOS, 0x0, L597
	jnzx	0, 8, SPR_MAC_CTLHI, 0x0, L596
	jnext	COND_PSM(5), L597
L596:
	orx	2, 0, 0x3, [RX_HDR_RxStatus2], [RX_HDR_RxStatus2]
	add	SPR_WEP_IV_Key, 0xC, SPR_DAGG_SH_OFFSET
	add	r26, 0xE, r60
	xor	r1, 0x1, r1
L597:
	orx	0, 0, r1, r22, r22
	orx	0, 2, r1, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	jext	COND_PSM(4), L625
	jext	COND_PSM(5), L605
	jzx	0, 0, [0xBA5], 0x0, L598
	jnzx	0, 1, [0xBA4], 0x0, L598
	jnext	0x35, L598
	jnzx	0, 1, [0xBA5], 0x0, L598
	jne	r19, 0x10, L598
	jnzx	0, 4, [0xBA4], 0x0, L598
	mov	0x1, r36
	calls	L1370
L598:
	orx	0, 8, 0x0, SPR_PSM_COND, SPR_PSM_COND
	mov	0xFFFF, r25
	jne	r42, 0x1, L599
	and	r19, 0xFFFB, r33
	jne	r33, 0x39, L604
	jmp	L600
L599:
	jnzx	0, 8, [0x03,off1], 0x0, L604
	jzx	0, 9, [0x03,off1], 0x0, L601
L600:
	jnext	0x62, L604
	srx	5, 8, SPR_AMT_Match1, 0x0, r34
	jmp	L602
L601:
	jnext	0x63, L604
	srx	5, 0, SPR_AMT_Match2, 0x0, r34
L602:
	je	[0x40B], 0x0, L603
	jzx	0, 0, [0x05,off1], 0x0, L604
	or	r34, 0x0, r25
L603:
	orx	0, 8, 0x1, SPR_PSM_COND, SPR_PSM_COND
L604:
	jzx	0, 0, SPR_MHP_Addr1_Low, 0x0, L625
	jnext	0x62, L625
L605:
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L620
	jzx	0, 0, r45, 0x0, L606
	je	r19, 0x35, L606
	orx	0, 0, 0x0, r45, r45
L606:
	orx	0, 1, 0x0, [0xB6E], [0xB6E]
	jzx	0, 0, [0x05,off1], 0x0, L608
	jne	r19, 0x20, L607
	or	[0xB1B], 0x0, r34
	jge	r34, [0xB0E], L613
L607:
	jzx	0, 5, [0xB31], 0x0, L618
L608:
	jnzx	0, 6, [0xB31], 0x0, L609
	je	r23, 0x0, L612
L609:
	srx	7, 0, [0x00,off1], 0x0, r35
	jnzx	0, 7, [0xB31], 0x0, L610
	jne	r23, 0x1, L610
	srx	1, 0, r35, 0x0, r35
	jls	r35, 0x3, L618
	jmp	L612
L610:
	jge	r23, 0x2, L611
	jmp	L618
L611:
	jnzx	0, 8, [0xB31], 0x0, L618
	jne	r35, 0x0, L618
L612:
	or	[0xB4B], 0x0, r33
	je	[0xB0C], 0x0, L618
	or	[0xB4A], 0x0, r34
	jge	[0xB0C], r34, L618
	je	r42, 0x2, L613
	je	r19, 0x34, L613
	jmp	L617
L613:
	or	[0xB4C], 0x0, r34
	or	[0xB0C], 0x0, r33
	jnzx	0, 7, [0xB6F], 0x0, L614
	je	[0xB44], 0x0, L615
	jl	r33, [0xB44], L615
L614:
	or	[0xB42], 0x0, r34
L615:
	jl	r34, [0xB4B], L616
	or	[0xB78], 0x0, [0xB77]
L616:
	orx	0, 10, 0x1, r45, r45
L617:
	jne	r19, 0x14, L618
	calls	L1309
	jzx	0, 9, r63, 0x0, L618
	add	[0xB57], 0x1, [0xB57]
L618:
	jne	r23, 0x0, L619
	jne	r42, 0x2, L619
	orx	0, 1, 0x1, [0xB6E], [0xB6E]
L619:
	je	[0xB39], 0x0, L620
	orx	0, 2, 0x1, r63, r63
L620:
	jzx	0, 0, [0xBA5], 0x0, L625
	jnzx	0, 1, [0xBA4], 0x0, L625
	jnzx	0, 0, [0x05,off1], 0x0, L625
	jnzx	0, 1, [0xBA5], 0x0, L625
	je	r42, 0x2, L621
	je	r19, 0x14, L624
	je	r19, 0x10, L624
	jmp	L625
L621:
	je	[0xB94], 0x0, L625
	srx	7, 0, [0x00,off1], 0x0, r0
	or	r23, 0x0, r36
	jne	r23, 0x0, L623
	srx	3, 3, r0, 0x0, r35
	jnzx	0, 3, r35, 0x0, L622
	jls	[0xB94], r35, L625
	jmp	L624
L622:
	jls	[0xB94], 0xB, L625
	jmp	L624
L623:
	srx	1, 0, r0, 0x0, r35
	jls	r35, 0x3, L625
	srx	1, 2, r0, 0x0, r35
	mul	r35, 0x3, r35
	or	SPR_PSM_0x5a, 0x0, r35
	jls	[0xB94], r35, L625
L624:
	jnzx	0, 4, [0xBA4], 0x0, L625
	mov	0x1, r36
	calls	L1370
L625:
	jzx	0, 14, SPR_MHP_FC, 0x0, L642
	add	SPR_DAGG_SH_OFFSET, 0x4, SPR_DAGG_SH_OFFSET
	sub	r60, 0x4, r60
	jnzx	0, 4, SPR_WEP_CTL, 0x0, L640
	mov	0xFFFF, r37
	jl	SPR_RXE_FRAMELEN, 0x16, L665
	je	r19, 0x2C, L626
	jne	r42, 0x2, L642
L626:
	jnext	0x63, L627
	srx	5, 0, SPR_AMT_Match2, 0x0, r33
	add	0x334, r33, SPR_BASE4
	jzx	0, 0, [0x00,off4], 0x0, L627
	jext	COND_PSM(5), L629
	jnzx	0, 0, [0x05,off1], 0x0, L629
	jmp	L642
L627:
	jext	COND_PSM(5), L628
	jzx	0, 0, [0x05,off1], 0x0, L642
	jzx	0, 11, [SHM_HOST_FLAGS4], 0x0, L631
L628:
	jnext	0x62, L630
	srx	5, 8, SPR_AMT_Match1, 0x0, r33
	je	r33, 0x3E, L630
L629:
	or	r33, 0x0, r37
	add	r37, 0x4, r37
L630:
	jne	r37, 0xFFFF, L631
	jnzx	0, 0, [0x05,off1], 0x0, L642
	jzx	0, 14, [SHM_HOST_FLAGS1], 0x0, L642
L631:
	mov	0x7D9, r34
	sr	SPR_WEP_IV_Key, 0x1, SPR_BASE4
	add	SPR_BASE4, r34, SPR_BASE4
	add	SPR_WEP_IV_Key, 0x8, [0xC83]
L632:
	jext	COND_RX_IFS2, L633
	calls	L1120
	calls	L1325
	jl	SPR_RXE_FRAMELEN, [0xC83], L632
L633:
	jl	SPR_RXE_FRAMELEN, [0xC83], L665
	mov	0x2F0, r33
	jne	r37, 0xFFFF, L634
	srx	1, 14, [0x01,off4], 0x0, r37
	jnext	0x34, L634
	jzx	0, 0, [0x05,off1], 0x0, L634
	jnext	COND_PSM(8), L642
	je	r25, 0xFFFF, L634
	add	r25, 0x4, r25
	add	r25, r33, SPR_BASE5
	srx	5, 4, [0x00,off5], 0x0, r25
	srx	0, 1, r37, 0x0, r37
	add	r25, r37, r25
	add	r25, 0x1, r25
	srx	2, 10, [0x00,off5], 0x0, r38
	jmp	L637
L634:
	add	r37, r33, SPR_BASE5
	jzx	0, 11, [SHM_HOST_FLAGS4], 0x0, L636
	srx	4, 4, [0x00,off5], 0x0, r25
	jzx	0, 0, [0x05,off1], 0x0, L636
	srx	2, 13, [0x00,off5], 0x0, r38
	srx	1, 14, [0x01,off4], 0x0, r36
	srx	1, 9, [0x00,off5], 0x0, r33
	jne	r36, r33, L635
	add	r25, 0x10, r25
	jmp	L638
L635:
	srx	1, 11, [0x00,off5], 0x0, r33
	jne	r36, r33, L642
	add	r25, 0x20, r25
	jmp	L638
L636:
	srx	5, 4, [0x00,off5], 0x0, r25
	srx	2, 0, [0x00,off5], 0x0, r38
L637:
	jne	r38, 0x7, L638
	orx	0, 3, [0x00,off4], 0x0, r33
	xor	r33, [0x00,off5], r33
	jnzx	0, 3, r33, 0x0, L642
L638:
	sl	r25, 0x3, r0
	add	[SHM_KTP], r0, SPR_BASE5
	orx	0, 6, 0x1, r38, SPR_WEP_CTL
	jne	r38, 0x2, L639
	sub	r60, 0x8, r60
	mov	0x87A, r1
	sl	r25, 0x3, r33
	sub	r33, r25, SPR_BASE2
	mov	0x170, r33
	add	SPR_BASE2, r33, SPR_BASE2
	or	[0x05,off2], 0x0, r33
	or	[0x06,off2], 0x0, r34
	jne	r33, [0x02,off4], L642
	jne	r34, [0x03,off4], L642
	calls	L1029
	mov	0x878, SPR_BASE5
	jzx	0, 15, [0x061], 0x0, L639
	jge	r0, 0x60, L639
	jnzx	0, 10, [0x03,off1], 0x0, L639
	jnzx	3, 0, [0x0E,off1], 0x0, L639
	orx	0, 13, 0x1, SPR_WEP_CTL, SPR_WEP_CTL
	orx	0, 3, 0x1, [RX_HDR_RxStatus2], [RX_HDR_RxStatus2]
	add	r0, [0x059], r35
	add	r35, 0x4, r35
L639:
	calls	L1031
	orx	4, 4, 0x15, SPR_WEP_CTL, SPR_WEP_CTL
	jl	r38, 0x5, L641
L640:
	add	SPR_DAGG_SH_OFFSET, 0x4, SPR_DAGG_SH_OFFSET
	sub	r60, 0x4, r60
	jne	r38, 0x7, L641
	add	SPR_DAGG_SH_OFFSET, 0xA, SPR_DAGG_SH_OFFSET
	sub	r60, 0x8, r60
L641:
	orx	0, 3, 0x1, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	orx	5, 5, r25, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	jmp	L644
L642:
	orx	4, 4, 0x15, 0x0, SPR_WEP_CTL
	jne	r19, 0x38, L644
	sr	SPR_WEP_IV_Key, 0x1, r33
	add	SPR_BASE1, r33, SPR_BASE4
	mov	0x607, r33
	add	SPR_WEP_IV_Key, 0x5, SPR_Bfm_Rpt_Offset
	je	[0x00,off4], 0x15, L643
	jne	[0x00,off4], r33, L644
	add	SPR_WEP_IV_Key, 0x8, SPR_Bfm_Rpt_Offset
L643:
	mov	0x441, r33
	mov	0x0, r34
	calls	L68
	mov	0x1, SPR_TX_BF_Control
	mov	0x43C, r33
	mov	0xC, r34
	calls	L68
	mov	0x2, r34
	calls	L68
	or	[0x0F,off0], 0x0, SPR_BASE5
	or	[0x00,off5], 0x0, r33
	orx	4, 5, r33, [0x06,off5], r34
	mov	0x441, r33
	calls	L68
	mov	0x440, r33
	or	[0x01,off4], 0x0, r34
	calls	L68
	sub	r26, SPR_Bfm_Rpt_Offset, SPR_Bfm_Rpt_Length
	add	SPR_Bfm_Rpt_Length, 0x2, SPR_Bfm_Rpt_Length
	mov	0x2, SPR_TX_BF_Control
L644:
	jzx	0, 0, [RX_HDR_RxStatus2], 0x0, L645
	sub	r60, SPR_DAGG_SH_OFFSET, SPR_DAGG_BYTESLEFT
	jles	SPR_DAGG_BYTESLEFT, 0xE, L645
	mov	0x7, SPR_DAGG_CTL2
L645:
	jext	COND_PSM(4), L652
	nand	r22, 0x218, r22
	jnzx	0, 7, [SHM_HOST_FLAGS1], 0x0, L647
	jzx	0, 11, [SHM_HOST_FLAGS3], 0x0, L646
	jnzx	0, 10, [0x03,off1], 0x0, L647
	jnzx	3, 0, [0x0E,off1], 0x0, L647
	jne	r42, 0x2, L647
	jzx	0, 14, [0x03,off1], 0x0, L646
	jzx	2, 0, SPR_WEP_CTL, 0x0, L647
L646:
	jmp	L648
L647:
	orx	1, 3, 0x1, r22, r22
	jmp	L652
L648:
	jzx	0, 1, [0x7A4], 0x0, L649
	jnzx	0, 0, [0x05,off1], 0x0, L650
	jext	COND_PSM(5), L651
	jmp	L652
L649:
	jzx	0, 0, [0x7A4], 0x0, L651
	jne	r19, 0x20, L651
L650:
	orx	0, 9, 0x1, r22, r22
	jmp	L652
L651:
	orx	0, 0, 0x0, SPR_PSO_Control, SPR_PSO_Control
L652:
	orx	10, 5, r22, 0x2, SPR_RXE_FIFOCTL1
	jext	COND_PSM(4), L666
	orx	0, 7, 0x1, r22, r22
	je	r19, 0x35, L656
	srx	7, 0, [0x00,off1], 0x0, r0
	or	r23, 0x0, r1
	jne	r23, 0x3, L653
	srx	3, 12, [0x01,off1], 0x0, r0
L653:
	jzx	0, 3, r45, 0x0, L655
	je	r1, 0x0, L654
	mov	0xB, r0
	mov	0x1, r1
	jmp	L655
L654:
	mov	0xA, r0
L655:
	calls	L72
	jne	r42, 0x2, L656
	and	r19, 0x23, r33
	je	r33, 0x2, L778
	je	r33, 0x22, L778
	jmp	L881
L656:
	jext	COND_RX_COMPLETE, L801
	jnzx	0, 15, SPR_RXE_0x1a, 0x0, L802
	calls	L1120
	calls	L1325
	napv	0xC00
	jnext	COND_RX_IFS2, L656
	jnand	[0xC47], 0x77, L657
	jext	COND_PSM(2), L748
L657:
	calls	L1120
	calls	L1325
	jzx	0, 14, SPR_RXE_0x1a, 0x0, L657
	jext	COND_RX_COMPLETE, L801
	jnzx	0, 15, SPR_RXE_0x1a, 0x0, L802
	jg	SPR_RXE_FRAMELEN, [0x010], L666
	jnext	COND_PHY1, L666
	jne	r42, 0x0, L661
	jnext	COND_PSM(5), L658
	add	[0x08A], 0x1, [0x08A]
	jmp	L660
L658:
	jnzx	0, 0, [0x05,off1], 0x0, L659
	add	[0x090], 0x1, [0x090]
	jmp	L660
L659:
	add	[0x095], 0x1, [0x095]
L660:
	je	r19, 0x20, L854
	je	r19, 0x14, L854
	je	r19, 0x10, L751
	je	r19, 0x24, L403
	je	r19, 0x28, L877
	je	r19, 0x30, L877
	je	r19, 0x34, L879
	je	r19, 0x38, L408
	jmp	L881
L661:
	jne	r42, 0x1, L747
	jnext	COND_PSM(5), L662
	add	[0x08B], 0x1, [0x08B]
	jmp	L664
L662:
	jnzx	0, 0, [0x05,off1], 0x0, L663
	add	[0x091], 0x1, [0x091]
	jmp	L664
L663:
	add	[0x096], 0x1, [0x096]
L664:
	je	r19, 0x35, L731
	je	r19, 0x21, L889
	je	r19, 0x25, L889
	je	r19, 0x2D, L780
	je	r19, 0x31, L731
	je	r19, 0x29, L876
	and	r19, 0xFFFB, r33
	je	r33, 0x39, L886
	je	r19, 0x15, L392
	je	r19, 0xB5, L784
	je	r19, 0xC5, L731
	jmp	L745
L665:
	add	[0x083], 0x1, [0x083]
	jnzx	1, 7, SPR_MAC_CTLHI, 0x0, L822
	jnzx	0, 9, SPR_RXE_ENCODING, 0x0, L748
	orx	0, 10, 0x1, SPR_BRC, SPR_BRC
	jmp	L748
L666:
	jext	COND_4_C6, L668
	jext	EOI(COND_RX_IFS2), L667
L667:
	jmp	L821
L668:
	jnzx	0, 12, SPR_DAGG_STAT, 0x0, L670
	calls	L1120
	calls	L1325
	jext	COND_RX_COMPLETE, L801
	jnzx	0, 5, SPR_RXE_ENCODING, 0x0, L669
	napv	0xC00
	jnext	COND_RX_ATIMWINEND, L668
	jl	SPR_DAGG_LEN, [0x010], L722
L669:
	mov	0x0, SPR_DAGG_CTL2
L670:
	jnzx	0, 5, SPR_RXE_ENCODING, 0x0, L671
	jext	EOI(COND_RX_IFS2), L671
	calls	L1120
	calls	L1325
	napv	0xC00
	jmp	L670
L671:
	jext	COND_RX_COMPLETE, L801
	jzx	0, 15, SPR_RXE_0x56, 0x0, L675
	jzx	0, 14, SPR_RXE_0x1a, 0x0, L671
	jne	r23, 0x0, L672
	mov	0x143, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x0, [RX_HDR_PhyRxStatus_0]
	mov	0x144, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x0, [RX_HDR_PhyRxStatus_1]
	mov	0x145, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x0, [RX_HDR_PhyRxStatus_2]
	mov	0x146, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x0, [RX_HDR_PhyRxStatus_3]
	mov	0x147, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x0, [RX_HDR_PhyRxStatus_4]
	mov	0x148, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x0, [RX_HDR_PhyRxStatus_5]
	jmp	L673
L672:
	orx	1, 0, r23, SPR_RXE_PHYRXSTAT0, [RX_HDR_PhyRxStatus_0]
	or	SPR_RXE_PHYRXSTAT0, 0x0, [RX_HDR_PhyRxStatus_0]
	mov	0x7, SPR_RCM_TA_Address_1
	or	SPR_RXE_PHYRXSTAT1, 0x0, [RX_HDR_PhyRxStatus_1]
	or	SPR_RXE_PHYRXSTAT2, 0x0, [RX_HDR_PhyRxStatus_2]
	or	SPR_RXE_PHYRXSTAT3, 0x0, [RX_HDR_PhyRxStatus_3]
	or	SPR_RXE_0x44, 0x0, [RX_HDR_PhyRxStatus_4]
	mov	0x7, SPR_RCM_TA_Address_1
	mov	0x0, 0x0
L673:
	jzx	0, 1, [0xCA2], 0x0, L674
	srx	0, 2, [0xCA3], 0x0, r33
	orx	0, 0, r33, [RX_HDR_PhyRxStatus_1], [RX_HDR_PhyRxStatus_1]
L674:
	srx	0, 12, r45, 0x0, r33
	orx	0, 8, 0x1, [RX_HDR_RxStatus2], [RX_HDR_RxStatus2]
	orx	0, 13, r33, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	rr	[0x86A], 0x8, [0x86A]
L675:
	orx	0, 3, 0x0, SPR_PSM_COND, SPR_PSM_COND
	jnzx	0, 15, SPR_RXE_0x56, 0x0, L676
	orx	1, 2, 0x3, SPR_PSM_COND, SPR_PSM_COND
L676:
	jext	COND_RX_COMPLETE, L801
	jzx	0, 1, [0x06C], 0x0, L682
	jnzx	0, 4, [SHM_HOST_FLAGS3], 0x0, L677
	orx	0, 0, 0x1, r20, r20
L677:
	jnext	COND_PHY1, L682
	jext	COND_PSM(5), L678
	add	[0x081], 0x1, [0x081]
	jmp	L679
L678:
	add	[0x080], 0x1, [0x080]
L679:
	jnzx	0, 9, [0x06C], 0x0, L680
	orx	0, 9, 0x1, [0x06C], [0x06C]
	mov	0x0, [0x06E]
	mov	0x0, [0x06F]
	jmp	L681
L680:
	sub	[0x0E,off1], 0x10, r33
	sub	r33, [0xCB2], r33
	sr	r33, 0x4, r33
	add.	[0x06E], r33, [0x06E]
	addc	[0x06F], 0x0, [0x06F]
L681:
	or	[0x0E,off1], 0x0, [0xCB2]
	jzx	0, 10, [0x06C], 0x0, L800
L682:
	jl	SPR_RXE_FRAMELEN, 0x14, L683
	jext	COND_PHY1, L686
L683:
	add	[0x085], 0x1, [0x085]
	jzx	0, 0, spr397, 0x0, L684
	jzx	0, 3, [0x3C9], 0x0, L684
	mov	0xC000, SPR_TSF_GPT2_STAT
L684:
	jext	COND_PSM(4), L685
	orx	0, 10, 0x1, SPR_BRC, SPR_BRC
	orx	0, 1, 0x0, SPR_BRC, SPR_BRC
	orx	0, 10, 0x0, r45, r45
	calls	L1374
L685:
	jext	COND_RX_COMPLETE, L801
	orx	0, 0, 0x1, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	orx	0, 0, 0x1, r20, r20
	jmp	L720
L686:
	jext	COND_RX_COMPLETE, L801
	jext	COND_PSM(4), L711
	orx	0, 4, 0x0, r63, r63
	jzx	0, 0, [0xBA5], 0x0, L689
	jnzx	0, 1, [0xBA4], 0x0, L689
	jnzx	0, 0, [0x05,off1], 0x0, L687
	jnzx	0, 5, [0xBA5], 0x0, L688
	jzx	0, 14, [0xBA5], 0x0, L689
	je	r19, 0x14, L688
	je	r19, 0x10, L688
L687:
	je	r19, 0x20, L688
	jmp	L689
L688:
	calls	L1374
L689:
	jzx	0, 0, spr397, 0x0, L690
	jzx	0, 2, [0x3C9], 0x0, L690
	mov	0xC000, SPR_TSF_GPT2_STAT
L690:
	jext	COND_PSM(5), L691
	jnext	COND_NEED_RESPONSEFR, L698
L691:
	orx	0, 10, 0x0, SPR_BRC, SPR_BRC
	jnext	COND_PSM(2), L693
	mov	0x3, SPR_TXBA_Control
	mov	0x4, SPR_TXBA_Data_Select
	sr	[0x0E,off1], 0x4, r33
	sub	r33, 0x3F, SPR_TXBA_Data
	orx	3, 12, SPR_MHP_QOS, 0x5, SPR_TME_VAL28
	srx	0, 12, [0x03,off1], 0x0, r33
	xor	r33, 0x1, r33
	orx	0, 5, r33, r43, r43
	jnzx	1, 5, SPR_MHP_QOS, 0x0, L698
	jmp	L518
L692:
	orx	2, 0, 0x2, SPR_BRC, SPR_BRC
	mov	0x4001, SPR_TXE0_CTL
	and	[SHM_TSSI_CCK_HI], 0xFF, SPR_IFS_CTL_SEL_PRICRS
	orx	0, 1, 0x1, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	jmp	L711
L693:
	jnext	COND_NEED_RESPONSEFR, L698
	jzx	1, 5, SPR_MHP_QOS, 0x0, L694
	orx	0, 1, 0x0, SPR_BRC, SPR_BRC
	jmp	L698
L694:
	jne	r23, 0x0, L695
	jzx	3, 4, SPR_TX_PLCP_HT_Sig0, 0x0, L695
	srx	0, 7, SPR_RXE_PHYRXSTAT0, 0x0, r33
	orx	0, 4, r33, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
L695:
	jzx	0, 0, [0xC47], 0x0, L697
	jne	r19, 0x34, L697
	je	[0x0F,off1], 0x10B, L696
	mov	0x2104, r33
	je	[0x0F,off1], r33, L696
	jmp	L697
L696:
	orx	0, 14, 0x1, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	calls	L1477
	orx	3, 0, 0x2, [0xC47], [0xC47]
	srx	7, 6, [0xC4A], 0x0, r33
	orx	7, 6, r33, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	jne	r23, 0x3, L697
	jzx	0, 8, [0xC47], 0x0, L697
	or	[0xC4A], 0x0, SPR_TXE0_PHY_CTL
	or	[0xC4B], 0x0, SPR_TXE0_PHY_CTL1
	or	[0xC4C], 0x0, SPR_TXE0_PHY_CTL2
	or	[0xC4D], 0x0, SPR_TX_PLCP_Sig0
	mov	0x0, SPR_TX_PLCP_Sig1
	or	[0xC4E], 0x0, SPR_TX_PLCP_HT_Sig0
	or	[0xC4F], 0x0, SPR_TX_PLCP_HT_Sig1
	or	[0xC50], 0x0, SPR_TX_PLCP_HT_Sig2
	or	[0xC51], 0x0, SPR_TX_PLCP_VHT_SigB0
	or	[0xC52], 0x0, SPR_TX_PLCP_VHT_SigB1
	orx	3, 0, 0x4, [0xC47], [0xC47]
L697:
	or	r17, 0x0, SPR_TXE0_CTL
	and	[SHM_TSSI_CCK_HI], 0xFF, SPR_IFS_CTL_SEL_PRICRS
L698:
	srx	0, 1, SPR_BRC, 0x0, r33
	orx	0, 1, r33, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	jext	COND_PSM(5), L707
	orx	14, 0, [0x04,off1], 0x0, SPR_NAV_ALLOCATION
	orx	2, 11, 0x2, SPR_NAV_CTL, SPR_NAV_CTL
	je	r42, 0x1, L720
	jzx	0, 0, [0x05,off1], 0x0, L702
	jne	r42, 0x2, L699
	add	[0x094], 0x1, [0x094]
L699:
	jnzx	0, 7, SPR_MHP_Status, 0x0, L720
	jnzx	0, 8, [0x03,off1], 0x0, L730
	jnzx	0, 9, [0x03,off1], 0x0, L700
	jext	COND_PSM(8), L701
	jmp	L704
L700:
	jnext	COND_PSM(8), L704
	je	r19, 0x20, L701
	srx	0, 13, [0x03,off1], 0x0, r33
	or	[0x7A2], 0x0, SPR_BASE5
	orx	0, 3, r33, [0x02,off5], [0x02,off5]
	orx	0, 15, r33, SPR_TSF_GPT1_STAT, SPR_TSF_GPT1_STAT
	je	[0x027], 0xFFFF, L701
	or	SPR_TSF_WORD0, 0x0, [0xCB5]
	jzx	0, 0, r33, 0x0, L701
	add	SPR_TSF_WORD0, [0x027], [0xCB5]
L701:
	je	r19, 0x10, L720
	jmp	L715
L702:
	jnext	0x34, L703
	jnext	0x62, L703
	jne	r42, 0x2, L703
	or	[0x7A2], 0x0, SPR_BASE5
	orx	0, 3, 0x0, [0x02,off5], [0x02,off5]
L703:
	jne	r42, 0x2, L705
	add	[0x08F], 0x1, [0x08F]
	jmp	L706
L704:
	je	r42, 0x2, L706
	jnzx	0, 0, [0x0B,off1], 0x0, L720
L705:
	jzx	0, 4, SPR_MAC_CTLHI, 0x0, L706
	je	r19, 0x20, L720
	je	r19, 0x14, L720
L706:
	jzx	0, 8, SPR_MAC_CTLHI, 0x0, L730
	jmp	L720
L707:
	je	r19, 0x2D, L715
	je	r19, 0x29, L715
	je	r42, 0x1, L720
	jne	r42, 0x2, L709
	jge	[0x40B], 0x1, L709
	mov	0x0, [0xB1B]
	orx	0, 1, 0x0, r63, r63
	jnzx	0, 12, r63, 0x0, L708
	je	[0xB39], 0x0, L709
	add	SPR_TSF_WORD0, [0xB38], [0xB39]
L708:
	je	[0xB40], 0xFFFE, L709
	add	[0xB40], 0x1, [0xB40]
L709:
	jnext	COND_4_C7, L711
	srx	5, 2, [0x6AE], 0x0, r35
	jne	r35, 0x29, L711
	orx	0, 15, 0x0, SPR_TXE0_TIMEOUT, SPR_TXE0_TIMEOUT
	orx	0, 9, 0x0, SPR_BRC, SPR_BRC
	or	r33, 0x0, r33
	jle	0x0, 0x1, L710
L710:
	jext	EOI(0x2A), L711
L711:
	jzx	0, 7, SPR_MHP_Status, 0x0, L712
	add	[0x098], 0x1, [0x098]
	jmp	L720
L712:
	jne	r42, 0x2, L714
	jzx	0, 2, [SHM_HOST_FLAGS2], 0x0, L713
	jnext	0x62, L706
L713:
	add	[0x089], 0x1, [0x089]
L714:
	je	r19, 0x0, L720
	je	r19, 0x8, L720
	je	r19, 0x2C, L720
	je	r19, 0x38, L720
L715:
	or	[0x7A2], 0x0, SPR_BASE4
	jnand	[0x02,off4], 0x100, L716
	jnand	[0x02,off4], 0xA0, L720
L716:
	srx	6, 9, SPR_PMQ_control_high, 0x0, r35
	jg	r35, 0x3E, L728
	srx	0, 12, [0x03,off1], 0x0, r34
	jnext	COND_PSM(2), L717
	srx	0, 5, r43, 0x0, r33
	jboh	r33, r34, L720
	orx	0, 5, r34, r43, r43
L717:
	jnzx	0, 2, SPR_PMQ_control_low, 0x0, L717
	srx	1, 0, SPR_PMQ_dat_or, 0x0, r33
	je	r33, 0x0, L718
	je	r33, 0x3, L718
	sr	r33, 0x1, r33
	je	r33, r34, L719
L718:
	or	SPR_MHP_Addr2_Low, 0x0, SPR_PMQ_pat_0
	or	SPR_MHP_Addr2_Mid, 0x0, SPR_PMQ_pat_1
	or	SPR_MHP_Addr2_High, 0x0, SPR_PMQ_pat_2
	add	r34, 0x1, SPR_PMQ_dat
	or	[0x016], 0x0, SPR_PMQ_control_low
	or	SPR_PMQ_control_low, 0x0, 0x0
L719:
	jzx	0, 1, [0x016], 0x0, L720
	mov	0x40, SPR_MAC_IRQLO
L720:
	jnzx	0, 7, SPR_MAC_CTLHI, 0x0, L721
	jnzx	0, 0, r20, 0x0, L822
L721:
	jext	COND_RX_COMPLETE, L801
	calls	L1120
	calls	L1325
	jext	0x04, L721
	orx	0, 2, 0x1, [RX_HDR_RxStatus2], [RX_HDR_RxStatus2]
	srx	0, 5, r20, 0x0, r33
	orx	0, 15, r33, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	srx	0, 15, SPR_WEP_CTL, 0x0, r33
	orx	0, 4, r33, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	jzx	0, 3, [RX_HDR_RxStatus2], 0x0, L722
	srx	0, 14, SPR_WEP_CTL, 0x0, r33
	orx	0, 4, r33, [RX_HDR_RxStatus2], [RX_HDR_RxStatus2]
L722:
	orx	6, 9, spr293, [RX_HDR_RxStatus2], [RX_HDR_RxStatus2]
	or	SPR_RXE_FRAMELEN, 0x0, r33
	jzx	0, 0, [RX_HDR_RxStatus2], 0x0, L723
	jg	SPR_DAGG_LEN, [0x010], L730
	srx	11, 0, SPR_DAGG_STAT, 0x0, r33
L723:
	jzx	0, 2, [RX_HDR_RxStatus1], 0x0, L724
	add	r33, 0x2, r33
L724:
	or	r33, 0x0, [RX_HDR_RxFrameSize]
	jg	r33, [0x010], L729
	mov	RX_HDR_BASE, SPR_RXE_RXHDR_OFFSET
	mov	0, [RX_HDR_NexmonExt]
	calls	L900
	jnzx	0, 12, SPR_DAGG_STAT, 0x0, L725
	orx	5, 0, 0x22, SPR_RXE_FIFOCTL1, SPR_RXE_FIFOCTL1
	orx	0, 2, 0x1, [RX_HDR_RxStatus1], [RX_HDR_RxStatus1]
	orx	0, 1, 0x0, [RX_HDR_RxStatus2], [RX_HDR_RxStatus2]
	jmp	L666
L725:
	orx	1, 0, 0x0, SPR_RXE_FIFOCTL1, SPR_RXE_FIFOCTL1
	jnext	COND_PSM(2), L726
	jnext	COND_PHY1, L726
	orx	0, 4, 0x1, SPR_PSM_COND, SPR_PSM_COND
	orx	3, 0, 0x5, [0x0E,off1], SPR_TXBA_Control
L726:
	jnext	COND_PSM(3), L727
	orx	4, 4, 0x1D, SPR_WEP_CTL, SPR_WEP_CTL
	jmp	L585
L727:
	je	DUMP_CSI, 0, csi_end+
#define		ACPHY_TBL_ID_CORE0CHANESTTBL	73
#define		ACPHY_TBL_ID_CORE1CHANESTTBL	105
#define		TONES_PER_CHUNK	14
#define		CHUNKS_80MHZ	19
#define		CHUNKS_40MHZ	10
#define		CHUNKS_20MHZ	5
#define		TONES_LAST_CHUNK_80MHZ	4
#define		TONES_LAST_CHUNK_40MHZ	2
#define		TONES_LAST_CHUNK_20MHZ	8
	mov	[RX_HDR_RxChan], [RXCHAN]
	mov	0, DUMP_CSI
	calls	enable_carrier_search
	mov	1, [CLEANDEAF]
	mov	0x3800, SPARE2
	and	[RXCHAN], SPARE2, SPARE2
	sr	SPARE2, 11, SPARE2
	mov	CHUNKS_80MHZ, [CHUNKS]
	mov	TONES_LAST_CHUNK_80MHZ, [TONES_LAST_CHUNK]
	je	SPARE2, 0x4, chunk_set+
	mov	CHUNKS_40MHZ, [CHUNKS]
	mov	TONES_LAST_CHUNK_40MHZ, [TONES_LAST_CHUNK]
	je	SPARE2, 0x3, chunk_set+
	mov	CHUNKS_20MHZ, [CHUNKS]
	mov	TONES_LAST_CHUNK_20MHZ, [TONES_LAST_CHUNK]
chunk_set:
	mov	0, SPARE4	// core 0..3
loop_core:
	mov	ACPHY_TBL_ID_CORE0CHANESTTBL, SPARE5
	je	SPARE4, 0, core_set+
	mov	ACPHY_TBL_ID_CORE1CHANESTTBL, SPARE5
core_set:
	mov	0, SPARE6	// txstream 0..3
loop_txstream:
	mov	SPARE6, SPARE1
	sl	SPARE1, 3, SPARE1
	or	SPARE4, SPARE1, SPARE1
	sl	SPARE1, 8, [CSICONFIGCACHE]
	sl	1, SPARE6, SPARE2
	and	SPARE2, [NSSMASK], SPARE2
	je	SPARE2, 0, skip_this_core_txstream
	sl	1, SPARE4, SPARE2
	and	SPARE2, [COREMASK], SPARE2
	je	SPARE2, 0, skip_this_core_txstream
	sl	SPARE6, 8, SPARE2
	mov	[CHUNKS], SPARE3
fill_next_rxhdr:
	mov	(RX_HDR_BASE + RXE_RXHDR_LEN), SPR_BASE5
	mov	2, [0,off5]
	mov	0, [1,off5]
	or	SPARE3, [CSICONFIGCACHE], [2,off5]
	jne	SPARE3, [CHUNKS], not_first_chunk+
	mov	0x4000, SPARE1
	or	SPARE1, [2,off5], [2,off5]
not_first_chunk:
	mov	TONES_PER_CHUNK, SPARE1	// number of tones for this chunk
	jne	SPARE3, 1, not_last_chunk+
	mov	[TONES_LAST_CHUNK], SPARE1
not_last_chunk:
	mov	SPARE1, [3,off5]
	add	SPR_BASE5, 4, SPR_BASE5
	phy_reg_write(0x00d, SPARE5)
	phy_reg_write(0x00e, SPARE2)
read_csi:
	phy_reg_read_to_shm_off(0x00f, 0, off5)
	phy_reg_read_to_shm_off(0x010, 1, off5)
	add	SPR_BASE5, 2, SPR_BASE5
	add	SPARE2, 1, SPARE2
	sub	SPARE1, 1, SPARE1
	jne	SPARE1, 0, read_csi-
	jne	SPARE3, 1, not_last_chunk_skip_mac+
	mov	[SRC_MAC_CACHE_0], [0,off5]
	mov	[SRC_MAC_CACHE_1], [1,off5]
	mov	[SRC_MAC_CACHE_2], [2,off5]
	mov	[SEQ_NUM_CACHE], [3,off5]
not_last_chunk_skip_mac:
	mov	RX_HDR_BASE + RXE_RXHDR_LEN, SPR_RXE_RXHDR_OFFSET
	calls	L900
	sub	SPARE3, 1, SPARE3
	jne	SPARE3, 0, fill_next_rxhdr-
skip_this_core_txstream:
	add	SPARE6, 1, SPARE6
	jne	SPARE6, 4, loop_txstream    // max 4 nss
	add	SPARE4, 1, SPARE4
	jne	SPARE4, NCORES, loop_core   // max NCORES
	calls	disable_carrier_search
csi_end:
	mov	0, [CLEANDEAF]
	mov	0x0, SPR_WEP_CTL
	orx	0, 6, 0x0, SPR_BRC, SPR_BRC
	nand	SPR_RXE_FIFOCTL1, 0x2, SPR_RXE_FIFOCTL1
	jmp	L469
L728:
	add	[0x0A1], 0x1, [0x0A1]
	jmp	L730
L729:
	add	[0x082], 0x1, [0x082]
L730:
	jext	COND_PSM(4), L822
	orx	1, 9, 0x3, SPR_BRC, SPR_BRC
	jmp	L822
L731:
	jnext	COND_PSM(5), L744
	je	r19, 0xC5, L732
	jne	r19, 0x35, L733
	add	[0x08E], 0x1, [0x08E]
	jand	[0xC47], 0x60, L734
	calls	L1477
	calls	L1481
	jmp	L734
L732:
	add	[0x3E2], 0x1, [0x3E2]
	jmp	L734
L733:
	add	[0x08D], 0x1, [0x08D]
L734:
	jnext	COND_4_C7, L745
	jne	r19, r14, L745
	orx	0, 15, 0x0, SPR_TXE0_TIMEOUT, SPR_TXE0_TIMEOUT
	orx	0, 9, 0x0, SPR_BRC, SPR_BRC
	or	r33, 0x0, r33
	jle	0x0, 0x1, L735
L735:
	jext	EOI(0x2A), L736
L736:
	je	r19, 0x31, L743
	mov	0x0, [0xB04]
	jnext	COND_PSM(1), L737
	jzx	0, 4, r44, 0x0, L738
	orx	3, 4, 0x6, [0x09,off0], [0x09,off0]
L737:
	orx	0, 4, 0x0, r44, r44
L738:
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L742
	calls	L1374
	jzx	0, 6, SPR_BTCX_Stat, 0x0, L739
	orx	0, 11, 0x1, SPR_BTCX_Stat, SPR_BTCX_Stat
L739:
	jnzx	0, 0, r45, 0x0, L740
	jnzx	0, 13, r63, 0x0, L740
	jmp	L742
L740:
	orx	0, 15, 0x0, SPR_TXE0_TIMEOUT, SPR_TXE0_TIMEOUT
	orx	0, 7, 0x0, SPR_BRC, SPR_BRC
	orx	0, 13, 0x0, r63, r63
	jzx	0, 0, r45, 0x0, L741
	calls	L1286
L741:
	jmp	L745
L742:
	jnzx	1, 2, SPR_TXE0_FIFO_PRI_RDY, 0x0, L745
	jzx	0, 10, [0x6AE], 0x0, L745
L743:
	orx	0, 4, 0x1, SPR_BRC, SPR_BRC
	jmp	L745
L744:
	calls	L749
	jne	r19, 0x31, L745
	add	[0x093], 0x1, [0x093]
	jmp	L745
L745:
	jext	COND_PSM(5), L746
	jzx	0, 8, SPR_MAC_CTLHI, 0x0, L748
L746:
	jnzx	0, 6, SPR_MAC_CTLHI, 0x0, L666
	jmp	L748
L747:
	jnzx	0, 8, SPR_MAC_CTLHI, 0x0, L666
L748:
	orx	0, 0, 0x1, r20, r20
	jmp	L666
L749:
	jnzx	0, 14, [SHM_HOST_FLAGS2], 0x0, L750
	jne	[0x04,off1], 0x0, L750
	mov	0x0, SPR_NAV_0x06
	mov	0x0, SPR_NAV_0x04
L750:
	rets
L751:
	jext	0x35, L752
	jext	0x34, L881
	jzx	0, 5, r20, 0x0, L881
L752:
	jext	COND_PSM(5), L753
	jzx	0, 0, [0x05,off1], 0x0, L747
L753:
	jnzx	0, 0, [0x0B,off1], 0x0, L754
	jnext	0x63, L881
L754:
	jzx	3, 0, [0x788], 0x0, L762
	mov	0x7E8, SPR_BASE4
	mov	0xDD, r36
L755:
	calls	L84
	or	r35, 0x0, r38
	jne	r36, 0xDD, L761
	jzx	0, 15, SPR_BASE4, 0x0, L756
	srx	7, 0, [0x01,off4], 0x0, r33
	srx	7, 8, [0x01,off4], 0x0, r34
	orx	7, 8, [0x02,off4], r34, r34
	srx	7, 8, [0x02,off4], 0x0, r35
	orx	7, 8, [0x03,off4], r35, r35
	jmp	L757
L756:
	srx	7, 8, [0x00,off4], 0x0, r33
	or	[0x01,off4], 0x0, r34
	or	[0x02,off4], 0x0, r35
L757:
	jl	r33, 0x4, L760
	mov	0x6F50, r37
	jne	r34, r37, L758
	mov	0x99A, r37
	je	r35, r37, L759
L758:
	mov	0x1700, r37
	jne	r34, r37, L760
	mov	0x5F2, r37
	jne	r35, r37, L760
L759:
	jmp	L776
L760:
	rr	r33, 0x1, r33
	add.	SPR_BASE4, r33, SPR_BASE4
	or	SPR_BASE4, 0x0, 0x0
	addc.	SPR_BASE4, 0x1, SPR_BASE4
	orx	14, 0, SPR_BASE4, 0x0, r34
	add	r34, 0x3, r34
	jl	r34, r38, L755
L761:
	sub	SPR_RXE_FRAMELEN, 0x4, r37
	jg	r37, SPR_RXE_Copy_Length, L776
	or	[0x787], 0x0, r33
	jne	r33, [SHM_CHAN], L881
L762:
	jzx	7, 8, [0x0F,off1], 0x0, L765
	srx	7, 8, [0x0F,off1], 0x0, r33
	jne	r33, [SHM_PRSSIDLEN], L775
	mov	0xB0, SPR_BASE5
	mov	0x7E9, SPR_BASE4
	je	r33, 0x1, L764
L763:
	or	[0x00,off4], 0x0, r34
	jne	r34, [0x00,off5], L775
	add	SPR_BASE4, 0x1, SPR_BASE4
	add	SPR_BASE5, 0x1, SPR_BASE5
	sub	r33, 0x2, r33
	jgs	r33, 0x1, L763
	je	r33, 0x0, L766
L764:
	srx	7, 0, [0x00,off4], 0x0, r33
	srx	7, 0, [0x00,off5], 0x0, r34
	jne	r33, r34, L775
	jmp	L766
L765:
	jnzx	0, 11, SPR_MAC_CTLHI, 0x0, L881
L766:
	mov	0x7E8, SPR_BASE4
	mov	0x2D, r36
	calls	L84
	jnzx	0, 0, [SHM_HOST_FLAGS2], 0x0, L775
	mov	0x5B4, r38
	add	[0x05F], 0x5, r37
	jl	r37, r38, L767
	mov	0x578, r37
L767:
	je	r37, [0x05E], L777
	or	[0x05E], 0x0, SPR_BASE4
	or	[0x09,off1], 0x0, r34
	or	[0x0A,off1], 0x0, r35
L768:
	je	SPR_BASE4, [0x05F], L770
	jne	r35, [0x02,off4], L769
	je	r34, [0x01,off4], L775
L769:
	add	SPR_BASE4, 0x5, SPR_BASE4
	jl	SPR_BASE4, r38, L768
	mov	0x578, SPR_BASE4
	jmp	L768
L770:
	add	[0x0A2], 0x1, [0x0A2]
	or	[0x05F], 0x0, SPR_BASE4
	or	[0x08,off1], 0x0, [0x00,off4]
	or	[0x09,off1], 0x0, [0x01,off4]
	or	[0x0A,off1], 0x0, [0x02,off4]
	jzx	3, 0, [0x788], 0x0, L771
	mov	0xB01, r33
	jmp	L772
L771:
	mov	0xB01, r33
	je	r23, 0x2, L772
	orx	7, 8, [0x00,off1], r23, r33
L772:
	orx	5, 2, r0, r33, [0x03,off4]
	sr	SPR_TSF_WORD0, 0x8, [0x04,off4]
	jzx	0, 5, [SHM_HOST_FLAGS5], 0x0, L773
	jne	r36, 0x2D, L774
L773:
	orx	0, 8, 0x1, [0x04,off4], [0x04,off4]
L774:
	or	r37, 0x0, [0x05F]
L775:
	jzx	0, 15, [SHM_HOST_FLAGS5], 0x0, L776
	orx	0, 0, 0x1, r20, r20
L776:
	jext	COND_PSM(5), L521
	jmp	L666
L777:
	add	[0x0A3], 0x1, [0x0A3]
	jmp	L747
L778:
	jext	COND_RX_IFS2, L779
	jl	SPR_RXE_FRAMELEN, 0x1C, L778
L779:
	jl	SPR_RXE_FRAMELEN, 0x1C, L747
	jnext	COND_PSM(5), L883
	jmp	L521
L780:
	jnext	COND_PSM(5), L782
	add	[0x08C], 0x1, [0x08C]
	calls	L1016
	jls	[0xC7F], r41, L781
	je	r41, 0x0, L781
	sub	SPR_TSF_WORD0, [0xC2D], r33
	jle	r33, [0xC7B], L781
	sub	[0xC7F], 0x1, [0xC7F]
	jzx	0, 2, SPR_RCM_TA_Address_2, 0x0, L745
L781:
	jmp	L522
L782:
	add	[0x092], 0x1, [0x092]
L783:
	srx	0, 7, SPR_RXE_PHYRXSTAT0, 0x0, r1
	orx	0, 4, r1, [0x864], r1
	calls	L1025
	or	r33, 0x0, SPR_NAV_0x12
	orx	0, 13, 0x1, SPR_NAV_CTL, SPR_NAV_CTL
	jmp	L745
L784:
	jnext	COND_PSM(5), L783
	add	[0x3E1], 0x1, [0x3E1]
	jmp	L520
L785:
	jnzx	0, 8, SPR_MHP_HTC_High, 0x0, L393
	jmp	L745
L786:
	jext	0x45, L53
	jext	COND_4_C7, L789
	add	[0x07F], 0x1, [0x07F]
	mov	0x0, r0
	jmp	L791
L787:
	orx	1, 4, 0x3, SPR_WEP_CTL, SPR_WEP_CTL
	orx	0, 9, 0x1, SPR_BRC, SPR_BRC
	jand	0x7, SPR_BRC, L788
	add	[0x07E], 0x1, [0x07E]
	jmp	L792
L788:
	mov	0x1, r0
	mov	0x76, r33
	add	r33, [SHM_TXFCUR], SPR_BASE4
	mov	0x0, SPR_TXE0_0x7e
	add	[0x00,off4], 0x1, [0x00,off4]
	jext	COND_PSM(1), L791
	jnzx	3, 4, [0x09,off0], 0x0, L790
	orx	3, 4, 0x6, [0x09,off0], [0x09,off0]
	jmp	L790
L789:
	add	[0x07F], 0x1, [0x07F]
L790:
	mov	0x1, r0
L791:
	jnext	COND_4_C7, L792
	orx	0, 7, 0x0, SPR_BRC, SPR_BRC
	orx	0, 0, 0x0, r45, r45
	mov	0x0, r14
	orx	0, 15, 0x0, SPR_TXE0_TIMEOUT, SPR_TXE0_TIMEOUT
	orx	0, 4, 0x0, SPR_BRC, SPR_BRC
L792:
	orx	0, 5, 0x0, SPR_BRC, SPR_BRC
	jext	EOI(0x10), L793
L793:
	jext	EOI(0x16), L794
L794:
	mov	0x7, r33
	jnzx	1, 0, SPR_TXE0_PHY_CTL, 0x0, L795
	or	0x7, [0x055], r33
L795:
	calls	L66
	or	SPR_Ext_IHR_Data, 0x0, r37
	jne	[0xC36], 0x0, L796
	or	r37, 0x0, [0xC37]
	or	SPR_TXE0_PHY_CTL, 0x0, [0xC38]
	or	SPR_TXE0_PHY_CTL1, 0x0, [0xC39]
	or	SPR_TXE0_PHY_CTL2, 0x0, [0xC3A]
	or	SPR_TX_PLCP_Sig0, 0x0, [0xC3B]
	or	SPR_TX_PLCP_Sig1, 0x0, [0xC3C]
	or	SPR_TX_PLCP_HT_Sig0, 0x0, [0xC3D]
	or	SPR_TX_PLCP_HT_Sig1, 0x0, [0xC3E]
	or	SPR_TX_PLCP_HT_Sig2, 0x0, [0xC3F]
	or	SPR_TX_PLCP_VHT_SigB0, 0x0, [0xC40]
	or	SPR_TX_PLCP_VHT_SigB1, 0x0, [0xC41]
	orx	7, 8, r18, [0xC43], [0xC43]
	or	SPR_TSF_WORD0, 0x0, r34
	or	spr32d, 0x0, [0xC45]
	sub	r34, SPR_TSF_0x40, [0xC44]
	mov	0x1, [0xC36]
L796:
	mov	0xFFFF, r34
	calls	L68
L797:
	jnzx	0, 8, SPR_IFS_STAT, 0x0, L797
	jext	EOI(0x11), L798
L798:
	jnand	0x7, SPR_BRC, L799
	jnzx	0, 13, r63, 0x0, L799
	je	r0, 0x0, L0
	or	r37, 0x0, [0x0C,off0]
	jmp	L250
L799:
	nand	SPR_BRC, 0x7, SPR_BRC
	orx	1, 13, 0x0, r63, r63
	jmp	L0
L800:
	add	[SHM_BCMCFIFOID], 0x1, [SHM_BCMCFIFOID]
	jmp	L804
L801:
	mov	0x100, SPR_MAC_IRQLO
L802:
	mov	0x9F, SPR_BASE4
	jnzx	0, 15, SPR_RXE_0x1a, 0x0, L803
	jnzx	0, 4, SPR_RXE_ENCODING, 0x0, L803
	mov	0x9D, SPR_BASE4
	jzx	1, 8, SPR_RXE_FIFOCTL1, 0x0, L803
	mov	0x9E, SPR_BASE4
L803:
	add	[0x00,off4], 0x1, [0x00,off4]
L804:
	calls	L1423
	jext	EOI(COND_RX_COMPLETE), L805
L805:
	jext	COND_PSM(4), L822
	orx	0, 10, 0x1, SPR_BRC, SPR_BRC
	jmp	L822
L806:
	jnzx	0, 8, SPR_IFS_STAT, 0x0, L52
	jnext	COND_NEED_RESPONSEFR, L808
	jne	[SHM_UCODESTAT], 0x8, L808
	jne	[0xCA8], 0x0, L807
	mov	0x4E20, r33
	add	SPR_TSF_WORD0, r33, [0xCA8]
L807:
	jdn	SPR_TSF_WORD0, [0xCA8], L809
	jnand	0x40, SPR_BRC, L52
	calls	L826
L808:
	mov	0x0, [0xCA8]
L809:
	jnand	0xE2, SPR_BRC, L52
	jext	0x17, L52
	jext	COND_TX_UNDERFLOW, L52
	jext	0x12, L52
	calls	L826
L810:
	add.	[0x3C0], SPR_IFS_0x0e, [0x3C0]
	addc	[0x3C1], 0x0, [0x3C1]
	mov	0x0, SPR_IFS_0x0e
	je	[0x05C], 0x0, L811
	mov	0x444, SPR_TME_VAL18
	calls	L134
	or	[0x05C], 0x0, SPR_TME_VAL14
	mov	0x0, [0x006]
	mov	0x0, [0x05C]
	orx	2, 0, 0x2, SPR_BRC, SPR_BRC
	mov	0x4001, SPR_TXE0_CTL
	mov	0x8, [SHM_UCODESTAT]
	jmp	L0
L811:
	mov	0x3, [SHM_UCODESTAT]
	mov	0x1, SPR_MAC_IRQLO
	orx	0, 15, 0x0, SPR_TSF_GPT0_STAT, SPR_TSF_GPT0_STAT
	calls	L1241
L812:
	jext	0x33, L831
	jnzx	7, 0, [0x03F], 0x0, L840
L813:
	je	[0x3D0], 0x0, L814
	calls	L1434
L814:
	jnext	0x38, L812
	mov	0x2, [SHM_UCODESTAT]
	mov	0x0, [0xC24]
	mov	0x0, SPR_IFS_med_busy_ctl
	mov	0x6000, SPR_TSF_GPT0_CNTLO
	or	[SHM_DEFAULTIV], 0x0, SPR_TSF_GPT0_CNTHI
	mov	0x578, [0x05E]
	mov	0x578, [0x05F]
	srx	0, 15, SPR_MAC_CTLHI, 0x0, r33
	orx	0, 0, r33, r43, r43
L815:
	calls	L817
	calls	L1227
	calls	L1322
	srx	2, 11, [SHM_CHAN], 0x0, r41
	sub	r41, 0x2, r41
	mov	0x0, [0x874]
	srx	2, 8, [SHM_CHAN], 0x0, r33
	sl	0x1, r33, [0xCAA]
	jne	r41, 0x0, L816
	mov	0x3, [0xCAA]
L816:
	calls	L1423
	jmp	L5
L817:
	mov	0x1000, r59
	and	SPR_BRC, r59, SPR_BRC
	mov	0xFFFF, SPR_BRCL0
	mov	0xFFFF, SPR_BRCL1
	mov	0xE7FF, SPR_BRCL2
	mov	0xFFFF, SPR_BRCL3
	calls	L1423
	orx	0, 15, 0x1, SPR_TSF_GPT0_STAT, SPR_TSF_GPT0_STAT
	mov	0x0, SPR_BRCL0
	mov	0x0, SPR_BRCL1
	mov	0x0, SPR_BRCL2
	mov	0x0, SPR_BRCL3
	mov	0x301, [0x017]
	srx	0, 13, SPR_MAC_CTLHI, 0x0, r33
	orx	0, 4, r33, [0x017], [0x017]
	srx	0, 14, SPR_MAC_CTLHI, 0x0, r33
	xor	r33, 0x1, r33
	orx	0, 1, r33, 0x0, [0x016]
	rets
L818:
	add	[0x086], 0x1, [0x086]
	jzx	0, 0, spr397, 0x0, L819
	jzx	0, 4, [0x3C9], 0x0, L819
	mov	0xC000, SPR_TSF_GPT2_STAT
L819:
	jzx	0, 0, r46, 0x0, L820
	add	[0x0AF], 0x1, [0x0AF]
L820:
	jext	COND_RX_COMPLETE, L801
L821:
	calls	L1423
	mov	0x2, SPR_IFS_0x06
	orx	0, 4, 0x1, SPR_IFS_CTL, SPR_IFS_CTL
	jmp	L5
L822:
	mov	0x1, SPR_DAGG_CTL2
	jext	COND_PSM(3), L823
	srx	13, 0, 0x0, 0x0, SPR_RXE_0x54
L823:
	mov	0x14, SPR_RXE_FIFOCTL1
	or	SPR_RXE_FIFOCTL1, 0x0, 0x0
	mov	0x110, SPR_RXE_FIFOCTL1
	or	SPR_RXE_FIFOCTL1, 0x0, 0x0
	mov	0x0, SPR_TX_BF_Control
	orx	0, 7, 0x1, r22, r22
L824:
	calls	L1120
	calls	L1325
	jext	0x04, L824
	or	SPR_WEP_CTL, 0x70, SPR_WEP_CTL
	mov	0x0, SPR_WEP_CTL
	jge	SPR_RXE_FRAMELEN, 0x14, L825
	orx	0, 4, 0x1, SPR_IFS_CTL, SPR_IFS_CTL
L825:
	jext	COND_PSM(3), L585
	orx	0, 6, 0x0, SPR_BRC, SPR_BRC
	jnext	0x4A, L469
	orx	0, 9, 0x1, r43, r43
	calls	L826
	orx	0, 0, 0x1, SPR_TXE0_AUX, SPR_TXE0_AUX
	or	r33, 0x0, r33
	orx	0, 0, 0x0, SPR_TXE0_AUX, SPR_TXE0_AUX
	jmp	L469
L826:
	mov	0x4000, SPR_TXE0_CTL
	or	SPR_TXE0_CTL, 0x0, 0x0
	orx	1, 8, 0x3, SPR_TXE0_0x76, SPR_TXE0_0x76
	jle	0x0, 0x1, L827
L827:
	jnext	EOI(0x10), L828
	nap2
	jmp	L266
L828:
	orx	0, 0, 0x0, r45, r45
	nand	SPR_BRC, 0x137, SPR_BRC
	jzx	0, 10, r43, 0x0, L830
L829:
	jext	EOI(0x16), L830
	jnext	EOI(0x11), L829
L830:
	orx	1, 9, 0x0, r43, r43
	rets
L831:
	jext	0x45, L52
	jnzx	7, 8, SPR_TXE0_0x66, 0x0, L832
	mov	0x1, r36
	mov	0x3F, r35
	sl	0x1, [SHM_TXFCUR], r34
	jmp	L833
L832:
	sl	0x1, 0x8, r36
	mov	0x3F00, r35
	or	[SHM_TXFCUR], 0x0, r34
	add	r34, 0x8, r34
	sl	0x1, r34, r34
L833:
	mov	0x5B4, SPR_BASE4
	mov	0x0, SPR_TXE0_FIFO_PRI_RDY
L834:
	jnand	SPR_TXE0_0x66, r36, L836
L835:
	add	SPR_BASE4, 0x20, SPR_BASE4
	add	SPR_TXE0_FIFO_PRI_RDY, 0x1, SPR_TXE0_FIFO_PRI_RDY
	sl	r36, 0x1, r36
	jand	r36, r35, L839
	jmp	L834
L836:
	jge	r36, 0x100, L838
	calls	L843
L837:
	jnand	SPR_TXE0_FIFO_DEF1, r36, L837
	jmp	L838
L838:
	or	r36, 0x0, SPR_TXE0_0x66
	orx	0, 4, 0x0, r63, r63
	mov	0x1, SPR_MAC_IRQHI
	jmp	L835
L839:
	or	[SHM_TXFCUR], 0x0, SPR_TXE0_FIFO_PRI_RDY
	jne	[SHM_UCODESTAT], 0x3, L52
	jmp	L813
L840:
	jnzx	7, 8, SPR_TXE0_0x66, 0x0, L813
	mov	0x5B4, SPR_BASE4
	mov	0x0, SPR_TXE0_FIFO_PRI_RDY
	mov	0x1, r36
	mov	0x3F, r35
L841:
	jand	r36, [0x03F], L842
	calls	L843
	nand	[0x03F], r36, [0x03F]
L842:
	sl	r36, 0x1, r36
	jand	r36, r35, L813
	add	SPR_BASE4, 0x20, SPR_BASE4
	add	SPR_TXE0_FIFO_PRI_RDY, 0x1, SPR_TXE0_FIFO_PRI_RDY
	jmp	L841
L843:
	orx	0, 0, 0x0, [0x0A,off4], [0x0A,off4]
	mov	0x0, [0x0A,off4]
	mov	0x0, [0x0B,off4]
	mov	0x0, [0x10,off4]
	mov	0x0, [0x11,off4]
	mov	0x0, [0x12,off4]
	mov	0x0, [0x15,off4]
	mov	0x0, [0x16,off4]
	mov	0x0, [0x17,off4]
	mov	0x0, [0x18,off4]
	mov	0x0, [0x1B,off4]
L844:
	add	SPR_TSF_WORD0, 0x20, r33
L845:
	jne	SPR_TSF_WORD0, r33, L845
	jnand	r36, SPR_TXE0_0x5e, L848
	jzx	0, 15, [0x03F], 0x0, L846
	jnzx	0, 14, SPR_TXE0_FIFO_DEF1, 0x0, L848
L846:
	jne	0x0, 0x1, L847
L847:
	jnzx	9, 0, SPR_TXE0_FIFO_Frame_Count, 0x0, L849
	jmp	L851
L848:
	jzx	9, 0, SPR_TXE0_FIFO_Frame_Count, 0x0, L844
L849:
	mov	0x3F, SPR_AQM_Max_IDX
	calls	L1391
	orx	0, 8, 0x1, SPR_TXE0_FIFO_PRI_RDY, SPR_TXE0_FIFO_PRI_RDY
	or	SPR_TXE0_FIFO_PRI_RDY, 0x0, 0x0
L850:
	jnzx	0, 8, SPR_TXE0_FIFO_PRI_RDY, 0x0, L850
	jmp	L844
L851:
	rets
L852:
	jnzx	0, 7, SPR_TXE0_STATUS, 0x0, L0
	or	r33, 0x0, r33
	jext	EOI(0x11), L410
	mov	0x20, SPR_MAC_IRQLO
	jext	0x34, L853
	or	r15, 0x0, SPR_IFS_BKOFFTIME
	mov	0x0, r15
	or	r16, 0x0, r5
	or	r3, 0x0, r16
	calls	L826
L853:
	jext	EOI(COND_TX_TBTTEXPIRE), L5
L854:
	jl	SPR_RXE_FRAMELEN, 0x2C, L748
	jext	COND_PSM(8), L855
	je	r19, 0x14, L868
	add	[0x099], 0x1, [0x099]
	jmp	L868
L855:
	je	r19, 0x14, L867
	add	[0x097], 0x1, [0x097]
	calls	L921
	orx	0, 11, 0x0, r45, r45
	orx	0, 1, 0x0, r63, r63
	mov	0x0, [0xB1B]
	or	[0x7A2], 0x0, SPR_BASE5
	jnzx	0, 8, [0x02,off5], 0x0, L856
	jext	0x34, L859
L856:
	orx	0, 0, 0x0, r63, r63
	mov	0x0, [0xB70]
	jnext	0x43, L858
	jnzx	0, 11, [SHM_HOST_FLAGS1], 0x0, L858
	add	[0x09B], 0x1, [0x09B]
	calls	L826
	orx	0, 12, 0x0, SPR_BRC, SPR_BRC
	orx	0, 0, 0x0, SPR_BRC, SPR_BRC
	orx	0, 3, 0x0, SPR_BRC, SPR_BRC
	orx	0, 1, 0x1, SPR_TXE0_AUX, SPR_TXE0_AUX
	mov	0x10, SPR_MAC_IRQLO
	jnzx	0, 0, SPR_TSF_0x0e, 0x0, L857
	or	r15, 0x0, SPR_IFS_BKOFFTIME
	mov	0x0, r15
	or	r16, 0x0, r5
	or	r3, 0x0, r16
	jmp	L858
L857:
	and	SPR_TSF_RANDOM, r3, SPR_IFS_BKOFFTIME
L858:
	jext	0x34, L875
L859:
	jnzx	0, 4, [SHM_HOST_FLAGS2], 0x0, L867
	or	[0x7A2], 0x0, SPR_BASE4
	jnzx	0, 10, [0x02,off4], 0x0, L875
	or	[0x01C], 0x0, r33
	add	r33, [0x00,off3], r33
	add.	r30, r33, r30
	addc.	r29, 0x0, r29
	addc.	r28, 0x0, r28
	addc	r27, 0x0, r27
	jext	0x34, L860
	jg	r27, [0x12,off1], L875
	jl	r27, [0x12,off1], L860
	jg	r28, [0x11,off1], L875
	jl	r28, [0x11,off1], L860
	jg	r29, [0x10,off1], L875
	jl	r29, [0x10,off1], L860
	jge	r30, [0x0F,off1], L875
L860:
	orx	0, 11, 0x0, r20, r20
	jnzx	0, 4, [SHM_HOST_FLAGS5], 0x0, L862
	or	SPR_TSF_WORD0, 0x0, [0x873]
	or	SPR_TSF_WORD1, 0x0, [0x872]
	or	SPR_TSF_WORD2, 0x0, [0x871]
	or	SPR_TSF_WORD3, 0x0, [0x870]
	jne	[0x873], SPR_TSF_WORD0, L860
	sub.	[0x873], r30, r30
	subc.	[0x872], r29, r29
	subc.	[0x871], r28, r28
	subc	[0x870], r27, r27
L861:
	add.	r30, [0x0F,off1], r33
	or	r33, 0x0, SPR_TSF_WORD0
	addc.	r29, [0x10,off1], SPR_TSF_WORD1
	addc.	r28, [0x11,off1], SPR_TSF_WORD2
	addc	r27, [0x12,off1], SPR_TSF_WORD3
	jne	r33, SPR_TSF_WORD0, L861
	jmp	L866
L862:
	sub.	[0x0F,off1], r30, r33
	subc.	[0x10,off1], r29, r34
	subc.	[0x11,off1], r28, r35
	subc	[0x12,off1], r27, r36
	sl	[0x40B], 0x2, r37
	mov	0x777, SPR_BASE5
	add	SPR_BASE5, r37, SPR_BASE5
	sub.	r33, [0x00,off5], [0x78D]
	subc.	r34, [0x01,off5], [0x78E]
	subc.	r35, [0x02,off5], [0x78F]
	subc	r36, [0x03,off5], [0x790]
	or	[0x7A2], 0x0, SPR_BASE4
	sl	[0x03,off4], 0x7, r37
	or	r37, 0x40, r37
	srx	6, 9, [0x03,off4], 0x0, r38
	sub.	r37, [0x78D], r37
	subc	r38, [0x78E], r38
	srx	15, 7, r37, r38, r37
	je	r37, [0x03,off4], L866
	sub	r37, [0x03,off4], r38
	or	r37, 0x0, [0x03,off4]
	je	[0x04,off4], 0x0, L863
	add	[0x05,off4], r38, [0x05,off4]
L863:
	je	[0x06,off4], 0x0, L864
	add	[0x07,off4], r38, [0x07,off4]
L864:
	sl	r38, 0x7, r33
	srx	6, 9, r38, 0x0, r34
	mov	0x0, r35
	mov	0x0, r36
	jges	r38, 0x0, L865
	mov	0xFFFF, r35
	mov	0xFFFF, r36
	orx	8, 7, r35, r34, r34
L865:
	sub.	[0x00,off5], r33, [0x00,off5]
	subc.	[0x01,off5], r34, [0x01,off5]
	subc.	[0x02,off5], r35, [0x02,off5]
	subc	[0x03,off5], r36, [0x03,off5]
L866:
	mov	0x0, [0xCA1]
	mov	0x0, [0xCA5]
L867:
	jnext	0x34, L875
L868:
	jnext	0x34, L875
	jext	0x35, L875
	je	r19, 0x14, L875
	jnext	COND_PSM(8), L875
	mov	0x7EE, SPR_BASE4
	mov	0x5, r36
	calls	L84
	jne	r36, 0x5, L875
	jzx	0, 15, SPR_BASE4, 0x0, L869
	srx	7, 8, [0x01,off4], 0x0, r59
	srx	7, 8, [0x02,off4], 0x0, [0xC83]
	jmp	L870
L869:
	srx	7, 0, [0x01,off4], 0x0, r59
	srx	7, 0, [0x02,off4], 0x0, [0xC83]
L870:
	or	[0x7A2], 0x0, SPR_BASE5
	or	r59, 0x0, [0x0B,off5]
	jzx	0, 13, [SHM_HOST_FLAGS4], 0x0, L871
	mov	0x0, [0xC83]
	jmp	L872
L871:
	jne	r59, 0x0, L873
L872:
	or	[0xC83], 0x0, r33
	orx	0, 3, r33, [0x02,off5], [0x02,off5]
L873:
	je	[0x013], 0xFFFF, L874
	jzx	0, 0, [0xC83], 0x0, L874
	sl	[0x013], 0x3, SPR_TSF_GPT1_CNTLO
	sr	[0x013], 0xD, SPR_TSF_GPT1_CNTHI
L874:
	orx	0, 15, [0xC83], SPR_TSF_GPT1_STAT, SPR_TSF_GPT1_STAT
	je	[0x027], 0xFFFF, L875
	or	SPR_TSF_WORD0, 0x0, [0xCB5]
	jzx	0, 0, [0xC83], 0x0, L875
	add	SPR_TSF_WORD0, [0x027], [0xCB5]
L875:
	jext	COND_PSM(5), L521
	jmp	L666
L876:
	jnext	COND_PSM(5), L747
	jmp	L521
L877:
	jext	COND_PSM(5), L878
	jnext	COND_PSM(8), L747
	jmp	L883
L878:
	or	[0x08,off1], 0x0, SPR_PMQ_pat_0
	or	[0x09,off1], 0x0, SPR_PMQ_pat_1
	or	[0x0A,off1], 0x0, SPR_PMQ_pat_2
	mov	0x4, SPR_PMQ_dat
	mov	0x40, SPR_MAC_IRQLO
	or	[0x016], 0x0, SPR_PMQ_control_low
	jmp	L521
L879:
	srx	7, 0, [0x0F,off1], 0x0, r33
	jzx	0, 8, SPR_MHP_Status, 0x0, L880
	srx	7, 0, [0x12,off1], 0x0, r33
L880:
	jne	r33, 0x4, L881
	jext	COND_PSM(5), L521
	jmp	L666
	jmp	L747
L881:
	jne	r19, 0x10, L882
	jzx	0, 15, [SHM_HOST_FLAGS5], 0x0, L882
	orx	0, 0, 0x1, r20, r20
L882:
	jext	COND_PSM(5), L521
L883:
	jzx	0, 0, [SHM_HOST_FLAGS4], 0x0, L884
	jzx	0, 8, SPR_MHP_Status, 0x0, L884
	srx	3, 0, r32, 0x0, r33
	jne	r33, 0x5, L884
	mov	0x212, SPR_IFS_slot
L884:
	jzx	0, 0, [0x05,off1], 0x0, L747
	jnext	COND_RX_RAMATCH, L885
	jnzx	0, 10, [SHM_HOST_FLAGS1], 0x0, L521
	jnext	0x62, L885
	je	SPR_MHP_Addr1_High, 0xFFFF, L885
	srx	5, 8, SPR_AMT_Match1, 0x0, r33
	add	0x334, r33, SPR_BASE4
	jnzx	0, 11, [0x00,off4], 0x0, L521
L885:
	jmp	L666
L886:
	mov	0x0, SPR_NAV_0x06
	mov	0x0, SPR_NAV_0x04
	jnext	COND_PSM(8), L887
	orx	3, 3, 0x1, SPR_TSF_0x00, SPR_TSF_0x00
	jmp	L888
L887:
	srx	3, 2, SPR_RXE_0x16, 0x0, r33
	je	r33, 0x0, L745
	orx	3, 3, r33, SPR_TSF_0x00, SPR_TSF_0x00
	jnext	0x62, L745
L888:
	and	r14, 0x4, r34
	jand	r19, r34, L745
	orx	0, 9, 0x0, SPR_BRC, SPR_BRC
	jmp	L745
L889:
	jext	COND_PSM(5), L890
	calls	L749
	jmp	L745
L890:
	jne	r19, 0x21, L891
	or	[0x0C,off1], 0x0, SPR_TME_VAL30
	or	[0x0B,off1], 0x0, SPR_TME_VAL28
	jnzx	0, 2, [0x0B,off1], 0x0, L518
	jmp	L892
L891:
	add	[0x0AA], 0x1, [0x0AA]
	jnzx	0, 2, [0x0B,off1], 0x0, L734
L892:
	jnext	COND_PSM(1), L893
	jzx	0, 4, r44, 0x0, L893
	orx	3, 4, 0x6, [0x09,off0], [0x09,off0]
	orx	0, 4, 0x0, r44, r44
L893:
	jzx	1, 0, [0x0B,off1], 0x0, L521
	jmp	L666
L894:
	mov	0x0, SPR_PSM_0x4e
	mov	0x0, SPR_PSM_0x0c
	orx	0, 1, 0x1, SPR_PHY_HDR_Parameter, SPR_PHY_HDR_Parameter
	jnzx	0, 5, SPR_MAC_CMD, 0x0, L896
	mov	0xCFF, SPR_BASE4
L895:
	mov	0x0, [0x00,off4]
	sub	SPR_BASE4, 0x1, SPR_BASE4
	jges	SPR_BASE4, 0x0, L895
L896:
	mov	0x1, [SHM_UCODESTAT]
	mov	0x0, r33
	calls	L66
	srx	7, 0, SPR_Ext_IHR_Data, 0x0, [SHM_PHYVER]
	srx	3, 8, SPR_Ext_IHR_Data, 0x0, [SHM_PHYTYPE]
	mov	0x8002, SPR_PHY_HDR_Parameter
	or	SPR_PSM_0x70, 0xA0, SPR_PSM_0x70
L897:
	jzx	0, 13, SPR_PSM_0x70, 0x0, L897
	jne	[SHM_PHYTYPE], 0x0, L898
	jmp	L899
L898:
	jne	[SHM_PHYTYPE], 0x4, L899
L899:
	mov	0x413, [SHM_UCODEREV]
	mov	0x854, [SHM_UCODEPATCH]
	mov	0x8D60, [SHM_UCODEDATE]
	mov	0x0, [SHM_UCODETIME]
	mov	0x0, [SHM_PCTLWDPOS]
	mov	0x1069, [0x005]
	mov	0x7D9, SPR_BASE1
	mov	0x5D4, SPR_BASE0
	mov	0x0, [0x86B]
	or	r3, 0x0, r5
	and	SPR_TSF_RANDOM, r3, SPR_IFS_BKOFFTIME
	jmp	L810
L900:
	jg	SPR_RCM_Control, 0x7C, L804
	jg	SPR_RCM_Match_Data, 0x7C, L804
	mov	0x0, r33
	mov	0x0, r34
	add	0xE, 0x4, r33
	sr	r33, 0x2, r33
	add	SPR_RCM_Match_Delay, r33, r34
	add	SPR_RCM_Match_Mask, r33, r33
	jg	r33, [0x0D0], L804
	jg	r34, [0x0CF], L804
	mov	RXE_RXHDR_LEN, SPR_RXE_RXHDR_LEN
	orx	0, 0, 0x1, SPR_RXE_FIFOCTL1, SPR_RXE_FIFOCTL1
	jnzx	0, 12, SPR_DAGG_STAT, 0x0, L901
	mov	0x7, SPR_DAGG_CTL2
L901:
	jext	COND_RX_COMPLETE, L801
	jnext	COND_RX_BADPLCP, L901
L902:
	jext	COND_RX_COMPLETE, L801
	jext	COND_RX_BADPLCP, L902
	or	r33, 0x0, r33
	jle	0x0, 0x1, L903
L903:
	jext	COND_RX_COMPLETE, L801
	rets
L904:
	jnext	0x42, L905
	add	[0x865], r33, [0x865]
	or	[0x865], 0x0, r11
	jmp	L916
L905:
	jnzx	0, 2, [0x0B,off0], 0x0, L906
	srx	3, 8, [0x09,off0], 0x0, r11
	add	r11, r33, r11
	add	[0x10,off0], r33, [0x10,off0]
	orx	3, 8, r11, [0x09,off0], [0x09,off0]
	jmp	L916
L906:
	jzx	0, 6, [0x08,off6], 0x0, L909
	jzx	0, 3, SPR_TXE0_PHY_CTL, 0x0, L907
	orx	3, 7, 0x1, [0x0A,off0], [0x0A,off0]
	jmp	L909
L907:
	srx	1, 7, [0x0A,off0], 0x0, r34
	je	r34, 0x1, L908
	jne	r34, 0x2, L909
L908:
	add	r34, 0x1, r34
	orx	1, 7, r34, [0x0A,off0], [0x0A,off0]
L909:
	mov	0x1, r34
	je	r33, 0x1, L910
	mov	0x2, r34
L910:
	orx	1, 14, r34, SPR_TXE0_FIFO_PRI_RDY, SPR_TXE0_FIFO_PRI_RDY
L911:
	jnzx	1, 14, SPR_TXE0_FIFO_PRI_RDY, 0x0, L911
	srx	6, 0, SPR_AQM_Agg_Stats, 0x0, r34
	jges	r33, 0x0, L912
	sub	0x0, r34, r34
L912:
	add	[0x13,off0], r33, r11
	add	[0x13,off0], r33, [0x13,off0]
	jnext	COND_PSM(1), L913
	add	r11, [0x12,off0], r11
L913:
	jzx	0, 1, [0x02,off0], 0x0, L914
	add	[0x15,off0], r34, [0x15,off0]
	jmp	L916
L914:
	srx	1, 4, [0x0B,off0], 0x0, r33
	add	SPR_BASE0, r33, SPR_BASE4
	srx	7, 0, [0x15,off4], 0x0, r33
	add	r33, r34, r33
	jle	r33, 0xFF, L915
	mov	0xFF, r33
L915:
	orx	7, 0, r33, [0x15,off4], [0x15,off4]
L916:
	rets
L917:
	jnzx	0, 5, [0x08,off6], 0x0, L920
	srx	1, 4, [0x0B,off0], 0x0, r33
	jge	r33, 0x3, L920
	je	r14, 0x31, L918
	add	r33, 0x1, r33
	jmp	L919
L918:
	jne	r33, 0x0, L919
	mov	0x1, r33
L919:
	orx	1, 4, r33, [0x0B,off0], [0x0B,off0]
L920:
	rets
L921:
	jnzx	0, 5, [SHM_HOST_FLAGS1], 0x0, L943
	or	SPR_BASE2, 0x0, [0x792]
	or	SPR_BASE3, 0x0, [0x793]
	or	SPR_TSF_WORD0, 0x0, r34
	srx	15, 7, r34, SPR_TSF_WORD1, r33
	mov	0x747, SPR_BASE4
	mov	0x0, r34
	mov	0x72A, SPR_BASE5
	mov	0x798, SPR_BASE2
L922:
	je	[0x00,off4], 0x0, L941
	mov	0x789, SPR_BASE3
	add	SPR_BASE3, r34, SPR_BASE3
	sr	[0x00,off3], 0x7, r38
	jdn	r33, [0x03,off4], L929
	or	[0x00,off4], 0x0, r35
L923:
	add	[0x03,off4], r38, [0x00,off2]
	add	[0x03,off4], r35, [0x03,off4]
	sub	[0x0B,off4], 0x1, [0x0B,off4]
	jges	[0x0B,off4], 0x0, L924
	sub	[0x01,off4], 0x1, [0x0B,off4]
L924:
	jdnz	[0x03,off4], r33, L923
	sub	[0x03,off4], r35, r36
	sub	r33, r36, r36
	jnand	[0x02,off4], 0x200, L925
	jg	r36, 0x4E, L926
L925:
	mov	0x1, [0x00,off5]
	mov	0x200, SPR_MAC_IRQHI
	mov	0x1, [0x797]
L926:
	jzx	0, 10, [0x02,off4], 0x0, L927
	orx	0, 12, 0x1, r43, r43
L927:
	jnzx	0, 1, [0x796], 0x0, L929
	jand	[0x02,off4], 0x40, L928
	mov	0x1, [0x7A0]
	jmp	L929
L928:
	jand	[0x02,off4], 0xA0, L929
	jnand	[0x02,off4], 0x200, L929
	orx	0, 11, 0x1, r45, r45
	sl	[SHM_NOSLPZNATDTIM], 0x6, SPR_TSF_GPT1_CNTLO
	sr	[SHM_NOSLPZNATDTIM], 0xA, SPR_TSF_GPT1_CNTHI
	mov	0xC000, SPR_TSF_GPT1_STAT
L929:
	jdn	r33, [0x00,off2], L932
	je	[0x04,off4], 0x0, L930
	orx	1, 0, 0x1, [0x02,off4], [0x02,off4]
	or	[0x00,off2], 0x0, r36
	add	r36, [0x04,off4], [0x05,off4]
L930:
	add	[0x03,off4], r38, [0x00,off2]
	jzx	0, 10, [0x02,off4], 0x0, L931
	orx	0, 12, 0x0, r43, r43
L931:
	jand	[0x02,off4], 0x40, L932
	mov	0x0, [0x7A0]
L932:
	je	[0x04,off4], 0x0, L933
	jdn	r33, [0x05,off4], L933
	orx	1, 0, 0x2, [0x02,off4], [0x02,off4]
	or	[0x00,off2], 0x0, r36
	add	r36, [0x04,off4], [0x05,off4]
	mov	0x1, [0x01,off5]
	mov	0x200, SPR_MAC_IRQHI
	mov	0x1, [0x797]
L933:
	je	[0x06,off4], 0x0, L941
	jdn	r33, [0x07,off4], L941
L934:
	jzx	0, 2, [0x02,off4], 0x0, L936
	sub	[0x06,off4], 0x1, [0x06,off4]
	or	[0x09,off4], 0x0, r35
	add	[0x07,off4], r35, [0x07,off4]
	mov	0x79C, SPR_BASE3
	add	SPR_BASE3, r34, SPR_BASE3
	or	[0x0A,off4], 0x0, r35
	add	[0x00,off3], r35, [0x00,off3]
	jzx	0, 7, [0x00,off3], 0x0, L935
	add	[0x07,off4], 0x1, [0x07,off4]
	srx	6, 0, [0x00,off3], 0x0, [0x00,off3]
L935:
	orx	0, 2, 0x0, [0x02,off4], [0x02,off4]
	jmp	L937
L936:
	or	[0x08,off4], 0x0, r35
	add	[0x07,off4], r35, [0x07,off4]
	orx	0, 2, 0x1, [0x02,off4], [0x02,off4]
L937:
	je	[0x06,off4], 0x0, L938
	jdnz	[0x07,off4], r33, L934
L938:
	jzx	0, 2, [0x02,off4], 0x0, L939
	mov	0x1, [0x02,off5]
	jmp	L940
L939:
	mov	0x1, [0x03,off5]
L940:
	mov	0x200, SPR_MAC_IRQHI
	mov	0x1, [0x797]
L941:
	add	SPR_BASE4, 0xC, SPR_BASE4
	add	r34, 0x1, r34
	add	SPR_BASE5, 0x4, SPR_BASE5
	add	SPR_BASE2, 0x1, SPR_BASE2
	jl	r34, 0x4, L922
	jnzx	3, 0, [0x788], 0x0, L942
	mov	0x0, [0x7A0]
L942:
	or	[0x792], 0x0, SPR_BASE2
	or	[0x793], 0x0, SPR_BASE3
L943:
	rets
L944:
	orx	0, 11, 0x0, r43, r43
	jnand	SPR_TXE0_0x5e, 0x3F, L0
	jext	0x12, L0
	jne	SPR_TXE0_0x78, 0x20, L0
	jnand	0x1FF, SPR_BRC, L0
	jnzx	0, 4, SPR_MAC_CMD, 0x0, L0
	jne	[0xB4B], 0x0, L0
	calls	L921
	je	[0x013], 0xFFFF, L945
	jzx	0, 15, SPR_TSF_GPT1_STAT, 0x0, L950
	je	[0x027], 0xFFFF, L0
L945:
	je	[0x027], 0xFFFF, L946
	je	[0xCB5], 0x0, L949
	jdpz	SPR_TSF_WORD0, [0xCB5], L950
	jmp	L0
L946:
	mov	0x747, SPR_BASE5
	add	SPR_BASE5, 0x30, r34
L947:
	jne	[0x0B,off5], 0x0, L948
	jnzx	0, 3, [0x02,off5], 0x0, L0
L948:
	add	SPR_BASE5, 0xC, SPR_BASE5
	jl	SPR_BASE5, r34, L947
L949:
	jnzx	0, 15, SPR_TSF_GPT1_STAT, 0x0, L0
L950:
	jne	[0x7A0], 0x0, L0
	jext	0x71, L0
	jext	COND_TX_TBTTEXPIRE, L852
	jnzx	0, 2, r20, 0x0, L952
	jnzx	0, 6, SPR_MAC_CMD, 0x0, L951
	jnzx	0, 3, r20, 0x0, L953
L951:
	mov	0x0, SPR_SCC_Timer_Low
	mov	0x0, SPR_SCC_Timer_High
	mov	0x8000, SPR_SCC_Divisor
	mov	0x2, SPR_SCC_Control
	orx	1, 2, 0x1, r20, r20
	mov	0x3900, SPR_PSM_0x6e
	mov	0x0, SPR_PSM_0x6c
	mov	0x88, r35
	calls	L69
	jmp	L0
L952:
	jnzx	0, 1, SPR_SCC_Control, 0x0, L0
	orx	14, 1, SPR_SCC_Timer_Low, 0x0, SPR_SCC_Period_Divisor
	srx	0, 15, SPR_SCC_Timer_Low, 0x0, r33
	orx	14, 1, SPR_SCC_Timer_High, r33, SPR_SCC_Period
	or	SPR_SCC_Period, 0x0, SPR_PSM_0x6e
	or	SPR_SCC_Period_Divisor, 0x0, SPR_PSM_0x6c
	mov	0x74, r35
	calls	L69
	or	SPR_SCC_Period, 0x0, [0xC84]
	or	SPR_SCC_Period_Divisor, 0x0, [0xC85]
	mov	0x0, SPR_SCC_Period
	mov	0x0, SPR_SCC_Period_Divisor
	sr	[0xC85], 0x6, [0xC85]
	or	[0xC84], 0x0, r33
	orx	5, 10, r33, [0xC85], [0xC85]
	orx	1, 2, 0x2, r20, r20
	mov	0x40, SPR_MAC_CMD
L953:
	jext	0x3B, L975
	orx	0, 12, 0x0, r44, r44
	jzx	0, 9, [SHM_HOST_FLAGS1], 0x0, L954
	mov	0xFFFF, [0x855]
	mov	0x7FFF, [0x863]
	jmp	L976
L954:
	mov	0x747, SPR_BASE4
	mov	0x789, SPR_BASE5
	mov	0x1, r33
	mov	0x0, r35
L955:
	je	[0x00,off4], 0x0, L971
	mov	0x0, r37
	jzx	0, 6, [0x02,off4], 0x0, L956
	jnzx	0, 0, [0x02,off4], 0x0, L975
	sub.	SPR_TSF_CFP_Start_Low, [0x00,off5], r59
	subc	SPR_TSF_CFP_Start_High, 0x0, r36
	srx	15, 7, r59, r36, r36
	jnzx	0, 8, [0x02,off4], 0x0, L958
	je	[0x04,off4], 0x0, L959
	jmp	L958
L956:
	jzx	0, 7, [0x02,off4], 0x0, L962
	or	[0x03,off4], 0x0, r36
	je	[0x01,off4], 0x1, L957
	je	[0x0B,off4], 0x1, L957
	mov	0x1, r37
L957:
	je	[0x04,off4], 0x0, L958
	jdnz	r36, [0x05,off4], L958
	or	[0x05,off4], 0x0, r36
	mov	0x1, r37
L958:
	jand	[0x73A], r33, L959
	je	[0x06,off4], 0x0, L968
	jmp	L960
L959:
	sl	r33, 0x4, r59
	jand	[0x73A], r59, L975
	jzx	0, 2, [0x02,off4], 0x0, L975
L960:
	jdnz	r36, [0x07,off4], L968
	or	[0x07,off4], 0x0, r36
	jand	[0x73A], r33, L961
	mov	0x1, r37
L961:
	jmp	L968
L962:
	jzx	0, 5, [0x02,off4], 0x0, L971
	jzx	0, 9, SPR_MAC_CTLHI, 0x0, L975
	or	[0x03,off4], 0x0, r36
	sub	[0x0B,off4], 0x1, r59
	jges	r59, 0x0, L963
	sub	[0x01,off4], 0x1, r59
L963:
	je	[0x05B], 0x0, L966
	or	SPR_TSF_WORD0, 0x0, r0
	srx	15, 7, r0, SPR_TSF_WORD1, r0
	jdpz	r0, [0x7A1], L964
	or	[0x7A1], 0x0, r36
	jmp	L968
L964:
	srx	7, 8, [0x05B], 0x0, r0
	jne	r0, 0x0, L965
	srx	7, 0, [0x05B], 0x0, r0
	sub	r0, 0x1, r59
	jmp	L966
L965:
	sub	r0, 0x1, r0
	mul	r0, [0x01,off4], r0
	add	r59, SPR_PSM_0x5a, r59
L966:
	je	r59, 0x0, L967
	add	r36, [0x00,off4], r36
	sub	r59, 0x1, r59
	jmp	L966
L967:
	or	r36, 0x0, [0x7A1]
L968:
	je	r35, 0x0, L969
	jdn	r36, r34, L970
	jmp	L971
L969:
	mov	0x1, r35
L970:
	or	r36, 0x0, r34
	or	r37, 0x0, r38
L971:
	sl	r33, 0x1, r33
	add	SPR_BASE4, 0xC, SPR_BASE4
	add	SPR_BASE5, 0x1, SPR_BASE5
	jl	r33, 0x10, L955
	je	r35, 0x0, L975
	or	SPR_TSF_WORD0, 0x0, r37
	srx	15, 7, r37, SPR_TSF_WORD1, r37
	sub	r34, r37, r36
	sl	r36, 0x7, [0x794]
	sr	r36, 0x9, [0x795]
	or	[SHM_SPUWKUP], 0x0, r35
	jne	[0x795], 0x0, L972
	jle	[0x794], r35, L974
L972:
	jext	0x4C, L975
	orx	0, 0, r38, [0x796], [0x796]
	je	r38, 0x0, L973
	mov	0x0, r35
L973:
	sub.	[0x794], r35, [0x855]
	subc	[0x795], 0x0, [0x863]
	jmp	L976
L974:
	je	r38, 0x0, L975
	orx	0, 2, 0x1, SPR_BRWK2, SPR_BRWK2
	sl	[0x794], 0x3, SPR_TSF_GPT2_CNTLO
	sr	[0x794], 0xD, SPR_TSF_GPT2_CNTHI
	mov	0xC000, SPR_TSF_GPT2_STAT
	napv	0xC00
	calls	L921
	jmp	L953
L975:
	jzx	0, 1, [0x796], 0x0, L0
	jmp	L1002
L976:
	jls	[0x863], 0x0, L0
	mov	0x4000, SPR_TSF_GPT0_STAT
	jnzx	0, 1, SPR_PHY_HDR_Parameter, 0x0, L977
	jext	0x3B, L1002
L977:
	jext	0x3B, L815
	jg	[0x855], SPR_SCC_Fast_Powerup_Delay, L979
	jne	[0x863], 0x0, L979
	jzx	0, 0, [0x796], 0x0, L978
	orx	0, 2, 0x1, SPR_BRWK2, SPR_BRWK2
	sl	[0x794], 0x3, SPR_TSF_GPT2_CNTLO
	sr	[0x794], 0xD, SPR_TSF_GPT2_CNTHI
	mov	0xC000, SPR_TSF_GPT2_STAT
	napv	0xC00
	calls	L921
	jmp	L953
L978:
	jnzx	0, 1, SPR_PHY_HDR_Parameter, 0x0, L0
	jmp	L1002
L979:
	sub.	[0x855], SPR_SCC_Fast_Powerup_Delay, SPR_SCC_Timer_Low
	subc	[0x863], 0x0, SPR_SCC_Timer_High
	mov	0x4, [SHM_UCODESTAT]
	je	SPR_PHY_HDR_Parameter, 0x0, L981
L980:
	jnzx	0, 8, SPR_IFS_STAT, 0x0, L980
	calls	L1242
	orx	0, 1, 0x1, r20, r20
	calls	L1038
L981:
	calls	L1040
	orx	0, 1, 0x1, [0x796], [0x796]
	jnext	0x34, L982
	mov	0x0, SPR_BRWK0
	mov	0x0, SPR_BRWK1
	mov	0xB00, SPR_BRWK2
	mov	0x800, SPR_BRWK3
	jmp	L983
L982:
	mov	0x0, SPR_BRWK0
	mov	0x0, SPR_BRWK1
	mov	0x1900, SPR_BRWK2
	mov	0x800, SPR_BRWK3
L983:
	mov	0x0, [0xCB5]
	orx	0, 0, 0x0, SPR_PSM_0x70, SPR_PSM_0x70
	jand	SPR_AQM_FIFO_Ready, 0x3F, L984
	orx	0, 0, 0x1, SPR_PSM_0x70, SPR_PSM_0x70
L984:
	mov	0x0, SPR_PSM_0x6e
	mov	0x0, SPR_PSM_0x6c
	mov	0x7C, r35
	calls	L69
	or	SPR_SCC_Timer_High, 0x0, SPR_PSM_0x6e
	or	SPR_SCC_Timer_Low, 0x0, SPR_PSM_0x6c
	mov	0x78, r35
	calls	L69
	mov	0x0, SPR_SCC_Divisor
	mov	0x2, SPR_SCC_Control
L985:
	jnzx	0, 1, SPR_SCC_Control, 0x0, L985
	orx	5, 8, 0x1F, 0x14, SPR_PSM_0x6a
L986:
	jnzx	0, 14, SPR_PSM_0x6a, 0x0, L986
	or	SPR_PSM_0x6c, 0x0, [0x0D1]
	or	SPR_PSM_0x6e, 0x0, [0x0D2]
	or	SPR_TSF_WORD0, 0x0, [0x873]
	or	SPR_TSF_WORD1, 0x0, [0x872]
	or	SPR_TSF_WORD2, 0x0, [0x871]
	or	SPR_TSF_WORD3, 0x0, [0x870]
	add.	SPR_TSF_WORD0, [0x855], [0xCA6]
	addc	SPR_TSF_WORD1, [0x863], [0xCA7]
	jext	EOI(0x28), L987
L987:
	mov	0xFFFF, SPR_SCC_Timer_High
	mov	0xFFFF, SPR_SCC_Timer_Low
	mov	0x5, SPR_SCC_Control
	mov	0x0, SPR_MAC_MAX_NAP
	napv	0xC00
	jzx	0, 9, [SHM_HOST_FLAGS1], 0x0, L988
	jnext	0x3B, L984
L988:
	mov	0x7, [SHM_UCODESTAT]
	orx	0, 5, 0x1, SPR_PSM_0x70, SPR_PSM_0x70
	orx	5, 8, 0x1F, 0x78, SPR_PSM_0x6a
L989:
	jnzx	0, 14, SPR_PSM_0x6a, 0x0, L989
	jne	SPR_PSM_0x6c, 0x0, L990
	je	SPR_PSM_0x6e, 0x0, L991
L990:
	orx	0, 12, 0x1, r44, r44
L991:
	mov	0x0, SPR_PSM_0x6e
	mov	0x0, SPR_PSM_0x6c
	mov	0x7C, r35
	calls	L69
	mov	0x78, r35
	calls	L69
	calls	L69
	mov	0x0, SPR_SCC_Control
L992:
	mov	0x0, SPR_SCC_Divisor
	mov	0x2, SPR_SCC_Control
L993:
	jnzx	0, 1, SPR_SCC_Control, 0x0, L993
	jzx	0, 15, SPR_PSM_0x70, 0x0, L992
	jext	EOI(0x28), L994
L994:
	orx	0, 12, 0x1, SPR_TSF_0x00, SPR_TSF_0x00
	orx	5, 8, 0x1F, 0x14, SPR_PSM_0x6a
L995:
	jnzx	0, 14, SPR_PSM_0x6a, 0x0, L995
	sub.	SPR_PSM_0x6c, [0x0D1], r28
	subc	SPR_PSM_0x6e, [0x0D2], r27
	mov	0x0, [0x0D1]
	mov	0x0, [0x0D2]
	or	[0xC85], 0x0, r33
	mul	r28, r33, r29
	or	SPR_PSM_0x5a, 0x0, r30
	srx	15, 10, r30, r29, r33
	sr	r29, 0xA, r34
	add.	[0x873], r33, SPR_TSF_WORD0
	addc.	[0x872], r34, SPR_TSF_WORD1
	addc.	[0x871], 0x0, SPR_TSF_WORD2
	addc	[0x870], 0x0, SPR_TSF_WORD3
	add.	[0x3BE], r33, [0x3BE]
	addc	[0x3BF], r34, [0x3BF]
	jnzx	0, 15, [0xBA5], 0x0, L997
	add	SPR_TSF_WORD1, 0x2, [0xBC9]
	jne	r34, 0x0, L996
	jl	r33, [0xBBF], L997
L996:
	orx	0, 8, 0x1, [0xBA4], [0xBA4]
L997:
	or	SPR_TSF_0x0e, 0x0, 0x0
	sl	SPR_TSF_0x10, 0xA, r35
	sr	SPR_TSF_0x10, 0x6, r36
L998:
	or	SPR_TSF_CFP_Start_Low, 0x0, r33
	or	SPR_TSF_CFP_Start_High, 0x0, r34
	sub.	r33, SPR_TSF_WORD0, r33
	subc	r34, SPR_TSF_WORD1, r34
	jges	r34, 0x0, L999
	add.	SPR_TSF_CFP_Start_Low, r35, SPR_TSF_CFP_Start_Low
	addc	SPR_TSF_CFP_Start_High, r36, SPR_TSF_CFP_Start_High
	sub	r8, 0x1, r8
	jges	r8, 0x0, L998
	sub	[SHM_DTIMP], 0x1, r8
	jmp	L998
L999:
	orx	0, 12, 0x0, SPR_TSF_0x00, SPR_TSF_0x00
	sub.	[0xCA6], SPR_TSF_WORD0, r33
	subc	[0xCA7], SPR_TSF_WORD1, r34
	jne	r34, 0x0, L1000
	mov	0x1388, r35
	jge	r33, r35, L1000
	orx	0, 2, 0x1, SPR_BRWK2, SPR_BRWK2
	rl	r33, 0x3, SPR_TSF_GPT2_CNTLO
	orx	12, 3, r34, SPR_TSF_GPT2_CNTLO, SPR_TSF_GPT2_CNTHI
	mov	0xC000, SPR_TSF_GPT2_STAT
	napv	0xC00
L1000:
	jnzx	0, 12, r44, 0x0, L1002
	jzx	0, 0, [0x796], 0x0, L1002
	mov	0x1000, r33
	add	SPR_TSF_WORD0, r33, r0
	mov	0x0, [0x797]
L1001:
	calls	L921
	jdp	SPR_TSF_WORD0, r0, L1002
	je	[0x797], 0x0, L1001
	jmp	L953
L1002:
	jzx	0, 13, SPR_PSM_0x70, 0x0, L1002
	orx	0, 1, 0x0, r20, r20
	mov	0x0, SPR_MAC_MAX_NAP
	mov	0x0, SPR_BRWK0
	mov	0x0, SPR_BRWK1
	mov	0x0, SPR_BRWK2
	mov	0x0, SPR_BRWK3
	calls	L1039
	calls	L1046
	mov	0xA00, SPR_BRWK2
	mov	0x800, SPR_BRWK3
	calls	L1042
	mov	0x0, SPR_MAC_MAX_NAP
	mov	0x0, [0xCB0]
	or	[SHM_PRETBTT], 0x0, SPR_TSF_CFP_PreTBTT
	mov	0x2CE, SPR_BRWK0
	mov	0x46AF, SPR_BRWK1
	mov	0x7C06, SPR_BRWK2
	mov	0x608, SPR_BRWK3
	calls	L1047
	mov	0x2, [SHM_UCODESTAT]
	mov	0x0, [0x796]
	jzx	0, 14, [SHM_HOST_FLAGS4], 0x0, L1003
	calls	L1486
L1003:
	jmp	L815
L1004:
	srx	1, 0, SPR_TXE0_PHY_CTL, 0x0, r33
	jnzx	0, 3, SPR_TXE0_PHY_CTL, 0x0, L1007
	jge	r33, 0x2, L1007
	jnzx	0, 12, [SHM_KEYIDXBLOCK], 0x0, L1007
	mov	0x2EA, SPR_BASE4
	jzx	0, 15, [0x00,off4], 0x0, L1005
	mov	0x86A, SPR_BASE4
L1005:
	je	r33, 0x0, L1006
	mov	0x2EB, SPR_BASE4
L1006:
	orx	7, 6, [0x00,off4], SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	calls	L1013
L1007:
	or	[0x0C9], 0x0, r1
	je	r33, 0x0, L1008
	or	[0x0C8], 0x0, r1
L1008:
	mov	0x4A, r0
	calls	L1036
	je	[0x0DD], 0x0, L1012
	srx	1, 0, SPR_TXE0_PHY_CTL, 0x0, r33
	je	r33, 0x0, L1010
	or	[0x0DC], 0x0, r36
	jzx	0, 1, SPR_TXE0_PHY_CTL, 0x0, L1011
	srx	2, 0, SPR_TXE0_PHY_CTL2, 0x0, r35
	jzx	0, 0, SPR_TXE0_PHY_CTL, 0x0, L1009
	srx	3, 0, SPR_TXE0_PHY_CTL2, 0x0, r35
L1009:
	jgs	r35, 0x3, L1011
L1010:
	or	[0x0DB], 0x0, r36
L1011:
	mov	0x679, r33
	calls	L66
	orx	8, 7, r36, SPR_Ext_IHR_Data, r34
	calls	L68
L1012:
	rets
L1013:
	jnzx	0, 0, SPR_TXE0_PHY_CTL, 0x0, L1014
	srx	1, 1, r0, 0x0, SPR_TXE0_PHY_CTL2
	sub	SPR_TXE0_PHY_CTL2, 0x1, SPR_TXE0_PHY_CTL2
	jne	r0, 0xE, L1015
	mov	0x3, SPR_TXE0_PHY_CTL2
	jmp	L1015
L1014:
	mov	0x570, SPR_BASE4
	srx	2, 0, r0, 0x0, r34
	add	SPR_BASE4, r34, SPR_BASE4
	or	[0x00,off4], 0x0, SPR_TXE0_PHY_CTL2
L1015:
	rets
L1016:
	jzx	0, 0, [0x08,off1], 0x0, L1017
	mov	0x6, SPR_RCM_TA_Address_1
	or	SPR_RCM_TA_Address_1, 0x0, 0x0
	srx	1, 0, SPR_RCM_TA_Address_2, 0x0, [0xC7F]
L1017:
	rets
L1018:
	or	[0xC7F], 0x0, r33
	jne	[0xC7F], 0xFFFF, L1020
	or	r47, 0x0, r33
	jzx	0, 5, [SHM_HOST_FLAGS2], 0x0, L1019
	jges	r62, [0x0C7], L1019
	mov	0x0, r33
L1019:
	jzx	0, 15, [SHM_HOST_FLAGS1], 0x0, L1020
	jne	r19, 0x2D, L1020
	or	r41, 0x0, r33
L1020:
	orx	1, 14, r33, [SHM_TXFIFO_SIZE01], r34
	orx	1, 0, [0x864], r34, SPR_TXE0_PHY_CTL
	srx	2, 8, [SHM_CHAN], 0x0, r34
	sr	r34, r33, r34
	orx	2, 0, r34, [0x07,off2], SPR_TXE0_PHY_CTL1
	mov	0x0, SPR_TXE0_PHY_CTL2
	calls	L1004
	jzx	7, 0, [0x2EF], 0x0, L1021
	je	0xFFFF, SPR_BTCX_CUR_RFACT_Timer, L1021
	orx	7, 6, [0x2EF], SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
	srx	7, 8, [0x2EF], 0x0, r33
	srx	5, 3, SPR_TXE0_PHY_CTL1, 0x0, r34
	jle	r33, r34, L1021
	orx	5, 3, r33, SPR_TXE0_PHY_CTL1, SPR_TXE0_PHY_CTL1
L1021:
	je	[0xC7F], 0xFFFF, L1022
	orx	0, 7, 0x1, SPR_TXE0_PHY_CTL2, SPR_TXE0_PHY_CTL2
L1022:
	je	[0x864], 0x1, L1024
	jne	[0x864], 0x0, L1023
	jzx	3, 4, [0x01,off2], 0x0, L1024
L1023:
	srx	0, 13, SPR_RXE_ENCODING, 0x0, r33
	orx	0, 4, r33, SPR_TXE0_PHY_CTL, SPR_TXE0_PHY_CTL
L1024:
	rets
L1025:
	add	[SHM_EDCFSTAT], 0x14, r33
	add	r33, [SHM_SLOTT], r33
	add	r33, [0x006], r33
	jnzx	1, 0, r1, 0x0, L1026
	add	r33, 0x64, r33
	jzx	0, 9, [SHM_HOST_FLAGS4], 0x0, L1026
	jzx	0, 4, r1, 0x0, L1026
	sr	[0x006], 0x1, r34
	sub	r33, r34, r33
L1026:
	rets
L1027:
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L1028
	calls	L1093
	rets
L1028:
	and	SPR_TSF_RANDOM, r5, SPR_IFS_BKOFFTIME
	rets
L1029:
	rr	[0x00,off4], 0x8, r34
	orx	7, 0, [0x01,off4], r34, r34
	or	[0x00,off2], 0x0, [0x87A]
	or	[0x01,off2], 0x0, [0x87B]
	or	[0x02,off2], 0x0, [0x87C]
	or	[0x03,off2], 0x0, [0x87D]
	or	[0x04,off2], 0x0, [0x87E]
	add	[0x04,off2], r34, [0x87F]
	or	[0x00,off4], 0x0, [0x878]
	srx	7, 0, r34, 0x0, [0x879]
	or	[0x87F], 0x0, r36
	mov	0x0, r34
	or	SPR_BASE5, 0x0, SPR_BASE4
L1030:
	xor	r36, [0x00,off4], r36
	add	r1, r34, SPR_BASE2
	tkipl	r36, r35
	tkiphs	r36, r36
	add	r34, 0x1, r34
	xor	r36, r35, r36
	add	SPR_BASE5, r34, SPR_BASE4
	add	[0x00,off2], r36, [0x00,off2]
	or	[0x00,off2], 0x0, r36
	jle	r34, 0x5, L1030
	xor	r36, [0x06,off5], r34
	rr	r34, 0x1, r34
	add	[0x87A], r34, [0x87A]
	or	[0x87A], 0x0, r36
	xor	r36, [0x07,off5], r34
	rr	r34, 0x1, r34
	add	[0x87B], r34, [0x87B]
	rr	[0x87B], 0x1, r34
	add	[0x87C], r34, [0x87C]
	rr	[0x87C], 0x1, r34
	add	[0x87D], r34, [0x87D]
	rr	[0x87D], 0x1, r34
	add	[0x87E], r34, [0x87E]
	rr	[0x87E], 0x1, r34
	add	[0x87F], r34, [0x87F]
	or	[0x87F], 0x0, r34
	xor	r34, [0x00,off5], r34
	sr	r34, 0x1, r34
	orx	7, 8, r34, [0x879], [0x879]
	rets
L1031:
	je	r38, 0x7, L1033
	mov	0x100, SPR_WEP_0x48
	or	[0x00,off5], 0x0, SPR_WEP_0x4a
	or	[0x01,off5], 0x0, SPR_WEP_0x4a
	or	[0x02,off5], 0x0, SPR_WEP_0x4a
	or	[0x03,off5], 0x0, SPR_WEP_0x4a
	or	[0x04,off5], 0x0, SPR_WEP_0x4a
	or	[0x05,off5], 0x0, SPR_WEP_0x4a
	or	[0x06,off5], 0x0, SPR_WEP_0x4a
	or	[0x07,off5], 0x0, SPR_WEP_0x4a
	jne	r38, 0x2, L1032
	or	r35, 0x0, SPR_BASE5
	or	[0x00,off5], 0x0, SPR_WEP_0x4a
	or	[0x01,off5], 0x0, SPR_WEP_0x4a
	or	[0x02,off5], 0x0, SPR_WEP_0x4a
	or	[0x03,off5], 0x0, SPR_WEP_0x4a
L1032:
	rets
L1033:
	mov	0x100, SPR_WEP_0x48
	or	[0x00,off5], 0x0, SPR_WEP_0x4a
	or	[0x01,off5], 0x0, SPR_WEP_0x4a
	or	[0x02,off5], 0x0, SPR_WEP_0x4a
	or	[0x03,off5], 0x0, SPR_WEP_0x4a
	or	[0x04,off5], 0x0, SPR_WEP_0x4a
	or	[0x05,off5], 0x0, SPR_WEP_0x4a
	or	[0x06,off5], 0x0, SPR_WEP_0x4a
	or	[0x07,off5], 0x0, SPR_WEP_0x4a
	add	[0x051], r0, SPR_BASE5
	mov	0x108, SPR_WEP_0x48
	or	[0x00,off5], 0x0, SPR_WEP_0x4a
	or	[0x01,off5], 0x0, SPR_WEP_0x4a
	or	[0x02,off5], 0x0, SPR_WEP_0x4a
	or	[0x03,off5], 0x0, SPR_WEP_0x4a
	or	[0x04,off5], 0x0, SPR_WEP_0x4a
	or	[0x05,off5], 0x0, SPR_WEP_0x4a
	or	[0x06,off5], 0x0, SPR_WEP_0x4a
	or	[0x07,off5], 0x0, SPR_WEP_0x4a
	orx	7, 8, 0x0, SPR_WEP_IV_Key, SPR_WEP_IV_Key
	rets
L1034:
	jnzx	0, 14, SPR_RXE_0x60, 0x0, L1034
	orx	0, 12, 0x1, r0, SPR_RXE_0x60
L1035:
	jnzx	0, 12, SPR_RXE_0x60, 0x0, L1035
	or	SPR_RXE_0x62, 0x0, r1
	rets
L1036:
	jnzx	0, 14, SPR_RXE_0x60, 0x0, L1036
	or	r1, 0x0, SPR_RXE_0x62
	orx	0, 13, 0x1, r0, SPR_RXE_0x60
	rets
L1037:
	calls	L103
	jmp	L1041
L1038:
	mov	0x19E, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x3, r34
	calls	L68
	mov	0xC88, SPR_BASE4
	mov	0x98, r0
	or	[0x00,off4], 0x0, r1
	calls	L1036
	mov	0x9C, r0
	or	[0x01,off4], 0x0, r1
	calls	L1036
	mov	0x95, r0
	or	[0x02,off4], 0x0, r1
	calls	L1036
	mov	0x12, r0
	or	[0x03,off4], 0x0, r1
	calls	L1036
	mov	0x1F, r0
	or	[0x04,off4], 0x0, r1
	calls	L1036
	mov	0x23, r0
	or	[0x05,off4], 0x0, r1
	calls	L1036
	mov	0x3D, r0
	or	[0x06,off4], 0x0, r1
	calls	L1036
	mov	0x98, r0
	or	[0x07,off4], 0x0, r1
	calls	L1036
	mov	0xA0, SPR_MAC_MAX_NAP
	napv	0xC00
	mov	0x87, r0
	or	[0x08,off4], 0x0, r1
	calls	L1036
	mov	0x728, r33
	mov	0x0, r34
	calls	L68
	mov	0x729, r33
	mov	0x0, r34
	calls	L68
	mov	0x721, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x0, [0xCA0]
	mov	0xFFFF, r34
	calls	L68
	mov	0x73A, r33
	mov	0x0, r34
	calls	L68
	mov	0x725, r33
	mov	0x1FFF, r34
	calls	L68
	rets
L1039:
	rets
L1040:
	orx	0, 5, 0x0, SPR_PSM_0x70, SPR_PSM_0x70
	mov	0x0, SPR_PHY_HDR_Parameter
L1041:
	rets
L1042:
	mov	0xC93, SPR_BASE4
	jzx	0, 1, r20, 0x0, L1043
	mov	0xC88, SPR_BASE4
	mov	0x173E, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x0, [0xC9D]
L1043:
	mov	0x1725, r33
	or	[0x09,off4], 0x0, r34
	calls	L68
	mov	0x173E, r33
	or	[0x0A,off4], 0x0, r34
	calls	L68
	rets
L1044:
	orx	1, 1, 0x3, SPR_PHY_HDR_Parameter, SPR_PHY_HDR_Parameter
	mov	0x19E, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x3, r34
	calls	L68
	orx	2, 1, 0x7, SPR_PHY_HDR_Parameter, SPR_PHY_HDR_Parameter
	add	SPR_TSF_WORD0, 0x2, r33
L1045:
	jne	SPR_TSF_WORD0, r33, L1045
	nand	SPR_PHY_HDR_Parameter, 0x8, SPR_PHY_HDR_Parameter
	mov	0x19E, r33
	calls	L66
	nand	SPR_Ext_IHR_Data, 0x3, r34
	calls	L68
	orx	1, 1, 0x1, SPR_PHY_HDR_Parameter, SPR_PHY_HDR_Parameter
	rets
L1046:
	mov	0x725, r33
	mov	0x600, r34
	calls	L68
	mov	0x73A, r33
	mov	0x180, r34
	calls	L68
	mov	0x721, r33
	or	[0xCA0], 0x0, r34
	calls	L68
	mov	0x729, r33
	mov	0x1000, r34
	calls	L68
	mov	0x728, r33
	mov	0x4080, r34
	calls	L68
	mov	0xC93, SPR_BASE4
	mov	0x87, r0
	or	[0x08,off4], 0x0, r1
	calls	L1036
	mov	0x98, r0
	or	[0x07,off4], 0x0, r1
	calls	L1036
	mov	0x95, r0
	or	[0x02,off4], 0x0, r1
	calls	L1036
	mov	0x98, r0
	or	[0x00,off4], 0x0, r1
	calls	L1036
	mov	0x9C, r0
	or	[0x01,off4], 0x0, r1
	calls	L1036
	mov	0xA0, SPR_MAC_MAX_NAP
	napv	0xC00
	mov	0x12, r0
	or	[0x03,off4], 0x0, r1
	calls	L1036
	mov	0x1F, r0
	or	[0x04,off4], 0x0, r1
	calls	L1036
	mov	0x23, r0
	or	[0x05,off4], 0x0, r1
	calls	L1036
	mov	0x3D, r0
	or	[0x06,off4], 0x0, r1
	calls	L1036
	mov	0x2C8, SPR_MAC_MAX_NAP
	napv	0xC00
	mov	0x23, r0
	or	[0x05,off4], 0x0, r1
	orx	3, 8, 0xF, r1, r1
	calls	L1036
	mov	0x50, SPR_MAC_MAX_NAP
	napv	0xC00
	mov	0x24, r0
	or	[0xC9F], 0x0, r1
	calls	L1036
	mov	0x38, r0
	or	[0xC9E], 0x0, r1
	calls	L1036
	mov	0x2C, r0
	calls	L1034
	orx	0, 13, 0x0, r1, r1
	calls	L1036
	mov	0xA0, SPR_MAC_MAX_NAP
	napv	0xC00
	mov	0x3D, r0
	or	[0x06,off4], 0x0, r1
	orx	1, 7, 0x0, r1, r1
	calls	L1036
	mov	0x24, r0
	orx	0, 0, 0x1, [0xC9F], r1
	calls	L1036
	mov	0x38, r0
	orx	0, 6, 0x1, [0xC9E], r1
	calls	L1036
	mov	0x8, SPR_MAC_MAX_NAP
	napv	0xC00
	mov	0x3, r0
	calls	L1034
	orx	0, 4, 0x1, r1, r1
	calls	L1036
	mov	0x2C, r0
	calls	L1034
	orx	0, 13, 0x1, r1, r1
	calls	L1036
	mov	0x3C0, SPR_MAC_MAX_NAP
	napv	0xC00
	mov	0x38, r0
	calls	L1034
	jnzx	0, 2, r1, 0x0, L1046
	mov	0x3, r0
	calls	L1034
	orx	0, 4, 0x0, r1, r1
	calls	L1036
	rets
L1047:
	orx	1, 1, 0x3, SPR_PHY_HDR_Parameter, SPR_PHY_HDR_Parameter
	or	SPR_PHY_HDR_Parameter, 0x0, 0x0
	mov	0x1, r33
	calls	L66
	orx	0, 14, 0x1, SPR_Ext_IHR_Data, r34
	or	r34, 0x0, r36
	calls	L68
	mov	0x19E, r33
	calls	L66
	orx	3, 2, 0x0, SPR_Ext_IHR_Data, r34
	calls	L68
	orx	0, 0, 0x1, r34, r34
	calls	L68
	orx	1, 1, 0x1, SPR_PHY_HDR_Parameter, SPR_PHY_HDR_Parameter
	or	SPR_PHY_HDR_Parameter, 0x0, 0x0
	mov	0x1, r33
	orx	0, 14, 0x0, r36, r34
	calls	L68
	mov	0x19E, r33
	calls	L66
	orx	1, 0, 0x0, SPR_Ext_IHR_Data, r34
	calls	L68
	mov	0xF0, SPR_TSF_GPT2_CNTLO
	mov	0x0, SPR_TSF_GPT2_CNTHI
	mov	0xC000, SPR_TSF_GPT2_STAT
L1048:
	jnzx	0, 15, SPR_TSF_GPT2_STAT, 0x0, L1048
	rets
L1049:
	jzx	0, 4, SPR_MAC_CMD, 0x0, L1064
	jnzx	0, 15, SPR_TSF_GPT1_STAT, 0x0, L1064
	or	SPR_TSF_WORD0, 0x0, r38
	srx	15, 8, r38, SPR_TSF_WORD1, r38
	jnzx	0, 4, r20, 0x0, L1050
	orx	0, 4, 0x1, r20, r20
	add	r38, [SHM_JSSI0], [0x866]
	or	r38, 0x0, [0x86E]
L1050:
	jdpz	r38, [0x866], L1051
	jnand	0x13F, SPR_BRC, L1064
L1051:
	jnzx	0, 8, SPR_IFS_STAT, 0x0, L1064
	mov	0x271, r33
	mov	0x2, r34
	calls	L68
	mov	0x272, r33
	mov	0x200, r34
	calls	L68
	or	[0x179], 0x0, [0xC2A]
	or	[0x17B], 0x0, [0xC2C]
	mov	0x45, [0x18A]
	jzx	0, 5, [SHM_HOST_FLAGS3], 0x0, L1053
	jdn	r38, [0x86E], L1064
	add	[0x86E], 0x64, [0x86E]
	mov	0x960, SPR_NAV_0x04
L1052:
	or	[0xC2A], 0x0, r34
	or	[0x173], 0x0, r33
	calls	L68
	or	[0xC2C], 0x0, r34
	or	[0x176], 0x0, r33
	calls	L68
	or	[0x17D], 0x0, r34
	calls	L1068
L1053:
	mov	0x0, r37
	mov	0x270, r33
	mov	0x1, r34
	calls	L68
	add	SPR_TSF_WORD0, 0x1C, r33
L1054:
	or	r37, SPR_IFS_STAT, r37
	jne	r33, SPR_TSF_WORD0, L1054
	jzx	0, 5, [SHM_HOST_FLAGS3], 0x0, L1055
	mov	0x0, r34
	calls	L1068
L1055:
	mov	0x184, SPR_BASE4
	mov	0x0, [0x184]
	mov	0x0, [0x185]
	mov	0x0, [0x186]
	mov	0x0, [0x187]
	mov	0x0, [0x188]
	mov	0x0, [0x189]
	mov	0x6C2, r34
L1056:
	mov	0x0, r35
L1057:
	add	r34, r35, r33
	calls	L66
	addc.	[0x00,off4], SPR_Ext_IHR_Data, [0x00,off4]
	add	r35, 0x1, r35
	xor	SPR_BASE4, 0x1, SPR_BASE4
	jne	r35, 0x4, L1057
	add	SPR_BASE4, 0x2, SPR_BASE4
	mov	0x8C2, r34
	je	SPR_BASE4, 0x186, L1056
	mov	0xAC2, r34
	je	SPR_BASE4, 0x188, L1056
	jzx	0, 5, [SHM_HOST_FLAGS3], 0x0, L1059
	je	[0x18A], 0x2D, L1059
	or	[0x185], 0x0, r33
	jge	r33, [0x187], L1058
	or	[0x187], 0x0, r33
L1058:
	jl	r33, 0x40, L1059
	or	[0x17A], 0x0, [0xC2A]
	or	[0x17C], 0x0, [0xC2C]
	mov	0x2D, [0x18A]
	jmp	L1052
L1059:
	jdpz	r38, [0x866], L1061
	add	SPR_TSF_WORD0, 0x14, r35
L1060:
	or	r37, SPR_IFS_STAT, r37
	jnzx	0, 11, r37, 0x0, L1063
	jne	r35, SPR_TSF_WORD0, L1060
L1061:
	jzx	0, 11, r37, 0x0, L1062
	orx	0, 15, 0x1, [0x185], [0x185]
L1062:
	or	[SHM_CHAN], 0x0, [SHM_JSSIAUX]
	mov	0x10, SPR_MAC_CMD
	mov	0x4, SPR_MAC_IRQHI
	orx	0, 4, 0x0, r20, r20
L1063:
	jnext	EOI(0x07), L1064
	calls	L1423
L1064:
	rets
L1065:
	jzx	0, 3, SPR_MAC_CMD, 0x0, L1067
	jnzx	0, 7, r43, 0x0, L1066
	orx	0, 7, 0x1, r43, r43
	or	SPR_TSF_WORD0, 0x0, [0x868]
	or	SPR_TSF_WORD1, 0x0, [0x869]
L1066:
	sub.	SPR_TSF_WORD0, [0x868], r33
	subc	SPR_TSF_WORD1, [0x869], r34
	rl	r33, 0x3, r33
	orx	12, 3, r34, r33, r34
	sub.	r33, SPR_TSF_GPT2_CNTLO, r33
	subc	r34, SPR_TSF_GPT2_CNTHI, r34
	jls	r34, 0x0, L1067
	mov	0x4000, SPR_TSF_GPT2_STAT
	add.	SPR_TSF_GPT2_VALLO, r33, SPR_TSF_GPT2_VALLO
	add.	SPR_TSF_GPT2_VALHI, r34, SPR_TSF_GPT2_VALHI
	orx	0, 7, 0x0, r43, r43
	mov	0x8, SPR_MAC_CMD
	mov	0x2, SPR_MAC_IRQHI
L1067:
	rets
L1068:
	or	[SHM_TKIP_P1KEYS], 0x0, r33
	calls	L68
	rets
L1069:
	mov	0x3B4, SPR_BASE4
	add	SPR_BASE4, [0xC24], SPR_BASE4
	jzx	0, 0, [0xC24], 0x0, L1070
	add	SPR_BASE4, 0x5, SPR_BASE4
L1070:
	mov	0x3BC, r33
	jg	SPR_BASE4, r33, L1071
	add.	[0x00,off4], SPR_IFS_med_busy_ctl, [0x00,off4]
	addc	[0x01,off4], 0x0, [0x01,off4]
L1071:
	mov	0x0, [0xC24]
	mov	0x0, SPR_IFS_med_busy_ctl
	rets
L1072:
	je	SPR_IFS_0x0e, 0x0, L1079
	or	SPR_IFS_0x0e, 0x0, r1
	or	[0x16D], 0x0, r38
	mov	0x120, SPR_BASE5
	mov	0x5B4, SPR_BASE4
	mov	0x0, r33
L1073:
	jzx	0, 8, r43, 0x0, L1076
	or	[0x03,off5], 0x0, r0
	je	r33, [0x161], L1078
	jzx	0, 0, r38, 0x0, L1076
	jnzx	0, 8, [0x01,off4], 0x0, L1074
	srx	3, 0, [0x07,off5], 0x0, r2
	add	r2, 0x1, r2
	orx	3, 0, r2, [0x07,off5], [0x07,off5]
	jmp	L1075
L1074:
	srx	3, 4, [0x07,off5], 0x0, r2
	add	r2, 0x1, r2
	orx	3, 4, r2, [0x07,off5], [0x07,off5]
L1075:
	orx	14, 1, r0, 0x1, r0
	and	r0, [0x02,off5], r0
	or	r0, 0x0, [0x03,off5]
	and	SPR_TSF_RANDOM, r0, r2
	or	r2, 0x0, [0x05,off5]
	add	r2, [0x04,off5], [0x06,off5]
	jmp	L1078
L1076:
	or	[0x04,off5], 0x0, r2
	sub	r1, r2, r37
	jls	r37, 0x0, L1077
	sub	[0x05,off5], r37, [0x05,off5]
	jgs	[0x05,off5], 0x0, L1077
	mov	0x0, [0x05,off5]
	orx	0, 9, 0x0, [0x07,off5], [0x07,off5]
L1077:
	or	[0x05,off5], 0x0, r37
	add	[0x04,off5], r37, [0x06,off5]
L1078:
	add	SPR_BASE5, 0x10, SPR_BASE5
	add	SPR_BASE4, 0x20, SPR_BASE4
	add	r33, 0x1, r33
	sr	r38, 0x1, r38
	jne	r33, 0x4, L1073
	mov	0x0, SPR_IFS_0x0e
L1079:
	rets
L1080:
	mov	0x0, [0x16C]
	mov	0x0, [0x16D]
	mov	0x150, SPR_BASE5
	mov	0x3, r33
	and	SPR_AQM_FIFO_Ready, 0xF, [0x16E]
	or	SPR_IFS_0x0e, 0x0, r37
	mov	0xFFFF, r34
L1081:
	jl	r37, [0x06,off5], L1082
	orx	0, 9, 0x0, [0x07,off5], [0x07,off5]
	mov	0x0, [0x05,off5]
	or	[0x04,off5], 0x0, [0x06,off5]
L1082:
	sl	0x1, r33, r1
	jand	[0x16E], r1, L1086
	jge	r37, [0x04,off5], L1083
	jnzx	0, 9, [0x07,off5], 0x0, L1083
	orx	0, 9, 0x1, [0x07,off5], [0x07,off5]
	and	SPR_TSF_RANDOM, r5, [0x05,off5]
	or	[0x04,off5], 0x0, r36
	add	r36, [0x05,off5], [0x06,off5]
L1083:
	sub	[0x06,off5], r37, r36
	jges	r36, 0x0, L1084
	mov	0x0, r36
L1084:
	jne	r34, r36, L1085
	add	[0x16C], 0x1, [0x16C]
	or	[0x16D], r1, [0x16D]
L1085:
	jle	r34, r36, L1086
	or	r33, 0x0, [0x165]
	or	r36, 0x0, r34
	or	SPR_BASE5, 0x0, [0x166]
	mov	0x0, [0x16C]
	mov	0x0, [0x16D]
L1086:
	sub	r33, 0x1, r33
	sub	SPR_BASE5, 0x10, SPR_BASE5
	jges	r33, 0x0, L1081
	or	r34, 0x0, [0x164]
	rets
L1087:
	or	[0x166], 0x0, SPR_BASE5
	or	[0x166], 0x0, [0x162]
	or	[0x165], 0x0, [0x161]
	or	[0x03,off5], 0x0, r5
	or	[0x01,off5], 0x0, r3
	or	[0x02,off5], 0x0, r4
	srx	3, 0, [0x07,off5], 0x0, r12
	srx	3, 4, [0x07,off5], 0x0, r13
	rets
	or	[0x165], 0x0, r0
	je	r0, [0x161], L1092
	mov	0x0, SPR_TSF_0x24
	mov	0x0, SPR_TSF_0x2a
	or	[0x166], 0x0, SPR_BASE5
	jzx	0, 0, SPR_IFS_STAT, 0x0, L1089
	or	SPR_IFS_0x0e, 0x0, r1
	sub	[0x164], r1, r0
	jles	r0, 0x0, L1088
	or	r0, 0x0, SPR_IFS_BKOFFTIME
	jmp	L1090
L1088:
	mov	0x1, SPR_IFS_BKOFFTIME
	jmp	L1090
L1089:
	or	[0x164], 0x0, SPR_IFS_BKOFFTIME
L1090:
	or	[0x160], 0x0, [0x169]
	or	[0x162], 0x0, [0x16A]
	or	[0x163], 0x0, [0x16B]
	or	[0x161], 0x0, [0x168]
	or	[0x16A], 0x0, SPR_BASE4
	jnzx	0, 8, [0x07,off4], 0x0, L1091
	or	r5, 0x0, [0x03,off4]
	orx	3, 0, r12, [0x07,off4], [0x07,off4]
	orx	3, 4, r13, [0x07,off4], [0x07,off4]
L1091:
	orx	0, 8, 0x0, [0x07,off4], [0x07,off4]
	or	[0x164], 0x0, [0x160]
	or	[0x166], 0x0, [0x162]
	or	[0x167], 0x0, [0x163]
	or	[0x165], 0x0, [0x161]
	or	[0x162], 0x0, SPR_BASE5
	or	[0x03,off5], 0x0, r5
	or	[0x01,off5], 0x0, r3
	or	[0x02,off5], 0x0, r4
	orx	3, 0, [0x07,off5], r12, r12
	orx	3, 4, [0x07,off5], r13, r13
L1092:
	rets
L1093:
	or	[0x162], 0x0, SPR_BASE5
	jg	SPR_BASE5, 0x150, L1096
	and	SPR_TSF_RANDOM, r5, r33
	or	r33, 0x0, [0x05,off5]
	add	[0x04,off5], r33, [0x06,off5]
	or	[0x06,off5], 0x0, SPR_IFS_BKOFFTIME
	jzx	0, 0, [SHM_HOST_FLAGS4], 0x0, L1094
	jl	SPR_BASE5, 0x140, L1094
	jzx	0, 1, r43, 0x0, L1094
	mov	0x212, SPR_IFS_slot
L1094:
	or	r33, 0x0, [0x16F]
	jzx	0, 2, r43, 0x0, L1095
	or	r5, 0x0, [0x03,off5]
L1095:
	orx	0, 9, 0x1, [0x07,off5], [0x07,off5]
L1096:
	orx	0, 2, 0x0, r43, r43
	rets
L1097:
	jzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L1100
	add.	[0x3E7], 0x1, [0x3E7]
	addc	[0x3E8], 0x0, [0x3E8]
	or	SPR_TSF_WORD0, 0x0, [0xCB0]
	or	SPR_TSF_WORD1, 0x0, [0xCB1]
	mov	0x0, r34
	jmp	L1099
L1098:
	jnzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L1100
	sub.	SPR_TSF_WORD0, [0xCB0], r38
	subc	SPR_TSF_WORD1, [0xCB1], r59
	add.	[0x3E9], r38, [0x3E9]
	addc	[0x3EA], r59, [0x3EA]
	mov	0x1, r34
L1099:
	orx	0, 7, r34, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
	mov	0xC2, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	orx	0, 6, r34, SPR_BTCX_ECI_Data, SPR_BTCX_ECI_Data
	je	[0xB7F], 0x0, L1100
	mov	0xC10, r33
	orx	0, 0, r34, [0xB7F], r34
	calls	L68
L1100:
	rets
L1101:
	jzx	0, 2, SPR_IFS_STAT, 0x0, L1103
	jnzx	0, 15, SPR_TSF_GPT1_STAT, 0x0, L1103
	orx	0, 1, 0x0, r63, r63
	jzx	0, 2, [0xB6E], 0x0, L1102
	add	[0xB70], 0x1, [0xB70]
	orx	0, 2, 0x0, [0xB6E], [0xB6E]
L1102:
	calls	L1374
	jzx	0, 11, r45, 0x0, L1103
	add	[0xB1B], 0x1, [0xB1B]
	orx	0, 11, 0x0, r45, r45
L1103:
	rets
L1104:
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L1110
	calls	L1123
	jzx	0, 6, r44, 0x0, L1107
L1105:
	jzx	0, 0, [0xBA4], 0x0, L1106
	rets
L1106:
	je	SPR_AQM_FIFO_Ready, 0x0, L944
	jmp	L0
L1107:
	jnzx	1, 1, [SHM_HOST_FLAGS5], 0x0, L1110
	jzx	0, 6, [0xB5A], 0x0, L1108
	jnzx	0, 9, SPR_BTCX_Stat, 0x0, L1110
L1108:
	jnzx	0, 6, r63, 0x0, L1105
	jnzx	0, 0, r45, 0x0, L1105
	jnzx	0, 9, r45, 0x0, L1105
	jnzx	0, 4, [0xB31], 0x0, L1109
	je	[0xB26], 0x0, L1109
	je	[0xB0C], 0x0, L1110
L1109:
	jnzx	0, 2, r45, 0x0, L1105
	jnzx	0, 1, r45, 0x0, L1105
L1110:
	rets
L1111:
	orx	0, 1, 0x0, r20, r20
	jmp	L1037
L1112:
	jnzx	0, 8, [SHM_HOST_FLAGS3], 0x0, L1113
	jzx	7, 0, [0x2EF], 0x0, L1116
L1113:
	jzx	0, 6, [0xB5A], 0x0, L1114
	jnzx	0, 9, SPR_BTCX_Stat, 0x0, L1119
L1114:
	jnzx	0, 8, SPR_IFS_STAT, 0x0, L1115
	jzx	0, 0, SPR_TXE0_CTL, 0x0, L1119
L1115:
	je	r18, 0x25, L1119
	je	r18, 0x35, L1119
	je	r18, 0x31, L1119
L1116:
	or	r44, 0x20, r44
	jnzx	0, 8, SPR_IFS_STAT, 0x0, L1117
	jnext	COND_4_C7, L1118
L1117:
	orx	0, 4, 0x1, r44, r44
L1118:
	orx	0, 1, 0x1, r20, r20
	jmp	L1037
L1119:
	rets
L1120:
	jext	0x45, L1122
	or	SPR_TSF_GPT0_VALLO, 0x0, 0x0
	jne	SPR_TSF_GPT0_VALHI, 0x0, L1121
	add	[0x0A6], 0x1, [0x0A6]
	jmp	L815
L1121:
	mov	0xFFFF, SPR_MAC_MAX_NAP
L1122:
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L1225
L1123:
	je	[0xB20], 0x0, L1124
	sub	SPR_TSF_WORD0, [0xB20], r33
	mov	0xFDE8, r34
	jl	r33, r34, L1124
	sub	SPR_TSF_WORD0, r34, [0xB20]
L1124:
	jdnz	SPR_TSF_WORD0, [0xB19], L1125
	sub	SPR_TSF_WORD0, 0x1, [0xB19]
L1125:
	jnzx	0, 0, SPR_BTCX_Stat, 0x0, L1152
	jzx	0, 14, [SHM_HOST_FLAGS5], 0x0, L1126
	orx	0, 4, 0x0, SPR_GPIO_OUT, SPR_GPIO_OUT
L1126:
	jzx	0, 3, r45, 0x0, L1225
	orx	0, 3, 0x0, r45, r45
	orx	0, 14, 0x1, SPR_BRPO1, SPR_BRPO1
	jzx	0, 13, r45, 0x0, L1127
	orx	0, 6, 0x1, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
	calls	L1111
	jmp	L1132
L1127:
	jzx	0, 6, r44, 0x0, L1132
	orx	0, 6, 0x1, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
	calls	L1111
	jnzx	0, 8, r45, 0x0, L1132
	jne	[0xB23], 0x4, L1128
	srx	0, 13, [0xB2B], 0x0, r59
	jne	r59, 0x0, L1130
L1128:
	jnzx	0, 9, [SHM_HOST_FLAGS3], 0x0, L1132
	jne	[0xB23], 0x1, L1129
	jdnz	SPR_TSF_WORD0, [0xB19], L1131
L1129:
	jne	[0xB23], 0x4, L1132
L1130:
	je	[0xB26], 0x0, L1132
L1131:
	orx	0, 1, 0x0, r45, r45
L1132:
	jnzx	0, 7, r45, 0x0, L1133
	sub	SPR_BTCX_RFACT_DUR_Timer, [0xB3D], r33
	jg	r33, [0xB0B], L1141
L1133:
	jzx	0, 6, r45, 0x0, L1139
	add	[0xB4B], 0x1, [0xB4B]
	mov	0x0, [0xB4D]
	je	[0xB77], 0x0, L1134
	sub	[0xB77], 0x1, [0xB77]
L1134:
	orx	0, 11, 0x0, r45, r45
	jzx	0, 10, r45, 0x0, L1137
	or	[0xB4C], 0x0, r34
	or	[0xB0C], 0x0, r33
	jnzx	0, 7, [0xB6F], 0x0, L1135
	je	[0xB44], 0x0, L1136
	jl	r33, [0xB44], L1136
L1135:
	or	[0xB42], 0x0, r34
L1136:
	jl	[0xB4B], r34, L1137
	orx	0, 10, 0x0, r45, r45
L1137:
	jzx	0, 9, r63, 0x0, L1139
	add	[0xB57], 0x10, [0xB57]
	or	SPR_TSF_WORD0, 0x0, [0xB62]
	srx	3, 0, [0xB57], 0x0, r33
	srx	3, 4, [0xB57], 0x0, r34
	jg	r33, 0x0, L1138
	jge	r34, [0xB58], L1138
	jmp	L1139
L1138:
	mov	0x0, [0xB57]
	orx	0, 9, 0x0, r63, r63
L1139:
	jne	[0xB23], 0x15, L1140
	add	[0xB8B], 0x1, [0xB8B]
L1140:
	jzx	0, 5, r45, 0x0, L1225
	jne	[0xB20], 0x0, L1225
	or	[0xB17], 0x0, [0xB20]
	rets
L1141:
	orx	0, 9, 0x0, r45, r45
	jne	[0xB23], 0x15, L1142
	mov	0x1, [0xB8B]
L1142:
	jzx	0, 5, r45, 0x0, L1144
	jzx	0, 12, [SHM_HOST_FLAGS3], 0x0, L1143
	jnzx	0, 0, [0xB5A], 0x0, L1143
	or	[0xB30], 0x0, r59
	jg	[0xB26], r59, L1225
L1143:
	jzx	0, 5, r45, 0x0, L1144
	or	SPR_TSF_WORD0, 0x0, [0xB20]
	rets
L1144:
	jzx	0, 6, r45, 0x0, L1149
	je	[0xB23], 0x43, L1145
	sub	SPR_TSF_WORD0, [0xB14], [0xB1C]
L1145:
	je	[0xB77], 0x0, L1146
	sub	[0xB77], 0x1, [0xB77]
L1146:
	add	[0xB4D], 0x1, [0xB4D]
	or	[0xB4E], 0x0, r33
	or	[0xB0C], 0x0, r34
	jnzx	0, 7, [0xB6F], 0x0, L1147
	je	[0xB44], 0x0, L1148
	jl	r34, [0xB44], L1148
L1147:
	or	[0xB43], 0x0, r33
L1148:
	jl	[0xB4D], r33, L1149
	mov	0x0, [0xB4B]
L1149:
	jne	[0xB23], 0x5, L1150
	or	SPR_TSF_WORD0, 0x0, [0xB55]
	or	SPR_TSF_WORD1, 0x0, [0xB59]
L1150:
	jne	[0xB23], 0x9, L1151
	or	SPR_TSF_WORD0, 0x0, [0xB71]
L1151:
	jmp	L1225
L1152:
	jzx	0, 14, [SHM_HOST_FLAGS5], 0x0, L1153
	orx	0, 4, 0x1, SPR_GPIO_OUT, SPR_GPIO_OUT
L1153:
	jzx	0, 3, r45, 0x0, L1157
	je	[0xB23], 0x3, L1154
	je	[0xB23], 0x19, L1154
	jmp	L1155
L1154:
	jzx	0, 13, [0xB2B], 0x0, L1155
	jzx	0, 12, [0xB2B], 0x0, L1155
	sub	SPR_TSF_WORD0, [0xB17], r33
	jl	r33, 0x190, L1155
	jnzx	0, 6, [0xB6E], 0x0, L1155
	mov	0x4E2, r59
	mov	0x1, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, [0xB2B]
	srx	3, 8, [0xB2B], 0x0, [0xB0C]
	mul	[0xB0C], r59, r59
	or	SPR_PSM_0x5a, 0x0, [0xB0C]
	orx	0, 8, 0x1, r45, r45
	orx	0, 6, 0x1, [0xB6E], [0xB6E]
L1155:
	jnzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L1156
	orx	0, 12, 0x1, r45, r45
L1156:
	jnzx	0, 6, r44, 0x0, L1225
	jzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L1220
	sub	SPR_TSF_WORD0, [0xB17], r33
	jl	r33, [0xB13], L1225
	orx	0, 7, 0x1, r45, r45
	orx	0, 14, 0x0, SPR_BRPO1, SPR_BRPO1
	jmp	L1225
L1157:
	add.	[0x3E5], 0x1, [0x3E5]
	addc	[0x3E6], 0x0, [0x3E6]
	mov	0x0, [0xB3D]
	jl	SPR_BTCX_CUR_RFACT_Timer, 0xFA, L1158
	or	SPR_BTCX_CUR_RFACT_Timer, 0x0, [0xB3D]
L1158:
	add	SPR_TSF_WORD0, [0xB3D], r59
	sub	r59, SPR_BTCX_CUR_RFACT_Timer, [0xB17]
	orx	4, 3, 0x1, r45, r45
	orx	0, 6, 0x0, [0xB6E], [0xB6E]
	mov	0x0, [0xB6B]
L1159:
	sub	SPR_TSF_WORD0, [0xB17], r33
	jl	r33, [0xB54], L1159
	jl	r33, [0xB13], L1160
	add	[0xB3E], 0x1, [0xB3E]
L1160:
	or	[0xB0A], 0x0, r51
	mov	0x0, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, [0xB2A]
	mov	0x1, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, [0xB2B]
	mov	0x2, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, [0xB2C]
	mov	0x3, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, [0xB2D]
	orx	0, 5, 0x0, [0xB6E], [0xB6E]
	jzx	0, 15, [0xB2C], 0x0, L1161
	orx	0, 5, 0x1, [0xB6E], [0xB6E]
L1161:
	or	[0xB2B], 0x0, r59
	srx	5, 0, r59, 0x0, [0xB23]
	mov	0x4E2, r59
	jzx	3, 0, [0xB2C], 0x0, L1162
	srx	3, 0, [0xB2C], 0x0, r38
	mul	r38, r59, r59
	or	SPR_PSM_0x5a, 0x0, r51
L1162:
	jzx	0, 4, [0xB6F], 0x0, L1163
	orx	0, 12, 0x1, [0xB6B], [0xB6B]
L1163:
	jg	[0xB23], 0xF, L1164
	sl	0x1, [0xB23], r59
	jnand	r59, [0xB48], L1165
	jmp	L1166
L1164:
	sub	[0xB23], 0x10, r59
	sl	0x1, r59, r59
	jand	r59, [0xB49], L1166
L1165:
	orx	0, 4, 0x1, r45, r45
	jzx	0, 9, [SHM_HOST_FLAGS2], 0x0, L1166
	orx	0, 9, 0x1, [0xB6B], [0xB6B]
L1166:
	jg	[0xB23], 0xF, L1168
	sl	0x1, [0xB23], r59
	jand	r59, 0xC, L1167
	orx	0, 12, 0x0, [0xB6B], [0xB6B]
	jne	[0xB77], 0x0, L1170
L1167:
	jnand	r59, [0xB3A], L1169
	jmp	L1170
L1168:
	sub	[0xB23], 0x10, r59
	sl	0x1, r59, r59
	jand	r59, [0xB3B], L1170
L1169:
	orx	0, 8, 0x1, [0xB6B], [0xB6B]
L1170:
	jne	[0xB23], 0x17, L1171
	srx	1, 11, [0xB2B], 0x0, r33
	srx	1, 13, [0xB2B], 0x0, r34
	je	r33, 0x0, L1171
	add	r33, r34, r33
	add	r33, 0x40, [0xB23]
	orx	0, 12, 0x0, [0xB6B], [0xB6B]
	je	[0xB77], 0x0, L1171
	orx	0, 8, 0x0, [0xB6B], [0xB6B]
L1171:
	jne	[0xB23], 0x15, L1172
	jne	[0xB2E], 0x0, L1172
	jnzx	0, 8, r45, 0x0, L1172
	srx	5, 8, [0xB2C], 0x0, r33
	jle	r33, 0x30, L1172
	je	[0xB15], 0x0, L1172
	or	[0xB8B], 0x0, r33
	jl	r33, [0xB15], L1172
	orx	0, 15, 0x1, [0xB6B], [0xB6B]
L1172:
	jne	[0xB23], 0x5, L1174
	srx	5, 8, [0xB2C], 0x0, r35
	jzx	0, 10, r63, 0x0, L1174
	jge	r35, [0xB67], L1174
	je	r35, 0x0, L1174
	jnzx	0, 7, [0xB2B], 0x0, L1173
	orx	0, 6, 0x1, [0xB6B], [0xB6B]
	jmp	L1174
L1173:
	or	[0xB5C], 0x0, [0xB56]
	or	SPR_TSF_WORD1, 0x0, [0xB5D]
L1174:
	jne	[0xB23], 0x9, L1178
	jzx	0, 5, [0xB6F], 0x0, L1175
	orx	0, 13, 0x1, [0xB6B], [0xB6B]
L1175:
	jnzx	0, 3, [0xB5A], 0x0, L1178
	mov	0x0, [0xB40]
	je	[0xB71], 0x0, L1178
	sub	SPR_TSF_WORD0, [0xB71], r33
	jl	r33, [0xB72], L1176
	or	[0xB72], 0x0, r34
	add	r34, [0xB73], r34
	jge	r33, r34, L1177
	jzx	0, 1, [0xB6E], 0x0, L1178
L1176:
	orx	0, 10, 0x1, [0xB6B], [0xB6B]
	jmp	L1178
L1177:
	orx	0, 1, 0x0, [0xB6E], [0xB6E]
L1178:
	jne	[0xB23], 0x8, L1179
	or	[0xB17], 0x0, [0xB37]
	orx	0, 11, 0x1, r63, r63
L1179:
	jzx	0, 11, r63, 0x0, L1180
	orx	0, 3, 0x1, [0xB6B], [0xB6B]
L1180:
	je	[0xB23], 0x1, L1182
	je	[0xB23], 0xF, L1182
	je	[0xB23], 0x18, L1182
	jne	[0xB23], 0x15, L1181
	jnzx	0, 15, [0xB6B], 0x0, L1186
	jmp	L1182
L1181:
	jne	[0xB23], 0x4, L1186
L1182:
	orx	0, 5, 0x1, r45, r45
	or	[0xB17], 0x0, [0xB1F]
	jne	[0xB23], 0x18, L1183
	je	[0xB2E], 0x0, L1183
	or	[SHM_PCTLWDPOS], 0x0, [0xB23]
	or	[0xB45], 0x0, [0xB26]
	jmp	L1185
L1183:
	jne	[0xB23], 0x4, L1186
	srx	3, 8, [0xB2B], 0x0, [0xB26]
	srx	0, 13, [0xB2B], 0x0, r59
	je	r59, 0x0, L1184
	mov	0x3, [0xB29]
	or	[0xB84], 0x2, [0xB84]
	jmp	L1185
L1184:
	nand	[0xB84], 0x2, [0xB84]
	mov	0x4, [0xB29]
L1185:
	or	[0xB17], 0x0, [0xB2E]
L1186:
	jzx	0, 8, r45, 0x0, L1191
	jnzx	0, 10, r45, 0x0, L1187
	jzx	0, 9, r63, 0x0, L1191
L1187:
	or	[0xB1B], 0x0, r34
	jge	r34, [0xB0E], L1190
	or	[0xB4C], 0x0, r34
	or	[0xB0C], 0x0, r33
	jnzx	0, 7, [0xB6F], 0x0, L1188
	je	[0xB44], 0x0, L1189
	jl	r33, [0xB44], L1189
L1188:
	or	[0xB42], 0x0, r34
L1189:
	jge	[0xB4B], r34, L1191
L1190:
	orx	0, 5, 0x1, [0xB6B], [0xB6B]
L1191:
	sl	0x1, [0xB23], r33
	jnand	r33, [0xB82], L1192
	sub	[0xB23], 0x10, r33
	sl	0x1, r33, r33
	jand	r33, [0xB83], L1194
L1192:
	je	[0xB81], 0x0, L1194
	srx	5, 8, [0xB2C], 0x0, r34
	jg	r34, 0x14, L1193
	or	[0xB84], 0x1, [0xB84]
	jmp	L1194
L1193:
	nand	[0xB84], 0x1, [0xB84]
L1194:
	je	[0xB23], 0x17, L1195
	jne	[0xB23], 0x1E, L1196
L1195:
	or	SPR_TSF_WORD0, 0x0, [0xB81]
L1196:
	add	r51, [0xB0B], r51
	orx	0, 1, 0x0, r63, r63
	or	[0xB70], 0x0, r33
	or	[0xB1B], 0x0, r34
	jl	r34, [0xB0E], L1197
	jnzx	0, 11, r45, 0x0, L1201
	jmp	L1198
L1197:
	jl	r33, [0xB65], L1202
	jnzx	0, 2, [0xB6E], 0x0, L1201
L1198:
	mov	0x747, SPR_BASE4
	mov	0x798, SPR_BASE5
	mov	0x79C, r36
L1199:
	je	[0x00,off4], 0x0, L1200
	sl	[0x00,off5], 0x7, r35
	srx	6, 9, [0x00,off5], 0x0, r34
	sub.	r35, SPR_TSF_WORD0, r35
	orx	8, 7, 0x0, SPR_TSF_WORD1, r37
	subc	r34, r37, r34
	jne	r34, 0x0, L1200
	jle	r35, r51, L1201
L1200:
	add	SPR_BASE5, 0x1, SPR_BASE5
	add	SPR_BASE4, 0xC, SPR_BASE4
	jl	SPR_BASE5, r36, L1199
	jmp	L1202
L1201:
	jnzx	0, 0, [0xBA4], 0x0, L1202
	orx	0, 1, 0x1, r63, r63
	calls	L1297
L1202:
	mov	0x4E2, r59
	srx	5, 8, [0xB2C], 0x0, r34
	mul	r34, r59, r59
	or	SPR_PSM_0x5a, 0x0, r34
	je	[0xB23], 0x2, L1204
	je	[0xB23], 0x12, L1204
	je	[0xB23], 0x13, L1204
	je	[0xB23], 0x3, L1204
	jzx	0, 0, [0xBA5], 0x0, L1203
	je	[0xB23], 0x19, L1204
L1203:
	je	[0xB23], 0x42, L1204
	je	[0xB23], 0x43, L1204
	je	[0xB23], 0x44, L1204
	je	[0xB23], 0x1E, L1204
	jmp	L1210
L1204:
	orx	0, 6, 0x1, r45, r45
	jzx	0, 13, [0xB2B], 0x0, L1206
	je	[0xB23], 0x3, L1205
	jne	[0xB23], 0x19, L1206
L1205:
	orx	0, 8, 0x0, [0xB6B], [0xB6B]
	jzx	0, 12, [0xB2B], 0x0, L1210
	orx	0, 8, 0x1, [0xB6B], [0xB6B]
	jmp	L1208
L1206:
	je	r34, 0x0, L1208
	or	r34, 0x0, [0xB0C]
	add	[0xB17], r34, [0xCAE]
	orx	0, 8, 0x1, r45, r45
	je	[0xB88], 0x0, L1207
	jg	r34, [0xB88], L1207
	orx	0, 2, 0x1, [0xB84], [0xB84]
L1207:
	add	[0xB50], 0x1, [0xB50]
	jg	r34, [0xB66], L1208
	orx	0, 4, 0x1, [0xB6B], [0xB6B]
L1208:
	sub	SPR_TSF_WORD0, [0xB17], r33
	or	SPR_TSF_WORD0, 0x0, r35
	je	[0xB23], 0x44, L1209
	sub	r35, r33, [0xB14]
L1209:
	orx	0, 6, 0x0, r63, r63
L1210:
	jnzx	0, 6, r44, 0x0, L1225
	jzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L1220
	or	[0xB10], 0x0, r34
	or	[0xB12], 0x0, r35
	jne	[0xB23], 0x4, L1213
	jnzx	0, 0, [0xB5A], 0x0, L1213
	or	[0xB26], 0x0, r33
	jnzx	0, 3, [0xB6F], 0x0, L1211
	jl	r33, [0xB29], L1212
L1211:
	orx	0, 1, 0x1, [0xB6B], [0xB6B]
	je	[0xB39], 0x0, L1212
	mov	0x0, [0xB22]
	calls	L1290
L1212:
	je	r33, 0x0, L1213
	je	[0xB5F], 0x0, L1213
	or	[0xB5F], 0x0, r34
	or	[0xB60], 0x0, r35
L1213:
	je	r35, 0x0, L1214
	je	[0xB20], 0x0, L1214
	sub	SPR_TSF_WORD0, [0xB20], r33
	add	r35, r34, r34
	jl	r33, r34, L1214
	orx	0, 2, 0x1, [0xB6B], [0xB6B]
	je	[0xB39], 0x0, L1214
	mov	0x0, [0xB22]
	calls	L1290
L1214:
	jnzx	0, 3, [0xB31], 0x0, L1216
	jzx	0, 12, r63, 0x0, L1216
	jzx	0, 8, SPR_IFS_STAT, 0x0, L1216
	jext	COND_NEED_RESPONSEFR, L1216
	jnzx	0, 7, [0xB6E], 0x0, L1215
	jnzx	0, 0, [0xBA4], 0x0, L1216
L1215:
	orx	0, 7, 0x1, [0xB6B], [0xB6B]
L1216:
	jnzx	0, 12, [0xB6B], 0x0, L1225
	jnzx	0, 13, [0xB6B], 0x0, L1225
	jnzx	0, 1, [SHM_HOST_FLAGS1], 0x0, L1225
	jnzx	0, 1, r63, 0x0, L1225
	jnzx	0, 4, [0xB5A], 0x0, L1219
	jnzx	0, 3, [0xB6B], 0x0, L1219
	jnzx	0, 1, [0xB6B], 0x0, L1219
	jnzx	0, 2, [0xB6B], 0x0, L1219
	jnzx	0, 4, [0xB6B], 0x0, L1219
	jnzx	1, 1, [SHM_HOST_FLAGS5], 0x0, L1219
	jnzx	0, 5, [0xB6B], 0x0, L1217
	jnzx	0, 6, [0xB2B], 0x0, L1219
	jnzx	0, 6, [0xB6B], 0x0, L1217
	jnzx	0, 10, [0xB6B], 0x0, L1217
	jnzx	0, 8, [0xB6B], 0x0, L1219
	jnzx	0, 15, [0xB6B], 0x0, L1219
	jnzx	0, 9, [0xB6B], 0x0, L1219
L1217:
	jnzx	0, 7, [0xB6B], 0x0, L1219
	jnzx	0, 1, r45, 0x0, L1218
	jzx	0, 2, r45, 0x0, L1218
	jnzx	0, 14, r63, 0x0, L1218
	orx	0, 2, 0x0, r45, r45
	orx	0, 7, 0x0, [0xB6E], [0xB6E]
	calls	L1291
L1218:
	jmp	L1225
L1219:
	calls	L1097
L1220:
	sub	SPR_TSF_WORD0, [0xB17], r33
	jl	r33, [0xB0B], L1225
	jnzx	0, 2, [SHM_HOST_FLAGS5], 0x0, L1221
	jzx	0, 1, [SHM_HOST_FLAGS5], 0x0, L1223
	jnzx	0, 8, [0xB6B], 0x0, L1223
	jnzx	0, 1, [0xB6B], 0x0, L1223
	jnzx	0, 15, [0xB6B], 0x0, L1223
L1221:
	jnzx	0, 5, [0xB5A], 0x0, L1222
	orx	0, 6, 0x0, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
L1222:
	jmp	L1225
L1223:
	jnzx	0, 5, [0xB5A], 0x0, L1224
	orx	0, 6, 0x0, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
L1224:
	calls	L1112
	jnzx	0, 1, r45, 0x0, L1225
	je	[0xB23], 0x15, L1225
	orx	0, 2, 0x1, r45, r45
	orx	0, 7, 0x1, [0xB6E], [0xB6E]
	add	[0xB2F], 0x1, [0xB2F]
	jmp	L1282
L1225:
	rets
L1226:
	orx	4, 6, 0x0, r45, r45
	mov	0x0, [0xB39]
	mov	0x0, [0xB2E]
	mov	0x0, [0xB26]
	mov	0x0, [0xB50]
	orx	0, 14, 0x0, [0xB61], [0xB61]
	orx	0, 2, 0x0, [0xB84], [0xB84]
	rets
L1227:
	orx	0, 15, 0x0, SPR_BTCX_Control, SPR_BTCX_Control
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L1236
	jnzx	0, 5, r63, 0x0, L1240
	orx	0, 5, 0x1, r63, r63
	mov	0x10, SPR_BTCX_PRI_WIN
	or	[0xB0B], 0x0, SPR_BTCX_TX_Conf_Timer
	orx	0, 14, 0x1, SPR_BRPO1, SPR_BRPO1
	orx	0, 14, 0x1, SPR_BRWK1, SPR_BRWK1
	jnzx	0, 0, SPR_BTCX_Control, 0x0, L1229
	jnzx	0, 5, [0xB5A], 0x0, L1228
	orx	0, 6, 0x0, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
L1228:
	calls	L1097
	orx	1, 0, 0x3, SPR_BTCX_Control, SPR_BTCX_Control
L1229:
	mov	0x1, r35
	calls	L1304
	je	[0xB14], 0x0, L1230
	orx	0, 6, 0x1, r63, r63
	mov	0xBB8, r35
	add	SPR_TSF_WORD0, r35, [0xB1A]
	mov	0x0, [0xB14]
L1230:
	calls	L1226
	sub	SPR_TSF_WORD1, [0xB64], r33
	jle	r33, 0x1, L1231
	or	[0xB5B], 0x0, [0xB56]
	mov	0x0, [0xB55]
	je	[0xB20], 0x0, L1231
	or	SPR_TSF_WORD0, 0x0, [0xB1F]
	sub	SPR_TSF_WORD0, [0xB10], [0xB20]
	or	[0xB12], 0x0, r33
	sub	[0xB20], r33, [0xB20]
L1231:
	jnzx	0, 1, [SHM_HOST_FLAGS1], 0x0, L1232
	jnzx	0, 14, r63, 0x0, L1233
	jzx	0, 0, SPR_BTCX_Stat, 0x0, L1232
	jnzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L1232
	jne	SPR_BTCX_CUR_RFACT_Timer, 0xFFFF, L1233
L1232:
	orx	0, 6, 0x1, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
	calls	L1098
	orx	1, 2, 0x0, r45, r45
	orx	0, 15, 0x0, r44, r44
	orx	0, 7, 0x0, [0xB6E], [0xB6E]
	jmp	L1285
L1233:
	jnzx	0, 5, [0xB5A], 0x0, L1234
	orx	0, 6, 0x0, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
L1234:
	calls	L1112
	orx	1, 2, 0x3, r45, r45
	orx	0, 7, 0x1, [0xB6E], [0xB6E]
	jzx	0, 0, [0xBA5], 0x0, L1235
	orx	0, 8, 0x1, [0xBA4], [0xBA4]
L1235:
	jmp	L1285
L1236:
	orx	1, 14, 0x0, SPR_BRWK1, SPR_BRWK1
	orx	1, 0, 0x3, SPR_BTCX_Control, SPR_BTCX_Control
	jnzx	0, 3, [SHM_HOST_FLAGS5], 0x0, L1237
	orx	0, 6, 0x1, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
	calls	L1097
	jmp	L1239
L1237:
	jnzx	0, 5, [0xB5A], 0x0, L1238
	orx	0, 6, 0x0, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
L1238:
	calls	L1097
L1239:
	orx	0, 3, 0x0, r45, r45
	orx	0, 2, 0x0, r45, r45
	orx	0, 7, 0x0, [0xB6E], [0xB6E]
	calls	L1226
L1240:
	rets
L1241:
	or	SPR_TSF_WORD1, 0x0, [0xB64]
	jzx	0, 6, r44, 0x0, L1242
	orx	0, 6, 0x1, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
	calls	L1111
L1242:
	jzx	0, 4, [SHM_HOST_FLAGS1], 0x0, L1245
	orx	0, 5, 0x0, r63, r63
	jzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L1243
	jzx	0, 1, [SHM_HOST_FLAGS1], 0x0, L1243
	orx	0, 6, 0x1, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
	calls	L1098
	jmp	L1245
L1243:
	jnzx	0, 5, [0xB5A], 0x0, L1244
	orx	0, 6, 0x0, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
L1244:
	calls	L1097
L1245:
	mov	0x0, r35
	calls	L1304
	jzx	0, 15, [0xBA4], 0x0, L1246
	mov	0x6, r35
	calls	L1373
L1246:
	calls	L1374
	orx	0, 6, 0x0, [0xBA4], [0xBA4]
	rets
L1247:
	mov	0x1, r34
L1248:
	jnand	0xFF, SPR_BRC, L1273
	jnand	0x8, SPR_PSM_COND, L1273
	je	[0xB14], 0x0, L1249
	sub	SPR_TSF_WORD0, [0xB14], r57
	sub	[0xB0C], r57, r57
L1249:
	jzx	0, 11, [0xB6F], 0x0, L1251
	jnzx	0, 0, [0xB89], 0x0, L1250
	je	[0xB14], 0x0, L1251
	jgs	r57, [0xB0D], L1251
L1250:
	jzx	0, 0, r63, 0x0, L1285
L1251:
	jnzx	0, 0, r45, 0x0, L1273
	jnzx	0, 0, SPR_TXE0_CTL, 0x0, L1273
	jnzx	0, 8, SPR_IFS_STAT, 0x0, L1273
	jext	0x12, L1273
	jne	[0xB39], 0x0, L1273
	jnzx	0, 9, r45, 0x0, L1273
	jnzx	0, 12, r63, 0x0, L1290
	jzx	0, 3, [SHM_HOST_FLAGS3], 0x0, L1285
	jnzx	0, 6, r44, 0x0, L1273
	jzx	0, 6, [0xBA4], 0x0, L1252
	jnzx	0, 7, [0xB6E], 0x0, L1252
	jzx	0, 10, [0xBA5], 0x0, L1256
	jmp	L1263
L1252:
	jzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L1263
	jzx	0, 9, [SHM_HOST_FLAGS3], 0x0, L1263
	je	r34, 0x0, L1256
	jzx	0, 7, [0xB5A], 0x0, L1253
	jnzx	0, 8, r63, 0x0, L1254
L1253:
	jnzx	0, 8, r45, 0x0, L1263
L1254:
	or	[0xB46], 0x0, r33
	jle	[0xB40], r33, L1256
	jzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L1263
	je	[0xB0C], 0x0, L1255
	je	[0xB14], 0x0, L1256
	jles	r57, [0xB0D], L1263
	jles	r57, [0xB38], L1263
L1255:
	je	[0xB1F], 0x0, L1263
L1256:
	jnzx	2, 8, [0x788], 0x0, L1257
	jzx	0, 6, r20, 0x0, L1259
	jmp	L1258
L1257:
	srx	2, 8, [0x788], 0x0, r38
	sr	[0x73A], r38, r38
	jzx	0, 0, r38, 0x0, L1259
L1258:
	or	[0xB47], 0x0, [0xB0D]
	jmp	L1285
L1259:
	mov	0x52, r18
	mov	0xFFFF, SPR_TME_MASK12
	mov	0x48, SPR_TME_VAL12
	orx	0, 12, r34, SPR_TME_VAL12, SPR_TME_VAL12
	orx	0, 8, 0x1, SPR_TME_VAL12, SPR_TME_VAL12
	je	[0xB21], 0x0, L1260
	orx	0, 11, 0x1, SPR_TME_VAL12, SPR_TME_VAL12
L1260:
	mov	0x1C, r2
	calls	L1276
	or	[0x03,off2], 0x0, SPR_TME_VAL14
	jnzx	0, 7, [0xB6E], 0x0, L1261
	jnzx	0, 6, [0xBA4], 0x0, L1262
L1261:
	add	SPR_TME_VAL14, [0xB3F], SPR_TME_VAL14
L1262:
	mov	0x0, SPR_TME_VAL34
	add	[0xB21], 0x1, [0xB21]
	mov	0x4C03, r38
	jmp	L1270
L1263:
	jnzx	0, 1, r45, 0x0, L1273
	mov	0x844, SPR_TME_VAL18
	calls	L135
	or	r51, 0x0, SPR_TME_VAL14
	jzx	0, 15, r44, 0x0, L1264
	sub	[0xB19], SPR_TSF_WORD0, r35
	jge	r35, SPR_TME_VAL14, L1264
	or	r35, 0x0, SPR_TME_VAL14
L1264:
	jnzx	0, 1, [0xB6F], 0x0, L1265
	je	[0xB0C], 0x0, L1265
	or	[0xB1C], 0x0, SPR_TME_VAL14
	jnzx	0, 0, SPR_BTCX_Stat, 0x0, L1265
	jls	r57, 0x0, L1265
	add	r57, [0xB1C], SPR_TME_VAL14
L1265:
	jnzx	0, 7, [0xB6E], 0x0, L1269
	jzx	0, 6, [0xBA4], 0x0, L1269
	jnzx	0, 15, [0xBA5], 0x0, L1266
	jzx	0, 5, [0xB9B], 0x0, L1267
	mul	[0xBCA], 0x3E8, r33
	add	SPR_PSM_0x5a, [0xB9F], r33
	sub	r33, SPR_TSF_WORD0, SPR_TME_VAL14
	jgs	SPR_TME_VAL14, 0x0, L1266
	mov	0x3E8, SPR_TME_VAL14
L1266:
	jzx	0, 15, [0xBA5], 0x0, L1269
L1267:
	jdpz	SPR_TSF_WORD0, [0xBBA], L1268
	sub	[0xBBA], SPR_TSF_WORD0, SPR_TME_VAL14
	jmp	L1269
L1268:
	mov	0x14, SPR_TME_VAL14
	add	SPR_TSF_WORD0, 0x14, [0xBBA]
L1269:
	mov	0xE, r2
	calls	L1276
	mov	0x4001, r38
	jmp	L1270
L1270:
	orx	1, 0, r1, [SHM_TXFIFO_SIZE01], SPR_TXE0_PHY_CTL
	calls	L1004
	jne	r18, 0x52, L1271
	orx	1, 0, [0x864], SPR_TXE0_PHY_CTL, r1
	calls	L1025
	sl	r33, 0x3, SPR_TXE0_TIMEOUT
	jmp	L1272
L1271:
	orx	2, 0, 0x2, SPR_BRC, SPR_BRC
L1272:
	orx	0, 0, 0x1, r45, r45
	or	r38, 0x0, SPR_TXE0_CTL
	jzx	0, 6, [0xBA4], 0x0, L1273
	jzx	0, 10, [0xBA5], 0x0, L1273
	je	[0xBB9], 0x0, L1273
	jdn	[0xBB9], SPR_TSF_WORD0, L1273
	jnzx	0, 12, SPR_RXE_0x1a, 0x0, L1273
	mov	0x4007, SPR_TXE0_CTL
	jmp	L1273
L1273:
	rets
L1274:
	jnzx	0, 12, r63, 0x0, L1275
	jnzx	0, 14, r63, 0x0, L1275
	jzx	0, 3, [SHM_HOST_FLAGS3], 0x0, L1285
	jzx	0, 9, [SHM_HOST_FLAGS3], 0x0, L1285
L1275:
	orx	0, 12, 0x0, r63, r63
	jnzx	0, 1, SPR_AQM_FIFO_Ready, 0x0, L1286
	jzx	0, 14, r63, 0x0, L1286
	mov	0x0, r34
	jmp	L1248
L1276:
	jnzx	0, 6, [0xBA4], 0x0, L1277
	jnzx	0, 7, r63, 0x0, L1280
L1277:
	je	r18, 0x31, L1278
	or	[0xB33], 0x0, r33
	jge	[0xB21], r33, L1280
	mov	0x9, r0
	or	[0xB34], 0x0, r33
	jl	[0xB21], r33, L1279
L1278:
	jnzx	0, 2, [0xB5A], 0x0, L1279
	mov	0xB, r0
L1279:
	mov	0x1, r1
	calls	L72
	orx	10, 5, r2, [0x01,off2], SPR_TX_PLCP_HT_Sig0
	or	[0x02,off2], 0x0, SPR_TX_PLCP_HT_Sig1
	jmp	L1281
L1280:
	jnzx	0, 1, [0xB5A], 0x0, L1278
	mov	0xA, r0
	mov	0x0, r1
	calls	L72
	or	[0x01,off2], 0x0, SPR_TX_PLCP_HT_Sig0
	sl	r2, 0x3, SPR_TX_PLCP_HT_Sig1
L1281:
	rets
L1282:
	je	[0xB22], 0x0, L1285
	jzx	0, 2, r45, 0x0, L1285
	sub	SPR_TSF_WORD0, [0xB22], r36
	jg	r36, [0xB0D], L1285
	sl	r36, 0x1, r36
	jl	r36, [0xB0D], L1285
	calls	L1301
	jmp	L1291
L1283:
	sub	SPR_TSF_WORD0, [0xB22], r36
	sl	r36, 0x1, r36
	jnzx	0, 1, [0xBA4], 0x0, L1284
	jnzx	0, 7, [0xB6E], 0x0, L1284
	jnzx	0, 6, [0xBA4], 0x0, L1285
L1284:
	calls	L1301
L1285:
	jmp	L1291
L1286:
	jnzx	0, 2, r45, 0x0, L1287
	orx	0, 14, 0x0, r63, r63
	jmp	L1291
L1287:
	jnzx	0, 7, [0xB6E], 0x0, L1288
	jnzx	0, 6, [0xBA4], 0x0, L1290
L1288:
	je	[0xB3F], 0x0, L1290
	add	SPR_TSF_WORD0, [0xB3F], [0xB39]
	je	[0xB40], 0x0, L1289
	add	SPR_TSF_WORD0, [0xB38], [0xB39]
L1289:
	rets
L1290:
	orx	0, 12, 0x1, r63, r63
	je	[0xB22], 0x0, L1291
	sub	SPR_TSF_WORD0, [0xB22], r36
	calls	L1301
L1291:
	orx	0, 0, 0x0, r45, r45
	mov	0x0, [0xB22]
	mov	0x0, [0xB39]
	mov	0x0, [0xB21]
	srx	0, 2, r45, 0x0, r33
	orx	0, 1, r33, r45, r45
	calls	L1383
	orx	0, 6, 0x0, [0xBA4], [0xBA4]
	jnzx	0, 2, r45, 0x0, L1292
	orx	0, 0, 0x1, SPR_PSM_COND, SPR_PSM_COND
	rets
L1292:
	jnzx	0, 1, [0xBA4], 0x0, L1293
	jnzx	0, 7, [0xB6E], 0x0, L1293
	jnzx	0, 0, [0xBA4], 0x0, L1296
L1293:
	jnzx	0, 15, r44, 0x0, L1296
	or	[0xB09], 0x0, r35
	jzx	0, 5, [0xB6E], 0x0, L1294
	or	[0xB11], 0x0, r35
L1294:
	jzx	0, 8, r45, 0x0, L1295
	or	[0xB08], 0x0, r35
L1295:
	add	SPR_TSF_WORD0, r35, [0xB19]
	orx	0, 15, 0x1, r44, r44
	or	SPR_TSF_WORD0, 0x0, [0xB69]
	calls	L1097
L1296:
	rets
L1297:
	jzx	0, 6, r44, 0x0, L1298
	orx	0, 6, 0x1, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
	calls	L1111
L1298:
	jzx	0, 7, SPR_BTCX_Transmit_Control, 0x0, L1299
	jnzx	0, 2, r45, 0x0, L1299
	jnzx	0, 14, r63, 0x0, L1299
	jnzx	0, 12, r63, 0x0, L1299
	jzx	0, 1, r45, 0x0, L1300
L1299:
	orx	0, 6, 0x1, SPR_BTCX_Transmit_Control, SPR_BTCX_Transmit_Control
	calls	L1098
	orx	0, 7, 0x0, [0xB6E], [0xB6E]
	orx	2, 0, 0x2, r45, r45
	mov	0x0, [0xB21]
	orx	0, 15, 0x0, r44, r44
L1300:
	rets
L1301:
	je	[0xB3C], 0x0, L1302
	or	[0xB3C], 0x0, r36
L1302:
	jl	r36, [0xB10], L1303
	or	[0xB10], 0x0, r36
L1303:
	sl	[0xB27], 0x1, r37
	sub	[0xB28], r37, [0xB28]
	sl	r36, 0x1, r36
	add	[0xB28], r36, [0xB28]
	sr	[0xB28], 0x5, [0xB27]
	or	[0xB27], 0x0, [0xB0D]
	rets
L1304:
	jzx	0, 8, [0xB6F], 0x0, L1308
L1305:
	jnzx	0, 14, SPR_PSM_0x6a, 0x0, L1305
	mov	0x1800, SPR_PSM_0x76
	mov	0x100, SPR_PSM_0x74
	mov	0x1FE0, SPR_PSM_0x6a
L1306:
	jnzx	0, 14, SPR_PSM_0x6a, 0x0, L1306
	orx	0, 8, r35, SPR_PSM_0x6c, SPR_PSM_0x6c
	orx	5, 8, 0x2F, 0xE0, SPR_PSM_0x6a
L1307:
	jnzx	0, 14, SPR_PSM_0x6a, 0x0, L1307
L1308:
	rets
L1309:
	je	[0xB58], 0x0, L1310
	or	[0xB62], 0x0, r33
	add	r33, [0xB63], r33
	jdpz	r33, SPR_TSF_WORD0, L1310
	orx	0, 9, 0x1, r63, r63
L1310:
	rets
L1311:
	jext	COND_NEED_RESPONSEFR, L1312
	jzx	0, 0, SPR_TXE0_CTL, 0x0, L1312
	calls	L826
L1312:
	orx	0, 7, 0x1, [0xB6E], [0xB6E]
	orx	2, 0, 0x4, r45, r45
	mov	0x0, [0xB21]
	or	SPR_TSF_WORD0, 0x0, [0xB22]
	rets
L1313:
	jzx	0, 9, [0xB6F], 0x0, L1315
	sub.	SPR_TSF_WORD0, [0x3FB], r30
	subc	SPR_TSF_WORD1, [0x3FC], r29
	jne	r29, 0x0, L1315
	jg	r30, 0x32, L1314
	mov	0xD00, r34
	mov	0xA0, r33
	mov	0x8000, SPR_PSM_0x6e
	mov	0x8, SPR_PSM_0x6c
	calls	L1475
	or	SPR_BTCX_CUR_RFACT_Timer, 0x0, [0xB8A]
	mov	0x8000, SPR_PSM_0x6e
	mov	0x0, SPR_PSM_0x6c
	calls	L1475
L1314:
	mov	0x7530, r33
	add.	[0x3FB], r33, [0x3FB]
	addc	[0x3FC], 0x0, [0x3FC]
L1315:
	rets
L1316:
	jnzx	0, 10, [0xB6F], 0x0, L1317
	jnzx	1, 1, [0xB89], 0x0, L1319
	jmp	L1321
L1317:
	jdn	SPR_TSF_WORD0, [0x3FD], L1321
	jnzx	0, 1, [0xB89], 0x0, L1318
	jnzx	0, 2, [0xB89], 0x0, L1319
	jnzx	0, 8, r45, 0x0, L1321
	mov	0x4B0, r51
	calls	L1311
	mov	0x2EE, r38
	orx	1, 0, 0x3, [0xB89], [0xB89]
	jmp	L1320
L1318:
	calls	L1223
	mov	0x4E2, r38
	orx	1, 1, 0x2, [0xB89], [0xB89]
	jmp	L1320
L1319:
	orx	2, 0, 0x0, [0xB89], [0xB89]
	calls	L1297
	mov	0x157C, r38
L1320:
	add	[0x3FD], r38, [0x3FD]
L1321:
	rets
L1322:
	jzx	0, 0, [0xBA5], 0x0, L1324
	mov	0x0, r36
	calls	L1370
	jzx	0, 15, [0xBA5], 0x0, L1323
	orx	1, 0, 0x3, SPR_IFS_0x54, SPR_IFS_0x54
L1323:
	add	SPR_TSF_WORD0, [0xBAE], [0xBAD]
L1324:
	rets
L1325:
	jzx	0, 0, [0xBA5], 0x0, L1369
	jzx	0, 10, [0xBA4], 0x0, L1332
	je	[0xB90], 0x0, L1328
	je	[0xB8D], 0x0, L1326
	jdn	SPR_TSF_WORD0, [0xB8D], L1327
L1326:
	add	SPR_TSF_WORD0, [0xB8F], [0xB8D]
	mov	0xD00, r34
	mov	0xA0, r33
	mov	0x8000, SPR_PSM_0x6e
	or	[0xB8E], 0x0, SPR_PSM_0x6c
	calls	L1475
	add	[0xBA0], 0x1, [0xBA0]
	sub	[0xB90], 0x1, [0xB90]
L1327:
	jmp	L1369
L1328:
	mov	0xC00, r34
	mov	0x14, r33
	calls	L1473
	jzx	0, 14, SPR_PSM_0x6c, 0x0, L1331
	mov	0xD00, r34
	mov	0xDC, r33
	calls	L1473
	srx	0, 12, SPR_PSM_0x6c, 0x0, r36
	srx	7, 0, SPR_PSM_0x6c, 0x0, r35
	add	[0xBC0], 0x1, [0xBC0]
	jzx	0, 15, [0xB8E], 0x0, L1330
	srx	7, 0, [0xB8E], 0x0, r36
	je	r36, r35, L1329
	add	[0xBBE], 0x1, [0xBBE]
L1329:
	jmp	L1369
L1330:
	mov	0xD00, r34
	mov	0xA0, r33
	calls	L1473
	jnzx	0, 15, SPR_PSM_0x6e, 0x0, L1330
	mov	0xA0, r33
	mov	0x8000, SPR_PSM_0x6e
	or	r35, 0x0, SPR_PSM_0x6c
	calls	L1475
	add	[0xBA0], 0x1, [0xBA0]
	mov	0xDC, r33
	calls	L1473
	srx	0, 12, SPR_PSM_0x6c, 0x0, r36
	srx	7, 0, SPR_PSM_0x6c, 0x0, r35
	je	r36, 0x0, L1331
	add	[0xBC0], 0x1, [0xBC0]
	jmp	L1330
L1331:
	jmp	L1369
L1332:
	je	[0xBA1], 0x0, L1333
	jnand	[0xBA4], 0x41, L1333
	orx	0, 1, 0x1, [0xBA4], [0xBA4]
	or	SPR_TSF_WORD0, 0x0, r34
	srx	15, 10, r34, SPR_TSF_WORD1, r35
	jdn	r35, [0xBA1], L1369
	orx	0, 1, 0x0, [0xBA4], [0xBA4]
	mov	0x0, [0xBA1]
L1333:
	mov	0xC, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, [0xBCB]
	mov	0xD, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, [0xBCC]
	mov	0xE, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, [0xBCD]
	mov	0xF, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, [0xBCE]
	jzx	0, 13, [0xBCE], 0x0, L1334
	or	SPR_TSF_WORD0, 0x0, [0xB9F]
	add	[0xBC1], 0x1, [0xBC1]
	orx	0, 1, 0x0, [0xBA4], [0xBA4]
	add	SPR_TSF_WORD0, [0xBAE], [0xBAD]
	mov	0xD00, r34
	mov	0x20, r33
	mov	0x1, SPR_PSM_0x6c
	calls	L1475
L1334:
	jnzx	0, 1, [0xB9C], 0x0, L1335
	jzx	0, 1, [0xBCB], 0x0, L1335
	add	[0xBC2], 0x1, [0xBC2]
L1335:
	jnzx	0, 2, [0xB9C], 0x0, L1336
	jzx	0, 2, [0xBCB], 0x0, L1336
	add	[0xBC3], 0x1, [0xBC3]
L1336:
	or	[0xBCB], 0x0, r33
	je	[0xB9C], r33, L1337
	orx	0, 1, 0x0, [0xBA4], [0xBA4]
	add	SPR_TSF_WORD0, [0xBAE], [0xBAD]
	or	[0xBCB], 0x0, [0xB9C]
L1337:
	jnzx	0, 15, [0xBA5], 0x0, L1348
	jzx	0, 15, [0xBBD], 0x0, L1338
	orx	0, 15, 0x0, [0xBBD], [0xBBD]
	or	[0xBBD], 0x0, r35
	calls	L1373
L1338:
	srx	7, 0, [0xBCE], 0x0, r33
	je	[0xB95], r33, L1347
	srx	7, 0, r33, 0x0, [0xB95]
	srx	2, 0, [0xB95], 0x0, r33
	jne	r33, 0x6, L1342
	add	[0xBC4], 0x1, [0xBC4]
	srx	4, 3, [0xB95], 0x0, r33
	orx	0, 5, 0x1, [0xB9B], [0xB9B]
	add	r33, 0x1, [0xBCA]
	mul	r33, 0x3E8, r34
	add	SPR_PSM_0x5a, [0xB9F], r34
	jdn	SPR_TSF_WORD0, r34, L1339
	mov	0x2710, r35
	add	r34, r35, r34
L1339:
	jzx	0, 10, [0xBA5], 0x0, L1340
	add	r34, 0x3E8, [0xBBA]
	jmp	L1341
L1340:
	add	r34, 0x3E8, [0xBAA]
L1341:
	jne	[0xBA9], 0x0, L1347
	add	[0xBBC], r34, [0xBA9]
	or	[0xBB4], 0x0, r34
	sub	[0xBA9], r34, [0xBA9]
	jmp	L1347
L1342:
	jne	r33, 0x3, L1345
	srx	4, 3, [0xB95], 0x0, r33
	jne	r33, 0x0, L1343
	nand	[0xBA4], 0x202, [0xBA4]
	jmp	L1347
L1343:
	jne	r33, 0x1F, L1344
	or	[0xBA4], 0x202, [0xBA4]
	jmp	L1347
L1344:
	mul	r33, 0x5, r33
	sub	SPR_PSM_0x5a, 0x3, r33
	or	SPR_TSF_WORD0, 0x0, r34
	srx	15, 10, r34, SPR_TSF_WORD1, r35
	add	r35, r33, [0xBA1]
	jmp	L1347
L1345:
	jne	r33, 0x7, L1347
	srx	4, 3, [0xB95], 0x0, r33
	srx	0, 13, [0xBA4], 0x0, r34
	orx	0, 13, r33, [0xBA4], [0xBA4]
	mov	0x0, [0xB93]
	jnzx	0, 14, [0xBA4], 0x0, L1346
	je	r33, r34, L1347
L1346:
	mov	0x80, SPR_MAC_IRQHI
	orx	0, 14, 0x0, [0xBA4], [0xBA4]
L1347:
	jnzx	0, 0, [0xBA4], 0x0, L1348
	jnzx	0, 9, [0xBA4], 0x0, L1369
L1348:
	je	[0xBA6], 0x0, L1349
	or	[0xBA8], 0x0, r34
	sub	[0xBA6], r34, r33
	jdn	SPR_TSF_WORD0, r33, L1349
	orx	0, 2, 0x1, [0xBA4], [0xBA4]
	mov	0x0, [0xBA6]
L1349:
	jzx	0, 10, [0xBA5], 0x0, L1356
	jnzx	0, 5, [0xB9B], 0x0, L1350
	jnzx	0, 2, [0xBCB], 0x0, L1350
	calls	L1387
	nand	[0xBA4], 0x41, [0xBA4]
	mov	0x0, [0xBB9]
	mov	0x0, [0xBBA]
	mov	0x0, [0xBA9]
L1350:
	jzx	0, 2, [0xBCB], 0x0, L1355
	jnzx	0, 3, [0xBA4], 0x0, L1351
	orx	0, 3, 0x1, [0xBA4], [0xBA4]
	add	SPR_TSF_WORD0, [0xBAB], [0xBA6]
	jnzx	0, 5, [0xB9B], 0x0, L1363
	add	SPR_TSF_WORD0, [0xBA8], r33
	add	[0xBAB], r33, [0xBBA]
	add	[0xBBA], 0x3E8, [0xBBA]
	add	r33, [0xBAB], [0xBBB]
	add	SPR_TSF_WORD0, [0xBAC], [0xBA9]
	calls	L1387
L1351:
	jnzx	0, 5, [0xB9B], 0x0, L1363
	jdn	SPR_TSF_WORD0, [0xBBB], L1363
	add	SPR_TSF_WORD0, 0x3E8, [0xBBB]
	jzx	0, 2, [0xBA4], 0x0, L1352
	add	SPR_TSF_WORD0, [0xBA8], [0xBBA]
	add	[0xBBA], 0x3E8, [0xBBA]
	jmp	L1353
L1352:
	add	SPR_TSF_WORD0, [0xBAB], [0xBBA]
	add	[0xBBA], 0x3E8, [0xBBA]
L1353:
	calls	L1387
	je	[0xBA9], 0x0, L1354
	jdn	SPR_TSF_WORD0, [0xBA9], L1363
L1354:
	or	SPR_TSF_WORD0, 0x0, [0xBA9]
	jmp	L1363
L1355:
	jzx	0, 3, [0xBA4], 0x0, L1363
	orx	0, 2, 0x0, [0xBA4], [0xBA4]
	orx	0, 5, 0x0, [0xB9B], [0xB9B]
	orx	0, 3, 0x0, [0xBA4], [0xBA4]
	jmp	L1363
L1356:
	je	[0xBAA], 0x0, L1358
	je	[0xBA9], 0x0, L1358
	jdn	SPR_TSF_WORD0, [0xBAA], L1358
	jdn	SPR_TSF_WORD0, [0xBA9], L1358
	or	[0xBAA], 0x0, r33
	jdn	[0xBA9], r33, L1357
	mov	0x0, [0xBAA]
	jmp	L1358
L1357:
	mov	0x0, [0xBA9]
L1358:
	jzx	0, 2, [0xBCB], 0x0, L1361
	jnzx	0, 3, [0xBA4], 0x0, L1363
	add	SPR_TSF_WORD0, [0xBAB], [0xBA6]
	jnzx	0, 5, [0xB9B], 0x0, L1360
	je	[0xBAA], 0x0, L1359
	sub	SPR_TSF_WORD0, [0xBAA], r33
	add	[0xBA8], 0x3E8, r34
	jl	r33, [0xBA8], L1359
	jdp	r33, r34, L1359
	mov	0x0, [0xBAA]
L1359:
	jne	[0xBA9], 0x0, L1360
	add	SPR_TSF_WORD0, [0xBAC], [0xBA9]
L1360:
	orx	0, 3, 0x1, [0xBA4], [0xBA4]
	jmp	L1363
L1361:
	jzx	0, 3, [0xBA4], 0x0, L1363
	orx	0, 2, 0x0, [0xBA4], [0xBA4]
	jnzx	0, 5, [0xB9B], 0x0, L1362
	jne	[0xBAA], 0x0, L1362
	or	SPR_TSF_WORD0, 0x0, [0xBAA]
L1362:
	orx	0, 3, 0x0, [0xBA4], [0xBA4]
L1363:
	jzx	0, 3, [0xBA5], 0x0, L1364
	jzx	0, 1, [0xBCB], 0x0, L1364
	jnzx	0, 2, [0xBA4], 0x0, L1366
L1364:
	jnzx	0, 4, [0xBA5], 0x0, L1365
	jnzx	0, 1, [0xBCB], 0x0, L1366
L1365:
	jzx	0, 1, r20, 0x0, L1369
	calls	L1381
	jmp	L1369
L1366:
	jnzx	0, 1, r20, 0x0, L1369
	jnzx	0, 5, [0xBA5], 0x0, L1369
	jnzx	0, 4, [0xBA4], 0x0, L1369
	srx	1, 0, r18, 0x0, r33
	je	r33, 0x1, L1369
	je	r18, 0x12, L1369
	jzx	0, 0, SPR_TXE0_CTL, 0x0, L1367
	jnzx	0, 7, SPR_TXE0_STATUS, 0x0, L1367
	orx	0, 0, 0x0, SPR_TXE0_CTL, SPR_TXE0_CTL
	jmp	L1369
L1367:
	jzx	0, 8, SPR_IFS_STAT, 0x0, L1369
	je	r18, 0x14, L1369
	srx	1, 0, [0x00,off6], 0x0, r33
	je	r33, 0x0, L1369
	orx	0, 4, 0x1, r44, r44
	jnext	0x35, L1368
	jne	r18, 0x20, L1368
	nand	SPR_BRC, 0x1, SPR_BRC
L1368:
	calls	L1382
L1369:
	rets
L1370:
	jzx	0, 15, [0xBA5], 0x0, L1371
	orx	0, 7, r36, SPR_IFS_0x58, SPR_IFS_0x58
L1371:
	orx	0, 4, r36, [0xBA4], [0xBA4]
	jnzx	0, 15, [0xBA5], 0x0, L1372
	mov	0x40, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	SPR_BTCX_ECI_Data, 0x0, r35
	orx	0, 4, r36, r35, r35
	mov	0xC0, SPR_BTCX_ECI_Address
	or	SPR_BTCX_ECI_Address, 0x0, 0x0
	or	r35, 0x0, SPR_BTCX_ECI_Data
L1372:
	rets
L1373:
	mov	0xD00, r34
	mov	0xA0, r33
	calls	L1473
	jnzx	0, 15, SPR_PSM_0x6e, 0x0, L1373
	mov	0xA0, r33
	mov	0x8000, SPR_PSM_0x6e
	or	r35, 0x0, SPR_PSM_0x6c
	calls	L1475
	rets
L1374:
	jzx	0, 0, [0xBA5], 0x0, L1375
	jzx	0, 4, [0xBA4], 0x0, L1375
	mov	0x0, r36
	calls	L1370
L1375:
	rets
L1376:
	jzx	0, 0, [0xBA5], 0x0, L1380
	jnzx	0, 1, [0xBA4], 0x0, L1380
	jnzx	0, 5, [0xBA5], 0x0, L1380
	jzx	0, 3, [0xBA5], 0x0, L1377
	jzx	0, 1, [0xBCB], 0x0, L1377
	jnzx	0, 2, [0xBA4], 0x0, L1378
L1377:
	jnzx	0, 4, [0xBA5], 0x0, L1380
	jzx	0, 1, [0xBCB], 0x0, L1380
L1378:
	jnzx	0, 4, [0xBA4], 0x0, L1380
	jnzx	0, 5, [0xBA4], 0x0, L1380
	jext	COND_NEED_RESPONSEFR, L1380
	jnext	0x35, L1379
	je	r18, 0x14, L1380
L1379:
	orx	0, 0, 0x0, SPR_TXE0_CTL, SPR_TXE0_CTL
	jmp	L0
L1380:
	rets
L1381:
	orx	0, 1, 0x0, r20, r20
	jmp	L1037
L1382:
	orx	0, 1, 0x1, r20, r20
	jmp	L1037
L1383:
	jzx	0, 0, [0xBA5], 0x0, L1388
	jzx	0, 10, [0xBA5], 0x0, L1384
	jzx	0, 6, [0xBA4], 0x0, L1388
	sub	[0xBBA], SPR_TSF_WORD0, r33
	add	SPR_TSF_WORD0, r33, [0xBB9]
	mov	0x0, [0xBA9]
	calls	L1387
	rets
L1384:
	jzx	0, 6, [0xBA4], 0x0, L1386
	jzx	0, 0, [0xBA4], 0x0, L1385
	mov	0x0, [0xBA9]
	rets
L1385:
	mov	0x0, [0xBAA]
L1386:
	rets
L1387:
	jnzx	0, 9, [0xBA5], 0x0, L1388
	jnzx	0, 7, [0xB6E], 0x0, L1388
	jnzx	0, 0, r45, 0x0, L1388
	jnzx	0, 12, r63, 0x0, L1388
	orx	0, 1, 0x0, r45, r45
	orx	0, 2, 0x0, r45, r45
L1388:
	rets
L1389:
	orx	0, 0, 0x1, [0xBA4], [0xBA4]
	orx	0, 6, 0x1, [0xBA4], [0xBA4]
	orx	2, 0, 0x4, r45, r45
	mov	0x0, [0xB21]
	rets
L1390:
	orx	0, 0, 0x0, [0xBA4], [0xBA4]
	orx	0, 6, 0x1, [0xBA4], [0xBA4]
	orx	2, 0, 0x2, r45, r45
	mov	0x0, [0xB21]
	rets
L1391:
	mov	0x0, SPR_AQM_BASSN
	mov	0x0, SPR_AQM_REFSN
	mov	0xFFFF, SPR_AQM_RCVD_BA0
	mov	0xFFFF, SPR_AQM_RCVD_BA1
	mov	0xFFFF, SPR_AQM_RCVD_BA2
	mov	0xFFFF, SPR_AQM_RCVD_BA3
	orx	0, 7, 0x1, SPR_TXE0_FIFO_PRI_RDY, SPR_TXE0_FIFO_PRI_RDY
	or	SPR_TXE0_FIFO_PRI_RDY, 0x0, 0x0
L1392:
	jnzx	0, 7, SPR_TXE0_FIFO_PRI_RDY, 0x0, L1392
	rets
L1393:
	jext	COND_PSM(1), L1394
	mov	0x1, SPR_AQM_RCVD_BA0
	mov	0x0, SPR_AQM_BASSN
	mov	0x0, SPR_AQM_REFSN
	mov	0x0, SPR_AQM_Max_IDX
	jmp	L1395
L1394:
	or	[0x0D,off1], 0x0, SPR_AQM_RCVD_BA0
	or	[0x0E,off1], 0x0, SPR_AQM_RCVD_BA1
	or	[0x0F,off1], 0x0, SPR_AQM_RCVD_BA2
	or	[0x10,off1], 0x0, SPR_AQM_RCVD_BA3
	sr	[0x0C,off1], 0x4, SPR_AQM_BASSN
	sr	[0x07,off0], 0x4, SPR_AQM_REFSN
	or	[0x1B,off0], 0x0, SPR_AQM_Max_IDX
L1395:
	orx	0, 7, 0x1, SPR_TXE0_FIFO_PRI_RDY, SPR_TXE0_FIFO_PRI_RDY
	jnzx	0, 3, SPR_TXE0_PHY_CTL, 0x0, L1396
	js	0x180, [0x0A,off0], L1396
	orx	1, 9, 0x1, [0x0A,off0], [0x0A,off0]
	jges	r62, [0x0CA], L1396
	orx	0, 10, 0x1, [0x0A,off0], [0x0A,off0]
L1396:
	or	r7, 0x0, r35
	jzx	0, 8, [SHM_HOST_FLAGS1], 0x0, L1397
	add	0x180, [SHM_TXFCUR], SPR_BASE4
	jg	SPR_BASE4, 0x183, L1397
	srx	3, 8, [0x00,off4], 0x0, r35
L1397:
	jnzx	0, 7, SPR_TXE0_FIFO_PRI_RDY, 0x0, L1397
	jzx	0, 1, [0x02,off0], 0x0, L1398
	add	[0x16,off0], SPR_AQM_ACK_Control, [0x16,off0]
	jmp	L1400
L1398:
	srx	1, 4, [0x0B,off0], 0x0, r33
	add	SPR_BASE0, r33, SPR_BASE5
	srx	7, 8, [0x15,off5], 0x0, r33
	add	r33, SPR_AQM_ACK_Control, r33
	jle	r33, 0xFF, L1399
	mov	0xFF, r33
L1399:
	orx	7, 8, r33, [0x15,off5], [0x15,off5]
L1400:
	jge	r11, r35, L449
	mov	0x0, [0x14,off0]
	jnzx	0, 0, SPR_AQM_Upd_BA0, 0x0, L449
	jl	r11, [0x1C,off0], L504
	calls	L917
	jmp	L504
L1401:
	mov	0xFFFF, SPR_AQM_Max_Agg_Len_Low
	mov	0x0, SPR_AQM_Max_Agg_Len_High
	jnzx	0, 3, [0x0A,off0], 0x0, L1402
	mov	0xFC0, SPR_AQM_Agg_Params
	mov	0x0, SPR_AQM_Min_MPDU_Length
	jmp	L1415
L1402:
	srx	7, 0, [0x6A3], 0x0, r33
	jzx	1, 4, [0x0B,off0], 0x0, L1403
	srx	7, 8, [0x6A3], 0x0, r33
L1403:
	srx	9, 0, SPR_TXE0_FIFO_Frame_Count, 0x0, r34
	jg	r34, r33, L1404
	or	r34, 0x0, r33
L1404:
	sub	r33, 0x1, r33
	orx	5, 6, [0x6A5], r33, SPR_AQM_Agg_Params
	sr	SPR_TSF_0x2a, 0x4, r34
	jext	0x15, L1405
	mov	0xFFFF, r34
L1405:
	srx	11, 4, [0x6A4], 0x0, r33
	jge	r34, r33, L1406
	or	r34, 0x0, r33
L1406:
	jzx	0, 8, [0xB5A], 0x0, L1408
	je	[0xCAE], 0x0, L1408
	jzx	0, 8, r45, 0x0, L1408
	sub	[0xCAE], SPR_TSF_WORD0, r59
	je	[0xB74], 0x0, L1407
	jle	r59, [0xB74], L5
	sub	r59, [0xB74], r59
L1407:
	sr	r59, 0x4, r59
	jges	r59, r33, L1408
	or	r59, 0x0, r33
L1408:
	mul	r33, r40, r33
	jzx	7, 8, [0x6A5], 0x0, L1410
	srx	7, 8, [0x6A5], 0x0, r34
	mov	0x0, r35
	jzx	3, 12, [0x6A5], 0x0, L1409
	sub	r34, 0x10, r35
	sl	0x1, r35, r35
L1409:
	sl	0x1, r34, r34
	sub.	r34, 0x1, r34
	subc	r35, 0x0, r35
	jl	r33, r35, L1410
	jg	r33, r35, L1411
	jg	SPR_PSM_0x5a, r34, L1411
L1410:
	or	r33, 0x0, r35
	or	SPR_PSM_0x5a, 0x0, r34
L1411:
	jzx	0, 0, [0x00,off6], 0x0, L1412
	mov	0xF, SPR_AQM_Max_Agg_Len_High
	jg	r35, 0xF, L1414
	or	r35, 0x0, SPR_AQM_Max_Agg_Len_High
	jmp	L1413
L1412:
	jne	r35, 0x0, L1414
L1413:
	or	r34, 0x0, SPR_AQM_Max_Agg_Len_Low
L1414:
	jzx	3, 0, [0x6A4], 0x0, L1415
	srx	3, 0, [0x6A4], 0x0, r33
	sub	0x7, r33, r33
	sr	r40, r33, r33
	add	r33, 0x3, r33
	nand	r33, 0x3, SPR_AQM_Min_MPDU_Length
L1415:
	or	[0x1F,off0], 0x0, SPR_AQM_MAC_Adj_Length
	jzx	0, 13, [0x01,off0], 0x0, L1416
	add	SPR_AQM_MAC_Adj_Length, 0x8, SPR_AQM_MAC_Adj_Length
L1416:
	srx	7, 8, [0x04,off0], 0x0, r33
	jzx	0, 0, [0x01,off0], 0x0, L1417
	add	SPR_AQM_MAC_Adj_Length, r33, SPR_AQM_MAC_Adj_Length
L1417:
	orx	0, 9, 0x1, SPR_TXE0_FIFO_PRI_RDY, SPR_TXE0_FIFO_PRI_RDY
L1418:
	jnzx	0, 9, SPR_TXE0_FIFO_PRI_RDY, 0x0, L1418
	srx	5, 7, SPR_AQM_Agg_Stats, 0x0, r33
	jle	r33, [0x1B,off0], L1419
	or	r33, 0x0, [0x1B,off0]
L1419:
	jzx	0, 3, [0x0A,off0], 0x0, L1420
	srx	2, 13, SPR_AQM_Agg_Stats, 0x0, r33
	mov	0xC12, SPR_BASE4
	add	SPR_BASE4, r33, SPR_BASE4
	add	[0x00,off4], 0x1, [0x00,off4]
L1420:
	rets
L1421:
	mov	0x20, SPR_PMQ_dat
	jnzx	0, 0, SPR_PMQ_control_high, 0x0, L1422
	or	[0x6B0], 0x0, SPR_PMQ_pat_0
	or	[0x6B1], 0x0, SPR_PMQ_pat_1
	or	[0x6B2], 0x0, SPR_PMQ_pat_2
	mov	0x2, SPR_PMQ_control_low
	mov	0x40, SPR_MAC_IRQLO
L1422:
	rets
L1423:
	srx	13, 0, 0x0, 0x0, SPR_RXE_0x54
	mov	0x14, SPR_RXE_FIFOCTL1
	or	SPR_RXE_FIFOCTL1, 0x0, 0x0
	mov	0x110, SPR_RXE_FIFOCTL1
	or	SPR_RXE_FIFOCTL1, 0x0, 0x0
	orx	1, 2, 0x0, SPR_PSM_COND, SPR_PSM_COND
	rets
L1424:
	orx	0, 6, 0x1, SPR_PSM_0x70, SPR_PSM_0x70
	or	SPR_PSM_0x70, 0x0, 0x0
	or	SPR_TSF_WORD0, 0x0, r33
L1425:
	je	r33, SPR_TSF_WORD0, L1425
	orx	0, 0, 0x1, spr397, spr397
	orx	0, 2, 0x0, spr397, spr397
	or	SPR_PHY_HDR_Parameter, 0x0, 0x0
	jext	EOI(COND_TX_DONE), L1426
L1426:
	mov	0x0, [0x3CA]
	jne	[0x3C9], 0x0, L1427
	mov	0xC000, SPR_TSF_GPT2_STAT
L1427:
	rets
L1428:
	mov	0x3EB, SPR_BASE4
	jges	r62, [0x0C5], L1429
	add	SPR_BASE4, 0x1, SPR_BASE4
	jges	r62, [0x0C6], L1429
	add	SPR_BASE4, 0x1, SPR_BASE4
L1429:
	add	[0x00,off4], 0x1, [0x00,off4]
	rets
L1430:
	or	r33, 0x0, r35
	or	r34, 0x0, SPR_BASE4
L1431:
	or	[0x00,off4], 0x0, r33
	or	[0x01,off4], 0x0, r34
	calls	L68
	add	SPR_BASE4, 0x2, SPR_BASE4
	sub	r35, 0x1, r35
	jne	r35, 0x0, L1431
	rets
L1432:
	or	r33, 0x0, r35
	or	r34, 0x0, SPR_BASE4
L1433:
	or	[0x00,off4], 0x0, r0
	or	[0x01,off4], 0x0, r1
	calls	L1036
	add	SPR_BASE4, 0x2, SPR_BASE4
	sub	r35, 0x1, r35
	jne	r35, 0x0, L1433
	rets
L1434:
	mov	0x19E, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x3, r34
	calls	L68
	jzx	0, 0, [0x3CF], 0x0, L1435
	calls	L1461
L1435:
	mov	0x3CB, SPR_BASE2
	mov	0x0, r36
	mov	0x7, SPR_TXE0_FIFO_PRI_RDY
	srx	8, 8, [0x3D0], 0x3, SPR_TXE0_FIFO_Head
	srx	7, 0, [0x3D0], 0x0, SPR_TXE0_FIFO_Read_Pointer
L1436:
	or	[0x00,off2], 0x0, r37
	je	r37, 0x0, L1452
	mov	0x0, r59
L1437:
	mov	0xFB0, SPR_TXE0_AGGFIFO_CMD
	or	[0x00A], 0x0, r38
	jg	r37, [0x00A], L1438
	or	r37, 0x0, r38
L1438:
	or	r38, 0x0, SPR_TXE0_FIFO_Write_Pointer
	orx	0, 15, 0x1, SPR_TXE0_FIFO_Head, SPR_TXE0_FIFO_Head
L1439:
	jnext	0x18, L1439
L1440:
	jext	0x18, L1440
	je	r36, 0x1, L1442
	je	r36, 0x2, L1442
	sr	r38, 0x2, r33
	mov	0x7D8, r34
	jne	r36, 0x0, L1441
	calls	L1432
	jne	r36, 0x3, L1451
L1441:
	calls	L1430
	jmp	L1451
L1442:
	mov	0x7D8, SPR_BASE4
	or	r38, 0x0, [0x3D1]
L1443:
	jne	r59, 0x0, L1444
	mov	0xD, r33
	srx	5, 10, [0x00,off4], 0x0, r34
	calls	L68
	mov	0xE, r33
	srx	9, 0, [0x00,off4], 0x0, r34
	calls	L68
	or	[0x01,off4], 0x0, r59
	add	SPR_BASE4, 0x2, SPR_BASE4
	sub	r38, 0x4, r38
	je	r38, 0x0, L1450
L1444:
	sr	r38, 0x1, r33
	je	r36, 0x1, L1445
	sr	r38, 0x2, r33
L1445:
	jle	r33, r59, L1446
	or	r59, 0x0, r33
L1446:
	sub	r59, r33, r59
	sl	r33, 0x1, r35
	je	r36, 0x1, L1447
	sl	r33, 0x2, r35
L1447:
	sub	r38, r35, r38
	je	r36, 0x2, L1448
	calls	L1453
	jmp	L1449
L1448:
	calls	L1456
L1449:
	jne	r38, 0x0, L1443
L1450:
	or	[0x3D1], 0x0, r38
L1451:
	sub	r37, r38, r37
	orx	0, 9, 0x1, SPR_TXE0_FIFO_Head, SPR_TXE0_FIFO_Head
	mov	0x0, SPR_TXE0_FIFO_Read_Pointer
	jne	r37, 0x0, L1437
	jne	r36, 0x0, L1452
	calls	L1460
L1452:
	add	SPR_BASE2, 0x1, SPR_BASE2
	add	r36, 0x1, r36
	jl	r36, 0x4, L1436
	mov	0x0, [0x3D0]
	mov	0x19E, r33
	calls	L66
	nand	SPR_Ext_IHR_Data, 0x3, r34
	calls	L68
	rets
L1453:
	je	r33, 0x0, L1455
	add	SPR_BASE4, r33, r33
L1454:
	jnzx	0, 14, SPR_Ext_IHR_Address, 0x0, L1454
	or	[0x00,off4], 0x0, SPR_Ext_IHR_Data
	add	SPR_BASE4, 0x1, SPR_BASE4
	orx	1, 13, 0x2, 0xF, SPR_Ext_IHR_Address
	jne	SPR_BASE4, r33, L1454
	jzx	0, 0, SPR_BASE4, 0x0, L1455
	add	SPR_BASE4, 0x1, SPR_BASE4
	sub	r38, 0x2, r38
L1455:
	rets
L1456:
	je	r33, 0x0, L1459
	sl	r33, 0x1, r33
	add	SPR_BASE4, r33, r33
L1457:
	jnzx	0, 14, SPR_Ext_IHR_Address, 0x0, L1457
	or	[0x01,off4], 0x0, SPR_Ext_IHR_Data
	orx	1, 13, 0x2, 0x10, SPR_Ext_IHR_Address
L1458:
	jnzx	0, 14, SPR_Ext_IHR_Address, 0x0, L1458
	or	[0x00,off4], 0x0, SPR_Ext_IHR_Data
	add	SPR_BASE4, 0x2, SPR_BASE4
	orx	1, 13, 0x2, 0xF, SPR_Ext_IHR_Address
	jne	SPR_BASE4, r33, L1457
L1459:
	rets
L1460:
	mov	0x2B, r33
	calls	L66
	orx	0, 0, 0x0, SPR_Ext_IHR_Data, r34
	calls	L68
	mov	0x2E, r33
	calls	L66
	orx	0, 2, 0x0, SPR_Ext_IHR_Data, r34
	calls	L68
	mov	0x2E, r33
	calls	L66
	orx	0, 2, 0x1, SPR_Ext_IHR_Data, r34
	calls	L68
	mov	0x2B, r33
	calls	L66
	orx	0, 0, 0x1, SPR_Ext_IHR_Data, r34
	calls	L68
	rets
L1461:
	jzx	0, 1, [0x3CF], 0x0, L1462
	mov	0x9, r33
	calls	L66
	orx	0, 0, 0x0, SPR_Ext_IHR_Data, r34
	calls	L68
L1462:
	or	SPR_PHY_HDR_Parameter, 0x0, r35
	orx	0, 2, 0x1, SPR_PHY_HDR_Parameter, SPR_PHY_HDR_Parameter
	or	[0x055], 0x1, r33
	calls	L66
	orx	1, 14, 0x3, SPR_Ext_IHR_Data, r34
	jzx	0, 1, [0x3CF], 0x0, L1463
	orx	1, 14, 0x0, SPR_Ext_IHR_Data, r34
L1463:
	calls	L68
	or	r35, 0x0, SPR_PHY_HDR_Parameter
	jnzx	0, 1, [0x3CF], 0x0, L1464
	mov	0x9, r33
	calls	L66
	orx	0, 0, 0x1, SPR_Ext_IHR_Data, r34
	calls	L68
L1464:
	mov	0x0, [0x3CF]
	rets
L1465:
	srx	1, 0, [0xCA2], 0x0, r36
	jand	r36, 0x3, L1471
	jnzx	0, 0, SPR_BTCX_Stat, 0x0, L1471
	jnzx	0, 11, SPR_IFS_STAT, 0x0, L1471
	or	[0xCA3], 0x0, r35
	jne	r36, 0x1, L1466
	mov	0x407, r33
	calls	L66
	orx	0, 0, r35, SPR_Ext_IHR_Data, r34
	calls	L68
	jmp	L1471
L1466:
	srx	0, 7, r35, 0x0, r33
	orx	0, 2, r33, [0xCA3], [0xCA3]
	srx	0, 0, [0xCA3], 0x0, r38
	srx	3, 8, [0xCA2], 0x0, r37
	sl	0x1, r37, r37
	or	r37, 0x0, r33
	je	r38, 0x0, L1467
	or	SPR_GPIO_OUT, r37, r34
	jmp	L1468
L1467:
	nand	SPR_GPIO_OUT, r37, r34
L1468:
	jne	r36, 0x3, L1470
	srx	0, 1, [0xCA3], 0x0, r38
	srx	3, 12, [0xCA2], 0x0, r37
	sl	0x1, r37, r37
	or	r33, r37, r33
	je	r38, 0x0, L1469
	or	r34, r37, r34
	jmp	L1470
L1469:
	nand	r34, r37, r34
L1470:
	or	SPR_GPIO_OUTEN, r33, SPR_GPIO_OUTEN
	or	r34, 0x0, SPR_GPIO_OUT
L1471:
	rets
	jle	[0xCA2], 0x1, L1472
	or	[0xCA4], 0x0, r35
	mov	0x407, r33
	calls	L66
	orx	0, 0, r35, SPR_Ext_IHR_Data, r34
	calls	L68
L1472:
	rets
	jnzx	0, 0, SPR_BTCX_Stat, 0x0, L1471
L1473:
	mov	0x1800, SPR_PSM_0x76
	or	r34, 0x0, SPR_PSM_0x74
	orx	5, 8, 0x1F, r33, SPR_PSM_0x6a
L1474:
	jnzx	0, 14, SPR_PSM_0x6a, 0x0, L1474
	rets
L1475:
	mov	0x1800, SPR_PSM_0x76
	or	r34, 0x0, SPR_PSM_0x74
	orx	5, 8, 0x2F, r33, SPR_PSM_0x6a
L1476:
	jnzx	0, 14, SPR_PSM_0x6a, 0x0, L1476
	rets
L1477:
	mov	0x140, r33
	calls	L66
	orx	1, 0, 0x0, SPR_Ext_IHR_Data, r34
	calls	L68
	rets
L1478:
	mov	0x0, r36
L1479:
	jne	r36, 0x0, L1480
	srx	11, 0, [0x00,off4], 0x0, r33
	srx	3, 12, [0x00,off4], 0x0, r36
	add	SPR_BASE4, 0x1, SPR_BASE4
L1480:
	or	[0x00,off5], 0x0, r34
	add	SPR_BASE5, 0x1, SPR_BASE5
	calls	L68
	sr	r36, 0x1, r36
	jne	SPR_BASE4, r35, L1479
	rets
L1481:
	jzx	0, 9, [0xC47], 0x0, L1485
	orx	1, 4, 0x3, SPR_PHY_HDR_Parameter, SPR_PHY_HDR_Parameter
	mov	0xC4A, SPR_BASE4
	mov	0xC59, SPR_BASE5
	mov	0xC58, r35
	or	[0xC78], 0x0, r33
	calls	L66
	or	SPR_Ext_IHR_Data, 0x0, [0x08,off5]
	sub	[0xC78], 0x1, r33
	calls	L66
	jand	SPR_Ext_IHR_Data, 0x1, L1482
	srx	11, 0, [0xC71], 0x0, [0x03,off5]
L1482:
	calls	L1478
	mov	0xC72, SPR_BASE2
	mov	0x402, r33
	add	SPR_TXE0_CLCT_STRPTR, [0x00,off2], r35
	add	SPR_TSF_WORD0, 0x1E, r36
L1483:
	jdp	SPR_TSF_WORD0, r36, L1484
	jl	SPR_TXE0_CLCT_CURPTR, r35, L1483
	or	[0x01,off2], 0x0, r34
	calls	L68
	add	SPR_BASE2, 0x2, SPR_BASE2
	add	r35, [0x00,off2], r35
	jnzx	14, 0, r34, 0x0, L1483
L1484:
	mov	0xC51, SPR_BASE4
	mov	0xC59, r35
	calls	L1478
	orx	1, 4, 0x0, SPR_PHY_HDR_Parameter, SPR_PHY_HDR_Parameter
L1485:
	orx	11, 0, 0x88, [0xC47], [0xC47]
	rets
L1486:
	mov	0x0, r36
L1487:
	mov	0x5800, [0xB01]
	add	[0xB01], r36, [0xB01]
	mov	0xB01, SPR_BASE4
	calls	L1488
	add	r36, 0x1, r36
	jne	0x47, r36, L1487
	mov	0xAD9, SPR_BASE4
	calls	L1488
	mov	0xAEB, SPR_BASE4
	calls	L1488
	mov	0xAFC, SPR_BASE4
	calls	L1488
	mov	0xAD0, SPR_BASE4
	calls	L1488
	mov	0xAD3, SPR_BASE4
	calls	L1488
	mov	0xAD6, SPR_BASE4
	calls	L1488
	rets
L1488:
	mov	0xD, r33
	srx	7, 8, [0x00,off4], 0x0, r34
	calls	L68
	mov	0xE, r33
	srx	7, 0, [0x00,off4], 0x0, r34
	calls	L68
	or	[0x01,off4], 0x0, r33
	add	SPR_BASE4, 0x2, SPR_BASE4
	calls	L1453
	rets
#define	ClassifierCtrl		0x140
#define	core0_crsControlu	0x167D
#define	core0_crsControll	0x167C
#define	core0_crsControluSub1	0x167F
#define	core0_crsControllSub1	0x167E
#define	core0_computeGainInfo	0x6D4
#define	ed_crsEn		0x339
#define	BBConfig		0x1
#define	RfseqMode		0x400
enable_carrier_search:
	phy_reg_read(ClassifierCtrl, SPARE1)
	orxh	4, SPARE1 & ~0x0007, SPARE1
	phy_reg_write(ClassifierCtrl, SPARE1)
	mov	0, SPARE1
	mov	NCORES, SPARE4
luppa_core:
	mov	core0_crsControlu, SPARE2
	add	SPARE2, SPARE1, SPARE2
	phy_reg_read(SPARE2, SPARE3)
	orxh	0, SPARE3 & ~0x0010, SPARE3
	phy_reg_write(SPARE2, SPARE3)
	mov	core0_crsControll, SPARE2
	add	SPARE2, SPARE1, SPARE2
	phy_reg_read(SPARE2, SPARE3)
	orxh	0, SPARE3 & ~0x0010, SPARE3
	phy_reg_write(SPARE2, SPARE3)
	mov	core0_crsControluSub1, SPARE2
	add	SPARE2, SPARE1, SPARE2
	phy_reg_read(SPARE2, SPARE3)
	orxh	0, SPARE3 & ~0x0010, SPARE3
	phy_reg_write(SPARE2, SPARE3)
	mov	core0_crsControllSub1, SPARE2
	add	SPARE2, SPARE1, SPARE2
	phy_reg_read(SPARE2, SPARE3)
	orxh	0, SPARE3 & ~0x0010, SPARE3
	phy_reg_write(SPARE2, SPARE3)
	add	0x200, SPARE1, SPARE1
	sub	SPARE4, 1, SPARE4
	jne	SPARE4, 0, luppa_core-
	mov	0, SPARE1
	mov	NCORES, SPARE4
luppa_core:
	mov	core0_computeGainInfo, SPARE2
	add	SPARE2, SPARE1, SPARE2
	phy_reg_read(SPARE2, SPARE3)
	orxh	0x4000, SPARE3 & ~0x4000, SPARE3
	phy_reg_write(SPARE2, SPARE3)
	add	0x200, SPARE1, SPARE1
	sub	SPARE4, 1, SPARE4
	jne	SPARE4, 0, luppa_core-
	phy_reg_write(ed_crsEn, 0)
	rets
disable_carrier_search:
	phy_reg_read(ClassifierCtrl, SPARE1)
	orxh    7, SPARE1 & ~0x0007, SPARE1
	phy_reg_write(ClassifierCtrl, SPARE1)
	mov     0, SPARE1
	mov     NCORES, SPARE4
luppa_core:
	mov	core0_crsControlu, SPARE2
	add	SPARE2, SPARE1, SPARE2
	phy_reg_read(SPARE2, SPARE3)
	orxh	0x10, SPARE3 & ~0x0010, SPARE3
	phy_reg_write(SPARE2, SPARE3)
	mov     core0_crsControll, SPARE2
	add    SPARE2, SPARE1, SPARE2
	phy_reg_read(SPARE2, SPARE3)
	orxh    0x10, SPARE3 & ~0x0010, SPARE3
	phy_reg_write(SPARE2, SPARE3)
	mov	core0_crsControluSub1, SPARE2
	add	SPARE2, SPARE1, SPARE2
	phy_reg_read(SPARE2, SPARE3)
	orxh	0x10, SPARE3 & ~0x0010, SPARE3
	phy_reg_write(SPARE2, SPARE3)
	mov	core0_crsControllSub1, SPARE2
	add	SPARE2, SPARE1, SPARE2
	phy_reg_read(SPARE2, SPARE3)
	orxh	0x10, SPARE3 & ~0x0010, SPARE3
	phy_reg_write(SPARE2, SPARE3)
	add	0x200, SPARE1, SPARE1
	sub	SPARE4, 1, SPARE4
	jne	SPARE4, 0, luppa_core-
	mov	0, SPARE1
	mov	NCORES, SPARE4
luppa_core:
	mov	core0_computeGainInfo, SPARE2
	add	SPARE2, SPARE1, SPARE2
	phy_reg_read(SPARE2, SPARE3)
	orxh	0x0, SPARE3 & ~0x4000, SPARE3
	phy_reg_write(SPARE2, SPARE3)
	add	0x200, SPARE1, SPARE1
	sub	SPARE4, 1, SPARE4
	jne	SPARE4, 0, luppa_core-
	phy_reg_write(ed_crsEn, 0xfff)
	rets
	@0	@0, @0, @0
//
// Created by jlink on 26.03.19.
//
#include <jni.h>
#include "unpack_float_acphy.h"
#include <stdio.h>
#include <stdlib.h>

#define k_tof_unpack_sgn_mask (1<<31)

void unpack_float_acphy(int nbits, int autoscale, int shft,
                       int fmt, int nman, int nexp, int nfft,
                       uint32_t *H, int32_t *Hout)
{
    int e_p, maxbit, e, i, pwr_shft = 0, e_zero, sgn;
    int n_out, e_shift;
    int8_t He[256];
    int32_t vi, vq, *pOut;
    uint32_t x, iq_mask, e_mask, sgnr_mask, sgni_mask;

    iq_mask = (1<<(nman-1))- 1;
    e_mask = (1<<nexp)-1;
    e_p = (1<<(nexp-1));
    sgnr_mask = (1 << (nexp + 2*nman - 1));
    sgni_mask = (sgnr_mask >> nman);
    e_zero = -nman;
    pOut = (int32_t*)Hout;
    n_out = (nfft << 1);
    e_shift = 1;
    maxbit = -e_p;
    for (i = 0; i < nfft; i++) {
        vi = (int32_t)((H[i] >> (nexp + nman)) & iq_mask);
        vq = (int32_t)((H[i] >> nexp) & iq_mask);
        e =   (int)(H[i] & e_mask);
        if (e >= e_p)
            e -= (e_p << 1);
        He[i] = (int8_t)e;
        x = (uint32_t)vi | (uint32_t)vq;
        if (autoscale && x) {
            uint32_t m = 0xffff0000, b = 0xffff;
            int s = 16;
            while (s > 0) {
                if (x & m) {
                    e += s;
                    x >>= s;
                }
                s >>= 1;
                m = (m >> s) & b;
                b >>= s;
            }
            if (e > maxbit)
                maxbit = e;
        }
        if (H[i] & sgnr_mask)
            vi |= k_tof_unpack_sgn_mask;
        if (H[i] & sgni_mask)
            vq |= k_tof_unpack_sgn_mask;
        Hout[i<<1] = vi;
        Hout[(i<<1)+1] = vq;
    }
    shft = nbits - maxbit;
    for (i = 0; i < n_out; i++) {
        e = He[(i >> e_shift)] + shft;
        vi = *pOut;
        sgn = 1;
        if (vi & k_tof_unpack_sgn_mask) {
            sgn = -1;
            vi &= ~k_tof_unpack_sgn_mask;
        }
        if (e < e_zero) {
            vi = 0;
        } else if (e < 0) {
            e = -e;
            vi = (vi >> e);
        } else {
            vi = (vi << e);
        }
        *pOut++ = (int32_t)sgn*vi;
    }
}

JNIEXPORT jintArray JNICALL
Java_com_seemoo_mstiegler_csidatacollector6p__UnpackFloatAcphy_run(JNIEnv *env, jobject obj, jlongArray h) {
    // create native input array uint32 from java long array
    jsize len = (*env)->GetArrayLength(env, h);
    jlong *elems = (*env)->GetLongArrayElements(env, h, 0);
    uint32_t *H = calloc(len, sizeof(uint32_t));
    if (H==NULL)
        return NULL;
    int i;
    for (i = 0; i < len; i++) {
        H[i] = (uint32_t)elems[i];
    }
    // create return array
    jintArray hout = (jintArray)(*env)->NewIntArray(env,2*len);
    if (hout==NULL)
        return NULL;
    // create native return array
    int32_t *Hout = calloc(2*len, sizeof(int32_t));
    if (Hout==NULL)
        return NULL;
    // call unpack
    unpack_float_acphy(10, 1, 0, 1, 9, 5, (int)len, H, Hout);
    if (H!=NULL)
        free(H);
    (*env)->SetIntArrayRegion(env,hout,0,2*len,(jint*)Hout);
    if (Hout!=NULL)
        free(Hout);
    return hout;
}
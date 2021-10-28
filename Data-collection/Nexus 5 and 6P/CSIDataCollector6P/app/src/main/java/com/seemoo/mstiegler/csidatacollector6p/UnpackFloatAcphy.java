package com.seemoo.mstiegler.csidatacollector6p;

public class UnpackFloatAcphy {
    static {
        System.loadLibrary("unpack_float_acphy");
    }

    public native int[] run(long[] in);
}

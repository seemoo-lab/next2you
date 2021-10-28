package com.seemoo.mstiegler.csidatacollector.util;

public class NexutilConfigHolder {
    private static String chanspec;

    public static String getChanspec(){
        return chanspec;
    }

    public static void setChanspec(String chanspec){
        NexutilConfigHolder.chanspec = chanspec;
    }
}

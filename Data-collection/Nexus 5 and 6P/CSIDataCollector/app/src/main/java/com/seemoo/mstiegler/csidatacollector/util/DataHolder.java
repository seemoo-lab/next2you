package com.seemoo.mstiegler.csidatacollector.util;

public class DataHolder {
    private static boolean csiCollectionActive;
    private static boolean isSending;
    public static final String defaultChannel = "157";
    public static final String defaultBandwidth = "80";

    public static boolean isActive(){
        return csiCollectionActive;
    }

    public static void setCollectionStatus(boolean status){
        DataHolder.csiCollectionActive = status;
    }

    public static boolean isSending(){
        return isSending;
    }

    public static void setSendingStatus(boolean status){
        DataHolder.isSending = status;
    }
}

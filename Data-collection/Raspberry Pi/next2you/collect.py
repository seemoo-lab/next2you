#!/usr/bin/python3

# Jakob Link <jlink@seemoo.tu-darmstadt.de>
# nexmon.org/csi

import socket
import threading
import sys
import struct
import numpy as np
import datetime

NULL_CARRIER = {20:[0, 1, 2, 3, 32, 61, 62, 63],40:[0, 1, 2, 3, 4, 5, 63, 64, 65, 123, 124, 125, 126, 127],80:[0, 1, 2, 3, 4, 5, 127, 128, 129, 251, 252, 253, 254, 255]}

UDP_IP = "0.0.0.0"
UDP_PORT = 5500

now = datetime.datetime.now()


def unpackdata(data, lock):
    with lock:
        global now
        colocated = [9, 10, 11]
        NFFT = int((len(data) - 18) / 4)
        hwaddr = struct.unpack_from("=6B"+str(2*NFFT+8)+"x", data, offset=4)
        devid = int(hwaddr[3])
        invnum = int(hwaddr[4] * 100 + hwaddr[5])
        #print("CSI from device",devid,"(",invnum,")")
        iqs = struct.unpack("=18x"+str(2*NFFT)+"h", data)
        off = 2 if NFFT == 256 else 0
        iqv = np.array(iqs[0+off:NFFT*2:2]) + 1j*np.array(iqs[1+off:NFFT*2:2])
        iqm = np.absolute(iqv)
        iqp = np.angle(iqv)
        prefix = "5G" if NFFT == 256 else "2G"
        fname = f"data/{prefix}/dev{devid}_invnr{invnum}_csi_{now.day}-{now.month}-{now.year}_{now.hour}-{now.minute}.txt"
        with open(fname, "a") as f:
            np.savetxt(f, np.concatenate([iqm, iqp]), fmt="%.2f", newline=" ")
            f.write("\n")
        fname = f"data/{prefix}/dev{devid}_invnr{invnum}_labels_{now.day}-{now.month}-{now.year}_{now.hour}-{now.minute}.txt"
        with open(fname, "a") as f:
            label = 1 if devid in colocated else 0
            f.write(f"{label}\n")
        exit()


stop_listener = False
def listen():
    lock = threading.Lock()
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((UDP_IP, UDP_PORT))
    #print("* listening on "+UDP_IP+":"+str(UDP_PORT))
    global stop_listener
    while True:
        data, addr = sock.recvfrom(1076)
        if stop_listener:
            sock.close()
            exit()
        collector = threading.Thread(target=unpackdata, args=(data, lock))
        collector.start()


def main():
    listener = threading.Thread(target=listen)
    listener.deamon = True
    listener.start()
    try:
        input("Press enter to exit\n")
    except SyntaxError:
        pass
    global stop_listener
    stop_listener = True
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(b'exit', (UDP_IP, UDP_PORT))
    sock.close()
    listener.join()
    sys.exit()


if __name__== "__main__":
    main()

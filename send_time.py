from datetime import datetime
import time
import serial
import sys

def send_time(port, res=0.01):
    with serial.Serial(port) as ser:
        while(True):
            t1 = time.time()
            now = datetime.now().strftime("t%Y-%m-%d--%H:%M:%S.%f")[:-3].encode()
            ser.write(now)
            t = time.time() - t1
            print(now)
            if (t < res):
                return t
            time.sleep(1)

if __name__ == '__main__':
    if (len(sys.argv) == 2):
        send_time(sys.argv[1])

    if (len(sys.argv) > 2):
        send_time(sys.argv[1], float(sys.argv[2]))
    

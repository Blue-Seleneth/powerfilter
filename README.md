Files for the Generation-1 pump controller by RBTS (designed by Aaron Yeiser)

Instructions PDF is self-explanatory

send_time.py  Execute this in the Python environment to synchronize the controller clock with the Windows time.  Follow the instructions.  (by Aaron Yeiser)

powerfilter2.m  Matlab graphical app to time-average the power and current displays so they are more human-readable. First select the serial port (similar to procedure for send_time).  Set sample rate fs to match that of the controller.  40/second works well.  Set number of points to average.  Click the "Run" button to Run/Stop.  The display updates approximately once per second regardless of the averaging time.  Depending on variability, total averaging times of 8-32 seconds work well.  If the Save box is checked, the app will write a line of data to a file on the Matlab path with each update.  The data line is, first the most recent data line from the controller, then two new numbers appended, the averaged current and the averaged power.  Finally, at lower left alarm thresholds can be set for power and current.  The display will flash red and Matlab will beep.  (by Tim Conover)

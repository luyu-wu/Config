import matplotlib.pyplot as plt
import numpy as np
# Constants

capacitance = 0.000001061
resistance = 84.4 # Ohms

# Data
no_rod = [0,3.985,8.015,12.27,16.885,22.15,28.2,35.4,43.8,52.9,62.3,68.9,70.85,68.4,63.2,57.2,51.55,46.55,42.3,38.7,35.6,32.95,30.7,28.7,27,25.4,24,22.75,21.65,20.55,19.65]
no_rod_res = 1150
iron1 = [0,4.05,8.49,13.73,20.3,28.1,36.1,40.9,40.3,36.9,33,29.4,26.5,24.1,22,20.3,18.9,17.6,16.6,15.6,14.8,14,13.4,12.8,12.2,11.7,11.2,10.8,10.4,10,9.7]
iron_res = 700
    
def DrawComp():

    freq_table = []
    for i in range(31):
        freq_table.append(i/10)
    plt.plot(freq_table,no_rod,label="Empty Inductor")
    plt.plot(freq_table,iron1,label="Iron Rod (1)")

    plt.grid()
    plt.title("Frequency (KHz) vs. Current (mA)")
    plt.xlabel("Frequency (KHz)")

    ax = plt.gca()
    ax.set_xlim([0, 3.00])
    ax.set_ylim([0, 100])

    plt.legend() 

    plt.ylabel("Current (mA)")
    plt.show()

def DrawExample():
    freq_table = []
    for i in range(310):
        freq_table.append(i/100)

        
    ind_x = []
    inductance = 0.018052161
    cap_x = [1000]

    combined = []
    
    for i in range(310):
        ind_x.append(i*10*2*np.pi*inductance)
        if i != 0:
            cap_x.append(1/(i*10*2*np.pi*capacitance))
        combined.append(abs(cap_x[-1] - ind_x[-1]))

    plt.plot(freq_table,ind_x,label="Inductive Reactance")
    plt.plot(freq_table,cap_x,label="Capacitive Reactance")
    plt.plot(freq_table,combined,label="Combined Reactance")

    
    plt.grid()
    plt.title("Frequency (KHz) vs. Current (mA)")
    plt.xlabel("Frequency (KHz)")

    ax = plt.gca()
    ax.set_xlim([0, 3.00])
    ax.set_ylim([0, 1000])

    plt.legend() 

    plt.ylabel("Reactance (Ω)")
    plt.show()

DrawExample()

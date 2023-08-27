import math
import matplotlib.pyplot as plt
x_list = range(250, 500)
k_const = 8.6*(10**(-5)) #eV
q = 1 #e
def n_i(temperature):
    return (5.2*(10**(15))*(temperature**(1.5))*math.exp(-1.1/(2*k_const*temperature)))


NAND = 8*10**(16)*1.4*10**(17)
const_part = (k_const/q)
y_list = [const_part*T*math.log(NAND/(n_i(T)**2))/math.log(math.e) for T in x_list]

plt.plot(x_list, y_list, 'ro')
plt.xlabel("Temperature (K)")
plt.ylabel("Built-in potential (mV)")
plt.show()
print(f"{x_list[50]}, {y_list[50]}")

import numpy as np
import nescin_read as nescin
from scipy.optimize import least_squares


### Input Files ###
# Import Vessel nescin File 
print('Importing vessel data')
M = nescin.M
N = nescin.N
crc2 = nescin.crc2
czs2 = nescin.czs2

# Import Hit Point Data
import hitpoint_data as hpd # imports hitpoint data variables

# Importing coordtinates data from hitpoint data set
print('importing hitpoint data')
Phi_h = np.loadtxt('./tests/toroidal_test/toroidal_test_Phi.dat')
R_h = np.loadtxt('./tests/toroidal_test/toroidal_test_R.dat')
Z_h = np.loadtxt('./tests/toroidal_test/toroidal_test_Z.dat')

# Preparing Approximate Theta
Theta_approx = np.loadtxt('./tests/toroidal_test/toroidal_test_theta_approx.dat')
# for bypasing saved data file and using the function directly use the following lines instead
#+import theta_approx as ta # imports theta approximations found in the theta_approx file
#+Theta_approx = ta.Theta_approx[:]

# file where theta data will be printed
data_file = "toroidal_theta_test.dat"


### Creating Functions to be used in Least Squares Calculation ###
# creating functions for R_s and Z_s
def R_s(Theta_s,M,N,Phi_h):  	
    #initializing arrays for storing outputs of individual elements and summations
    R_s_arr = np.empty(len(M)) 
    for mode in range(len(M)):           
        # Using s=3 and p=1
        R_s_arr[mode] = crc2[mode] * np.cos(M[mode] * Theta_s + 3*N[mode]*Phi_h[coord,file_number])    
    R_s_sum = sum(R_s_arr)  
    return R_s_sum
    
def Z_s(Theta_s,M,N,Phi_h):  
    #initializing arrays for storing outputs of individual elements and summations
    Z_s_arr = np.empty(len(M)) 
    for mode in range(len(M)):            
        # Using s=3 and p=1
        Z_s_arr[mode] = czs2[mode] * np.sin(M[mode] * Theta_s + 3*N[mode]*Phi_h[coord,file_number]);    
    Z_s_sum = sum(Z_s_arr)
    return Z_s_sum

# defining the function that will be used in the least squares method
def chi_squared(Theta_s):
    return np.array([np.subtract(R_s(Theta_s,M,N,Phi_h),R_h[coord,file_number]),np.subtract(Z_s(Theta_s,M,N,Phi_h),Z_h[coord,file_number])])

### Creating Functions to be used in Jacobian Variable ###
# defining the derivatives with repsect to Theta_s of R_s
def R_s_deriv(Theta_s,M,N,Phi_h):
    #initializing arrays for storing outputs of individual elements and summations
    R_s_deriv_arr = np.empty(len(M))
    for mode in range(len(M)):
        # Using s=3 and p=1
        R_s_deriv_arr[mode] = -crc2[mode] * M[mode] * np.sin(M[mode] * Theta_s + 3*N[mode] * Phi_h[coord,file_number]);
    R_s_deriv_fun = sum(R_s_deriv_arr)
    return R_s_deriv_fun

# defining the derivatives with repsect to Theta_s of Z_s
def Z_s_deriv(Theta_s,M,N,Phi_h):
    #initializing arrays for storing outputs of individual elements and summations
    Z_s_deriv_arr = np.empty(len(M))
    for mode in range(len(M)):
        # Using s=3 and p=1
        Z_s_deriv_arr[mode] = czs2[mode] * M[mode] * np.cos(M[mode] * Theta_s + 3*N[mode] * Phi_h[coord,file_number]);
    Z_s_deriv_fun = sum(Z_s_deriv_arr)
    return Z_s_deriv_fun

# defining the Jacobian that will be used in the least squares method
def chi_squared_jac(Theta_s):
    return np.array(([R_s_deriv(Theta_s,M,N,Phi_h)],[Z_s_deriv(Theta_s,M,N,Phi_h)])) 


### Using Least Squares Function ###
# using the least squares method to find the closest Theta_s
print('finding least square')
# for each column in the input files
try:
    file_columns = Phi_h.shape[1]
except IndexError: # when there is only one column
    file_columns = 1 
    # changing all arrays that use two dimensions to 2D arrays
    Phi_h = Phi_h.reshape((Phi_h.shape[0],1))
    R_h = R_h.reshape((Phi_h.shape[0],1))
    Z_h = Z_h.reshape((Phi_h.shape[0],1))
    Theta_approx = Theta_approx.reshape((Theta_approx.shape[0],1))
Theta_s_result = np.empty([Phi_h.shape[0],file_columns]) # initializing final array based off of input file size
for file_number in range(file_columns):
    print('file number', file_number)
    for coord in range(Phi_h.shape[0]):    
        if coord % 100 == 0:
            print('computing theta', coord)
        Theta_result_temp = least_squares(chi_squared, Theta_approx[coord,file_number], chi_squared_jac, method='lm')
        Theta_s_result[coord,file_number] = Theta_result_temp.x
        if Theta_s_result[coord,file_number] < 0:
            Theta_s_result[coord,file_number] = Theta_s_result[coord,file_number] + 2*np.pi
        elif Theta_s_result[coord,file_number] > 2*np.pi:
            Theta_s_result[coord,file_number] = Theta_s_result[coord,file_number] - 2*np.pi

np.savetxt(data_file,Theta_s_result)

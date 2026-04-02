import numpy as np


# =====================================
# Thrust lapse model (very simplified)
# =====================================
def calc_thrust_lapse(h_m, v_mps, delta_T_celsius=0.0, throttle=1.0):
    """
    Returns thrust [N].
    thrust_mode: "TO" or "CLB"
    """
    rho0 = 1.225  # kg/m3

    curr_atm = US_Standard_1976_Atmosphere().compute_constants(altitude=h_m, delta_T_celsius=delta_T_celsius)
    rho = curr_atm['rho']
    v_sound = curr_atm['v_sound']

    sigma = rho / rho0
    Mach = v_mps / v_sound

    # Simple lapse: turbofan thrust decreases with density and Mach
    lapse = (sigma ** 0.80) * max(0.10, (1.0 - 0.30 * Mach))

    return lapse * throttle


# =============================================================
# International Standard Atmosphere with Temperature Adjusment
# =============================================================
class US_Standard_1976_Atmosphere(object):
    """
    docstring for US_Standard_1976_Atmosphere
    Assumptions:
            > Data from U.S. Standard Atmosphere (1976 version)
            > Altitude is from -2 km to 85 km
            > Altitude is divided into 8 sub-layers
            > Constant temperature rate of change at each sub-layer
            > Constant gravitational acceleration
            > Supports ISA + Delta_T (Temperature deviation)
    """

    def __init__(self):
        super(US_Standard_1976_Atmosphere, self).__init__()
        # Altitudes in meters
        self.break_altitudes = np.array([-2000.0, 0.000, 11000.0, 20000.0, 32000.0, 47000.0, 51000.0, 71000.0, 84852.0])
        
        # Standard Temperatures in Kelvin (at the break points for Standard Day)
        # Note: These are used to determine the base temperature before Delta_T is applied
        self.break_temperatures_std = np.array([301.5, 288.15, 216.65, 216.65, 228.65, 270.65, 270.65, 214.65, 186.95])
        
        # Lapse rates (K/m)
        self.T_lapse_rate = np.array([-0.0067, -0.0065, 0.0000, 0.0010, 0.0028, 0.0000, -0.0028, -0.0020])

        # Constants of air
        self.R = 287.0528742      # Joules/(kgK)
        self.beta = 1.458E-6      # kg/m-s-sqrt(K), Sutherland's constant
        self.gamma = 1.401        # ratio of specific heats of air (adiabatic index)
        self.S = 110.4            # K, Sutherland's constant for air
        self.P_std_sl = 101325.0  # Pa, Standard Pressure at Sea Level

    def _calculate_layer_pressure(self, P_base, T_base, H_base, H_target, rate, gravity):
        """
        Helper to calculate pressure change across a layer or partial layer.
        Handles both non-zero and zero lapse rates.
        """
        delta_h = H_target - H_base
        
        if abs(rate) < 1e-9:  # Isothermal layer (rate approx 0)
            # Formula: P = P0 * exp(-g * dh / (R * T))
            return P_base * np.exp(-gravity * delta_h / (self.R * T_base))
        else:
            # Formula: P = P0 * (1 + rate * dh / T0) ^ (-g / (R * rate))
            base = 1 + (rate * delta_h) / T_base
            exponent = -gravity / (self.R * rate)
            return P_base * (base ** exponent)

    def compute_constants(self, altitude=0.0, delta_T_celsius=0.0, gravity=9.80665):
        """
        Computes constants at an altitude with optional Temperature deviation.
        """

        if altitude < -2000.0 or altitude > 84852.0:
            raise ValueError('Altitude is outside the range [-2000, 84852] m')

        # 1. Identify the target layer index
        layer_idx = 0
        for i in range(len(self.T_lapse_rate)):
            # FIX: Change <= to < for the upper bound to handle H=0 correctly.
            # This ensures H=0 falls into the [0, 11000] layer, not [-2000, 0].
            if self.break_altitudes[i] <= altitude < self.break_altitudes[i+1]:
                layer_idx = i
                break
            # Handle the very last specific altitude edge case (84852.0)
            if i == len(self.T_lapse_rate) - 1: 
                layer_idx = i

        # 2. Integrate Pressure from Sea Level (0m)
        current_P = self.P_std_sl
        current_T = 288.15 + delta_T_celsius 
        
        # Determine integration bounds
        if altitude >= 0.0:
            start_layer_idx = 1  # Index 1 is the layer starting at 0m
            end_layer_idx = layer_idx
        else:
            start_layer_idx = 0
            end_layer_idx = layer_idx

        if altitude >= 0.0:
            # Loop through full layers below the target
            for i in range(start_layer_idx, end_layer_idx):
                H_bottom = self.break_altitudes[i]
                H_top = self.break_altitudes[i + 1]
                rate = self.T_lapse_rate[i]
                
                current_P = self._calculate_layer_pressure(current_P, current_T, H_bottom, H_top, rate, gravity)
                current_T = current_T + rate * (H_top - H_bottom)

            # Integrate part-way through the target layer
            # If H=0, layer_idx is 1. H_bottom is 0. altitude is 0. 
            # Integration distance is 0. No change to P or T. Correct.
            rate = self.T_lapse_rate[layer_idx]
            final_P = self._calculate_layer_pressure(current_P, current_T, self.break_altitudes[layer_idx], altitude, rate, gravity)
            final_T = current_T + rate * (altitude - self.break_altitudes[layer_idx])

        else:
            # Handling altitude < 0 (from 0 down to -2000)
            rate = self.T_lapse_rate[0] 
            final_P = self._calculate_layer_pressure(self.P_std_sl, 288.15 + delta_T_celsius, 0.0, altitude, rate, gravity)
            final_T = (288.15 + delta_T_celsius) + rate * (altitude - 0.0)

        # 3. Calculate derived properties
        data = {}
        data['H'] = float(altitude)
        data['P'] = final_P
        data['T'] = final_T
        data['rho'] = data['P'] / (self.R * data['T'])
        data['mu'] = self.beta * (data['T']**1.5 / (data['T'] + self.S))
        data['nu'] = data['mu'] / data['rho']
        data['v_sound'] = np.sqrt(self.gamma * data['P'] / data['rho'])

        return data


def calc_TOP_given_BFL_requirement(BFL_req_m, n_engine):
    """
    BFL_req_m     : Required Balanced Field Length [m]
    n_engine      : Number of engine [-]
    TOP_lbf_p_ft2 : Takeoff Parameter [lbf / ft^2]
    
    Figure is from Raymer page 130, extracted using PlotDigitizer
    linear equation: BFL_req_ft = m * TOP + c
    """
    M_TO_FT = 3.28084
    BFL_req_ft = BFL_req_m * M_TO_FT

    if n_engine == 2:
        x1, y1 = 167.07742596604100, 6.632832230907997
        x2, y2 = 283.48877329978080, 11.36952495490078
        x3, y3 = 215.51762157394316, 8.593241130487070
        x4, y4 = 243.98324102058552, 9.779434756464221

    if n_engine == 3:
        x1, y1 = 185.33978441622455, 6.8396873120865910
        x2, y2 = 313.62769641861127, 11.636608538785328
        x3, y3 = 235.75681319964198, 8.7319783523752260
        x4, y4 = 277.55827377323493, 10.281659651232712

    if n_engine == 4:
        x1, y1 = 147.22348332533434, 5.0378352375225495
        x2, y2 = 315.42552501524130, 10.773686109440769
        x3, y3 = 224.36278261320743, 7.6557546602525560
        x4, y4 = 272.72904154722220, 9.3270475045099220

    m1 = (y2 - y1) / (x2 - x1)
    c1 = y1 - m1 * x1

    m2 = (y4 - y3) / (x4 - x3)
    c2 = y3 - m2 * x3

    m = 0.5 * (m1 + m2)
    c = 0.5 * (c1 + c2)

    TOP_lbf_p_ft2 = (BFL_req_ft / 1000.0 - c) / m

    return TOP_lbf_p_ft2

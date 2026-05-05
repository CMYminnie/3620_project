# from mech3620_step1_preliminary_weight_estimation import perform_preliminary_weight_estimation
# from mech3620_step2_constraint_analysis import perform_constraint_analysis
from mech3620_models import US_Standard_1976_Atmosphere, calc_thrust_lapse
import numpy as np

# ==========
# Constants
# ==========
g = 9.81  # m/s^2
NMI_TO_KM = 1.852
FT_TO_M = 0.3048
KTS_TO_MPS = 0.514444

aero_data = {
    'AR_wing': 8,
    'e_clean': 0.85,
    'CD0_clean': 0.01065
}

# ===========================
# Time to Climb Calculation
# ===========================


def calculate_time_to_climb(W_kg, S_m2, T_sl_total_N, aero_data, target_alt_ft=35000):
    """
    Integrates the Rate of Climb from Sea Level to Target Altitude.
    Uses a standard climb schedule:
      - 250 kts CAS below 10,000 ft
      - 290 kts CAS above 10,000 ft
      - Capped at Mach 0.74
    """
    
    # Unpack Aero
    CD0 = aero_data['CD0_clean']
    K = 1.0 / (np.pi * aero_data['e_clean'] * aero_data['AR_wing'])
    
    # Simulation Parameters
    dt_sum = 0.0
    current_h_m = 0.0
    target_h_m = target_alt_ft * FT_TO_M
    step_h_m = 100 * FT_TO_M  # 100 ft steps
    
    atm_solver = US_Standard_1976_Atmosphere()
    
    # Loop
    while current_h_m < target_h_m:
        
        # 1. Atmosphere at current altitude
        atm = atm_solver.compute_constants(current_h_m, delta_T_celsius=0.0)
        rho = atm['rho']
        v_sound = atm['v_sound']
        
        # 2. Determine Climb Speed (CAS -> TAS)
        # Schedule: 250kts < 10k ft, 290kts > 10k ft, max M 0.74
        if current_h_m < 10000 * FT_TO_M:
            v_cas_kts = 250.0
        else:
            v_cas_kts = 290.0
            
        # Convert CAS to TAS (Simplified approximation for low subsonic)
        # TAS ~= CAS / sqrt(sigma)
        sigma = rho / 1.225
        v_tas_mps = (v_cas_kts * KTS_TO_MPS) / np.sqrt(sigma)
        
        # Check Mach Limit
        mach = v_tas_mps / v_sound
        if mach > 0.78:
            mach = 0.78
            v_tas_mps = mach * v_sound
            
        # 3. Calculate Drag
        q = 0.5 * rho * v_tas_mps**2
        CL = (W_kg * g) / (q * S_m2)
        CD = CD0 + K * CL**2
        Drag_N = q * S_m2 * CD
        
        # 4. Calculate Thrust
        # calc_thrust_lapse returns the ratio (alpha), need to multiply by T_sl
        alpha = calc_thrust_lapse(current_h_m, v_tas_mps, delta_T_celsius=0.0, throttle=1.0)
        Thrust_N = alpha * T_sl_total_N
        
        # 5. Rate of Climb (RoC)
        # RoC = (T - D) * V / W
        # Note: We ignore the acceleration factor (energy height) for this preliminary check,
        # which makes this slightly optimistic, but acceptable for Step 3 sanity check.
        excess_power = (Thrust_N - Drag_N) * v_tas_mps
        roc_mps = excess_power / (W_kg * g)
        
        if roc_mps <= 0:
            print(f"Warning: Ceiling reached at {current_h_m/FT_TO_M:.0f} ft. Cannot climb further.")
            return float('inf')
            
        # 6. Integrate Time
        # dt = dh / RoC
        dt = step_h_m / roc_mps
        dt_sum += dt
        
        # Advance
        current_h_m += step_h_m
        
    return dt_sum / 60.0  # Return minutes


# =================
# Main Execution
# =================

if __name__ == "__main__":
    
    # 1. Get Weight Estimate
    # weight_breakdown = perform_preliminary_weight_estimation(
    #     engine_data, aero_data, mission_req,
    #     W_guess_fp_kg=20000.0, W_a_bi_kg=10000.0, W_b_bi_kg=60000.0,
    #     verbose=False, plot=False
    # )

    # W_takeoff = weight_breakdown['total']
    W_takeoff = 32113.5  # kg

    # 2. Perform Constraint Analysis
    # ws_range = np.linspace(1000, 6000, 500) 
    # design_points = perform_constraint_analysis(ws_range, engine_data, aero_data, mission_req, plot=False, verbose=False)

    # The limiting Wing Loading is determined by Landing
    # WS_limit = design_points['dp1']['W/S']
    WS_limit = 4069.4
    # TW_req_takeoff = design_points['dp1']['T/W']
    # TW_req_climb = design_points['dp2']['T/W']
    # TW_req_cruise = design_points['dp3']['T/W']
    # TW_req_takeoff = 0.312003020362084
    # TW_req_climb = 0.30070608000941507
    # TW_req_cruise = 0.30070608000941507

    # Select the highest T/W required to satisfy ALL constraints
    TW_selected =0.284  # This is the T/W required for takeoff, which is the highest among the three constraints

    # Identify which constraint is sizing the engine
    # if TW_selected == TW_req_takeoff:
    #     sizing_case = "Takeoff Field Length"
    # elif TW_selected == TW_req_climb:
    #     sizing_case = "Climb Gradient (OEI)"
    # else:
    #     sizing_case = "Cruise Speed"

    WS_selected = WS_limit

    # 3. Calculate Geometry (simplified)
    AR_wing = 8
    S_wing_required = W_takeoff * g / WS_selected
    b_wing_required = np.sqrt(S_wing_required * AR_wing)
    c_wing_required = S_wing_required / b_wing_required

    # 4. Calculate Time to Climb (Sanity Check)
    # Total Installed Thrust (Sea Level)
    T_sl_total_N = TW_selected * W_takeoff * g

    ttc_min = calculate_time_to_climb(W_takeoff, S_wing_required, T_sl_total_N, aero_data, target_alt_ft=35000)

    # 5. Output
    print(f'W_takeoff = {W_takeoff:.2f} kg')
    print(f'WS_selected = {WS_selected:.2f} N/m**2')
    print(f'TW_selected = {TW_selected:.4f} )')
    print(f'Thrust required per engine = {T_sl_total_N / 2 / 1000.0:.2f} kN')
    print(f'Required wing area = {S_wing_required:.2f} m**2')
    print(f'Required wing span = {b_wing_required:.2f} m')
    print(f'Required wing chord = {c_wing_required:.2f} m')
    print(f'Time to Climb (FL350) = {ttc_min:.2f} min')

    print(50 * '-')
    print('!!! Sanity Checks !!!')
    
    # Weight Check
    print('SUCCESS:' if W_takeoff <= 35000.0 else 'FAIL:', f'Takeoff Weight = {W_takeoff:.2f} kg <= 35000.0 kg')

    # Span Check
    if b_wing_required <= 28.0:
        print(f'SUCCESS: Wing span = {b_wing_required:.2f} m <= 28.0 m')
        if b_wing_required > 27.0:
            print('  [WARNING] Span is very close to limit. Consider reducing AR or increasing CL_land.')
    else:
        print(f'FAIL: Wing span = {b_wing_required:.2f} m > 28.0 m')
        
    # Time to Climb Check
    if ttc_min <= 17.0:
        print(f'SUCCESS: Time to Climb = {ttc_min:.2f} min <= 17.0 min')
    else:
        print(f'FAIL: Time to Climb = {ttc_min:.2f} min > 17.0 min')
        print('  [Suggestion] Increase T/W ratio or reduce Drag.')

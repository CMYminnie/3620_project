### A Pluto.jl notebook ###
# v0.20.24

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 981ca2b5-f92f-4410-b80c-e8ccabd008d5
begin
	using Plots
	using PlutoUI
end

# ╔═╡ 1a47d504-da67-11ef-1188-7b0242ee46fb
md"""
# Preliminary Weight Estimation

![](https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/iterative_takeoff_weight_estimation.png)

"""

# ╔═╡ b0d766cc-7cf0-495a-a3f9-9c97c9fa6af9
html"""
<img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/XDSM/WeightEstimationXDSM.svg" width="100%">
"""

# ╔═╡ 7915c630-fbf1-4bee-8728-5fdeec03acda
md"""
## Problem Specification

Anti-submarine warfare aircraft specifications:
* Crew: $4$ passengers, $200$ lb each
* Payload: radar equipment, $10,000$ lb
* Cruise condition: $M = 0.6$ at $35,000$ ft
* Maximum lift-to-drag ratio: $(L/D)_\max = 16$

Suppose we will consider the design of an aircraft similar to a Lockheed S-3 Viking.

![](https://upload.wikimedia.org/wikipedia/commons/a/af/S-3A_%28cropped%29.jpg)

_Reference_: Raymer, Daniel P., Aircraft Design: A Conceptual Approach, Fifth Edition, Chapter 3.

"""

# ╔═╡ 82bd4967-153d-4c95-99a2-7c3dcfa8a5f2
begin
	W_payload 	= 10000.0  	# Payload weight in lb
	W_crew 		= 4*200.0 	# Crew weight in lb
	M 			= 0.6 		# Cruise speed in Mach
	LD_max 		= 16. 		# Maximum L/D ratio
end;

# ╔═╡ 4232909a-eef5-4db8-81a9-ea35b1751019
md"""
## Takeoff Weight Estimation
"""

# ╔═╡ 74194f3b-cce3-41a2-9c68-752a8e2907a9
html"""
<img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/XDSM/TakeoffWeightXDSM.svg" width="100%">
"""

# ╔═╡ 8bc3787a-0671-4b3e-a3e6-277263c9181b
md"""
The 'governing equation' of this problem is:

```math
W_\text{TO} = \frac{W_\text{payload} + W_\text{crew}}{1 - \displaystyle\frac{W_\text{f}}{W_\text{TO}} - \displaystyle\frac{W_\text{e}}{W_\text{TO}}}
```


So we need to compute the maximum takeoff weight given payload weight, crew weight, fuel-weight fraction, and empty-weight fraction. We will compute this by writing the following function:

"""

# ╔═╡ d5710498-2f50-4663-8a5d-4badca0959c2
function maximum_takeoff_weight(W_payload, W_crew, Wf_WTO, We_WTO)
	WTO = (W_payload + W_crew) / (1 - Wf_WTO - We_WTO)
	return WTO
end

# ╔═╡ f8505334-0976-4c7d-98b8-698b9804da99
# Example computation
maximum_takeoff_weight(
	10000.0, # Payload weight, kg
	800.0,  # Crew weight, kg
	0.1,  # Fuel-weight fraction
	0.6   # Empty-weight fraction
)

# ╔═╡ 8551adf3-6487-44b6-9cc8-f7aacfe67eee
md"""
## Mission Segment Weight Fractions
"""

# ╔═╡ 38abb573-46d6-4c54-b092-b72e4430f3ee
html"""
<img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/XDSM/MissionSegmentWeightXDSM.svg" width="100%">
"""

# ╔═╡ ae4d63c8-9285-4b15-9978-64547c7aed65
md"""
We consider a mission consisting of 7 segments in the following order:

1. Warmup and takeoff
2. Climb
3. Cruise_1: $1500$ nautical miles (nmi) 
4. Loiter_1: $3$ hrs
5. Cruise_2: $1500$ nmi
6. Loiter_2: $20$ mins
7. Landing

![](https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/sample_mission_profile.png)
"""

# ╔═╡ 2bdbaba7-39bc-4ca0-a090-4d9176cf9a62
md"Let's use the historical mission segment weight fractions as given in Raymer's textbook.
"

# ╔═╡ 5e184816-d1a2-47f3-9b8d-5a8c6307a0f3
html"""
<center><img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/historical_mission_segment_weight_fractions.png" width="60%" >
"""

# ╔═╡ 91bcb310-8438-48eb-972d-e1e4cb27c8bc
md"### Warmup and takeoff

$\left(\frac{W_1}{W_0}\right)_\text{takeoff} = 0.97$
"

# ╔═╡ d72b775b-f464-4a10-839d-af6c0bfa0348
takeoffWF = 0.97;

# ╔═╡ 4356c491-6fac-4a51-9830-22ffef3a6aea
md"### Climb
$\left(\frac{W_2}{W_1}\right)_\text{climb} = 0.985$
"

# ╔═╡ 61650532-a8ee-4b84-847d-83b2f97095a0
climbWF = 0.985;

# ╔═╡ 9c858137-4c28-47d0-8cd3-1566c81eee7f
md"### Cruise


The cruise weight fraction is computed from the Breguet range equation, given range ``R``, specific fuel consumption ``SFC``, cruise speed ``V``, and lift-to-drag ratio $(L/D)_\text{cruise}$. 

$$\left(\frac{W_3}{W_2}\right)_\text{cruise} = \exp\left(-\frac{R_1 \times SFC}{V \times (L/D)_\text{cruise}}\right)$$

"

# ╔═╡ e0a0b9e0-f60c-40c4-b1af-17258af2de77
function cruise_weight_fraction(R, SFC, V, L_D)
	cruiseWF = exp(-R * SFC / (V * L_D))
	return cruiseWF
end;

# ╔═╡ 82504448-5dc7-4121-aff2-58df81df9469
md"For a jet aircraft at cruise altitude, we consider $SFC = 0.5$ /hr (which is the best $SFC$ for subsonic aircraft, obtained from using high-bypass turbofan), and $(L/D)_\text{cruise} = 0.866 \times (L/D)_\max$.
"

# ╔═╡ d543c42d-1eb7-4b98-b50e-896d0dcd8b0f
html"""
<center><img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/typical_SFC.png" width="80%" >

<center><img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/L_by_D_table.png" width="50%">
"""

# ╔═╡ 642b9276-33d2-4072-aa58-518d26b1664a
begin
	# At 35000 ft, speed of sound ≈ 994.8 ft/s
	# 1 nmi ≈ 6076 ft
	V = M * 994.8       		# Cruise speed in ft/s
	cruise_SFC = 0.5/3600 		# TSFC at cruise in 1/secs
	R1 = 1500 * 6076   			# Range of cruise segment 1 in ft
	LD_cruise = LD_max * 0.866  # L/D ratio at cruise
end;

# ╔═╡ ac9e6a70-b4db-4ce9-bc86-26a0438185d7
cruise1WF = cruise_weight_fraction(R1, cruise_SFC, V, LD_cruise)

# ╔═╡ 74d01961-0a6a-4d35-866f-3473fea20840
md"### Loiter

The weight fraction during the loiter phase is also calculated similarly, given endurance time ``E``, specific fuel consumption ``SFC``, and maximum lift-to-drag ratio $(L/D)_\max$.

$$\left(\frac{W_4}{W_3}\right)_\text{loiter} = \exp\left(-\frac{E_1 \times SFC}{(L/D)_\max}\right)$$"

# ╔═╡ b8812a7c-f4f0-497f-aa64-1ad947f43e69
function loiter_weight_fraction(E, SFC, L_D)
	loiterWF = exp(- E * SFC / L_D)
	return loiterWF
end;

# ╔═╡ 4054b18d-64ba-485c-82b1-9eb3443ce8c0
begin
	E1 = 3 * 3600 		  # Endurance time, secs
	loiter_SFC = 0.4/3600 # Specific fuel consumption, 1 / secs
end;

# ╔═╡ 1cf0fac8-6556-4736-91d6-2be9a5c67a27
loiter1WF = loiter_weight_fraction(E1, loiter_SFC, LD_max)

# ╔═╡ 401568d6-b4a1-4275-8382-3ec03fa3a981
md"### Cruise 2

$$\left(\frac{W_5}{W_4}\right)_\text{cruise} = \exp\left(-\frac{R_2 \times SFC}{V \times (L/D)_\text{cruise}}\right)$$
"

# ╔═╡ 330af40e-04c2-4f99-a0c4-5814e74ef4ff
R2 = 1500 * 6076; # in ft (1 nmi ≈ 6076 ft)

# ╔═╡ 552332e2-7cee-41e5-8730-8fb12872cb22
cruise2WF = cruise_weight_fraction(R2, cruise_SFC, V, LD_cruise)

# ╔═╡ 809ee2fb-2a4a-4935-ac6d-33744f2d9c79
md"### Loiter 2

$$\left(\frac{W_6}{W_5}\right)_\text{loiter} = \exp\left(-\frac{E_2 \times SFC}{(L/D)_\max}\right)$$
"

# ╔═╡ 908a45a4-03cf-43fb-88a2-28299e8ee786
E2 = 1/3 * 3600; # Endurance of second segment, secs

# ╔═╡ d929f9b0-b340-4145-b9e2-87f6ada614d1
loiter2WF = loiter_weight_fraction(E2, loiter_SFC, LD_max)

# ╔═╡ 44639a99-983d-41c9-b7e0-a4a5886bb891
md"### Landing

$\left(\frac{W_7}{W_6}\right)_\text{landing} = 0.995$"

# ╔═╡ f5b749a2-23cd-4d41-b1f2-0d3a4856bb5c
landingWF = 0.995;

# ╔═╡ 18a12ada-b884-49cf-909f-e98fe2aeb883
md"
### Summary
"

# ╔═╡ 93c58936-6063-45f0-bbf3-04571176b930
WFs = [takeoffWF, climbWF, cruise1WF, loiter1WF, cruise2WF, loiter2WF, landingWF]

# ╔═╡ 14edd542-98d8-4b45-b13c-1d84765e233a
md"""## Fuel Weight Fractions
"""

# ╔═╡ 6a6faced-3793-4053-bfd3-e5e19d3c1dca
html"""
<img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/XDSM/FuelWeightXDSM.svg" width="100%">
"""

# ╔═╡ 2b9fe065-1fd7-46b4-84b2-d300ce09fdaa
md"""
The fuel weight fraction is given by:
```math
W_{\text{f}_0} \equiv \frac{W_\text{f}}{W_\text{TO}} = a\left(1 - \prod_{i = 1}^{N}\frac{W_{\text{f}_i}}{W_{\text{f}_{i-1}}}\right)
```
where the input $a$ is the reserve and trapped fuel (usually as a percentage of the total).
"""

# ╔═╡ 755cd536-e19f-4290-be51-e4d024a081d2
function fuel_weight_fraction(segment_weight_fracs, a)
	Wf_WTO = a * (1 - prod(segment_weight_fracs))
	return Wf_WTO
end

# ╔═╡ f7781783-5374-47d2-901e-074417e91541
a = 1.06 # Reserve and trapped fuel (6%)

# ╔═╡ f59f969b-2d87-4c4c-ae86-762f5bf1c842
Wf_WTO = fuel_weight_fraction(WFs, a) # Estimated fuel-weight fraction

# ╔═╡ f5140ee4-7ba9-4fdd-9a14-2b215d091cf6
md"""## Empty Weight Fraction
"""

# ╔═╡ f3a7682d-54f9-4768-8d15-1199c53bc00f
html"""
<img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/XDSM/EmptyWeightXDSM.svg" width="100%">
"""

# ╔═╡ 56553c22-2abf-469a-b0b4-aeaf59c31dc6
md"""Compute the empty-weight ratio ``W_\text{e}/W_\text{TO}`` for an aircraft given the maximum takeoff weight ``W_\text{TO}`` (in lb) and regression coefficients ``A`` and ``B``.

The following regression formula is used from Raymer:

```math
\frac{W_\text{e}}{W_\text{TO}} \equiv W_{\text{EF}}(W_\text{TO}) = A W_\text{TO}^B
```
"""

# ╔═╡ 4c688c33-bba2-4bea-8cb1-e7f5209f465e
html"""
<center><img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/historical_empty_weight_graph.png" width="80%">
"""

# ╔═╡ 5a555d98-18b7-4c51-8bc2-06896c0292b8
html"""
<center><img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/historical_empty_weight_table.png" width="80%">
"""

# ╔═╡ ee7c7f0c-d9b9-42a4-9307-3834c738dbeb
function empty_weight_raymer(WTO, A, B)
	We_WTO = A * WTO^B
	return We_WTO
end;

# ╔═╡ d84d8493-ff2e-4b2b-b457-389d2d64e77d
md"Regression coefficients:"

# ╔═╡ 5c5f59d2-0faf-4c62-a370-6bf2ed98d6c4
A, B = 0.93, -0.07; # Raymer's coefficients for this aircraft type

# ╔═╡ 22e2bb79-be53-4474-ad7f-b220436d4c00
WTO_random = 11000; # kg

# ╔═╡ 6bbc74c1-7741-41f0-89ec-877047c9e96d
We_WTO_random = empty_weight_raymer(WTO_random, A, B)

# ╔═╡ 8c4d140a-3228-4e10-9fb4-6e5f822c14a3
md"For demonstration, here are the estimated empty weights for a range of guessed takeoff weights."

# ╔═╡ 4fed483a-3f6c-4421-bcea-5a061a950465
WTO_range = 2000:1000:22000; # lb

# ╔═╡ 29fc98d4-9ba9-4572-8847-d158c44d9b02
We_WTO_range = empty_weight_raymer.(WTO_range, A, B) # Broadcasting over range

# ╔═╡ 07bb8a5c-ac57-45ca-8c09-83df56c78257
plot(
	WTO_range, # x-values (Takeoff weights)
	We_WTO_range, # y-values (Empty weight ratios) 
	xlabel = "Takeoff Weight", 
	ylabel = "Empty Weight / Takeoff Weight", 
	label = ""
)

# ╔═╡ 7318875f-e93c-4433-924d-2be64e71d502
md"""
## Iterative Estimation
"""

# ╔═╡ e5cd4840-3bd0-42f9-a11f-bdcd35333b40
html"""
<img src="https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/XDSM/TakeoffEmptyWeightXDSM.svg" width="100%">
"""

# ╔═╡ 79ee2e6b-66b3-449d-bcb8-40800da02610
md"""### Fixed-Point Iteration
We need to solve the following equation for $W_\text{TO}$:
```math
\begin{align}
W_\text{TO} & = \frac{W_\text{payload} + W_\text{crew}}{1 - \displaystyle\frac{W_\text{f}}{W_\text{TO}} - \displaystyle\frac{W_\text{e}}{W_\text{TO}}},
\end{align}
```
where
```math
\begin{align}
\text{Fuel Weight Fraction:}  &\quad  & \frac{W_\text{f}}{W_\text{TO}} \equiv W_{\text{f}_0} & = a\left(1 - \prod_{i = 1}^{N}\frac{W_{\text{f}_i}}{W_{\text{f}_{i-1}}}\right), \\

\text{Empty Weight Fraction:} &\quad & \frac{W_\text{e}}{W_\text{TO}} \equiv W_{\text{EF}}(W_\text{TO}) = AW_\text{TO}^B.

\end{align}
```

To numerically solve the equation, you can:

1. Begin with a guess for $W_\text{TO}$, insert it into the right-hand expression and check the computed value to get the left-hand side, a new value of $W_\text{TO}$. 
2. If you insert this new value of $W_\text{TO}$ into the right-hand side again, you will get another new value for $W_\text{TO}$.
3. Repeat the process for more iterations. Eventually, the value of $W_0$ should converge to a _fixed point_.


Here, we will denote the iteration number of a variable by an additional subscript $(-)_n$:
```math
\begin{align}
\text{Takeoff Weight Iteration:} & \quad & (W_\text{TO})_n & = \frac{W_\text{payload} + W_\text{crew}}{1 - W_{\text{f}_0} - W_\text{EF}[(W_\text{TO})_{n-1}]}\\
% \text{Equality:} & \quad & (W_\text{TO})_n & = (W_\text{TO})_{n-1}
\end{align}
```
So, we need to evaluate the right-hand expression to obtain the value of $W_\text{TO}$ for the $n^\text{th}$ iteration, and compare it to the value of $W_\text{TO}$ in the $(n-1)^{\text{th}}$ iteration.

Let the following indicate the relative error for the $n$th iteration:
```math
\varepsilon_n = \left|\frac{(W_\text{TO})_n - (W_\text{TO})_{n-1}}{(W_\text{TO})_{n-1}}\right|
```

We would like our analysis to converge below some tolerance $\varepsilon_\text{tol}$, i.e. the error should be $\varepsilon_{n} < \varepsilon_\text{tol}$.
"""

# ╔═╡ 2b7598bc-fba2-4ca2-a6b0-e37e96a7b2f8
function compute_WTO_via_fixed_point_iteration(
		# Input arguments
		WTO_guess, W_payload, W_crew, Wf_WTO, A, B;
		# Default arguments
		num_iters = 20, # number of iterations
		tol = 1e-12 	# convergence tolerance
	)

	# Initial value of takeoff weight from guessing
	WTO = WTO_guess

	# Array of MTOW iterative values
	WTO_list = [WTO]

	# Array of errors over iterations of size num_iters, initially infinite
	error_list = [ Inf; zeros(num_iters) ]

	# Iterative loop
	for i in 2:num_iters
		
		# Calculate empty weight fraction
		We_WTO = empty_weight_raymer(WTO, A, B)

		# Calculate new MTOW with the calculated empty weight fraction
		WTO_new = maximum_takeoff_weight(W_payload, W_crew, Wf_WTO, We_WTO)

		# Evaluate relative error
		error = abs((WTO_new - WTO)/WTO)

		# Append MTOW_new to MTOW_list
		push!(WTO_list, WTO_new)

		# Assign error to error_list
		error_list[i] = error

		# Conditional
		if error < tol
			break 				# break loop
		else
			WTO = WTO_new 	# assign new value
		end
	end

	# Return arrays of MTOW and error
	return WTO_list, error_list[2:length(WTO_list)]
end

# ╔═╡ 136ad7e4-0b1a-4a73-9722-2627195a71e7
md"We need an initial guess to start the iteration process. Let's try the sum of the payload and crew weights."

# ╔═╡ 3baf8a83-11c0-434f-9d25-cc4d64b32bf6
begin
	max_iter = 20
	WTO_guess = W_payload + W_crew # Initial guess
end;

# ╔═╡ e626a2e3-929f-4318-b42c-4674b59f5f66
md"The iteration is performed by calling the function with the relevant inputs. It returns the arrays of takeoff weights and convergence errors over the iterations."

# ╔═╡ 20887d53-bd86-491b-ad70-459693f603e9
md"We can check the iterative maximum takeoff weights and their errors."

# ╔═╡ 1517018b-da24-4ab7-9f84-bad32410a097
md"We can evaluate the converged maximum takeoff weight by indexing the last element of the array. This is the desired quantity of the whole process."

# ╔═╡ ac421b6c-58a8-4225-8e19-3c6e8568ef66
md"Now, let's plot the convergence throughout the iterations."

# ╔═╡ 3fca957b-e017-4ab7-934e-71f9a65759af
begin
	num_slider = @bind num NumberField(1:max_iter, default = 6)
	md"""
	Number of iterations for **fixed-point iteration method**: `num` = $(num_slider)
	"""
end

# ╔═╡ f4f2fb53-e396-4f7c-ad2a-9b168e18f528
WTO_list1, error_list = compute_WTO_via_fixed_point_iteration(
							WTO_guess, W_payload, W_crew, Wf_WTO, A, B;
							num_iters = num,
							tol = 1e-12
						);

# ╔═╡ 6b34d94f-ab70-4cd4-b2fd-c286273efb20
WTO_list1

# ╔═╡ eb01deb2-2587-48f5-85f2-b2b1efc7d794
error_list

# ╔═╡ 0a34fdc0-6c1a-42b2-a4b7-03f39c5fa423
WTO_result1_lb = WTO_list1[end] # in lb

# ╔═╡ 42f60b8d-6c64-4701-aa76-efcaa1f2cc45
begin
	plot0 = plot(title="Fixed-point iteration method",
				 grid=false, showaxis=false, bottom_margin = -140Plots.px)
	plot1 = plot(WTO_list1,
		label = "", 
		ylabel = "W_takeoff (lb)", 
		xlabel = "Iterations"
	)
	plot2 = plot(error_list,
		label = "", 
		ylabel = "Error, ε", 
		yscale = :log10, 
		xlabel = "Iterations"
	)
	plot(plot0, plot1, plot2, layout = (3,1))
end

# ╔═╡ f0d5afdd-ce75-4f19-93bf-208870fcbdb7
md"""### Bisection Method (optional)
"""

# ╔═╡ b9d204b8-eb92-413b-80cf-76997fd30a09
function compute_WTO_residual(WTO, W_payload, W_crew, Wf_WTO, A, B)
	We_WTO = empty_weight_raymer(WTO, A, B)
	WTO_calc = maximum_takeoff_weight(W_payload, W_crew, Wf_WTO, We_WTO)
	residual = WTO - WTO_calc
	return residual
end

# ╔═╡ ffb30ebd-b8a5-4f3e-bcc2-c2d9d4dba845
function compute_WTO_via_bisection_method(
		f::Function, a::Number, b::Number,
		# Input arguments
		W_payload, W_crew, Wf_WTO, A, B;
		# Default arguments
		num_iters = 20, # number of iterations
		tol = 1e-12 	# convergence tolerance
	)

	WTO_list, residual_list = [], []
	
    fa = f(a, W_payload, W_crew, Wf_WTO, A, B)
    fa*f(b, W_payload, W_crew, Wf_WTO, A, B) <= 0 || error("No real root in [a,b]")
    i = 0
    local c

	for i in 1:num_iters
		
        c = (a+b)/2
        fc = f(c, W_payload, W_crew, Wf_WTO, A, B)
		push!(WTO_list, c)
		push!(residual_list, abs(fc))

		# Conditional
		if abs(fc) < tol
			break  # break loop if abs(residual) is less than tolerance
        elseif fa*fc > 0
            a = c  # Root is in the right half of [a,b].
            fa = fc
        else
            b = c  # Root is in the left half of [a,b].
        end
    end
    return WTO_list, residual_list
end

# ╔═╡ 9f65b5d9-4d1f-4c42-8613-92ded9987edb
begin
	max_iter_bisect = 20
	WTO_guess1 = 10800.0  # in lb, initial guess 1
	WTO_guess2 = 100000.0 # in lb, initial guess 2
end;

# ╔═╡ aed4d675-d725-44af-a2d8-b5e9160a6214
begin
	num_slider2 = @bind num_iter_bisect NumberField(1:max_iter_bisect, default = 20)
	md"""
	Number of iterations for **bisection method**: `num_iter_bisect` = $(num_slider2)
	"""
end

# ╔═╡ 04700882-1230-4012-b367-3502c11dce46
WTO_list2, residual_list = compute_WTO_via_bisection_method(
							compute_WTO_residual, WTO_guess1, WTO_guess2,
							W_payload, W_crew, Wf_WTO, A, B,
							num_iters=num_iter_bisect, tol=1e-3
);

# ╔═╡ 1161a6d3-8bfa-4d38-be4d-43b2cc0a1c40
WTO_list2

# ╔═╡ e18df7d1-1af5-4155-8bcd-04ed63f96845
residual_list

# ╔═╡ 5653b0c3-ce58-4935-89e8-cdb5f5389e87
WTO_result2_lb = WTO_list2[end] # in lb

# ╔═╡ 28e544ae-aeac-4da3-aa2f-1beda3bb04b4
num_iter_bisect

# ╔═╡ 39056ece-e86f-4637-a2bb-5c81aa043261
begin
	plot3 = plot(title="Bisection method",
				 grid=false, showaxis=false, bottom_margin = -140Plots.px)
	plot4 = plot(WTO_list2, 
		label = "", 
		ylabel = "Takeoff weight (lb)", 
		xlabel = "Iterations"
	)
	plot5 = plot(residual_list,
		label = "", 
		ylabel = "Residual", 
		yscale = :log10, 
		xlabel = "Iterations"
	)
	plot(plot3, plot4, plot5, layout = (3,1))
end

# ╔═╡ bad2dbd9-5bfa-4d8a-a33c-7ff73718923e
md"""### Final results
"""

# ╔═╡ f69cb2ca-5c9e-4337-8e11-6e4cb4eef882
md"
Takeoff weight calculated via **fixed-point iteration** = $WTO_result1_lb lb

Takeoff weight calculated via **bisection method** = $WTO_result2_lb lb
"

# ╔═╡ 4b6dfe00-5b96-459c-b591-1d7ab948a53c
# Empty Weight (in lb)
W_empty = empty_weight_raymer(WTO_result1_lb, A, B) * WTO_result1_lb

# ╔═╡ 9b17d4f5-40c3-4f9f-b3ae-9e0b01aa0d50
# Fuel Weight (in lb)
W_fuel = Wf_WTO * WTO_result1_lb

# ╔═╡ c77256b0-4ca7-4aff-8718-0778f33702f6
# Residual weight (in lb)
W_residual = WTO_result1_lb - (W_empty + W_fuel + W_payload + W_crew)

# ╔═╡ ae5eccd0-ceda-4be4-a83c-4943dd59c411
# The end of main tutorial

# ╔═╡ ae211c87-5c58-403d-ac75-cc97da87af38
md"
## Additional exercise (optional)
"

# ╔═╡ c79c43cf-ef87-41fe-b3aa-0928fc08ed2d
md"""

!!! tip "Exercise"
	Suppose we have achieved a 5% empty-weight saving due to the use of composite materials; how much take-off weight saving would we get?
"""

# ╔═╡ dc5ad53b-f105-4f00-8756-9087aab87abf
composite_saving = 0.05;

# ╔═╡ 00fce8aa-7760-4a20-825b-f5c1b54d480b
function compute_WTO_with_composites(
		# Input arguments
		WTO_guess, W_payload, W_crew, Wf_WTO, A, B, composite_saving,
		# Default arguments
		num_iters = 20, # number of iterations
		tol = 1e-12 	# convergence tolerance
	)

	# Initial value of takeoff weight from guessing
	WTO = WTO_guess

	# Array of MTOW iterative values
	WTO_list = [WTO]

	# Array of errors over iterations of size num_iters, initially infinite
	error_list = [ Inf; zeros(num_iters) ]

	# Iterative loop
	for i in 2:num_iters
		
		# Calculate empty weight fraction and consider composite saving
		We_WTO = (1 - composite_saving) * empty_weight_raymer(WTO, A, B)

		# Calculate new MTOW with the calculated empty weight fraction
		WTO_new = maximum_takeoff_weight(W_payload, W_crew, Wf_WTO, We_WTO)

		# Evaluate relative error
		error = abs((WTO_new - WTO)/WTO)

		# Append MTOW_new to MTOW_list
		push!(WTO_list, WTO_new)

		# Assign error to error_list
		error_list[i] = error

		# Conditional
		if error < tol
			break 				# break loop
		else
			WTO = WTO_new 	# assign new value
		end
	end

	# Return arrays of MTOW and error
	return WTO_list, error_list[2:length(WTO_list)]	

end

# ╔═╡ 46e1712d-1019-483d-8aba-8fde7f27c565
WTO_list3, error_list3 = compute_WTO_with_composites(W_payload+W_crew, W_payload, W_crew, Wf_WTO, A, B, composite_saving);

# ╔═╡ 89befc48-b2a1-4f94-83d8-7afee54498c5
# Takeoff gross weight
WTO_result3_lb = WTO_list3[end] # in lb

# ╔═╡ a8feca0a-95df-4d11-97a6-61f2b5a79397
total_weight_saving = (WTO_result3_lb-WTO_result1_lb)/WTO_result1_lb * 100 # %

# ╔═╡ a2861049-d1a6-45df-aa4e-9ad494487827
md"
The total weight saving due to a **5 %** composite empty-weight saving is **$(round(total_weight_saving; digits=2))%**
"

# ╔═╡ e7632467-e079-4073-aea6-4fdeee42f32d
# Table of Contents
begin
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]));
	alert(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Alert!", [text]));
	exercise(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("correct", "Exercise", [text]));
	correct(text=md"Great! You got the right answer! Let's move on to the next section.") = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]));
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]));
	TableOfContents()
end

# ╔═╡ 1aad12b5-1af0-4b60-8e9c-a43296f6cd29
# The end.

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Plots = "~1.40.9"
PlutoUI = "~0.7.23"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.5"
manifest_format = "2.0"
project_hash = "81a1ac7894b0ea68ff567c5b0df7a8e9073f52b6"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "8873e196c2eb87962a2048b3b8e08946535864a1"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+4"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "26ec26c98ae1453c692efded2b17e15125a5bea1"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.28.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "c7acce7a7e1078a20a285211dd73cd3941a871d6"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.0"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "64e15186f0aa277e174aa81798f7eb8598e0157e"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "f36e5e8fdffcb5646ea5da81495a5a7566005127"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.3"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e51db81749b0777b2147fbe7b783ee79045b8e99"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.4+3"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "21fac3c77d7b5a9fc03b0ec503aa1a6392c34d2b"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.15.0+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "786e968a8d2fb167f2e4880baba62e0e26bd8e4e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.3+1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "846f7026a9decf3679419122b49f8a1fdb48d2d5"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.16+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "424c8f76017e39fdfcdbb5935a8e6742244959e8"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.10"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "b90934c8cb33920a8dc66736471dc3961b42ec9f"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.10+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "b0036b392358c80d2d2124746c2bf3d48d457938"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.82.4+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "01979f9b37367603e2848ea225918a3b3861b606"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "c67b33b085f6e2faf8bf79a61962e7339a81129c"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.15"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "55c53be97790242c29031e5cd45e8ac296dadda3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.0+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "71b48d857e86bf7a1838c4736545699974ce79a2"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.9"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eac1206917768cb54957c65a615460d87b455fc1"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.1+0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "27ecae93dd25ee0909666e6835051dd684cc035e"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+2"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "8be878062e0ffa2c3f67bb58a595375eda5de80b"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.0+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "ff3b4b9d35de638936a525ecd36e86a8bb919d11"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "df37206100d39f79b3376afb6b9cee4970041c61"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.51.1+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "89211ea35d9df5831fca5d33552c02bd33878419"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.3+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "4ab7581296671007fc33f07a721631b8855f4b1d"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.1+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e888ad02ce716b319e6bdb985d2ef300e7089889"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.3+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "72aebe0b5051e5143a079a4685a46da330a40472"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.15"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "926c6af3a037c68d02596a44c22ec3595f5f760b"
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "030ea22804ef91648f29b7ad3fc15fa49d0e6e71"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.3"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "12f1439c4f986bb868acda6ea33ebc78e19b95ad"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.7.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.44.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ed6834e95bd326c52d5675b4181386dfbe885afb"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.55.5+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "dae01f8c2e069a683d3a6e17bbae5070ab94786f"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.9"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "5152abbdab6488d5eec6a01029ca6697dff4ec8f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.23"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "492601870742dcd38f233b23c3ec629628c1d724"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.7.1+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "e5dd466bf2569fe08c91a2cc29c1003f4797ac3b"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.7.1+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "1a180aeced866700d4bebc3120ea1451201f16bc"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.7.1+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "729927532d48cf79f49070341e1d918a65aba6b0"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.7.1+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "c0667a8e676c53d390a09dc6870b3d8d6650e2bf"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.22.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "85c7811eddec9e7f22615371c3cc81a504c508ee"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+2"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5db3e9d307d32baba7067b13fc7b5aa6edd4a19a"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.36.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "a2fccc6559132927d4c5dc183e3e01048c6dcbd6"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.5+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "7d1671acbe47ac88e981868a078bd6b4e27c5191"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.42+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "beef98d5aad604d9e7d60b2ece5181f7888e2fd6"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.6.4+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "326b4fea307b0b39892b3e85fa451692eda8d46c"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.1+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "3796722887072218eabafb494a13c963209754ce"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "9dafcee1d24c4f024e7edc92603cedba72118283"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+3"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e9216fdcd8514b7072b43653874fd688e4c6c003"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.12+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "807c226eaf3651e7b2c468f687ac788291f9a89b"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.3+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "89799ae67c17caa5b3b5a19b8469eeee474377db"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.5+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d7155fea91a4123ef59f42c4afb5ab3b4ca95058"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+3"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "6fcc21d5aea1a0b7cce6cab3e62246abd1949b86"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.0+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "984b313b049c89739075b8e2a94407076de17449"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.2+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a1a7eaf6c3b5b05cb903e35e8372049b107ac729"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.5+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "b6f664b7b2f6a39689d822a6300b14df4668f0f4"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.4+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a490c6212a0e90d2d55111ac956f7c4fa9c277a6"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+1"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c57201109a9e4c0585b208bb408bc41d205ac4e9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.2+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "1a74296303b6524a0472a8cb12d3d87a78eb3612"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "dbc53e4cf7701c6c7047c51e17d6e64df55dca94"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+1"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "ab2221d309eda71020cdda67a973aa582aa85d69"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+1"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6dba04dbfb72ae3ebe5418ba33d087ba8aa8cb00"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.1+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "622cf78670d067c738667aaa96c553430b65e269"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+0"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6e50f145003024df4f5cb96c7fce79466741d601"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.56.3+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0ba42241cb6809f1a278d0bcb976e0483c3f1f2d"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+1"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "522c1df09d05a71785765d19c9524661234738e9"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.11.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d7b5bbf1efbafb5eca466700949625e07533aff2"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.45+1"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "63406453ed9b33a0df95d570816d5366c92b7809"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+2"
"""

# ╔═╡ Cell order:
# ╟─1a47d504-da67-11ef-1188-7b0242ee46fb
# ╟─b0d766cc-7cf0-495a-a3f9-9c97c9fa6af9
# ╠═981ca2b5-f92f-4410-b80c-e8ccabd008d5
# ╟─7915c630-fbf1-4bee-8728-5fdeec03acda
# ╠═82bd4967-153d-4c95-99a2-7c3dcfa8a5f2
# ╟─4232909a-eef5-4db8-81a9-ea35b1751019
# ╟─74194f3b-cce3-41a2-9c68-752a8e2907a9
# ╟─8bc3787a-0671-4b3e-a3e6-277263c9181b
# ╠═d5710498-2f50-4663-8a5d-4badca0959c2
# ╠═f8505334-0976-4c7d-98b8-698b9804da99
# ╟─8551adf3-6487-44b6-9cc8-f7aacfe67eee
# ╟─38abb573-46d6-4c54-b092-b72e4430f3ee
# ╟─ae4d63c8-9285-4b15-9978-64547c7aed65
# ╟─2bdbaba7-39bc-4ca0-a090-4d9176cf9a62
# ╟─5e184816-d1a2-47f3-9b8d-5a8c6307a0f3
# ╟─91bcb310-8438-48eb-972d-e1e4cb27c8bc
# ╠═d72b775b-f464-4a10-839d-af6c0bfa0348
# ╟─4356c491-6fac-4a51-9830-22ffef3a6aea
# ╠═61650532-a8ee-4b84-847d-83b2f97095a0
# ╟─9c858137-4c28-47d0-8cd3-1566c81eee7f
# ╠═e0a0b9e0-f60c-40c4-b1af-17258af2de77
# ╟─82504448-5dc7-4121-aff2-58df81df9469
# ╟─d543c42d-1eb7-4b98-b50e-896d0dcd8b0f
# ╠═642b9276-33d2-4072-aa58-518d26b1664a
# ╠═ac9e6a70-b4db-4ce9-bc86-26a0438185d7
# ╟─74d01961-0a6a-4d35-866f-3473fea20840
# ╠═b8812a7c-f4f0-497f-aa64-1ad947f43e69
# ╠═4054b18d-64ba-485c-82b1-9eb3443ce8c0
# ╠═1cf0fac8-6556-4736-91d6-2be9a5c67a27
# ╟─401568d6-b4a1-4275-8382-3ec03fa3a981
# ╠═330af40e-04c2-4f99-a0c4-5814e74ef4ff
# ╠═552332e2-7cee-41e5-8730-8fb12872cb22
# ╟─809ee2fb-2a4a-4935-ac6d-33744f2d9c79
# ╠═908a45a4-03cf-43fb-88a2-28299e8ee786
# ╠═d929f9b0-b340-4145-b9e2-87f6ada614d1
# ╟─44639a99-983d-41c9-b7e0-a4a5886bb891
# ╠═f5b749a2-23cd-4d41-b1f2-0d3a4856bb5c
# ╟─18a12ada-b884-49cf-909f-e98fe2aeb883
# ╠═93c58936-6063-45f0-bbf3-04571176b930
# ╟─14edd542-98d8-4b45-b13c-1d84765e233a
# ╟─6a6faced-3793-4053-bfd3-e5e19d3c1dca
# ╟─2b9fe065-1fd7-46b4-84b2-d300ce09fdaa
# ╠═755cd536-e19f-4290-be51-e4d024a081d2
# ╠═f7781783-5374-47d2-901e-074417e91541
# ╠═f59f969b-2d87-4c4c-ae86-762f5bf1c842
# ╟─f5140ee4-7ba9-4fdd-9a14-2b215d091cf6
# ╟─f3a7682d-54f9-4768-8d15-1199c53bc00f
# ╟─56553c22-2abf-469a-b0b4-aeaf59c31dc6
# ╟─4c688c33-bba2-4bea-8cb1-e7f5209f465e
# ╟─5a555d98-18b7-4c51-8bc2-06896c0292b8
# ╠═ee7c7f0c-d9b9-42a4-9307-3834c738dbeb
# ╟─d84d8493-ff2e-4b2b-b457-389d2d64e77d
# ╠═5c5f59d2-0faf-4c62-a370-6bf2ed98d6c4
# ╠═22e2bb79-be53-4474-ad7f-b220436d4c00
# ╠═6bbc74c1-7741-41f0-89ec-877047c9e96d
# ╟─8c4d140a-3228-4e10-9fb4-6e5f822c14a3
# ╠═4fed483a-3f6c-4421-bcea-5a061a950465
# ╠═29fc98d4-9ba9-4572-8847-d158c44d9b02
# ╠═07bb8a5c-ac57-45ca-8c09-83df56c78257
# ╟─7318875f-e93c-4433-924d-2be64e71d502
# ╟─e5cd4840-3bd0-42f9-a11f-bdcd35333b40
# ╟─79ee2e6b-66b3-449d-bcb8-40800da02610
# ╠═2b7598bc-fba2-4ca2-a6b0-e37e96a7b2f8
# ╟─136ad7e4-0b1a-4a73-9722-2627195a71e7
# ╠═3baf8a83-11c0-434f-9d25-cc4d64b32bf6
# ╟─e626a2e3-929f-4318-b42c-4674b59f5f66
# ╠═f4f2fb53-e396-4f7c-ad2a-9b168e18f528
# ╟─20887d53-bd86-491b-ad70-459693f603e9
# ╠═6b34d94f-ab70-4cd4-b2fd-c286273efb20
# ╠═eb01deb2-2587-48f5-85f2-b2b1efc7d794
# ╟─1517018b-da24-4ab7-9f84-bad32410a097
# ╠═0a34fdc0-6c1a-42b2-a4b7-03f39c5fa423
# ╟─ac421b6c-58a8-4225-8e19-3c6e8568ef66
# ╟─3fca957b-e017-4ab7-934e-71f9a65759af
# ╟─42f60b8d-6c64-4701-aa76-efcaa1f2cc45
# ╟─f0d5afdd-ce75-4f19-93bf-208870fcbdb7
# ╠═b9d204b8-eb92-413b-80cf-76997fd30a09
# ╠═ffb30ebd-b8a5-4f3e-bcc2-c2d9d4dba845
# ╠═9f65b5d9-4d1f-4c42-8613-92ded9987edb
# ╠═04700882-1230-4012-b367-3502c11dce46
# ╠═28e544ae-aeac-4da3-aa2f-1beda3bb04b4
# ╠═1161a6d3-8bfa-4d38-be4d-43b2cc0a1c40
# ╠═e18df7d1-1af5-4155-8bcd-04ed63f96845
# ╠═5653b0c3-ce58-4935-89e8-cdb5f5389e87
# ╟─aed4d675-d725-44af-a2d8-b5e9160a6214
# ╠═39056ece-e86f-4637-a2bb-5c81aa043261
# ╟─bad2dbd9-5bfa-4d8a-a33c-7ff73718923e
# ╟─f69cb2ca-5c9e-4337-8e11-6e4cb4eef882
# ╠═4b6dfe00-5b96-459c-b591-1d7ab948a53c
# ╠═9b17d4f5-40c3-4f9f-b3ae-9e0b01aa0d50
# ╠═c77256b0-4ca7-4aff-8718-0778f33702f6
# ╠═ae5eccd0-ceda-4be4-a83c-4943dd59c411
# ╟─ae211c87-5c58-403d-ac75-cc97da87af38
# ╟─c79c43cf-ef87-41fe-b3aa-0928fc08ed2d
# ╠═dc5ad53b-f105-4f00-8756-9087aab87abf
# ╠═00fce8aa-7760-4a20-825b-f5c1b54d480b
# ╠═46e1712d-1019-483d-8aba-8fde7f27c565
# ╠═89befc48-b2a1-4f94-83d8-7afee54498c5
# ╠═a8feca0a-95df-4d11-97a6-61f2b5a79397
# ╟─a2861049-d1a6-45df-aa4e-9ad494487827
# ╟─e7632467-e079-4073-aea6-4fdeee42f32d
# ╠═1aad12b5-1af0-4b60-8e9c-a43296f6cd29
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

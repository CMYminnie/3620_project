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

# ╔═╡ 95c9b1cb-e413-4009-a832-a676be35636c
### A Pluto.jl notebook ###
# v0.20.24

using Markdown

# ╔═╡ c51dc284-e083-4f95-9dce-2759ec611bab
using InteractiveUtils

# ╔═╡ 26a0adb1-1409-4775-8cff-9aa2217903c6
using Dates

# ╔═╡ 4aa83f77-90a8-4f20-8669-46bf2f979059
using Printf

# ╔═╡ 8e5cd055-1d1a-4d82-bc0d-ae6ef7e2adfe
begin
	using AeroFuse
	using PlutoUI
	using DataFrames
	using Plots
	using StaticArrays
	gr(size = (800,600))
	TableOfContents()
end

# ╔═╡ f416ccd5-5c3e-4e11-a842-b72dadbf4226
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

# ╔═╡ e64fb8a4-b40d-4b53-887d-bb5132d30a82
md"""
# Weight & Balance with Stability Analysis

## Example: Jet Aircraft -- Boeing 777-200LR

![](https://www.norebbo.com/wp-content/uploads/2012/12/777-200-custom-livery-001.jpg)

**Source**: [https://www.norebbo.com/wp-content/uploads/2012/12/777-200-custom-livery-001.jpg](https://www.norebbo.com/wp-content/uploads/2012/12/777-200-custom-livery-001.jpg)

"""

# ╔═╡ f1ec4070-8fbc-4088-8506-6c4c789b4dec
begin
	ϕ_s1 			= @bind ϕ1 Slider(0:1e-2:90, default = 15)
	ψ_s1 			= @bind ψ1 Slider(0:1e-2:90, default = 30)
	ϕ_s2 			= @bind ϕ2 Slider(0:1e-2:90, default = 15)
	ψ_s2 			= @bind ψ2 Slider(0:1e-2:90, default = 30)
	ϕ_s3 			= @bind ϕ3 Slider(0:1e-2:90, default = 15)
	ψ_s3 			= @bind ψ3 Slider(0:1e-2:90, default = 30)
end;

# ╔═╡ 9ebd5f97-4f94-4eb1-9d4d-1d40009a1476
md"""### Wing
First, you can define the wing from your preliminary wing sizing. Here, we'll choose a supercritical airfoil for the wing section. **This is not the same one as used in the Boeing 777-200LR.**
"""

# ╔═╡ 050da6ba-9fae-4f6e-a644-a48a621d8fdd
begin
foil_w_root = read_foil("C:\\Users\\CMY\\OneDrive\\Desktop\\Airfoil\\NASA SC(2)-0714.txt") 
	# Read the root airfoil
foil_w_tip  = read_foil("C:\\Users\\CMY\\OneDrive\\Desktop\\Airfoil\\NASA SC(2)-0714.txt") 
	#Read the tip airfoil
end

# ╔═╡ 610612f6-91c9-45ab-922f-400a1765e2ac
plot(foil_w_root, aspect_ratio = 1)

# ╔═╡ 6ba64e0f-ac22-4203-b175-f15b124cda20
md"""Here, we'll define a two-section wing planform that we'll use in this notebook."""

# ╔═╡ 164bed18-6886-4055-b25e-1624a34e5b7f
wing = Wing(
    foils       = [foil_w_root, foil_w_root, foil_w_tip],              # Airfoils
   	chords 		= [5.1655749037, 3.427880928, 1.690012819],  	# Chord lengths 
    spans       = [5.0, 7.915],             # Span lengths
    dihedrals   = [5.0, 7.0],               # Dihedral angles (deg)
    sweeps      = [30.0, 30.0],             # Sweep angles (deg )
    w_sweep     = 0.0,                      # Leading-edge sweep
    position    = [9.3, 0.0, -1.0],      	 # HOW DO YOU DETERMINE THIS?
    symmetry    = true,                      # Symmetry
    angle       = 5,
    axis        = [0, 1, 0]
)

# ╔═╡ 9cd51ad4-b7fe-4bd4-800f-bf3e48a743e1
md"""
!!! hint
	You may have to change the wing position to maintain weight balance and aerodynamic stability.
"""

# ╔═╡ 5a304070-ce97-45b9-945a-5a3bef23ee71
sweeps(wing, 0.25)  # Quarter-chord sweep angles

# ╔═╡ 22735a60-aafc-4b14-9f00-fc625e862d88
md"The following quantities will be useful for evaluation of the static stability."

# ╔═╡ 8765c09d-65a1-4ff2-a906-0886598b04e4
begin
	AR_w = aspect_ratio(wing)
	S_w = projected_area(wing)
	lambda_w = deg2rad(sweeps(wing, 0.)[1]) # Leading-edge sweep angle, rad
	b_w = span(wing)
	c_w = mean_aerodynamic_chord(wing)
end;

# ╔═╡ d1bb7c89-03ea-4a94-86ac-85f33a52f841
md"Let's compute the mean aerodynamic center, which is at 25% of the mean aerodynamic chord by default. Go to the appendix in this notebook to see how this is calculated!."

# ╔═╡ 3b85dffb-381d-47f5-8f78-9af754b38fa2
mac25_w = mean_aerodynamic_center(wing, 0.25)

# ╔═╡ a049009a-a004-4e1e-ac97-4c14b2c8cc0f
mac25_w.x 	# x-coordinate of mean aerodynamic center at 25%

# ╔═╡ 11940b7c-6e2a-4655-b95a-8c4c56cb6dbe
mac25_w.y 	# y-coordinate of mean aerodynamic center at 25%

# ╔═╡ 9f6226c6-dc1e-4d32-9b80-b21946d85f8a
md"You can also use this function to compute the centroid at various chordwise ratios."

# ╔═╡ bbb8f33f-2fb4-4cab-8573-2255e9b2cdaa
mac40_w = mean_aerodynamic_center(wing, 0.40) # at 40% of the chord length

# ╔═╡ e7367b43-8045-4528-89e0-aca2a8b3b420
mac40_w.x 	# x-coordinate of mean aerodynamic center at 40%

# ╔═╡ 75dd41f9-5f61-45ee-9d90-0fab44f1b29b
md"""
!!! warning
	The choice of the mean aerodynamic center percentage is important when considering subsonic or supersonic flow! From thin airfoil theory, the mean aerodynamic center for subsonic flow is located at approximately $25\%$ of the chord length. As the flow reaches supersonic conditions, the mean aerodynamic center is experimentally observed to gradually move aft, to approximately $50\%$.
"""

# ╔═╡ 29b9e3bf-ffc5-452f-9c61-35a43bc313b6
md"### Engines
We can also place the engines based on the wing information.
"

# ╔═╡ 0387074d-4e1a-488b-9f53-6a787e800a55
wing_coo = coordinates(wing) # Get leading and trailing edge coordinates

# ╔═╡ 07ddffc2-ca74-4752-994b-6717ae703eb6
wing_coo[1,:] # Leading edge coordinates

# ╔═╡ ad88f03f-3dc3-4783-8346-4a6954ad5b63
begin 
	eng_L = wing_coo[1,2] - [1, 0., 0.] # Left engine, at mid-section leading edge
	eng_R = wing_coo[1,4] - [1, 0., 0.] # Right engine, at mid-section leading edge
end;

# ╔═╡ 13f8e443-5272-4a7c-8f32-e0d39d86a0f8
md"### Fuselage"

# ╔═╡ ac56d7ca-e7ee-4e37-82b9-22e06610263a
fuse = HyperEllipseFuselage(
	radius = 1.7, 			# Radius, m (diameter 3.4)
	length = 32, 			# Length, m
	x_a    = 0.145, 		# Start of cabin, ratio of length
	x_b    = 0.81,  			# End of cabin, ratio of length
	c_nose = 1.3,  			# Curvature of nose
	c_rear = 1.2,  			# Curvature of rear
	d_nose = -0.75, 			# "Droop" or "rise" of nose, m
	d_rear = -0.09,  			# "Droop" or "rise" of rear, m
	position = [-0.123,0.,0.] 	# Set nose at origin, m
);

# ╔═╡ 2d41d953-f895-470b-b5c6-3059c4d23210
ts = 0:0.01:1 # Distribution of each section for surface area and volume computation

# ╔═╡ 556483ff-587b-48d0-93cc-625fd3a4fa14
S_f = wetted_area(fuse, ts) # Surface area, m²

# ╔═╡ 4bf8f4fb-63da-4316-aad6-4d0a74563415
V_f = volume(fuse, ts) # Volume, m³

# ╔═╡ 31bb27f3-ea48-4ea6-b111-b6a8338ced67
fuse_end_x = fuse.affine.translation.x + fuse.length # x-coordinate of fuselage end

# ╔═╡ 37afde2e-d341-4273-9f61-5047abec4ccb
md"### Visualization"

# ╔═╡ ae84a119-649c-49af-8330-657acff20cc5
camera_angles1 = md"""
ϕ: $(ϕ_s1)
ψ: $(ψ_s1)
"""

# ╔═╡ af59e555-ad11-4228-8e8c-73dcc1bee42c
begin
	p1 = plot(
			# aspect_ratio = 1, 
			zlim = (-0.5, 0.5) .* span(wing),
			camera = (ϕ1, ψ1)
		)

	# Fuselage and wing
	plot!(fuse, alpha = 0.3, label = "Fuselage")
	plot!(wing, 
		0.4, 		 # Can set the MAC factor (40% here)
		mac = false, # Can disable MAC plot
		label = "Wing",
	)
	
	# Engines
	scatter!(Tuple(eng_L), label = "Engine Left")
	scatter!(Tuple(eng_R), label = "Engine Right")
end

# ╔═╡ 78b06118-4099-40f4-ad9b-5b47679c9e37
md"## Stabilizer Design"

# ╔═╡ 86810a39-1cc4-48f0-ab57-851fd45aa212
md"### Horizontal Tail"

# ╔═╡ a42bf88e-1f2d-44ad-a35b-c9f0e24881ff
con_foil = control_surface(naca4(0,0,0,9), hinge = 0.91, angle = 0)

# ╔═╡ 77cd36fb-456c-4d33-85c0-54d95a67e0c5
htail = WingSection(
    area        = 18,  # HOW DO YOU DETERMINE THIS?--> Area~12.5-25% S_wing
    aspect      = 7.1,  
    taper       = 0.25,  
    dihedral    = 0.,   
    sweep       = 30.,  
    w_sweep     = 0.,   # Leading-edge sweep
    root_foil   = con_foil, 		# Root airfoil
	tip_foil    = con_foil, 		# Tip airfoil
    symmetry    = true,
    
    ## Orientation
    angle       = -3,           # Incidence angle (deg), HOW DO YOU DETERMINE THIS?
    axis        = [0., 1., 0.], # Axis of rotation, y-axis
    position    = [ fuse_end_x - 4.0, 0., 0.], # HOW DO YOU DETERMINE THIS?
);

# ╔═╡ bb470818-b822-4538-b459-8d8f33edb7fd
begin
println("Wing MAC x: ", mean_aerodynamic_center(wing, 0.25).x)
println("HTail MAC x: ", mean_aerodynamic_center(htail, 0.25).x)
end

# ╔═╡ 409a7733-9e9d-4604-af4b-12f831cfc36e
begin
	AR_h 		= aspect_ratio(htail)
	S_h 		= projected_area(htail)
	lambda_h 	= deg2rad(sweeps(htail)[1])
	mac25_h 	= mean_aerodynamic_center(htail, 0.25)
	mac40_h 	= mean_aerodynamic_center(htail, 0.4)
end;

# ╔═╡ ff4e7014-d4cf-4da2-b3e6-ecbe8f7dc1e2
md"""
Recall the definition of the tail volume coefficient:

```math
V_h = \frac{S_h l_h}{S_w \bar c}
```

"""

# ╔═╡ 3dffc1de-d32a-4667-9296-02201fac0584
l_h = mac25_h.x - mac25_w.x # Horizontal tail moment arm

# ╔═╡ 4c2a7d02-5284-4bfa-97e8-591f7d00ade3
V_h = S_h / S_w * l_h / c_w # Horizontal tail volume coefficient

# ╔═╡ c3d409eb-b894-4216-9d0f-f7ee8b3c7d77
md"### Vertical Tail"

# ╔═╡ 597fc036-5c95-4b41-ab39-d23c36678b67
vtail = WingSection(
    area        = 6.183, # HOW DO YOU DETERMINE THIS?
    aspect      = 3.12,
    taper       = 0.25,
    sweep       = 30,
    w_sweep     = 0.,   # Leading-edge sweep
    root_foil   = naca4(0,0,1,2),
    
    ## Orientation
    angle       = 90.,       # To make it vertical
    axis        = [1, 0, 0], # Axis of rotation, x-axis
    position    = htail.affine.translation + [0.082,0.,-0.01] # HOW DO YOU DETERMINE THIS?
); # Not a symmetric surface

# ╔═╡ 48243c4c-69b4-4bf0-8371-71968c56e72b
chords(vtail)

# ╔═╡ 31713842-a036-457d-9f06-87e0c5caae3d
md"### Visualization"

# ╔═╡ 28906501-f75e-48fb-aceb-a19106b01b21
begin
	S_v = projected_area(vtail)
	mac25_v = mean_aerodynamic_center(vtail, 0.25)
	mac40_v = mean_aerodynamic_center(vtail, 0.4)
end;

# ╔═╡ e81ae7f8-1f1b-4a08-a469-6348c4342943
md"""Recall the tail volume coefficient:

```math
V_v = \frac{S_v l_v}{S_w b}
```
"""

# ╔═╡ bd4b83d7-1b48-458f-a840-f610a0913313
l_v = mac25_v.x - mac25_w.x # Vertical tail moment arm

# ╔═╡ 189a0b36-736d-4f56-8245-0c32087ac9de
V_v = S_v / S_w * l_v / b_w # Vertical tail volume coefficient

# ╔═╡ 43ad7cd9-5e00-44a0-8453-5df3e584addf
md"""### Static Margin Estimation

The weights of the components of the aircraft are some of the largest contributors to the longitudinal stability characteristics.

![](https://raw.githubusercontent.com/HKUST-OCTAD-LAB/MECH3620Materials/main/pics/777200LRMoments.svg)

In addition to the weights, the aerodynamic forces depicted are also major contributors to the stability of a conventional aircraft configuration.

![](https://raw.githubusercontent.com/HKUST-OCTAD-LAB/MECH3620Materials/main/pics/777200LR.svg)

**CAD Source:** [https://grabcad.com/library/boeing-777-200](https://grabcad.com/library/boeing-777-200)

This interrelationship between aerodynamics and weights on stability is expressed via the static margin.

```math
\text{Static Margin} = \frac{x_{np} - x_{cg}}{\bar c} 
```

We need to determine both of these locations: the center of gravity $x_{cg}$ and the neutral point $x_{np}$.
"""

# ╔═╡ dfcef291-2876-4180-9160-36c556485c9b
md"""
#### Center of Gravity

The aircraft’s center of gravity (CG) is defined as:
```math
\mathbf{r}_\text{cg} = \frac{\sum_i W_i \ (\mathbf{r}_{\text{cg}})_i}{\sum_i W_i}, \quad \mathbf{r} = \begin{bmatrix}
  x \\ y \\ z
\end{bmatrix}
```

where $W_i$ represents the weight for each component and $(\mathbf r_{\text{cg}})_i$ is the position vector between the origin and the CG of the $i$th component. The product in the form $W_i(\mathbf r_{\text{cg}})_i$ is also referred to as the moment induced by the $i$th component.

Considering a takeoff gross weight of 766000 lbs and using Raymer's "quick and dirty approach", the specific weight and position parameters of the structural components are shown in the following table:

Components | Loading (lb/ft²) | Reference Area (ft²) | Approximate Location
:-------- | :-----: | :----------:|----------:
Wing     | 10  | $(S_w * 10.7639)    | 40% MAC
Horizontal tail     | 5.5  | $(S_h * 10.7639)     | 40% MAC
Vertical tail     | 5.5  | $(S_v * 10.7639)   | 40% MAC
Fuselage     | 5  | $(S_f * 10.7639)    | 40-50% Length

Components | Weight Ratio | Reference Weight (lb) | Approximate Location
:-------- | :-----: | :----------:|----------:
Nose landing gear | 0.043 * 15% | 766 000 | Centroid
Main landing gear | 0.043 * 85% | 766 000 | Centroid
Installed engine     | 1.3 | 36 520     | Centroid
“All-else empty”    | 0.17  | 766 000     | 40-50% Length

Note: We consider the **nose** as the reference point and **clockwise moments** as positive!
"""

# ╔═╡ c128e913-3bd6-431e-89f9-2b7f1896aa7b
md"""

!!! warning
	These are not all the weights present in the aircraft! So which CG are you estimating?

"""

# ╔═╡ 6bdc79ec-802f-4786-b0d0-fbe849ed231d
begin
	# Reference quantities
	TOGW = 33614.1 # Takeoff gross weight, kg (changed)
	W_engine = 1179 # GE CF34-8E engine weight (single), kg
end;

# ╔═╡ bbe1641b-7119-45e9-9a74-33c20732b34c
lb_ft2_to_kg_m2 = 4.88243 # Convert lb/ft² to kg/m²

# ╔═╡ fc9ae1d0-31a7-4634-be4d-089268f78cb9
md"For the previously generated wing, the total longitudinal moment (with MAC at $40%) with respect to the nose as origin is:"

# ╔═╡ 92db82cd-f153-4228-ab48-e2bef5da0553
M_w = (12.2 * lb_ft2_to_kg_m2 * S_w) * mac40_w.x # Moment generated by wing weight

# ╔═╡ 1123c67e-f1dc-4b18-9e42-86a2db615d85
md"We can express the landing gear, fuselage, and all-other component centroids  in terms of the fuselage length and its origin, the nose in this case."

# ╔═╡ 7a8d4ab5-9394-4205-9014-a8e1da3b29e7
begin
	x_nose 	= fuse.affine.translation.x 	# Nose location 
	x_fuse 	= x_nose + fuse.length / 2   	# Fuselage centroid (50% L_f)
	x_other = x_nose + fuse.length / 2 		# All-other component centroid (50% L_f)
	x_nLG  	= x_nose + 0.15 * fuse.length  	# Nose landing gear centroid (15% L_f)
	x_mLG 	= x_nose + 0.5 * fuse.length  	# Main landing gear centroid (50% L_f)
end;

# ╔═╡ b551cba7-d4ac-4f48-9d99-08ef0d28b58e
begin
	md"""The weight and CG position of each component can hence be computed and included in a dictionary for convenience in calculations."""
	
	# ---- payload / loading assumptions ----
	n_crew = 4
	n_pax  = 70              # or whatever your team finalized
	
	W_crew = n_crew * 90.0   # kg, adjust if your team uses another crew mass
	W_pax  = n_pax  * 90.0   # kg
	W_bag  = n_pax  * 15.0   # kg
	W_fuel = 9647.2467          # <-- replace with your actual fuel weight from sizing
	
	# ---- representative x-locations ----
	# replace these with values from your cabin / tank layout
	x_crew = x_nose + 0.12 * fuse.length
	x_pax  = x_nose + 0.45 * fuse.length
	x_bag  = x_nose + 0.50 * fuse.length
	x_fuel = mac40_w.x       # acceptable first-pass if wing tank fuel
end

# ╔═╡ 9ffbd29e-d28b-4ddb-8f36-e563d0342c48
weight_position = Dict(	
	"engine" 	=> (1.3 * 2 * W_engine, 			eng_L.x), 	# Engines (2 × weight)
	"wing"   	=> (S_w * 12.2  * lb_ft2_to_kg_m2, 	mac40_w.x), # Wing, 40% MAC
	# changed the wing loading from 10 to 12.2 
	"htail"  	=> (S_h * 5.5 * lb_ft2_to_kg_m2, 	mac40_h.x), # HTail, 40% MAC
	"vtail"  	=> (S_v * 5.5 * lb_ft2_to_kg_m2, 	mac40_v.x), # VTail, 40% MAC
	"fuse"   	=> (S_f * 5.0 * lb_ft2_to_kg_m2, 	x_fuse), 	# Fuse, centroid
	"all-else" => (
    TOGW - (
        (1.3 * 2 * W_engine) +
        (S_w * 12.2 * lb_ft2_to_kg_m2) +
        (S_h * 5.5 * lb_ft2_to_kg_m2) +
        (S_v * 5.5 * lb_ft2_to_kg_m2) +
        (S_f * 5.0 * lb_ft2_to_kg_m2) +
        (0.043 * 0.15 * TOGW) +
        (0.043 * 0.85 * TOGW) +
        W_crew + W_pax + W_bag + W_fuel
    ),
    x_other),
	"noseLG" 	=> (0.043 	* 0.15 * TOGW, 			x_nLG), 
	"mainLG" 	=> (0.043 	* 0.85 * TOGW, 			x_mLG),
    "crew"      => (W_crew, x_crew),
    "passenger" => (W_pax,  x_pax),
    "baggage"   => (W_bag,  x_bag),
    "fuel"      => (W_fuel, x_fuel), 
);

# ╔═╡ 124ce647-2f07-4007-a733-31958b557309
W_wing, x_wing = weight_position["wing"] # Get weight and position of 'wing' entry

# ╔═╡ f3bebf5c-5e2d-47d6-b67b-9110fc3b85f6
keys(weight_position) # Get keys of the dictionary

# ╔═╡ ec810b63-51ea-4107-9fcb-a5b1be5dc0eb
values(weight_position) # Get corresponding values of the dictionary

# ╔═╡ 6d7379c2-fc6f-4e5b-b24c-562d71379e16
md"""

!!! warning 
	Dictionaries are **not ordered** according to the entries upon generation.
"""

# ╔═╡ 0b9a2567-17b6-473b-9208-9f5f3eed0d66
md"Now we can calculate the total longitudinal moments generated from all the components, i.e., $\sum_i W_i x_{\text{cg}_i}$"

# ╔═╡ cf216293-7a07-4cc1-a702-931feae1c1b7
moments = [ weight * pos_x for (weight, pos_x) in values(weight_position) ]

# ╔═╡ 49c1a50e-6291-4f05-bf21-ab05d0caa2c7
M_sum = sum(moments) # Sum all moments

# ╔═╡ b0333914-e068-4a5d-bd6a-ffe41f490aa2
md"The same applies to the total weight, i.e., $\sum_i W_i$"

# ╔═╡ bc98f5fc-bc79-4171-87cc-720a82508d49
W_sum = sum(weight for (weight, pos_x) in values(weight_position)) # Sum weights

# ╔═╡ c6ae323e-9fe0-4766-909d-7a7554afd5d1
x_cg = M_sum / W_sum 	# Compute center of gravity, m

# ╔═╡ e7af56e2-df6e-4dbe-8ced-b5b6dd14eabb
md"#### Neutral Point

The neutral point is:
```math
\frac{x_{np}}{\bar c} = V_h\frac{C_{L_{\alpha_h}}}{C_{L_{\alpha_w}}} - \frac{\partial C_{m_f}}{\partial C_L}, \qquad V_h = \frac{S_h l_h}{S_w \bar c}
```
"

# ╔═╡ 32256af7-86ce-47b8-87f8-57aadfc44853
function neutral_point(V_h, CL_αh, CL_αw, dCm_fuse_dCL)
	x_np = V_h * CL_αh / CL_αw - dCm_fuse_dCL
	return x_np;
end;

# ╔═╡ 132043b6-d081-4877-aad1-e24a0c711570
md"""3 parameters are unknown after the sizing and placement of the empennage:
1. The lift curve slope for the wing $C_{L_{\alpha_w}}$ 
2. The lift curve slope of the horizontal stabilizer $C_{L_{\alpha_h}}$ 
3. Derivative of pitching moment of fuselage (including other components) with respect to $C_L$ $\frac{\partial C_{m_{f}}}{\partial C_L}$ 
"""

# ╔═╡ 502090a9-25bf-4106-a154-49b1b538285b
md"Let's determine the distance between the CG and the aerodynamic center of the wing using the values from the previous section."

# ╔═╡ 2f7a0365-05c9-4c4b-bf69-d0ff31d8fb8b
begin
	dist_cg_mac = x_cg - mac40_w.x
	println("Distance Between CG and Aerodynamic Center of the Wing: ", dist_cg_mac)
end

# ╔═╡ 143593fe-b9c4-427b-becd-c1d74111bb22
md"""

!!! danger "Sanity Check"
	If it's negative, it means the CG is ahead of the wing's aerodynamic center with respect to the nose as the origin! 
"""

# ╔═╡ b24ec168-ca9f-4b66-ba45-fcd33f984984
md"Keep in mind that the neutral point is the equivalent of the aerodynamic center of the aircraft, namely including all lifting surfaces!"

# ╔═╡ 226b0d86-31dc-4726-871c-5b2eb3506809
md"##### Wing Contribution
The wing lift curve slope can be approximated using the DATCOM formula.
```math
 C_{L_{\alpha_w}} \approx \frac{2\pi AR_w}{2 + \sqrt{(AR_w/\eta)^2 (1 + \tan^2\Lambda_w - M^2) + 4}}
```
"

# ╔═╡ 386f7f9c-1a16-4057-ad01-c38203dbb592
function lift_slope_DATCOM(AR, eta, sweep_LE, M)
	CL_α_w = 2π * AR / (2 + sqrt((AR/eta)^2 * (1 + tan(sweep_LE)^2 - M^2) + 4))
	return CL_α_w
end

# ╔═╡ 541649ee-6505-4814-b5c8-bc0ce6c4d56a
# Example
begin
	eta = 0.97 # Aerodynamic efficiency factor (for DATCOM formula)
	M = 0.78 # operating cruise Mach number
	CL_α_w = lift_slope_DATCOM(AR_w, eta, lambda_w, M)
end

# ╔═╡ 757f8a70-94b1-4982-8e02-cd791b631555
md"##### Horizontal Tail Contribution
The downwash effect on the lift curve slope of the horizontal stabilizer is estimated by applying lifting line theory. For an elliptically loaded structure:
```math
C_{L_{\alpha_h}} = C_{L_{\alpha_{h_0}}} \left(1 - \frac{\partial \epsilon}{\partial \alpha} \right)\eta_h, \qquad \frac{\partial \epsilon}{\partial \alpha} \approx \frac{2C_{L_{\alpha_w}}}{\pi AR_w}
```

where $\epsilon$ is the _downwash angle_, and $\eta_h$ is the horizontal stabilizer aerodynamic efficiency which accounts for changes in the flow due to the wing.
"

# ╔═╡ d9c988b4-5403-4ec4-9845-b1568da8bf6b
function downwash_slope(CL_α_w, AR_w)
	∂ϵ_∂α = 2 * CL_α_w / (π * AR_w)
	return ∂ϵ_∂α
end

# ╔═╡ 4f6a34c6-f974-4359-a502-3d4f738029e9
function lift_slope_tail_DATCOM(AR_h, eta_h, sweep_LE_h, M, CL_α_w, AR_w)
	CL_α_0 = lift_slope_DATCOM(AR_h, eta_h, sweep_LE_h, M) # DATCOM, ∂CL/∂α_0
	∂ϵ_∂α = downwash_slope(CL_α_w, AR_w)
	corr = (1 - ∂ϵ_∂α) * eta_h # Correction factor
	return CL_α_0 * corr # corrected lift-curve slope
end

# ╔═╡ c8268482-c7e4-46bb-9166-7f6d08107334
eta_h = 0.88 # Horizontal stability aerodynamic efficiency factor (for DATCOM)

# ╔═╡ ec8b9d88-b84e-49d0-9821-70a479c05df5
CL_α_h = lift_slope_tail_DATCOM(AR_h, eta_h, lambda_h, M, CL_α_w, AR_w) # 1/radians

# ╔═╡ 1f8c5e8d-ebf6-4f1b-8a17-37ea9ada6e4b
md""" ##### Fuselage Contribution
The moment-lift derivative of the fuselage is estimated via slender-body theory, which primarily depends on the volume of the fuselage. 

```math
\frac{\partial C_{m_f}}{\partial C_L} \approx \frac{2\mathcal V_f}{S_w \bar{c}C_{L_{\alpha_w}}} 
```

!!! tip 
	For estimating the volume without using [AeroFuse](https://github.com/GodotMisogi/AeroFuse.jl), you can initially approximate the fuselage as a square prism of length $L_f$ with maximum width $w_f$ and introduce a form factor $K_f$ as a correction factor for the volume of the actual shape.
	```math
	\frac{\partial C_{m_f}}{\partial C_L} \approx \frac{K_f w_f^2 L_f}{S_w \bar{c}C_{L_{\alpha_w}}}
	```

	Your notes provide the empirical estimation of $K_f$.
"""

# ╔═╡ 6f6022da-3e9c-4c03-8d57-eb5f5e813f64
md"""

!!! hint
	What design requirements would determine the width or height of the fuselage?

"""

# ╔═╡ 8dd6529f-d309-4822-9e4c-052104b5a20a
# Fuselage moment-lift derivative
function fuse_Cm_CL(vol_fuse, S_w, c_bar, CL_α_w)
	fuse_Cm_CL = 2 * vol_fuse / (S_w * c_bar * CL_α_w)
end;

# ╔═╡ 85e9896d-c2d6-43f2-8a7e-43c07e4044fb
Cm_f_CL = fuse_Cm_CL(V_f, S_w, c_w, CL_α_w)

# ╔═╡ c72b730f-8a22-4bdf-974f-7b75bfdb02b7
md"##### Static Margin
Now we can estimate the neutral point of the aircraft.
"

# ╔═╡ 9495c3f8-f947-477b-92ef-2bac79217be0
x_np_by_c = neutral_point(V_h, CL_α_h, CL_α_w, Cm_f_CL) # (xₙₚ/c̄)

# ╔═╡ fd7ca8d9-29b3-4524-9b34-1b60dcdfbf43
x_np = mac40_w.x + x_np_by_c * c_w 		# Translate from the wing MAC

# ╔═╡ 57190953-ca75-47d1-ba81-2a8f4c333b0d
md"So we obtain the static margin as:"

# ╔═╡ 824ae9c9-b600-4818-99ea-a5cba8a99a48
SM = (x_np - x_cg) / c_w

# ╔═╡ 85dba5a3-43d7-4a82-9952-af7333485aec
SM * 100 # in percentage

# ╔═╡ 32ea462a-9da1-45c1-a639-2deffc9bf4f5
md"### Visualization"

# ╔═╡ 92262f8f-2679-4de6-abfd-d99db391da24
begin 
	# Position vectors for plots
	r_cg  = [x_cg, 0, 0]  			  # Center of gravity
	r_np  = [x_np,  0., 0.] 		  # Neutral point
	r_mLG = [x_mLG, 0., -fuse.radius] # Main landing gear
	r_nLG = [x_nLG, 0., -fuse.radius] # Nose landing gear
end

# ╔═╡ 745f5bfc-72f0-4432-a446-9cf0873fb06b
camera_angles2 = md"""
ϕ: $(ϕ_s2)
ψ: $(ψ_s2)
"""

# ╔═╡ 449172b8-6b3d-44de-bf41-9efe01b1e976
begin
	p2 = plot(
		# aspect_ratio = 1, 
		zlim = (-0.5, 0.5) .* span(wing),
		camera = (ϕ2, ψ2)
	)

	# Surfaces
	plot!(fuse, alpha = 0.3, label = "Fuselage")
	plot!(wing, 0.4, label = "Wing") 			 # 40% MAC specified "0.4" for CG
	plot!(htail, 0.4, label = "Horizontal Tail") # 40% MAC specified "0.4" for CG
	plot!(vtail, 0.4, label = "Vertical Tail") 	 # 40% MAC specified "0.4" for CG

	# Engine
	scatter!(Tuple(eng_L), label = "Engine Left")
	scatter!(Tuple(eng_R), label = "Engine Right")

	# Landing gear
	scatter!(Tuple(r_nLG), label = "Nose Landing Gear")
	scatter!(Tuple(r_mLG), label = "Main Landing Gear")

	# CG and NP
	scatter!(Tuple(r_cg), label = "Center of Gravity")
	scatter!(Tuple(r_np), label = "Neutral Point")
    p2
end

# ╔═╡ a21f0198-b10b-4f79-89fe-24b7eb0c3820
md"# Alternative: Vortex Lattice Method
The vortex lattice method (VLM) provides estimations of aerodynamic derivatives, which can also be used to evaluate the stability with fewer approximations.
"

# ╔═╡ a1a8dc20-a3db-4107-9e00-f4e8c8d12af5
md"## Analysis Setup
First, let's mesh the lifting surfaces.
"

# ╔═╡ 94c142b3-c339-4652-8e51-0450ca705af5
md"""

!!! info
	The meshing cells below have been disabled to speed up the loading of the notebook. You can enable them to activate the VLM analysis. **You may have to run each dependent cell further below (possibly faded block) manually after enabling these three cells.**
"""

# ╔═╡ a27b494a-1d5a-43a7-b293-fc9b09bca0a5
wing_mesh = WingMesh(wing, [8,16], 10, 
	span_spacing = fill(Uniform(), 4) # Number of spacings = number of spanwise stations (including symmetry)
)

# ╔═╡ d2c18a1d-6bff-44b5-88f4-74556636d21b
htail_mesh = WingMesh(htail, [10], 8)

# ╔═╡ 43d4a082-8eaa-4893-9963-8aa105fe003e
vtail_mesh = WingMesh(vtail, [8], 6)

# ╔═╡ b4006caa-544c-42cd-80c8-587413059bac
md"Now we define the aircraft, freestream and reference values."

# ╔═╡ 0ae37ab9-14e4-4882-be30-1185b9e93558
ac = ComponentVector(
	wing  = make_horseshoes(wing_mesh),
	htail = make_horseshoes(htail_mesh),
	vtail = make_horseshoes(vtail_mesh)
);

# ╔═╡ 2502b74a-52fe-47d2-9aff-c43d3bf549a2
fs = Freestream(
	alpha = 0.0, # HOW DO YOU CHOOSE THIS?
	beta = 0.0,
);

# ╔═╡ 5743447f-7cba-4503-9d98-5841f32f74cc
refs = References(
	speed = M * 330.,
	density = 1.225,
	area = projected_area(wing),
	chord = mean_aerodynamic_chord(wing),
	span = span(wing),
	location = [0.,0.,0.], # From the nose as reference (origin)
);

# ╔═╡ d2220eee-42bb-4135-8326-9e5f818e6a91
md"Now, let's run the VLM analysis."

# ╔═╡ 6725bc56-1245-42f0-a32c-b3bca6acccda
sys = solve_case(ac, fs, refs,
		name = "Boing",
		compressible = true,
	)

# ╔═╡ af94a37d-04a1-4708-8c8d-47d664632031
md"## Angle of Attack Variation"

# ╔═╡ d27de2c5-6168-4873-a650-1fcba8cc0767
function solve_alpha(ac, α, M, refs, compressible = false)
	# Set reference speed with input Mach number
	new_ref = @set refs.speed = M * refs.sound_speed 
	new_fs = Freestream(alpha = α) # Set angle of attack
	sys = solve_case(ac, new_fs, new_ref, compressible = compressible) # Solve system

	return sys
end

# ╔═╡ 265c2da7-9266-40cd-a7ba-629ea51247fb
begin
	alphas = -5:13 # Angles of attack
	M1 = M 			# Operating condition
	M2 = 0.2 		# Subsonic condition
end

# ╔═╡ 70452016-0f80-4d17-bbf9-6e0a10694d9e
vlms_M1 = map(alpha -> solve_alpha(ac, alpha, M1, refs, true), alphas); # Evaluate for range of angles at operating Mach number

# ╔═╡ d9df0af8-7ee6-42cb-bd5b-a9fe5e9a4439
vlms_M2 = map(alpha -> solve_alpha(ac, alpha, M2, refs), alphas); # Evaluate for range of angles at other Mach number

# ╔═╡ 0d82212d-8532-4b58-b2c3-72b105ce69ab
begin
	nfs_M1 = mapreduce(nearfield, hcat, vlms_M1)'
	nfs_M2 = mapreduce(nearfield, hcat, vlms_M2)'
end

# ╔═╡ a41ef71a-7881-4716-b816-8018a375c384
# Create DataFrame
df_M1 = DataFrame(
	[ alphas nfs_M1 ], 
	[:al,:CDi,:CY,:CL,:Cl,:Cm,:Cn]
)

# ╔═╡ f40fa0c1-b7c5-4cc0-80af-962ffeeba327
# Create DataFrame
df_M2 = DataFrame(
	[ alphas nfs_M2 ], 
	[:al,:CDi,:CY,:CL,:Cl,:Cm,:Cn]
)

# ╔═╡ 0cff771c-9bbd-4414-a1d7-3d2c3acb7765
begin
	plt_Cm_CL = plot(df_M1[!,"CL"], df_M1[!,"Cm"], xlabel = "CL", ylabel = "Cm", label = "M = $(mach_number(vlms_M1[1].reference))") # Operating condition
	
	plot!(df_M2[!,"CL"], df_M2[!,"Cm"], xlabel = "CL", ylabel = "Cm", label = "M = $(mach_number(vlms_M2[1].reference))") # Subsonic condition
end

# ╔═╡ e2417347-97c9-483c-ac23-687843eb3d99
# savefig(plt_Cm_CL, "Cm_CL_curve.png")

# ╔═╡ d7f6ace6-37e5-4035-bea4-fb9ca212d6b3
md"So $\partial C_m/\partial C_L$ is negligibly sensitive to the Mach number."

# ╔═╡ 8657f5fd-cb4e-402d-b63f-a1016745a93e
md"## Freestream Derivatives
You can evaluate the derivatives of the forces and moment coefficients $(C_{D_i}, C_Y, C_L, C_l, C_m, C_n)$ computed via the VLM analysis with respect to the freestream values $M, \alpha, \beta$.
"

# ╔═╡ 0f737ee5-7bde-41de-9f18-8610a6cb57f5
dvs = freestream_derivatives(sys, 
		# print = true, # Print derivatives for only the aircraft
		print_components = true, # Print derivatives for all components
		farfield = true, # Farfield derivatives (usually unnecessary)
	)

# ╔═╡ 26408fa7-e7e9-472f-a9f6-501740d22e53
dvs.htail # Use the 'dot' syntax to access the values and derivatives of each component

# ╔═╡ d5ff02b9-3c71-467d-b846-b991ed6aa966
ac_dvs = dvs.aircraft # Accessing the derivatives of the aircraft

# ╔═╡ 2b76a77b-b9aa-4425-a831-85ad67f3eb1e
ac_dvs.Cm_al # Moment curve slope of aircraft

# ╔═╡ ab76a183-2779-48e1-b52b-7b12107af3ae
ac_dvs.CZ_al # Lift curve slope of aircraft

# ╔═╡ 52aa322f-1fec-4391-8d7e-3e54fcfff49d
dvs.wing.CZ_al # Lift curve slope of wing

# ╔═╡ 59bb63ff-b86b-4d56-a17d-73bad7abb3ff
dvs.htail.CZ_al # Lift curve slope of horizontal tail

# ╔═╡ 9276af20-c0cd-4f1d-b7f5-f59068bde963
md"""
!!! tip
	Compare the lift curve slopes estimated from the vortex lattice method compared to the DATCOM formula predictions!
"""

# ╔═╡ b5048f8b-9316-4f92-85ae-b881cec7bbe1
CL_α_w 	# DATCOM lift curve slope for the wing

# ╔═╡ 54bc8ada-8f15-4540-a3ad-312865be442a
CL_α_h  # DATCOM lift curve slope for the horizontal tail

# ╔═╡ 094f263b-8fd0-4cf9-b868-f84836e26ecd
md"## Stability Analysis
The location of the center of pressure is:

```math
	x_{cp} = -\bar c \frac{C_m}{C_L}
```
"

# ╔═╡ 56921e11-1b08-4842-90a1-fc870477483e
x_cp = -refs.chord * ac_dvs.Cm / ac_dvs.CZ # Center of pressure

# ╔═╡ 2cf74e8c-92af-4d76-b63c-79a8aa19eaf0
md"""

Recall from your notes, the definition of neutral point:

```math
	x_{np} = -\bar c \frac{C_{m_\alpha}}{C_{L_\alpha}}
```

!!! info 
	Here, we add the contribution of the fuselage $\partial C_{m_f}/\partial{C_L}$ from the slender-body approximation, as the VLM doesn't account for the fuselage effects. But we'll use the lift curve slope computed from the VLM in this approximation instead of the DATCOM formula.
"""

# ╔═╡ d7020429-d1f8-453b-b832-3e30f287b4dc
Cm_fuse_CL = fuse_Cm_CL(V_f, S_w, c_w, dvs.wing.CZ_al) # Fuselage Cm/CL

# ╔═╡ e7a596f9-6c0a-439a-92b5-ed224625b222
x_np_vlm = -refs.chord * (ac_dvs.Cm_al / ac_dvs.CZ_al + Cm_fuse_CL) # Neutral point

# ╔═╡ be061850-1c89-4cad-8b9c-786bc84637b6
begin 
	# Translating position vectors wrt to nose as origin
	r_cp 		= refs.location + [x_cp, 0, 0]
	r_np_vlm 	= refs.location + [x_np_vlm, 0, 0]

	r_cp, r_np_vlm
end

# ╔═╡ 7a1efc92-7a66-4eaf-ac5c-9127830a91d2
SM_VLM = (r_np_vlm - r_cg).x / c_w

# ╔═╡ cba725a6-e7cc-431b-b966-43dcdb5500e0
SM_VLM * 100 # From VLM analysis, in percentage

# ╔═╡ eb8ef4c9-4cd2-49e9-a62f-4d909ab52c62
SM * 100 # From DATCOM approximations, in percentage

# ╔═╡ 9ca6e8a2-635b-45da-8e78-fe6e39b3a0e6
md"""
!!! hint
	The VLM accounts for the detailed wing/tail geometry (airfoil, orientation, etc.) in determining ``C_{m_a}, C_{L_a}``. Did we use this information in the previous neutral point estimation? Specifically, the downwash angle approximation may not always be correct.
"""

# ╔═╡ f0d72efb-e26c-4acd-a90a-71f77c0ab42e
md"## Visualization"

# ╔═╡ cea49201-c0f2-42ec-8051-c6302e4284a0
print_derivatives(dvs.aircraft; farfield = true) # Example of printing

# ╔═╡ 8517b3e7-be3b-4311-ba73-e2a11da04c6e
plot_vlm = false

# ╔═╡ a85bb31c-2b00-4678-bf30-366b3bae1e00
plot_streamlines = false

# ╔═╡ 9af910f0-9059-4065-a3ab-75bd1bfd653c
camera_angles3 = md"""
ϕ: $(ϕ_s3)
ψ: $(ψ_s3)
"""

# ╔═╡ 6f5edcde-412e-4dc0-8e25-77b46419b327
begin
	begin
		if plot_vlm
			plt_vlm = plot(
				# aspect_ratio = 1, 
				zlim = (-0.5, 0.5) .* span(wing),
				camera = (ϕ3, ψ3)
			)
			# plot!(wing, label = "Wing")
			plot!(fuse, alpha = 0.3, label = "Fuselage")
			plot!(wing_mesh, 0.4, label = "Wing Faired")
			plot!(htail_mesh, 0.4, label = "Horizontal Tail")
			plot!(vtail_mesh, 0.4, label = "Vertical Tail")
	
			if plot_streamlines
				plot!(sys, wing, span = 5) # Streamlines
			end
				
			# Engine
			scatter!(Tuple(eng_L), label = "Engine Left")
			scatter!(Tuple(eng_R), label = "Engine Right")
	
			# Landing gear
			scatter!(Tuple(r_nLG), label = "Nose Landing Gear")
			scatter!(Tuple(r_mLG), label = "Main Landing Gear")
			
			# CG, CP and NP
			scatter!(Tuple(r_cg), label = "Center of Gravity")
			scatter!(Tuple(r_cp), label = "Center of Pressure (VLM)")
			scatter!(Tuple(r_np_vlm), label = "Neutral Point (VLM)")
		end
	end
	
	
	# CG Envelope
	begin
	    # -----------------------------
	    # 1) Split current model into:
	    #    - fixed components
	    #    - variable loading items
	    # -----------------------------
	    variable_keys = Set(["crew", "passenger", "baggage", "fuel"])
	
	    fixed_components = Dict(
	        k => v for (k, v) in weight_position if !(k in variable_keys)
	    )
	
	    # helper: compute total weight, total moment, x_cg
	    function compute_cg(component_dict::Dict{String, Tuple{Float64, Float64}})
	        W_total = sum(w for (w, x) in values(component_dict))
	        M_total = sum(w * x for (w, x) in values(component_dict))
	        xcg = M_total / W_total
	        return W_total, M_total, xcg
	    end
	
	    # helper: build one loading case
	    function build_case(case_name;
	        crew_frac = 0.0,
	        pax_frac  = 0.0,
	        bag_frac  = 0.0,
	        fuel_frac = 0.0
	    )
	        comps = Dict(fixed_components)
	
	        if crew_frac > 0
	            comps["crew"] = (W_crew * crew_frac, x_crew)
	        end
	        if pax_frac > 0
	            comps["passenger"] = (W_pax * pax_frac, x_pax)
	        end
	        if bag_frac > 0
	            comps["baggage"] = (W_bag * bag_frac, x_bag)
	        end
	        if fuel_frac > 0
	            comps["fuel"] = (W_fuel * fuel_frac, x_fuel)
	        end
	
	        W_total, M_total, xcg = compute_cg(comps)
	
	        # report CG as %MAC from 25% MAC reference
	        cg_pct_mac25 = 100 * (xcg - mac25_w.x) / c_w
	
	        # static margin for this loading case
	        sm_case = (x_np - xcg) / c_w * 100
	
	        return (
	            case = case_name,
	            W_total_kg = W_total,
	            x_cg_m = xcg,
	            cg_pct_MAC25 = cg_pct_mac25,
	            SM_pct = sm_case
	        )
	    end
	
	    # -----------------------------
	    # 2) Define representative cases
	    # -----------------------------
	    cg_cases = DataFrame([
	        build_case("OEW"),
	        build_case("OEW + crew"; crew_frac = 1.0),
	        build_case("Zero-fuel, full payload"; crew_frac = 1.0, pax_frac = 1.0, bag_frac = 1.0),
	        build_case("Takeoff, full payload + full fuel"; crew_frac = 1.0, pax_frac = 1.0, bag_frac = 1.0, fuel_frac = 1.0),
	        build_case("Landing, full payload + 15% fuel"; crew_frac = 1.0, pax_frac = 1.0, bag_frac = 1.0, fuel_frac = 0.15),
	        build_case("Ferry, crew + full fuel"; crew_frac = 1.0, fuel_frac = 1.0),
	    ])
	
	    cg_cases = sort(cg_cases, :x_cg_m)
	
	    # forward / aft limits from the cases above
	    i_fwd = argmin(cg_cases.x_cg_m)
	    i_aft = argmax(cg_cases.x_cg_m)
	
	    fwd_case = cg_cases[i_fwd, :]
	    aft_case = cg_cases[i_aft, :]
	
	    println("--------------------------------------------------")
	    println("CG LOADING CASES")
	    println("--------------------------------------------------")
	    show(cg_cases, allrows = true, allcols = true)
	    println()
	    println("--------------------------------------------------")
	    println("Forward CG limit from cases:")
	    println("  Case   = ", fwd_case.case)
	    println("  x_cg   = ", round(fwd_case.x_cg_m, digits = 3), " m")
	    println("  %MAC25 = ", round(fwd_case.cg_pct_MAC25, digits = 2), " %")
	    println("  SM     = ", round(fwd_case.SM_pct, digits = 2), " %")
	    println()
	    println("Aft CG limit from cases:")
	    println("  Case   = ", aft_case.case)
	    println("  x_cg   = ", round(aft_case.x_cg_m, digits = 3), " m")
	    println("  %MAC25 = ", round(aft_case.cg_pct_MAC25, digits = 2), " %")
	    println("  SM     = ", round(aft_case.SM_pct, digits = 2), " %")
	    println("--------------------------------------------------")
	end
	
	begin
	    cg_envelope_plot = scatter(
	        cg_cases.x_cg_m,
	        cg_cases.W_total_kg,
	        xlabel = "CG location, x_cg (m from nose)",
	        ylabel = "Aircraft weight (kg)",
	        label = false,
	        markersize = 6,
	        title = "CG loading cases"
	    )
	
	    # label each point
	    for i in 1:nrow(cg_cases)
	        annotate!(
	            cg_cases.x_cg_m[i] + 0.03,
	            cg_cases.W_total_kg[i],
	            text(cg_cases.case[i], 8)
	        )
	    end
	
	    # show neutral point as a reference line
	    vline!([x_np], linestyle = :dash, label = "Neutral point")
	
	    cg_envelope_plot
	end
	
	begin
	    sm_case_plot = bar(
	        cg_cases.case,
	        cg_cases.SM_pct,
	        xlabel = "Loading case",
	        ylabel = "Static margin (%)",
	        legend = false,
	        xrotation = 25,
	        title = "Static margin by loading case"
	    )
	
	    hline!([0.0], linestyle = :dash, label = "Neutral stability")
	    sm_case_plot
	end
	
	begin
	    fuel_fracs = collect(0.0:0.05:1.0)
	
	    full_payload_curve = DataFrame(
	        fuel_frac = fuel_fracs,
	        x_cg_m = [
	            build_case(
	                "tmp";
	                crew_frac = 1.0,
	                pax_frac = 1.0,
	                bag_frac = 1.0,
	                fuel_frac = ff
	            ).x_cg_m
	            for ff in fuel_fracs
	        ]
	    )
	
	    ferry_curve = DataFrame(
	        fuel_frac = fuel_fracs,
	        x_cg_m = [
	            build_case(
	                "tmp";
	                crew_frac = 1.0,
	                pax_frac = 0.0,
	                bag_frac = 0.0,
	                fuel_frac = ff
	            ).x_cg_m
	            for ff in fuel_fracs
	        ]
	    )
	
	    fuel_cg_plot = plot(
	        full_payload_curve.fuel_frac,
	        full_payload_curve.x_cg_m,
	        xlabel = "Fuel fraction of full fuel load",
	        ylabel = "CG location, x_cg (m from nose)",
	        label = "Full payload",
	        title = "CG travel with fuel burn"
	    )
	
	    plot!(
	        ferry_curve.fuel_frac,
	        ferry_curve.x_cg_m,
	        label = "Ferry"
	    )
	
	    hline!([x_np], linestyle = :dash, label = "Neutral point")
	    fuel_cg_plot
	end
	
	println("--------------------------------------------------")
	println("Static Margin")
	println("   Static margin = ", SM)
	println("   Static margin (%) = ", SM * 100)
	println("   Static margin from VLM (%) = ", SM_VLM * 100)
	println("--------------------------------------------------")
	println("CG")
	println("   x_np_by_c = ", x_np_by_c)
	println("   x_cg = ", x_cg)
	println("   x_fuel = ", x_fuel)
	println("   x_pax = ", x_pax)
	println("   x_bag = ", x_bag)
	println("--------------------------------------------------")
	println("Tail Stuff")
	println("   V_h = ", V_h)
	println("   CLah/CLaw = ", CL_α_h / CL_α_w)
	println("   tail contribution = ", V_h * CL_α_h / CL_α_w)
	println("   Cm_f_CL = ", Cm_f_CL)
end

# ╔═╡ d445b0bf-15e1-4aaa-bc2a-41d0f51cc86f
# savefig(plt_vlm, "static_stability_vlm.png")

# ╔═╡ a7341726-78c8-46e9-92fc-f2476cd261c5
begin
	# ========== WING‑ONLY PERFORMANCE ANALYSIS ==========
	# Create VLM system for wing alone
	ac_wing = ComponentVector(wing = make_horseshoes(wing_mesh))
	refs_wing = References(
	    speed = M1 * 330.,
	    density = 1.225,
	    area = projected_area(wing),
	    chord = mean_aerodynamic_chord(wing),
	    span = span(wing),
	    location = [0.,0.,0.]
	)
	
	# Sweep angle of attack
	vlms_wing = map(alpha -> solve_case(ac_wing, Freestream(alpha=alpha), refs_wing, compressible=true), alphas)
	
	# Extract wing‑only data (optional)
	nfs_wing = mapreduce(nearfield, hcat, vlms_wing)'
	df_wing = DataFrame([alphas nfs_wing], [:al, :CDi, :CY, :CL, :Cl, :Cm, :Cn])
	
	# Plot wing‑only performance
	plot(df_wing.al, df_wing.CL, xlabel="α (deg)", ylabel="CL", label="Wing only")
	plot!(df_M1.al, df_M1.CL, label="Wing + tail")  # overlay full aircraft
	
	plot(df_wing.CL, df_wing.CDi, xlabel="CL", ylabel="CDi", label="Wing only induced drag")
	
	# Lift curve slope from VLM (use solution at α = 0)
	idx0 = findfirst(==(0), alphas)
	dvs_wing = freestream_derivatives(vlms_wing[idx0])
	CLα_wing_VLM = -dvs_wing.wing.CZ_al   # <-- corrected access
	
	println("CLα (wing) from VLM = ", CLα_wing_VLM, " 1/rad")
	println("CLα (wing) from DATCOM = ", CL_α_w, " 1/rad")
end

# ╔═╡ 40f825bd-9c7a-470c-999c-e9c9bb7256ab
# it shows the df_M1 exist or not, for some reason, it keeps showing result are incorrect like the above, and the static margin from VLM is -12 sth, and when i used the code below to c if the df_M1 exit or not it shows it does not exist 
begin
	println("df_M1 exists: ", isdefined(Main, :df_M1))
	if isdefined(Main, :df_M1)
	    println("Number of rows: ", nrow(df_M1))
	    println("First few rows:")
	    show(first(df_M1, 3))
	end
end

# ╔═╡ 3ba8a43b-32fb-4b21-a03e-9e1aed8a8a4f
# this is the code that use plot to CL curve of tail +wing 
# since can't hv two def for the nfs_M1, so i just make nffs_M1 for convenience 
begin
    # Recompute everything needed for plotting
    nffs_M1 = mapreduce(nearfield, hcat, vlms_M1)'
    df_temp = DataFrame([alphas nffs_M1], [:al, :CDi, :CY, :CL, :Cl, :Cm, :Cn])

    # ---------- Parameters for Kirchhoff stall correction ----------
    α_stall_deg = 14.0          # Stall angle (degrees) – adjust if needed
    n_exp = 2.0                 # Kirchhoff exponent

    # ---------- Fit linear CL slope from small angles (e.g., -5° to 20°) ----------
    small_range = (-5:20)
    mask = df_temp.al .∈ Ref(small_range)
    α_small = df_temp.al[mask]
    CL_small = df_temp.CL[mask]
    # Linear regression (slope per degree)
    slope = (CL_small[end] - CL_small[1]) / (α_small[end] - α_small[1])
    intercept = CL_small[1] - slope * α_small[1]
    CL_linear = intercept .+ slope * df_temp.al

    # ---------- Kirchhoff correction ----------
    α_rad = deg2rad.(df_temp.al)
    α_stall_rad = deg2rad(α_stall_deg)
    function kirchhoff_factor(α, α_s, n)
        x = α / α_s
        f = max(0.0, 1.0 - x^n)
        return sqrt(f)
    end
    factor = kirchhoff_factor.(α_rad, α_stall_rad, n_exp)
    CL_corrected = CL_linear .* factor

    # ---------- Find maximum CL and its angle ----------
    max_CL, idx_max = findmax(CL_corrected)
    angle_max_CL = df_temp.al[idx_max]

    # ---------- Print results ----------
    println("--- Kirchhoff Corrected Results ---")
    println("Maximum CL (CL_max) = ", round(max_CL, digits=4))
    println("Angle of maximum CL = ", round(angle_max_CL, digits=2), "°")
    println("Assumed stall angle = ", α_stall_deg, "°")
    println("-----------------------------------")

    # ---------- Plot both curves ----------
    plot(df_temp.al, CL_linear, label="VLM (linear, no stall)", lw=2, ls=:dash)
    plot!(df_temp.al, CL_corrected, label="Kirchhoff corrected (realistic)", lw=2, color=:red)
    vline!([α_stall_deg], label="Assumed stall α = $(α_stall_deg)°", ls=:dot)
    # Mark the maximum CL point
    scatter!([angle_max_CL], [max_CL], label="CL_max = $(round(max_CL, digits=3)) at $(angle_max_CL)°", color=:blue)
    xlabel!("α (deg)")
    ylabel!("CL")
    title!("Realistic CL-α curve using Kirchhoff stall model")
end
#here

# ╔═╡ 7148be59-7fb9-47f0-a4db-7757eb431f3f
md"# Appendix"

# ╔═╡ a0c3a9a3-f048-441f-9caf-7d127d309abf
md"""## Mean Aerodynamic Chord Calculation

![](https://raw.githubusercontent.com/HKUST-OCTAD-LAB/MECH3620Materials/main/pics/WingParams.svg)

From the trapezoidal geometry:
```math
\begin{align}
x_{25\%~\text{MAC}} & = x_{\text{LE},\ \text{MAC}} + \bar{c} / 4, & \quad \text{where} & & \quad x_{\text{LE},\ \text{MAC}} & = x_{\text{LE},\ \text{root}} + \bar Y\tan\Lambda_{\text{LE}} \\
\bar Y & = \frac{b}{3}\left(\frac{1 + 2\lambda}{1 + \lambda}\right), & \quad \text{where} & & \quad \lambda & = \frac{c_{\text{tip}}}{c_{\text{root}}}
\end{align}
```
"""

# ╔═╡ 79cc7525-9de9-4717-a8a5-66e3b92759ba
# The End.

# ╔═╡ b43bfda9-52c9-44c1-9695-ec777dde4841
begin
	plot(foil_w_tip, aspect_ratio = 1)
	display(fuel_cg_plot)
	display(sm_case_plot)
	display(cg_envelope_plot)
	display(p2)
	
	begin
	    function export_stability_package(; base_dir = @__DIR__, bundle_name = "stability_outputs")
	        timestamp = Dates.format(now(), "yyyy-mm-dd_HHMMSS")
	        outdir = joinpath(base_dir, "$(bundle_name)_$(timestamp)")
	        mkpath(outdir)
	
	        # -----------------------------
	        # 1) Save text summary
	        # -----------------------------
	        txt_path = joinpath(outdir, "results_summary.txt")
	
	        open(txt_path, "w") do io
	            println(io, "==================================================")
	            println(io, "STABILITY / CG EXPORT")
	            println(io, "Generated: ", Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))
	            println(io, "==================================================")
	            println(io)
	
	            # --------------------------------------------------
	            # CG loading cases
	            # --------------------------------------------------
	            if isdefined(Main, :cg_cases)
	                println(io, "CG LOADING CASES")
	                println(io, "--------------------------------------------------")
	                show(io, MIME"text/plain"(), Main.cg_cases)
	                println(io)
	                println(io)
	            end
	
	            if isdefined(Main, :fwd_case) && isdefined(Main, :aft_case)
	                println(io, "Forward / Aft CG from tested cases")
	                println(io, "--------------------------------------------------")
	                println(io, "Forward case = ", Main.fwd_case.case)
	                println(io, @sprintf("Forward x_cg = %.6f m", Main.fwd_case.x_cg_m))
	                println(io, @sprintf("Forward %%MAC25 = %.6f %%", Main.fwd_case.cg_pct_MAC25))
	                println(io, @sprintf("Forward SM = %.6f %%", Main.fwd_case.SM_pct))
	                println(io)
	                println(io, "Aft case = ", Main.aft_case.case)
	                println(io, @sprintf("Aft x_cg = %.6f m", Main.aft_case.x_cg_m))
	                println(io, @sprintf("Aft %%MAC25 = %.6f %%", Main.aft_case.cg_pct_MAC25))
	                println(io, @sprintf("Aft SM = %.6f %%", Main.aft_case.SM_pct))
	                println(io)
	            end
	
	            # --------------------------------------------------
	            # Static stability summary
	            # --------------------------------------------------
	            println(io, "STATIC STABILITY SUMMARY")
	            println(io, "--------------------------------------------------")
	
	            if isdefined(Main, :SM)
	                println(io, @sprintf("Static margin = %.10f", Main.SM))
	                println(io, @sprintf("Static margin (%%) = %.6f", Main.SM * 100))
	            end
	            if isdefined(Main, :SM_VLM)
	                println(io, @sprintf("Static margin from VLM (%%) = %.6f", Main.SM_VLM * 100))
	            end
	
	            if isdefined(Main, :x_np_by_c)
	                println(io, @sprintf("x_np_by_c = %.10f", Main.x_np_by_c))
	            end
	            if isdefined(Main, :x_np)
	                println(io, @sprintf("x_np = %.6f m", Main.x_np))
	            end
	            if isdefined(Main, :x_cg)
	                println(io, @sprintf("x_cg = %.6f m", Main.x_cg))
	            end
	            if isdefined(Main, :x_fuel)
	                println(io, @sprintf("x_fuel = %.6f m", Main.x_fuel))
	            end
	            if isdefined(Main, :x_pax)
	                println(io, @sprintf("x_pax = %.6f m", Main.x_pax))
	            end
	            if isdefined(Main, :x_bag)
	                println(io, @sprintf("x_bag = %.6f m", Main.x_bag))
	            end
	            if isdefined(Main, :dist_cg_mac)
	                println(io, @sprintf("Distance between CG and wing aerodynamic center = %.6f m", Main.dist_cg_mac))
	            end
	
	            println(io)
	
	            # --------------------------------------------------
	            # Tail / DATCOM pieces
	            # --------------------------------------------------
	            println(io, "TAIL / DATCOM TERMS")
	            println(io, "--------------------------------------------------")
	
	            if isdefined(Main, :V_h)
	                println(io, @sprintf("V_h = %.10f", Main.V_h))
	            end
	            if isdefined(Main, :V_v)
	                println(io, @sprintf("V_v = %.10f", Main.V_v))
	            end
	            if isdefined(Main, :CL_α_w)
	                println(io, @sprintf("CL_alpha_w = %.10f 1/rad", Main.CL_α_w))
	            end
	            if isdefined(Main, :CL_α_h)
	                println(io, @sprintf("CL_alpha_h = %.10f 1/rad", Main.CL_α_h))
	            end
	            if isdefined(Main, :CL_α_h) && isdefined(Main, :CL_α_w)
	                println(io, @sprintf("CLah/CLaw = %.10f", Main.CL_α_h / Main.CL_α_w))
	                println(io, @sprintf("tail contribution = %.10f", Main.V_h * Main.CL_α_h / Main.CL_α_w))
	            end
	            if isdefined(Main, :Cm_f_CL)
	                println(io, @sprintf("Cm_f_CL = %.10f", Main.Cm_f_CL))
	            end
	            if isdefined(Main, :l_h)
	                println(io, @sprintf("l_h = %.6f m", Main.l_h))
	            end
	            if isdefined(Main, :l_v)
	                println(io, @sprintf("l_v = %.6f m", Main.l_v))
	            end
	            println(io)
	
	            # --------------------------------------------------
	            # Freestream derivatives / VLM setup
	            # --------------------------------------------------
	            println(io, "FREESTREAM / VLM SETUP")
	            println(io, "--------------------------------------------------")
	
	            if isdefined(Main, :M)
	                println(io, @sprintf("Mach number, M = %.6f", Main.M))
	            end
	            if isdefined(Main, :fs)
	                try
	                    println(io, "Freestream alpha (deg) = ", Main.fs.alpha)
	                    println(io, "Freestream beta (deg)  = ", Main.fs.beta)
	                catch
	                end
	            end
	            if isdefined(Main, :refs)
	                try
	                    println(io, @sprintf("Reference speed = %.6f", Main.refs.speed))
	                    println(io, @sprintf("Reference density = %.6f", Main.refs.density))
	                    println(io, @sprintf("Reference area = %.6f", Main.refs.area))
	                    println(io, @sprintf("Reference chord = %.6f", Main.refs.chord))
	                    println(io, @sprintf("Reference span = %.6f", Main.refs.span))
	                catch
	                end
	            end
	            println(io)
	
	            # --------------------------------------------------
	            # VLM derivative tables
	            # --------------------------------------------------
	            println(io, "VLM FREESTREAM DERIVATIVES")
	            println(io, "--------------------------------------------------")
	
	            if isdefined(Main, :dvs)
	                try
	                    println(io, "[Wing]")
	                    show(io, MIME"text/plain"(), Main.dvs.wing)
	                    println(io)
	                    println(io)
	
	                    println(io, "[Horizontal Tail]")
	                    show(io, MIME"text/plain"(), Main.dvs.htail)
	                    println(io)
	                    println(io)
	
	                    println(io, "[Vertical Tail]")
	                    show(io, MIME"text/plain"(), Main.dvs.vtail)
	                    println(io)
	                    println(io)
	
	                    println(io, "[Aircraft]")
	                    show(io, MIME"text/plain"(), Main.dvs.aircraft)
	                    println(io)
	                    println(io)
	                catch err
	                    println(io, "Could not export full dvs tables.")
	                    println(io, "Reason: ", err)
	                    println(io)
	                end
	            end
	
	            # --------------------------------------------------
	            # Key aircraft derivative summary
	            # --------------------------------------------------
	            println(io, "KEY AIRCRAFT DERIVATIVES")
	            println(io, "--------------------------------------------------")
	            if isdefined(Main, :ac_dvs)
	                try
	                    println(io, @sprintf("Cm_al = %.10f", Main.ac_dvs.Cm_al))
	                    println(io, @sprintf("CZ_al = %.10f", Main.ac_dvs.CZ_al))
	                    println(io, @sprintf("Cn_be = %.10f", Main.ac_dvs.Cn_be))
	                    println(io, @sprintf("Cl_be = %.10f", Main.ac_dvs.Cl_be))
	                    println(io, @sprintf("CY_be = %.10f", Main.ac_dvs.CY_be))
	                catch
	                end
	            end
	            println(io)
	
	            # --------------------------------------------------
	            # Warnings / interpretation notes
	            # --------------------------------------------------
	            println(io, "NOTES")
	            println(io, "--------------------------------------------------")
	            println(io, "- DATCOM-based static margin is the main preliminary stability result.")
	            println(io, "- VLM result at transonic Mach should be interpreted cautiously.")
	            println(io, "- CG envelope here is based on lumped payload and fuel stations.")
	        end
	
	        # -----------------------------
	        # 2) Save plots if they exist
	        # -----------------------------
	        saved_files = String[txt_path]
	
	        function maybe_save_plot(varname::Symbol, filename::String)
	            if isdefined(Main, varname)
	                p = getfield(Main, varname)
	                filepath = joinpath(outdir, filename)
	                savefig(p, filepath)
	                push!(saved_files, filepath)
	            end
	        end
	
	        maybe_save_plot(:p1, "geometry_overview.png")
	        maybe_save_plot(:p2, "stability_geometry.png")
	        maybe_save_plot(:cg_envelope_plot, "cg_loading_cases.png")
	        maybe_save_plot(:sm_case_plot, "static_margin_cases.png")
	        maybe_save_plot(:fuel_cg_plot, "cg_travel_with_fuel_burn.png")
	        maybe_save_plot(:plt_Cm_CL, "Cm_vs_CL.png")
	        maybe_save_plot(:plt_vlm, "vlm_view.png")
	
	        # -----------------------------
	        # 3) Create zip file
	        # -----------------------------
	        zip_path = outdir * ".zip"
	
	        zip_ok = false
	        zip_error = nothing
	
	        try
	            if Sys.iswindows()
	                cmd_str = "Compress-Archive -Path '$(joinpath(outdir, "*"))' -DestinationPath '$zip_path' -Force"
	                run(`powershell -NoProfile -Command $cmd_str`)
	                zip_ok = true
	            elseif Sys.isapple() || Sys.islinux()
	                run(Cmd(`zip -r -q $zip_path .`, dir = outdir))
	                zip_ok = true
	            end
	        catch err
	            zip_error = err
	        end
	
	        println("--------------------------------------------------")
	        println("EXPORT COMPLETE")
	        println("Output folder: ", outdir)
	        println("Text file:     ", txt_path)
	        println("Saved files:")
	        for f in saved_files
	            println("  - ", f)
	        end
	
	        if zip_ok
	            println("Zip file:      ", zip_path)
	        else
	            println("Zip file not created automatically.")
	            if zip_error !== nothing
	                println("Reason: ", zip_error)
	            end
	        end
	        println("--------------------------------------------------")
	
	        return outdir, txt_path, saved_files, zip_path
	    end
	end
	
	begin
	    outdir, txt_path, saved_files, zip_path = export_stability_package()
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AeroFuse = "477c59f4-51f5-487f-bf1e-8db39645b227"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
AeroFuse = "~0.4.12"
DataFrames = "~1.7.0"
Plots = "~1.41.6"
PlutoUI = "~0.7.79"
StaticArrays = "~1.9.18"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.1"
manifest_format = "2.0"
project_hash = "80e1d27da1b0c466fd24d37cbac408d971f9075c"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "856ecd7cebb68e5fc87abecd2326ad59f0f911f3"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.43"

    [deps.Accessors.extensions]
    AxisKeysExt = "AxisKeys"
    IntervalSetsExt = "IntervalSets"
    LinearAlgebraExt = "LinearAlgebra"
    StaticArraysExt = "StaticArrays"
    StructArraysExt = "StructArrays"
    TestExt = "Test"
    UnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "35ea197a51ce46fcd01c4a44befce0578a1aaeca"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.5.0"
weakdeps = ["SparseArrays", "StaticArrays"]

    [deps.Adapt.extensions]
    AdaptSparseArraysExt = "SparseArrays"
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AeroFuse]]
deps = ["Accessors", "ComponentArrays", "CoordinateTransformations", "DelimitedFiles", "DiffResults", "ForwardDiff", "Interpolations", "LabelledArrays", "LinearAlgebra", "MacroTools", "PrettyTables", "RecipesBase", "Roots", "Rotations", "SparseArrays", "SplitApplyCombine", "StaticArrays", "Statistics", "StatsBase", "StructArrays", "Test", "TimerOutputs"]
git-tree-sha1 = "4fc20bc9228bfbc8b00db08f05f14b10dadfbfdd"
uuid = "477c59f4-51f5-487f-bf1e-8db39645b227"
version = "0.4.12"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra"]
git-tree-sha1 = "78b3a7a536b4b0a747a0f296ea77091ca0a9f9a3"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.23.0"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceAMDGPUExt = "AMDGPU"
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceCUDSSExt = ["CUDSS", "CUDA"]
    ArrayInterfaceChainRulesCoreExt = "ChainRulesCore"
    ArrayInterfaceChainRulesExt = "ChainRules"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceMetalExt = "Metal"
    ArrayInterfaceReverseDiffExt = "ReverseDiff"
    ArrayInterfaceSparseArraysExt = "SparseArrays"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    AMDGPU = "21141c5a-9bdb-4563-92ae-f87d6854732e"
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    CUDSS = "45b445bb-4962-46a0-9369-b4df9d0f772e"
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    Metal = "dde4c033-4e86-420c-a63e-0dd931031962"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "a21c5464519504e41e0cbc91f0188e8ca23d7440"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.5+1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "e4c6a16e77171a5f5e25e9646617ab1c276c5607"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.26.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

[[deps.CommonSolve]]
git-tree-sha1 = "78ea4ddbcf9c241827e7035c3a03e2e456711470"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.6"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

[[deps.CommonWorldInvalidations]]
git-tree-sha1 = "ae52d1c52048455e85a387fbee9be553ec2b68d0"
uuid = "f70d9fcc-98c5-4d4a-abd7-e4cdeebd8ca8"
version = "1.0.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.ComponentArrays]]
deps = ["ArrayInterface", "ChainRulesCore", "LinearAlgebra", "Requires", "StaticArrayInterface"]
git-tree-sha1 = "2736dee49260e412a352b2d0a37fb863f9a5b559"
uuid = "b0b7db55-cfe3-40fc-9ded-d10e2dbeff66"
version = "0.13.8"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "21d088c496ea22914fe80906eb5bce65755e5ec8"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.1"

[[deps.ConstructionBase]]
git-tree-sha1 = "b4b092499347b18a015186eae3042f72267106cb"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.6.0"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "a692f5e257d332de1e554e4566a4e5a8a72de2b2"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.4"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "fb61b4812c49343d7ef0b533ba982c46021938a6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.7.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4e1fe97fdaed23e9dc21d4d664bea76b65fc50a0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.22"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "a55766a9c8f66cf19ffcdbdb1444e249bb4ace33"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.4.6"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

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
git-tree-sha1 = "27af30de8b5445644e8ffe3bcb0d72049c089cf1"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.7.3+0"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "95ecf07c2eea562b5adbd0696af6db62c0f52560"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.5"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "01ba9d15e9eae375dc1eb9589df76b3572acd3f2"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "8.0.1+0"

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
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "afb7c51ac63e40708a3071f80f5e84a752299d4f"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.39"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "2c5512e11c791d1baed2049c5652441b28fc6a31"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "b7bfd56fa66616138dfe5237da4dc13bbd83c67f"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.1+0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "83cf05ab16a73219e5f6bd1bdfa9848fa24ac627"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.2.0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "ee0585b62671ce88e48d3409733230b401c9775c"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.22"

    [deps.GR.extensions]
    IJuliaExt = "IJulia"

    [deps.GR.weakdeps]
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "7dd7173f7129a1b6f84e0f03e0890cd1189b0659"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.22+0"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "24f6def62397474a297bfcec22384101609142ed"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.86.3+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a6dbda1fd736d60cc477d99f2e7a042acfa46e8"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.15+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "51059d23c8bb67911a2e6fd5130229113735fc7e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.11.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "f923f9a774fcf3f5cb761bfa43aeadd689714813"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.1+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.InlineStrings]]
git-tree-sha1 = "8f3d257792a522b4601c24a577954b0a8cd7334d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.5"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "88a101217d7cb38a7b481ccd50d21876e1d1b0e0"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.15.1"

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

    [deps.Interpolations.weakdeps]
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "0533e564aae234aff59ab625543145446d8b6ec2"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.1"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "b3ad4a0255688dcb895a52fafbaae3023b588a90"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.4.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6893345fd6658c8e475d40155789f4860ac3b21"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.4+0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eb62a3deb62fc6d8822c0c4bef73e4412419c5d8"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.8+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.LabelledArrays]]
deps = ["ArrayInterface", "ChainRulesCore", "ForwardDiff", "LinearAlgebra", "MacroTools", "PreallocationTools", "PrecompileTools", "RecursiveArrayTools", "StaticArrays"]
git-tree-sha1 = "1514acbc5f0722552df69514abe5d096cfbda74c"
uuid = "2ee39098-c373-598a-b85f-a56591580800"
version = "1.18.0"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "44f93c47f9cd6c7e431f2f2091fcba8f01cd7e8f"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.10"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.11.1+1"

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
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "97bbca976196f2a1eb9607131cb108c69ec3f8a6"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.41.3+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "f04133fe05eff1667d2054c53d59f9122383fe05"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.2+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d0205286d9eceadc518742860bf23f703779a3d6"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.41.3+0"

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
git-tree-sha1 = "f00544d95982ea270145636c181ceda21c4e2575"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.2.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "8785729fa736197687541f7053f6d8ab7fc44f92"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.10"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ff69a2b1330bcb730b9ac1ab7dd680176f5896b8"
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.1010+0"

[[deps.Measures]]
git-tree-sha1 = "b513cedd20d9c914783d8ad83d08120702bf2c77"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.3"

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
version = "2025.5.20"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "9b8215b1ee9e78a293f99797cd31375471b2bcae"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.3"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "117432e406b5c023f665fa73dc26e79ec3630151"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.17.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "NetworkOptions", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "1d1aaa7d449b58415f97d2839c318b70ffb525a0"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.6.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.44.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0662b083e11420952f2e62e17eddae7fc07d5997"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.57.0+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "db76b1ecd5e9715f3d043cec13b2ec93ce015d53"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.44.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.0"
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
git-tree-sha1 = "26ca162858917496748aad52bb5d3be4d26a228a"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.4"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "cb20a4eacda080e517e4deb9cfb6c7c518131265"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.41.6"

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
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "3ac7038a98ef6977d44adeadc73cc6f596c08109"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.79"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PreallocationTools]]
deps = ["Adapt", "ArrayInterface", "PrecompileTools"]
git-tree-sha1 = "dc8d6bde5005a0eac05ae8faf1eceaaca166cfa4"
uuid = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
version = "1.1.2"

    [deps.PreallocationTools.extensions]
    PreallocationToolsForwardDiffExt = "ForwardDiff"
    PreallocationToolsReverseDiffExt = "ReverseDiff"
    PreallocationToolsSparseConnectivityTracerExt = "SparseConnectivityTracer"

    [deps.PreallocationTools.weakdeps]
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseConnectivityTracer = "9f842d2f-2579-4b1d-911e-f412cf18a3f5"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "07a921781cab75691315adc645096ed5e370cb77"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.3"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "8b770b60760d4451834fe79dd483e318eee709c4"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.2"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "1101cd475833706e4d0e7b122218257178f48f34"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "34f7e5d2861083ec7596af8b8c092531facf2192"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.8.2+2"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "da7adf145cce0d44e892626e647f9dcbe9cb3e10"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.8.2+1"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "9eca9fc3fe515d619ce004c83c31ffd3f85c7ccf"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.8.2+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "8f528b0851b5b7025032818eb5abbeb8a736f853"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.8.2+2"

[[deps.Quaternions]]
deps = ["LinearAlgebra", "Random", "RealDot"]
git-tree-sha1 = "4d8c1b7c3329c1885b857abb50d08fa3f4d9e3c8"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.7.7"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

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

[[deps.RecursiveArrayTools]]
deps = ["Adapt", "ArrayInterface", "DocStringExtensions", "GPUArraysCore", "IteratorInterfaceExtensions", "LinearAlgebra", "RecipesBase", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables"]
git-tree-sha1 = "f8726bd5a8b7f5f5d3f6c0ce4793454a599b5243"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "3.36.0"

    [deps.RecursiveArrayTools.extensions]
    RecursiveArrayToolsFastBroadcastExt = "FastBroadcast"
    RecursiveArrayToolsForwardDiffExt = "ForwardDiff"
    RecursiveArrayToolsKernelAbstractionsExt = "KernelAbstractions"
    RecursiveArrayToolsMeasurementsExt = "Measurements"
    RecursiveArrayToolsMonteCarloMeasurementsExt = "MonteCarloMeasurements"
    RecursiveArrayToolsReverseDiffExt = ["ReverseDiff", "Zygote"]
    RecursiveArrayToolsSparseArraysExt = ["SparseArrays"]
    RecursiveArrayToolsStructArraysExt = "StructArrays"
    RecursiveArrayToolsTrackerExt = "Tracker"
    RecursiveArrayToolsZygoteExt = "Zygote"

    [deps.RecursiveArrayTools.weakdeps]
    FastBroadcast = "7034ab61-46d4-4ed7-9d0f-46aef9175898"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    MonteCarloMeasurements = "0987c9cc-fe09-11e8-30f0-b96dd679fdca"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

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
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Roots]]
deps = ["Accessors", "CommonSolve", "Printf"]
git-tree-sha1 = "10a488dbecb88a9679c8f357d383d7d83dcc748d"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.2.13"

    [deps.Roots.extensions]
    RootsChainRulesCoreExt = "ChainRulesCore"
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"
    RootsUnitfulExt = "Unitful"

    [deps.Roots.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays"]
git-tree-sha1 = "5680a9276685d392c87407df00d57c9924d9f11e"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.7.1"
weakdeps = ["RecipesBase"]

    [deps.Rotations.extensions]
    RotationsRecipesBaseExt = "RecipesBase"

[[deps.RuntimeGeneratedFunctions]]
deps = ["ExprTools", "SHA", "Serialization"]
git-tree-sha1 = "7257165d5477fd1025f7cb656019dcb6b0512c38"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.17"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SciMLPublic]]
git-tree-sha1 = "0ba076dbdce87ba230fff48ca9bca62e1f345c9b"
uuid = "431bcebd-1456-4ced-9d72-93c2757fff0b"
version = "1.0.1"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "ebe7e59b37c400f694f52b58c93d26201387da70"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.9"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
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
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "5acc6a41b3082920f79ca3c759acbcecf18a8d78"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.7.1"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.SplitApplyCombine]]
deps = ["Dictionaries", "Indexing"]
git-tree-sha1 = "c06d695d51cfb2187e6848e98d6252df9101c588"
uuid = "03a91e81-4c3e-53e1-a0a4-9c0c8f19dd66"
version = "1.2.3"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "4f96c596b8c8258cc7d3b19797854d368f243ddc"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.4"

[[deps.Static]]
deps = ["CommonWorldInvalidations", "IfElse", "PrecompileTools", "SciMLPublic"]
git-tree-sha1 = "49440414711eddc7227724ae6e570c7d5559a086"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "1.3.1"

[[deps.StaticArrayInterface]]
deps = ["ArrayInterface", "Compat", "IfElse", "LinearAlgebra", "PrecompileTools", "SciMLPublic", "Static"]
git-tree-sha1 = "aa1ea41b3d45ac449d10477f65e2b40e3197a0d2"
uuid = "0d7ed370-da01-4f52-bd93-41d350b8b718"
version = "1.9.0"
weakdeps = ["OffsetArrays", "StaticArrays"]

    [deps.StaticArrayInterface.extensions]
    StaticArrayInterfaceOffsetArraysExt = "OffsetArrays"
    StaticArrayInterfaceStaticArraysExt = "StaticArrays"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "246a8bb2e6667f832eea063c3a56aef96429a3db"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.18"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6ab403037779dae8c514bad259f32a447262455a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.4"

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
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "d05693d339e37d6ab134c5ab53c29fce5ee5d7d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.4"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "9537ef82c42cdd8c5d443cbc359110cbb36bae10"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.21"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = ["GPUArraysCore", "KernelAbstractions"]
    StructArraysLinearAlgebraExt = "LinearAlgebra"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "28145feabf717c5d65c1d5e09747ee7b1ff3ed13"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.6.3"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.SymbolicIndexingInterface]]
deps = ["Accessors", "ArrayInterface", "RuntimeGeneratedFunctions", "StaticArraysCore"]
git-tree-sha1 = "b19cf024a2b11d72bef7c74ac3d1cbe86ec9e4ed"
uuid = "2efcf032-c050-4f8e-a9bb-153293bab1f5"
version = "0.3.44"
weakdeps = ["PrettyTables"]

    [deps.SymbolicIndexingInterface.extensions]
    SymbolicIndexingInterfacePrettyTablesExt = "PrettyTables"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "f2c1efbc8f3a609aadf318094f8fc5204bdaf344"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.1"

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

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "3748bd928e68c7c346b52125cf41fff0de6937d0"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.29"

    [deps.TimerOutputs.extensions]
    FlameGraphsExt = "FlameGraphs"

    [deps.TimerOutputs.weakdeps]
    FlameGraphs = "08572546-2f56-4bcf-ba4e-bab62c3a3f89"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

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
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "96478df35bbc2f3e1e791bc7a3d0eeee559e60e9"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.24.0+0"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "248a7031b3da79a127f14e5dc5f417e26f9f6db7"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.1.0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "9cce64c0fdd1960b597ba7ecda2950b5ed957438"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.2+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "808090ede1d41644447dd5cbafced4731c56bd2f"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.13+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "1a4a26870bf1e5d26cd585e38038d399d7e65706"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.8+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "a376af5c7ae60d29825164db40787f15c80c7c54"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.3+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "0ba01bc7396896a4ace8aab67db31403c71628f4"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.7+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c174ef70c96c76f4c3f4d3cfbe09d018bcd1b53"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.6+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "4909eb8f1cbf6bd4b1c30dd18b2ead9019ef2fad"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.18.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "ed756a03e95fff88d8f738ebc2849431bdd4fd1a"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.2.0+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "9750dc53819eba4e9a20be42349a6d3b86c7cdf8"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.6+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f4fc02e384b74418679983a97385644b67e1263b"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll"]
git-tree-sha1 = "68da27247e7d8d8dafd1fcf0c3654ad6506f5f97"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "44ec54b0e2acd408b0fb361e1e9244c60c9c3dd4"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "5b0263b6d080716a02544c55fdff2c8d7f9a16a0"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.10+0"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f233c83cad1fa0e70b7771e0e21b061a116f2763"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.2+0"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "00af7ebdc563c9217ecc67776d1bbf037dbcebf4"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.44.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c3b0e6196d50eab0c5ed34021aaa0bb463489510"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.14+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "371cc681c00a3ccc3fbc5c0fb91f58ba9bec1ecf"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.13.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "125eedcb0a4a0bba65b657251ce1d27c8714e9d6"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.4+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libdrm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "63aac0bcb0b582e11bad965cef4a689905456c03"
uuid = "8e53e030-5e6c-5a89-a30b-be5b7263a166"
version = "2.4.125+1"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56d643b57b188d30cccc25e331d416d3d358e557"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.13.4+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "91d05d7f4a9f67205bd6cf395e488009fe85b499"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.28.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e015f211ebb898c8180887012b938f3851e719ac"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.55+0"

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "7dbf96baae3310fe2fa0df0ccbb3c6288d5816c9"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.23.0+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b4d631fd51f2e9cdd93724ae25b2efc198b059b1"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.5.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "a1fc6507a40bf504527d0d4067d718f8e179b2b8"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.13.0+0"
"""

# ╔═╡ Cell order:
# ╠═95c9b1cb-e413-4009-a832-a676be35636c
# ╠═c51dc284-e083-4f95-9dce-2759ec611bab
# ╠═26a0adb1-1409-4775-8cff-9aa2217903c6
# ╠═4aa83f77-90a8-4f20-8669-46bf2f979059
# ╠═f416ccd5-5c3e-4e11-a842-b72dadbf4226
# ╠═8e5cd055-1d1a-4d82-bc0d-ae6ef7e2adfe
# ╠═e64fb8a4-b40d-4b53-887d-bb5132d30a82
# ╠═f1ec4070-8fbc-4088-8506-6c4c789b4dec
# ╠═9ebd5f97-4f94-4eb1-9d4d-1d40009a1476
# ╠═050da6ba-9fae-4f6e-a644-a48a621d8fdd
# ╠═610612f6-91c9-45ab-922f-400a1765e2ac
# ╠═6ba64e0f-ac22-4203-b175-f15b124cda20
# ╠═164bed18-6886-4055-b25e-1624a34e5b7f
# ╠═9cd51ad4-b7fe-4bd4-800f-bf3e48a743e1
# ╠═5a304070-ce97-45b9-945a-5a3bef23ee71
# ╠═22735a60-aafc-4b14-9f00-fc625e862d88
# ╠═8765c09d-65a1-4ff2-a906-0886598b04e4
# ╠═d1bb7c89-03ea-4a94-86ac-85f33a52f841
# ╠═3b85dffb-381d-47f5-8f78-9af754b38fa2
# ╠═a049009a-a004-4e1e-ac97-4c14b2c8cc0f
# ╠═11940b7c-6e2a-4655-b95a-8c4c56cb6dbe
# ╠═9f6226c6-dc1e-4d32-9b80-b21946d85f8a
# ╠═bbb8f33f-2fb4-4cab-8573-2255e9b2cdaa
# ╠═e7367b43-8045-4528-89e0-aca2a8b3b420
# ╠═75dd41f9-5f61-45ee-9d90-0fab44f1b29b
# ╠═29b9e3bf-ffc5-452f-9c61-35a43bc313b6
# ╠═0387074d-4e1a-488b-9f53-6a787e800a55
# ╠═07ddffc2-ca74-4752-994b-6717ae703eb6
# ╠═ad88f03f-3dc3-4783-8346-4a6954ad5b63
# ╠═13f8e443-5272-4a7c-8f32-e0d39d86a0f8
# ╠═ac56d7ca-e7ee-4e37-82b9-22e06610263a
# ╠═2d41d953-f895-470b-b5c6-3059c4d23210
# ╠═556483ff-587b-48d0-93cc-625fd3a4fa14
# ╠═4bf8f4fb-63da-4316-aad6-4d0a74563415
# ╠═31bb27f3-ea48-4ea6-b111-b6a8338ced67
# ╠═37afde2e-d341-4273-9f61-5047abec4ccb
# ╠═ae84a119-649c-49af-8330-657acff20cc5
# ╠═af59e555-ad11-4228-8e8c-73dcc1bee42c
# ╠═78b06118-4099-40f4-ad9b-5b47679c9e37
# ╠═86810a39-1cc4-48f0-ab57-851fd45aa212
# ╠═a42bf88e-1f2d-44ad-a35b-c9f0e24881ff
# ╠═77cd36fb-456c-4d33-85c0-54d95a67e0c5
# ╠═bb470818-b822-4538-b459-8d8f33edb7fd
# ╠═409a7733-9e9d-4604-af4b-12f831cfc36e
# ╠═ff4e7014-d4cf-4da2-b3e6-ecbe8f7dc1e2
# ╠═3dffc1de-d32a-4667-9296-02201fac0584
# ╠═4c2a7d02-5284-4bfa-97e8-591f7d00ade3
# ╠═c3d409eb-b894-4216-9d0f-f7ee8b3c7d77
# ╠═597fc036-5c95-4b41-ab39-d23c36678b67
# ╠═48243c4c-69b4-4bf0-8371-71968c56e72b
# ╠═31713842-a036-457d-9f06-87e0c5caae3d
# ╠═28906501-f75e-48fb-aceb-a19106b01b21
# ╠═e81ae7f8-1f1b-4a08-a469-6348c4342943
# ╠═bd4b83d7-1b48-458f-a840-f610a0913313
# ╠═189a0b36-736d-4f56-8245-0c32087ac9de
# ╠═43ad7cd9-5e00-44a0-8453-5df3e584addf
# ╠═dfcef291-2876-4180-9160-36c556485c9b
# ╠═c128e913-3bd6-431e-89f9-2b7f1896aa7b
# ╠═6bdc79ec-802f-4786-b0d0-fbe849ed231d
# ╠═bbe1641b-7119-45e9-9a74-33c20732b34c
# ╠═fc9ae1d0-31a7-4634-be4d-089268f78cb9
# ╠═92db82cd-f153-4228-ab48-e2bef5da0553
# ╠═1123c67e-f1dc-4b18-9e42-86a2db615d85
# ╠═7a8d4ab5-9394-4205-9014-a8e1da3b29e7
# ╠═b551cba7-d4ac-4f48-9d99-08ef0d28b58e
# ╠═9ffbd29e-d28b-4ddb-8f36-e563d0342c48
# ╠═124ce647-2f07-4007-a733-31958b557309
# ╠═f3bebf5c-5e2d-47d6-b67b-9110fc3b85f6
# ╠═ec810b63-51ea-4107-9fcb-a5b1be5dc0eb
# ╠═6d7379c2-fc6f-4e5b-b24c-562d71379e16
# ╠═0b9a2567-17b6-473b-9208-9f5f3eed0d66
# ╠═cf216293-7a07-4cc1-a702-931feae1c1b7
# ╠═49c1a50e-6291-4f05-bf21-ab05d0caa2c7
# ╠═b0333914-e068-4a5d-bd6a-ffe41f490aa2
# ╠═bc98f5fc-bc79-4171-87cc-720a82508d49
# ╠═c6ae323e-9fe0-4766-909d-7a7554afd5d1
# ╠═e7af56e2-df6e-4dbe-8ced-b5b6dd14eabb
# ╠═32256af7-86ce-47b8-87f8-57aadfc44853
# ╠═132043b6-d081-4877-aad1-e24a0c711570
# ╠═502090a9-25bf-4106-a154-49b1b538285b
# ╠═2f7a0365-05c9-4c4b-bf69-d0ff31d8fb8b
# ╠═143593fe-b9c4-427b-becd-c1d74111bb22
# ╠═b24ec168-ca9f-4b66-ba45-fcd33f984984
# ╠═226b0d86-31dc-4726-871c-5b2eb3506809
# ╠═386f7f9c-1a16-4057-ad01-c38203dbb592
# ╠═541649ee-6505-4814-b5c8-bc0ce6c4d56a
# ╠═757f8a70-94b1-4982-8e02-cd791b631555
# ╠═d9c988b4-5403-4ec4-9845-b1568da8bf6b
# ╠═4f6a34c6-f974-4359-a502-3d4f738029e9
# ╠═c8268482-c7e4-46bb-9166-7f6d08107334
# ╠═ec8b9d88-b84e-49d0-9821-70a479c05df5
# ╠═1f8c5e8d-ebf6-4f1b-8a17-37ea9ada6e4b
# ╠═6f6022da-3e9c-4c03-8d57-eb5f5e813f64
# ╠═8dd6529f-d309-4822-9e4c-052104b5a20a
# ╠═85e9896d-c2d6-43f2-8a7e-43c07e4044fb
# ╠═c72b730f-8a22-4bdf-974f-7b75bfdb02b7
# ╠═9495c3f8-f947-477b-92ef-2bac79217be0
# ╠═fd7ca8d9-29b3-4524-9b34-1b60dcdfbf43
# ╠═57190953-ca75-47d1-ba81-2a8f4c333b0d
# ╠═824ae9c9-b600-4818-99ea-a5cba8a99a48
# ╠═85dba5a3-43d7-4a82-9952-af7333485aec
# ╠═32ea462a-9da1-45c1-a639-2deffc9bf4f5
# ╠═92262f8f-2679-4de6-abfd-d99db391da24
# ╠═745f5bfc-72f0-4432-a446-9cf0873fb06b
# ╠═449172b8-6b3d-44de-bf41-9efe01b1e976
# ╠═a21f0198-b10b-4f79-89fe-24b7eb0c3820
# ╠═a1a8dc20-a3db-4107-9e00-f4e8c8d12af5
# ╠═94c142b3-c339-4652-8e51-0450ca705af5
# ╠═a27b494a-1d5a-43a7-b293-fc9b09bca0a5
# ╠═d2c18a1d-6bff-44b5-88f4-74556636d21b
# ╠═43d4a082-8eaa-4893-9963-8aa105fe003e
# ╠═b4006caa-544c-42cd-80c8-587413059bac
# ╠═0ae37ab9-14e4-4882-be30-1185b9e93558
# ╠═2502b74a-52fe-47d2-9aff-c43d3bf549a2
# ╠═5743447f-7cba-4503-9d98-5841f32f74cc
# ╠═d2220eee-42bb-4135-8326-9e5f818e6a91
# ╠═6725bc56-1245-42f0-a32c-b3bca6acccda
# ╠═af94a37d-04a1-4708-8c8d-47d664632031
# ╠═d27de2c5-6168-4873-a650-1fcba8cc0767
# ╠═265c2da7-9266-40cd-a7ba-629ea51247fb
# ╠═70452016-0f80-4d17-bbf9-6e0a10694d9e
# ╠═d9df0af8-7ee6-42cb-bd5b-a9fe5e9a4439
# ╠═0d82212d-8532-4b58-b2c3-72b105ce69ab
# ╠═a41ef71a-7881-4716-b816-8018a375c384
# ╠═f40fa0c1-b7c5-4cc0-80af-962ffeeba327
# ╠═0cff771c-9bbd-4414-a1d7-3d2c3acb7765
# ╠═e2417347-97c9-483c-ac23-687843eb3d99
# ╠═d7f6ace6-37e5-4035-bea4-fb9ca212d6b3
# ╠═8657f5fd-cb4e-402d-b63f-a1016745a93e
# ╠═0f737ee5-7bde-41de-9f18-8610a6cb57f5
# ╠═26408fa7-e7e9-472f-a9f6-501740d22e53
# ╠═d5ff02b9-3c71-467d-b846-b991ed6aa966
# ╠═2b76a77b-b9aa-4425-a831-85ad67f3eb1e
# ╠═ab76a183-2779-48e1-b52b-7b12107af3ae
# ╠═52aa322f-1fec-4391-8d7e-3e54fcfff49d
# ╠═59bb63ff-b86b-4d56-a17d-73bad7abb3ff
# ╠═9276af20-c0cd-4f1d-b7f5-f59068bde963
# ╠═b5048f8b-9316-4f92-85ae-b881cec7bbe1
# ╠═54bc8ada-8f15-4540-a3ad-312865be442a
# ╠═094f263b-8fd0-4cf9-b868-f84836e26ecd
# ╠═56921e11-1b08-4842-90a1-fc870477483e
# ╠═2cf74e8c-92af-4d76-b63c-79a8aa19eaf0
# ╠═d7020429-d1f8-453b-b832-3e30f287b4dc
# ╠═e7a596f9-6c0a-439a-92b5-ed224625b222
# ╠═be061850-1c89-4cad-8b9c-786bc84637b6
# ╠═7a1efc92-7a66-4eaf-ac5c-9127830a91d2
# ╠═cba725a6-e7cc-431b-b966-43dcdb5500e0
# ╠═eb8ef4c9-4cd2-49e9-a62f-4d909ab52c62
# ╠═9ca6e8a2-635b-45da-8e78-fe6e39b3a0e6
# ╠═f0d72efb-e26c-4acd-a90a-71f77c0ab42e
# ╠═cea49201-c0f2-42ec-8051-c6302e4284a0
# ╠═8517b3e7-be3b-4311-ba73-e2a11da04c6e
# ╠═a85bb31c-2b00-4678-bf30-366b3bae1e00
# ╠═9af910f0-9059-4065-a3ab-75bd1bfd653c
# ╠═6f5edcde-412e-4dc0-8e25-77b46419b327
# ╠═d445b0bf-15e1-4aaa-bc2a-41d0f51cc86f
# ╠═a7341726-78c8-46e9-92fc-f2476cd261c5
# ╠═40f825bd-9c7a-470c-999c-e9c9bb7256ab
# ╠═3ba8a43b-32fb-4b21-a03e-9e1aed8a8a4f
# ╠═7148be59-7fb9-47f0-a4db-7757eb431f3f
# ╠═a0c3a9a3-f048-441f-9caf-7d127d309abf
# ╠═79cc7525-9de9-4717-a8a5-66e3b92759ba
# ╠═b43bfda9-52c9-44c1-9695-ec777dde4841
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

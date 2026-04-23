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

# ╔═╡ 8f7caf16-306c-41e3-a38a-fc8f681a3626
begin
	using AeroFuse
	using PlutoUI
	using DataFrames
	using Plots
	using StaticArrays
	gr(size = (800,600))
	TableOfContents()
end

# ╔═╡ 07559c60-063b-11f0-1a5c-37ed11f4209e
md"""
# Weight & Balance with Stability Analysis

## Example: Jet Aircraft -- Boeing 777-200LR

![](https://www.norebbo.com/wp-content/uploads/2012/12/777-200-custom-livery-001.jpg)

**Source**: [https://www.norebbo.com/wp-content/uploads/2012/12/777-200-custom-livery-001.jpg](https://www.norebbo.com/wp-content/uploads/2012/12/777-200-custom-livery-001.jpg)

"""

# ╔═╡ 17a7b231-19fb-455b-a93a-687251df87fb
begin
	ϕ_s1 			= @bind ϕ1 Slider(0:1e-2:90, default = 15)
	ψ_s1 			= @bind ψ1 Slider(0:1e-2:90, default = 30)
	ϕ_s2 			= @bind ϕ2 Slider(0:1e-2:90, default = 15)
	ψ_s2 			= @bind ψ2 Slider(0:1e-2:90, default = 30)
	ϕ_s3 			= @bind ϕ3 Slider(0:1e-2:90, default = 15)
	ψ_s3 			= @bind ψ3 Slider(0:1e-2:90, default = 30)
end;

# ╔═╡ d6b41872-bd8e-45d1-baa2-fa0cc36b6177
md"""### Wing
First, you can define the wing from your preliminary wing sizing. Here, we'll choose a supercritical airfoil for the wing section. **This is not the same one as used in the Boeing 777-200LR.**
"""

# ╔═╡ d9ef5002-70d7-40a8-81fa-7a07567eb613
<<<<<<< Updated upstream
<<<<<<< Updated upstream
begin
foil_w_root = read_foil("Airfoil\\NACA64_312.txt") # Read the root airfoil
foil_w_tip  = read_foil("Airfoil\\NACA64_209.txt")#Read the tip airfoil
end

# ╔═╡ a76599c7-563d-4647-8fda-36869d07ff71
plot(foil_w_root, aspect_ratio = 1)

=======
foil_w = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=rae2822-il")) # Download airfoil
=======
foil_w = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=rae2822-il")) # Download airfoil

# ╔═╡ a76599c7-563d-4647-8fda-36869d07ff71
plot(foil_w, aspect_ratio = 1)
>>>>>>> Stashed changes

# ╔═╡ a76599c7-563d-4647-8fda-36869d07ff71
plot(foil_w, aspect_ratio = 1)

>>>>>>> Stashed changes
# ╔═╡ 87f54aa2-861a-44f7-b331-1198f522d1e4
md"""Here, we'll define a two-section wing planform that we'll use in this notebook."""

# ╔═╡ c8c3daf0-4e63-49b6-bc07-6ba37f817c5e
wing = Wing(
    foils       = fill(foil_w, 3),              # Airfoils
    chords      = [14.4, 9.6, 1.5],  			# Chord lengths
    spans       = [14.0, 46.9] / 2,             # Span lengths
    dihedrals   = fill(6, 2),                   # Dihedral angles (deg)
    sweeps      = fill(35.6, 2),                # Sweep angles (deg )
    w_sweep     = 0.,                           # Leading-edge sweep
    position    = [19.51, 0., -2.5],            # HOW DO YOU DETERMINE THIS?
    symmetry    = true                          # Symmetry
)

# ╔═╡ 678f44cb-e7fa-403d-bb45-7ece4195b88b
md"""
!!! hint
	You may have to change the wing position to maintain weight balance and aerodynamic stability.
"""

# ╔═╡ 6131d42a-38c5-4af5-b065-ba022852146c
sweeps(wing, 0.25)  # Quarter-chord sweep angles

# ╔═╡ 618ba8c3-8d46-4ef3-a038-5ecdb21eab03
md"The following quantities will be useful for evaluation of the static stability."

# ╔═╡ 77be2a32-09fb-4f8e-8aca-09bad314e790
begin
	AR_w = aspect_ratio(wing)
	S_w = projected_area(wing)
	lambda_w = deg2rad(sweeps(wing, 0.)[1]) # Leading-edge sweep angle, rad
	b_w = span(wing)
	c_w = mean_aerodynamic_chord(wing)
end;

# ╔═╡ 38c60ab8-cf05-4051-a5a8-e35ffae7e50c
md"Let's compute the mean aerodynamic center, which is at 25% of the mean aerodynamic chord by default. Go to the appendix in this notebook to see how this is calculated!."

# ╔═╡ 335a090d-a50c-4f9c-a23a-a32b8ff6de34
mac25_w = mean_aerodynamic_center(wing, 0.25)

# ╔═╡ 9d59c6d6-0e2e-40be-aedb-2ea21f6639a8
mac25_w.x 	# x-coordinate of mean aerodynamic center at 25%

# ╔═╡ 4b84579b-3a9f-43e8-88bc-879cd950f657
mac25_w.y 	# y-coordinate of mean aerodynamic center at 25%

# ╔═╡ 3e31ace1-1073-49b8-936b-1d5da789b895
md"You can also use this function to compute the centroid at various chordwise ratios."

# ╔═╡ 5baf5f31-eba8-42eb-9d62-96ce53c7cac8
mac40_w = mean_aerodynamic_center(wing, 0.40) # at 40% of the chord length

# ╔═╡ 12d6baf4-c15b-46e8-8be3-0cc52fc9267b
mac40_w.x 	# x-coordinate of mean aerodynamic center at 40%

# ╔═╡ c7d034c8-d72f-461e-93e6-603a9c8f4c62
md"""
!!! warning
	The choice of the mean aerodynamic center percentage is important when considering subsonic or supersonic flow! From thin airfoil theory, the mean aerodynamic center for subsonic flow is located at approximately $25\%$ of the chord length. As the flow reaches supersonic conditions, the mean aerodynamic center is experimentally observed to gradually move aft, to approximately $50\%$.
"""

# ╔═╡ 0d0e82f3-d489-4abc-8887-3e557380d21e
md"### Engines
We can also place the engines based on the wing information.
"

# ╔═╡ fb46cb05-f84c-4554-93cb-5491ebdc9eb0
wing_coo = coordinates(wing) # Get leading and trailing edge coordinates

# ╔═╡ d90d5231-8680-4d24-ac39-be9e2d532c10
wing_coo[1,:] # Leading edge coordinates

# ╔═╡ 25f56a3b-b8f8-4304-969d-7a4e49c338ea
begin 
	eng_L = wing_coo[1,2] - [1, 0., 0.] # Left engine, at mid-section leading edge
	eng_R = wing_coo[1,4] - [1, 0., 0.] # Right engine, at mid-section leading edge
end;

# ╔═╡ 9be9d09b-a563-49a7-a6c8-72adcbf3a840
md"### Fuselage"

# ╔═╡ b849f0aa-6391-4945-8ef3-70907a9ff1ec
fuse = HyperEllipseFuselage(
<<<<<<< Updated upstream
	radius = 1.7, 			# Radius, m (diameter 3.4)
=======
	radius = 1.75, 			# Radius, m (diameter 3.5)
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
	length = 32, 			# Length, m
	x_a    = 0.145, 		# Start of cabin, ratio of length
	x_b    = 0.81,  			# End of cabin, ratio of length
	c_nose = 1.3,  			# Curvature of nose
	c_rear = 1.2,  			# Curvature of rear
	d_nose = -0.75, 			# "Droop" or "rise" of nose, m
	d_rear = -0.09,  			# "Droop" or "rise" of rear, m
	position = [-0.123,0.,0.] 	# Set nose at origin, m
);

# ╔═╡ 4b754590-3137-4400-a1a9-bd99135aee4d
ts = 0:0.01:1 # Distribution of each section for surface area and volume computation

# ╔═╡ ef4431d6-5113-4e77-b549-62b0f6444a39
S_f = wetted_area(fuse, ts) # Surface area, m²

# ╔═╡ 532e2bf5-2ab9-4efb-84a3-3ab16b6ea81b
V_f = volume(fuse, ts) # Volume, m³

# ╔═╡ 2b098bef-934b-40fa-8da5-f08d032aa0e4
fuse_end_x = fuse.affine.translation.x + fuse.length # x-coordinate of fuselage end

# ╔═╡ 7f9790ab-a1af-4de3-8375-44d11d784bf7
md"### Visualization"

# ╔═╡ 04f96ffb-aa30-4bf5-918f-ba1d8528768f
camera_angles1 = md"""
ϕ: $(ϕ_s1)
ψ: $(ψ_s1)
"""

# ╔═╡ c559cb5f-a016-43a0-8596-89f006245b4f
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

# ╔═╡ 8026eb26-010f-487b-bd6d-e82939d09d54
md"## Stabilizer Design"

# ╔═╡ 28739577-e9fd-48f2-8f55-a036b560931d
md"### Horizontal Tail"

# ╔═╡ 115e9a7e-c194-4ac3-bc10-19d6d8973537
con_foil = control_surface(naca4(0,0,0,9), hinge = 0.91, angle = 0)

# ╔═╡ 704943ec-10e2-4c50-994b-4688a99ac6c7
htail = WingSection(
<<<<<<< Updated upstream
    area        = 13.7,  # HOW DO YOU DETERMINE THIS?--> Area~12.5-25% S_wing
    aspect      = 7.1,  
    taper       = 0.25,  
    dihedral    = 0.,   
    sweep       = 30.,  
=======
    area        = 101,  # HOW DO YOU DETERMINE THIS?
    aspect      = 4.16,  
    taper       = 0.4,  
    dihedral    = 7.,   
    sweep       = 35.,  
>>>>>>> Stashed changes
    w_sweep     = 0.,   # Leading-edge sweep
    root_foil   = con_foil, 		# Root airfoil
	tip_foil    = con_foil, 		# Tip airfoil
    symmetry    = true,
    
    ## Orientation
    angle       = -3,           # Incidence angle (deg), HOW DO YOU DETERMINE THIS?
    axis        = [0., 1., 0.], # Axis of rotation, y-axis
    position    = [ fuse_end_x - 6., 0., 0.], # HOW DO YOU DETERMINE THIS?
);

# ╔═╡ 50969d37-e674-4fa7-b28f-04833835e6a3
begin
println("Wing MAC x: ", mean_aerodynamic_center(wing, 0.25).x)
println("HTail MAC x: ", mean_aerodynamic_center(htail, 0.25).x)
end


# ╔═╡ 9072dc86-1f9f-48c5-8b11-31bf722223f2
begin
	AR_h 		= aspect_ratio(htail)
	S_h 		= projected_area(htail)
	lambda_h 	= deg2rad(sweeps(htail)[1])
	mac25_h 	= mean_aerodynamic_center(htail, 0.25)
	mac40_h 	= mean_aerodynamic_center(htail, 0.4)
end;

# ╔═╡ 04750bc6-5e32-4182-8c58-805d902bc6b4
md"""
Recall the definition of the tail volume coefficient:

```math
V_h = \frac{S_h l_h}{S_w \bar c}
```

"""

# ╔═╡ 9f330052-b13c-4a11-84e9-95ee1d404e9e
l_h = mac25_h.x - mac25_w.x # Horizontal tail moment arm

# ╔═╡ ae2b717e-3102-4954-9f02-763e96794762
V_h = S_h / S_w * l_h / c_w # Horizontal tail volume coefficient

# ╔═╡ 25fba8e3-b444-424d-b839-836ab64d76ac
md"### Vertical Tail"

# ╔═╡ add41f70-5744-494f-8324-726fa5d9bb27
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

# ╔═╡ 0c13b5ef-8a2e-4cb9-a246-69f66db9b92f
chords(vtail)

# ╔═╡ 32d4cbb9-0206-4708-85fa-f8001fda9e9b
md"### Visualization"

# ╔═╡ 888b4f11-37ba-43df-984b-a887563142ff
begin
	S_v = projected_area(vtail)
	mac25_v = mean_aerodynamic_center(vtail, 0.25)
	mac40_v = mean_aerodynamic_center(vtail, 0.4)
end;

# ╔═╡ 1be5a6b2-994a-44b0-8b13-5bbb1fffecd9
md"""Recall the tail volume coefficient:

```math
V_v = \frac{S_v l_v}{S_w b}
```
"""

# ╔═╡ 69f762a3-9a0c-4480-a300-30c3a3914d36
l_v = mac25_v.x - mac25_w.x # Vertical tail moment arm

# ╔═╡ 18a16755-03be-483b-8fb2-51a4fa78bf68
V_v = S_v / S_w * l_v / b_w # Vertical tail volume coefficient

# ╔═╡ 1d16ebec-add7-4d22-854e-cf92d45fc2a3
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

# ╔═╡ cd504799-eb4d-4518-9da6-a1ed95c9c9e6
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

# ╔═╡ e531ec16-57df-4d07-b913-8bb5569a4bf9
md"""

!!! warning
	These are not all the weights present in the aircraft! So which CG are you estimating?

"""

# ╔═╡ c159f556-4443-4077-acf2-2c11422cf86a
begin
	# Reference quantities
	TOGW = 766000 *	0.4536 # Takeoff gross weight, kg
	W_engine = 8762 # GE90-110B1 engine weight (single), kg
end;

# ╔═╡ e7bcb068-b1b4-45c3-a549-75d6af6dc871
lb_ft2_to_kg_m2 = 4.88243 # Convert lb/ft² to kg/m²

# ╔═╡ 70f129d3-ffa8-4019-bd53-34185ad85356
md"For the previously generated wing, the total longitudinal moment (with MAC at $40%) with respect to the nose as origin is:"

# ╔═╡ a3924235-a17d-463a-b1f4-4bd8f715fe5f
M_w = (10 * lb_ft2_to_kg_m2 * S_w) * mac40_w.x # Moment generated by wing weight

# ╔═╡ 5b12700f-a0ad-4f29-afc7-649ce6c1dfc4
md"We can express the landing gear, fuselage, and all-other component centroids  in terms of the fuselage length and its origin, the nose in this case."

# ╔═╡ ae708986-6529-4069-904e-60858905f319
begin
	x_nose 	= fuse.affine.translation.x 	# Nose location 
	x_fuse 	= x_nose + fuse.length / 2   	# Fuselage centroid (50% L_f)
	x_other = x_nose + fuse.length / 2 		# All-other component centroid (50% L_f)
	x_nLG  	= x_nose + 0.15 * fuse.length  	# Nose landing gear centroid (15% L_f)
	x_mLG 	= x_nose + 0.5 * fuse.length  	# Main landing gear centroid (50% L_f)
end;

# ╔═╡ 0567a709-6420-44f6-908f-28c283bbaecf
md"""The weight and CG position of each component can hence be computed and included in a dictionary for convenience in calculations."""

# ╔═╡ 9e9f2802-c8ee-4df4-b643-ee3a271e2986
weight_position = Dict(	
	"engine" 	=> (1.3 * 2 * W_engine, 			eng_L.x), 	# Engines (2 × weight)
	"wing"   	=> (S_w * 10  * lb_ft2_to_kg_m2, 	mac40_w.x), # Wing, 40% MAC
	"htail"  	=> (S_h * 5.5 * lb_ft2_to_kg_m2, 	mac40_h.x), # HTail, 40% MAC
	"vtail"  	=> (S_v * 5.5 * lb_ft2_to_kg_m2, 	mac40_v.x), # VTail, 40% MAC
	"fuse"   	=> (S_f * 5.0 * lb_ft2_to_kg_m2, 	x_fuse), 	# Fuse, centroid
	"all-else" 	=> (0.17 	* 		 TOGW, 			x_other),
	"noseLG" 	=> (0.043 	* 0.15 * TOGW, 			x_nLG), 
	"mainLG" 	=> (0.043 	* 0.85 * TOGW, 			x_mLG),
);

# ╔═╡ 1cb4658c-16ac-412b-8dfb-49778f7fe78a
W_wing, x_wing = weight_position["wing"] # Get weight and position of 'wing' entry

# ╔═╡ 6468ecea-d228-4789-a8dd-74b053aa0047
keys(weight_position) # Get keys of the dictionary

# ╔═╡ 816c7fef-e74a-4628-a81a-878b53a1d9ab
values(weight_position) # Get corresponding values of the dictionary

# ╔═╡ 5fcf1f4b-ff6a-4458-b253-21c9a2f1f4a4
md"""

!!! warning 
	Dictionaries are **not ordered** according to the entries upon generation.
"""

# ╔═╡ 26df6f87-cb16-49c7-b7da-b7d18f793d9d
md"Now we can calculate the total longitudinal moments generated from all the components, i.e., $\sum_i W_i x_{\text{cg}_i}$"

# ╔═╡ 14daf923-a87c-4e32-853f-51aabff2794b
moments = [ weight * pos_x for (weight, pos_x) in values(weight_position) ]

# ╔═╡ 693c8ac5-8d90-4427-ba1d-a787224245c4
M_sum = sum(moments) # Sum all moments

# ╔═╡ 6949b7fb-9e9b-4cf4-a6e9-8e4f4c8a0445
md"The same applies to the total weight, i.e., $\sum_i W_i$"

# ╔═╡ d4213288-b448-4783-a3bc-78c2fb25b4a6
W_sum = sum(weight for (weight, pos_x) in values(weight_position)) # Sum weights

# ╔═╡ cba370b6-b8c8-44d8-970b-a178602d596f
x_cg = M_sum / W_sum 	# Compute center of gravity, m

# ╔═╡ f87881bb-7eeb-4ded-b9e4-21a72410872e
md"#### Neutral Point

The neutral point is:
```math
\frac{x_{np}}{\bar c} = V_h\frac{C_{L_{\alpha_h}}}{C_{L_{\alpha_w}}} - \frac{\partial C_{m_f}}{\partial C_L}, \qquad V_h = \frac{S_h l_h}{S_w \bar c}
```
"

# ╔═╡ ff8adfc7-59ea-4f46-b102-ec09a039bd55
function neutral_point(V_h, CL_αh, CL_αw, dCm_fuse_dCL)
	x_np = V_h * CL_αh / CL_αw - dCm_fuse_dCL
	return x_np;
end;

# ╔═╡ cd9bc398-9f62-4a93-90bf-bf9896abbb2e
md"""3 parameters are unknown after the sizing and placement of the empennage:
1. The lift curve slope for the wing $C_{L_{\alpha_w}}$ 
2. The lift curve slope of the horizontal stabilizer $C_{L_{\alpha_h}}$ 
3. Derivative of pitching moment of fuselage (including other components) with respect to $C_L$ $\frac{\partial C_{m_{f}}}{\partial C_L}$ 
"""

# ╔═╡ c4bdfa4e-e4bb-4ba8-9a64-80c867a2ed99
md"Let's determine the distance between the CG and the aerodynamic center of the wing using the values from the previous section."

# ╔═╡ e0fe156d-7748-4585-bb80-c0c487af76cf
x_cg - mac40_w.x

# ╔═╡ d53fa5b1-eadb-4bc5-a00e-55308f55fac0
md"""

!!! danger "Sanity Check"
	If it's negative, it means the CG is ahead of the wing's aerodynamic center with respect to the nose as the origin! 
"""

# ╔═╡ cc80f43c-b0fb-4f2f-9f8f-7b3fed86405d
md"Keep in mind that the neutral point is the equivalent of the aerodynamic center of the aircraft, namely including all lifting surfaces!"

# ╔═╡ aa2e3ac0-fb90-43a0-8177-c6cf1a2019b4
md"##### Wing Contribution
The wing lift curve slope can be approximated using the DATCOM formula.
```math
 C_{L_{\alpha_w}} \approx \frac{2\pi AR_w}{2 + \sqrt{(AR_w/\eta)^2 (1 + \tan^2\Lambda_w - M^2) + 4}}
```
"

# ╔═╡ 49dec81f-909e-4a05-b8be-a72231b47a85
function lift_slope_DATCOM(AR, eta, sweep_LE, M)
	CL_α_w = 2π * AR / (2 + sqrt((AR/eta)^2 * (1 + tan(sweep_LE)^2 - M^2) + 4))
	return CL_α_w
end

# ╔═╡ a79b738f-90ca-4213-a89f-80e2dfce2fa5
# Example
begin
	eta = 0.97 # Aerodynamic efficiency factor (for DATCOM formula)
	M = 0.84 # operating cruise Mach number
	CL_α_w = lift_slope_DATCOM(AR_w, eta, lambda_w, M)
end

# ╔═╡ 7b1e3dc7-423c-4c4a-9ffd-be54fe991c47
md"##### Horizontal Tail Contribution
The downwash effect on the lift curve slope of the horizontal stabilizer is estimated by applying lifting line theory. For an elliptically loaded structure:
```math
C_{L_{\alpha_h}} = C_{L_{\alpha_{h_0}}} \left(1 - \frac{\partial \epsilon}{\partial \alpha} \right)\eta_h, \qquad \frac{\partial \epsilon}{\partial \alpha} \approx \frac{2C_{L_{\alpha_w}}}{\pi AR_w}
```

where $\epsilon$ is the _downwash angle_, and $\eta_h$ is the horizontal stabilizer aerodynamic efficiency which accounts for changes in the flow due to the wing.
"

# ╔═╡ 92ab5a18-eeb0-44ff-a20a-b12b3093aa43
function downwash_slope(CL_α_w, AR_w)
	∂ϵ_∂α = 2 * CL_α_w / (π * AR_w)
	return ∂ϵ_∂α
end

# ╔═╡ 23d5c748-d77c-4252-add0-deade4f4a416
function lift_slope_tail_DATCOM(AR_h, eta_h, sweep_LE_h, M, CL_α_w, AR_w)
	CL_α_0 = lift_slope_DATCOM(AR_h, eta_h, sweep_LE_h, M) # DATCOM, ∂CL/∂α_0
	∂ϵ_∂α = downwash_slope(CL_α_w, AR_w)
	corr = (1 - ∂ϵ_∂α) * eta_h # Correction factor
	return CL_α_0 * corr # corrected lift-curve slope
end

# ╔═╡ 0a763717-9f1b-4c6d-98ed-95029d01f509
eta_h = 0.88 # Horizontal stability aerodynamic efficiency factor (for DATCOM)

# ╔═╡ 40e02dbd-fcd4-4297-ab3b-bc5b3d71717a
CL_α_h = lift_slope_tail_DATCOM(AR_h, eta_h, lambda_h, M, CL_α_w, AR_w) # 1/radians

# ╔═╡ dff70e54-4ea9-4edf-a3ca-2f7c765b624f
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

# ╔═╡ 4deac195-47c6-4053-9812-cac86eb34913
md"""

!!! hint
	What design requirements would determine the width or height of the fuselage?

"""

# ╔═╡ fe494a18-44d3-4342-beea-a6ac891066af
# Fuselage moment-lift derivative
function fuse_Cm_CL(vol_fuse, S_w, c_bar, CL_α_w)
	fuse_Cm_CL = 2 * vol_fuse / (S_w * c_bar * CL_α_w)
end;

# ╔═╡ e74c66b7-287d-46ed-9e5b-a241fe06055a
Cm_f_CL = fuse_Cm_CL(V_f, S_w, c_w, CL_α_w)

# ╔═╡ 62df7c3a-4667-41a6-98b3-aa330519a41a
md"##### Static Margin
Now we can estimate the neutral point of the aircraft.
"

# ╔═╡ 23db0b3d-f844-4889-8386-79126a19093b
x_np_by_c = neutral_point(V_h, CL_α_h, CL_α_w, Cm_f_CL) # (xₙₚ/c̄)

# ╔═╡ e07d5942-bb5e-41cc-9deb-369c25ef6c2e
x_np = mac40_w.x + x_np_by_c * c_w 		# Translate from the wing MAC

# ╔═╡ 0c8b15b1-d848-47f3-ab7d-bd8f254970b0
md"So we obtain the static margin as:"

# ╔═╡ bf08b856-d9d8-4fdc-876e-9950dc549f6e
SM = (x_np - x_cg) / c_w

# ╔═╡ 133329d8-cd89-46ab-8691-81cbfeb72649
SM * 100 # in percentage

# ╔═╡ f71f0b50-161e-4ca3-bbd7-73a8691ee2b6
md"### Visualization"

# ╔═╡ 7a8932d4-1470-47f1-a598-192ccfa66d94
begin 
	# Position vectors for plots
	r_cg  = [x_cg, 0, 0]  			  # Center of gravity
	r_np  = [x_np,  0., 0.] 		  # Neutral point
	r_mLG = [x_mLG, 0., -fuse.radius] # Main landing gear
	r_nLG = [x_nLG, 0., -fuse.radius] # Nose landing gear
end

# ╔═╡ 929142bd-0ab7-4c89-b3f1-e0bc652caa09
camera_angles2 = md"""
ϕ: $(ϕ_s2)
ψ: $(ψ_s2)
"""

# ╔═╡ dc65ebaa-cd46-4763-bf96-7210f6bc620b
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
end

# ╔═╡ deb15310-a7ef-4291-990e-c4bba8e5c176
md"# Alternative: Vortex Lattice Method
The vortex lattice method (VLM) provides estimations of aerodynamic derivatives, which can also be used to evaluate the stability with fewer approximations.
"

# ╔═╡ bb607eb8-b337-4320-8c4a-629a26796eca
md"## Analysis Setup
First, let's mesh the lifting surfaces.
"

# ╔═╡ 47dd8354-5778-460b-84a5-93fa8ca796a1
md"""

!!! info
	The meshing cells below have been disabled to speed up the loading of the notebook. You can enable them to activate the VLM analysis. **You may have to run each dependent cell further below (possibly faded block) manually after enabling these three cells.**
"""

# ╔═╡ 80c18169-5f8d-4665-9320-270aa20e926a
wing_mesh = WingMesh(wing, [8,16], 10, 
	span_spacing = fill(Uniform(), 4) # Number of spacings = number of spanwise stations (including symmetry)
)

# ╔═╡ e9318a7c-125c-4db1-a220-eb0d6de00212
htail_mesh = WingMesh(htail, [10], 8)

# ╔═╡ 5f7738d8-367c-40fc-87f0-f6732623392d
vtail_mesh = WingMesh(vtail, [8], 6)

# ╔═╡ aa1ac62e-244d-4fc3-8543-0db8104e740a
md"Now we define the aircraft, freestream and reference values."

# ╔═╡ d3dc7232-ab8b-408d-a8d4-d1cf443afe52
ac = ComponentVector(
	wing  = make_horseshoes(wing_mesh),
	htail = make_horseshoes(htail_mesh),
	vtail = make_horseshoes(vtail_mesh)
);

# ╔═╡ 777ee0ce-64fa-4dfe-91f1-ca7d8f61a7a4
fs = Freestream(
	alpha = 0.0, # HOW DO YOU CHOOSE THIS?
	beta = 0.0,
);

# ╔═╡ 41a1dda8-275e-4090-bcd8-5670b4d005a7
refs = References(
	speed = M * 330.,
	density = 1.225,
	area = projected_area(wing),
	chord = mean_aerodynamic_chord(wing),
	span = span(wing),
	location = [0.,0.,0.], # From the nose as reference (origin)
);

# ╔═╡ 8f269b3f-90e8-4cd1-a05a-4fbc63de1cdb
md"Now, let's run the VLM analysis."

# ╔═╡ 4e2cf07e-a5c6-464d-ba5e-c3ee0c7098e3
sys = solve_case(ac, fs, refs,
		name = "Boing",
		compressible = true,
	)

# ╔═╡ 26d51540-49e4-44b3-af4d-62478d6327e2
md"## Angle of Attack Variation"

# ╔═╡ 41028657-878a-4f99-83dc-060a8b95a78a
function solve_alpha(ac, α, M, refs, compressible = false)
	# Set reference speed with input Mach number
	new_ref = @set refs.speed = M * refs.sound_speed 
	new_fs = Freestream(alpha = α) # Set angle of attack
	sys = solve_case(ac, new_fs, new_ref, compressible = compressible) # Solve system

	return sys
end

# ╔═╡ ca7d7dc1-8ec7-4480-99da-5aa0695c84dd
begin
	alphas = -10:10 # Angles of attack
	M1 = M 			# Operating condition
	M2 = 0.2 		# Subsonic condition
end

# ╔═╡ be3485c9-2aec-41f3-8c05-5d6ceadd787d
vlms_M1 = map(alpha -> solve_alpha(ac, alpha, M1, refs, true), alphas); # Evaluate for range of angles at operating Mach number

# ╔═╡ cc237b8a-f912-46b9-8ea1-b68a04bb322c
vlms_M2 = map(alpha -> solve_alpha(ac, alpha, M2, refs), alphas); # Evaluate for range of angles at other Mach number

# ╔═╡ ce4faad3-c7d1-4fa1-b907-305e1ffb0206
begin
	nfs_M1 = mapreduce(nearfield, hcat, vlms_M1)'
	nfs_M2 = mapreduce(nearfield, hcat, vlms_M2)'
end

# ╔═╡ eb8954a0-f8da-4825-b0a9-bc13f2b53ebe
# Create DataFrame
df_M1 = DataFrame(
	[ alphas nfs_M1 ], 
	[:al,:CDi,:CY,:CL,:Cl,:Cm,:Cn]
)

# ╔═╡ 4f0aac7f-2b19-4a45-ad01-36626d594f42
# Create DataFrame
df_M2 = DataFrame(
	[ alphas nfs_M2 ], 
	[:al,:CDi,:CY,:CL,:Cl,:Cm,:Cn]
)

# ╔═╡ 0f45f2a6-0aa7-4c58-9b1e-4c538584f4e9
begin
	plt_Cm_CL = plot(df_M1[!,"CL"], df_M1[!,"Cm"], xlabel = "CL", ylabel = "Cm", label = "M = $(mach_number(vlms_M1[1].reference))") # Operating condition
	
	plot!(df_M2[!,"CL"], df_M2[!,"Cm"], xlabel = "CL", ylabel = "Cm", label = "M = $(mach_number(vlms_M2[1].reference))") # Subsonic condition
end

# ╔═╡ 04b8750c-87ce-4063-a8d5-388f2e08aaa6
# savefig(plt_Cm_CL, "Cm_CL_curve.png")

# ╔═╡ 43fcac01-3590-4560-aefd-5881f1fd2f76
md"So $\partial C_m/\partial C_L$ is negligibly sensitive to the Mach number."

# ╔═╡ f2ae1eaa-0844-4c8c-9939-298661195d72
md"## Freestream Derivatives
You can evaluate the derivatives of the forces and moment coefficients $(C_{D_i}, C_Y, C_L, C_l, C_m, C_n)$ computed via the VLM analysis with respect to the freestream values $M, \alpha, \beta$.
"

# ╔═╡ 24435be1-39d8-43d8-8ff6-cf8e4a3b954c
dvs = freestream_derivatives(sys, 
		# print = true, # Print derivatives for only the aircraft
		print_components = true, # Print derivatives for all components
		farfield = true, # Farfield derivatives (usually unnecessary)
	)

# ╔═╡ 78da147a-7b02-4751-b558-955217089dbd
dvs.htail # Use the 'dot' syntax to access the values and derivatives of each component

# ╔═╡ 7ef0b6d0-b55d-4552-aeec-fada357b377d
ac_dvs = dvs.aircraft # Accessing the derivatives of the aircraft

# ╔═╡ 82768f65-3f44-4184-86dc-1715cfe5677d
ac_dvs.Cm_al # Moment curve slope of aircraft

# ╔═╡ 68887c8c-9346-4bab-9c76-588adecac9eb
ac_dvs.CZ_al # Lift curve slope of aircraft

# ╔═╡ f033373f-1d24-4ddd-9bb8-93c6363bcbaf
dvs.wing.CZ_al # Lift curve slope of wing

# ╔═╡ 87ced096-5bba-4b5d-9ddf-247b43fd97f9
dvs.htail.CZ_al # Lift curve slope of horizontal tail

# ╔═╡ a02429ea-3366-4d06-9c11-4044048569a6
md"""
!!! tip
	Compare the lift curve slopes estimated from the vortex lattice method compared to the DATCOM formula predictions!
"""

# ╔═╡ 20c9112d-84db-42e1-aa33-5bf9f6ea016b
CL_α_w 	# DATCOM lift curve slope for the wing

# ╔═╡ 3d38e9d2-7319-4b4b-ab7c-bcb3d475d17f
CL_α_h  # DATCOM lift curve slope for the horizontal tail

# ╔═╡ 65efafc2-3f58-40ac-9ecf-81bf0b133205
md"## Stability Analysis
The location of the center of pressure is:

```math
	x_{cp} = -\bar c \frac{C_m}{C_L}
```
"

# ╔═╡ 4b235b39-43c0-44db-afe0-29306e59e50f
x_cp = -refs.chord * ac_dvs.Cm / ac_dvs.CZ # Center of pressure

# ╔═╡ de870ed8-944f-438e-8cf8-d951d96797d9
md"""

Recall from your notes, the definition of neutral point:

```math
	x_{np} = -\bar c \frac{C_{m_\alpha}}{C_{L_\alpha}}
```

!!! info 
	Here, we add the contribution of the fuselage $\partial C_{m_f}/\partial{C_L}$ from the slender-body approximation, as the VLM doesn't account for the fuselage effects. But we'll use the lift curve slope computed from the VLM in this approximation instead of the DATCOM formula.
"""

# ╔═╡ e7a0bccb-d292-48b5-bcb7-3a4cb53f065f
Cm_fuse_CL = fuse_Cm_CL(V_f, S_w, c_w, dvs.wing.CZ_al) # Fuselage Cm/CL

# ╔═╡ 7fbb061f-a9ef-47bd-9989-37119e4e6b88
x_np_vlm = -refs.chord * (ac_dvs.Cm_al / ac_dvs.CZ_al + Cm_fuse_CL) # Neutral point

# ╔═╡ 88c47f03-fa83-497a-8738-a4a0f47cf966
begin 
	# Translating position vectors wrt to nose as origin
	r_cp 		= refs.location + [x_cp, 0, 0]
	r_np_vlm 	= refs.location + [x_np_vlm, 0, 0]

	r_cp, r_np_vlm
end

# ╔═╡ 26513f85-c5d5-42aa-bdb2-7e8353cada30
SM_VLM = (r_np_vlm - r_cg).x / c_w

# ╔═╡ 532a497e-0faf-450b-89ff-9e0482a94a94
SM_VLM * 100 # From VLM analysis, in percentage

# ╔═╡ 3e947f88-dfe4-4425-a0cf-cb609aa574c0
SM * 100 # From DATCOM approximations, in percentage

# ╔═╡ 936bad10-c8ca-4911-af6c-c8cb7926f2cf
md"""
!!! hint
	The VLM accounts for the detailed wing/tail geometry (airfoil, orientation, etc.) in determining ``C_{m_a}, C_{L_a}``. Did we use this information in the previous neutral point estimation? Specifically, the downwash angle approximation may not always be correct.
"""

# ╔═╡ a68fe0b6-eb1c-4df6-9c19-e0057dfe2208
md"## Visualization"

# ╔═╡ 45cd25ad-fa8c-44d3-a3d1-1a9043dbff03
print_derivatives(dvs.aircraft; farfield = true) # Example of printing

# ╔═╡ 143d4eb1-3e19-4ca8-8bea-e0d35bf69761
plot_vlm = @bind plot_vlm CheckBox(default = false)

# ╔═╡ 17c59c56-d2aa-44d9-8658-bd323b7d50b7
plot_streamlines = @bind plot_streamlines CheckBox(default = false)

# ╔═╡ a9cc0876-a907-4b39-bf8b-5c1c8f92258a
camera_angles3 = md"""
ϕ: $(ϕ_s3)
ψ: $(ψ_s3)
"""

# ╔═╡ 5e2bfe78-d6ec-4bc1-bd24-460176ea2936
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

# ╔═╡ 12d48e84-bd6f-4efc-a265-e64234183650
# savefig(plt_vlm, "static_stability_vlm.png")

# ╔═╡ b710c3fa-a48d-4c0a-841e-bc3332cd5bf7
md"# Appendix"

# ╔═╡ cbdf5265-1c2b-4bbc-a458-18fba0c9d376
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

# ╔═╡ 402ead4c-b3e9-4153-baee-1048468e6080
# The End.

# ╔═╡ 415a9fb5-9f65-4af1-a6bb-f8204788ff5d
plot(foil_w_tip, aspect_ratio = 1)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AeroFuse = "477c59f4-51f5-487f-bf1e-8db39645b227"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
AeroFuse = "~0.4.12"
DataFrames = "~1.7.0"
Plots = "~1.40.9"
PlutoUI = "~0.7.23"
StaticArrays = "~1.9.18"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.1"
manifest_format = "2.0"
project_hash = "9d4785d32cb2ff78c9b7d234ecd098410fc4208c"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "0ba8f4c1f06707985ffb4804fdad1bf97b233897"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.41"

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
    Requires = "ae029012-a4dd-5104-9daa-d747884805df"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cd8b948862abee8f3d3e9b73a102a9ca924debb0"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.2.0"
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
git-tree-sha1 = "017fcb757f8e921fb44ee063a7aafe5f89b86dd1"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.18.0"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceCUDSSExt = "CUDSS"
    ArrayInterfaceChainRulesCoreExt = "ChainRulesCore"
    ArrayInterfaceChainRulesExt = "ChainRules"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceReverseDiffExt = "ReverseDiff"
    ArrayInterfaceSparseArraysExt = "SparseArrays"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    CUDSS = "45b445bb-4962-46a0-9369-b4df9d0f772e"
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
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
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "1713c74e00545bfe14605d2a2be1712de8fbcb58"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.1"
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
git-tree-sha1 = "403f2d8e209681fcbd9468a8514efff3ea08452e"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.29.0"

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
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "64e15186f0aa277e174aa81798f7eb8598e0157e"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.0"

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

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
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"

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
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

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
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "1cdab237b6e0d0960d5dcbd2c0ebfa15fa6573d9"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.4.4"

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
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

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
git-tree-sha1 = "d55dffd9ae73ff72f1c0482454dcf2ec6c6c4a63"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.5+0"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

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

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "a2df1b776752e3f344e5116c06d75a10436ab853"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.38"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

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

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "83cf05ab16a73219e5f6bd1bdfa9848fa24ac627"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.2.0"

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

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.InlineStrings]]
git-tree-sha1 = "6a9fde685a7ac1eb3495f8e812c5a7c3711c2d5e"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.3"

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
weakdeps = ["Unitful"]

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

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
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

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

[[deps.LabelledArrays]]
deps = ["ArrayInterface", "ChainRulesCore", "ForwardDiff", "LinearAlgebra", "MacroTools", "PreallocationTools", "RecursiveArrayTools", "StaticArrays"]
git-tree-sha1 = "e459fda6b68ea8684b3fcd513d2fd1e5130c4402"
uuid = "2ee39098-c373-598a-b85f-a56591580800"
version = "1.16.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "cd714447457c660382fe634710fb56eb255ee42e"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.6"

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
version = "2025.5.20"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "cc0a5deefdb12ab3a096f00a6d42133af4560d71"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "5e1897147d1ff8d98883cda2be2187dcf57d8f0c"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.15.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

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
version = "3.5.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.44.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3b31172c032a1def20c98dae3f2cdc9d10e3b561"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.1+0"

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

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PreallocationTools]]
deps = ["Adapt", "ArrayInterface", "ForwardDiff"]
git-tree-sha1 = "8765738bc5a6f1554cb61c5ddfae5bf279e8b110"
uuid = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
version = "0.4.25"

    [deps.PreallocationTools.extensions]
    PreallocationToolsReverseDiffExt = "ReverseDiff"
    PreallocationToolsSparseConnectivityTracerExt = "SparseConnectivityTracer"

    [deps.PreallocationTools.weakdeps]
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseConnectivityTracer = "9f842d2f-2579-4b1d-911e-f412cf18a3f5"

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

[[deps.Quaternions]]
deps = ["LinearAlgebra", "Random", "RealDot"]
git-tree-sha1 = "994cc27cdacca10e68feb291673ec3a76aa2fae9"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.7.6"

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
git-tree-sha1 = "fe9d37a17ab4d41a98951332ee8067f8dca8c4c2"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "3.29.0"

    [deps.RecursiveArrayTools.extensions]
    RecursiveArrayToolsFastBroadcastExt = "FastBroadcast"
    RecursiveArrayToolsForwardDiffExt = "ForwardDiff"
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
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Roots]]
deps = ["Accessors", "CommonSolve", "Printf"]
git-tree-sha1 = "e52cf0872526c7a0b3e1af9c58a69b90e19b022e"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.2.5"

    [deps.Roots.extensions]
    RootsChainRulesCoreExt = "ChainRulesCore"
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"

    [deps.Roots.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"

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
git-tree-sha1 = "04c968137612c4a5629fa531334bb81ad5680f00"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.13"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "712fb0231ee6f9120e005ccd56297abbc053e7e0"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.8"

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
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "64cca0c26b4f31ba18f13f6c12af7c85f478cfde"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.0"
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
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.Static]]
deps = ["CommonWorldInvalidations", "IfElse", "PrecompileTools"]
git-tree-sha1 = "87d51a3ee9a4b0d2fe054bdd3fc2436258db2603"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "1.1.1"

[[deps.StaticArrayInterface]]
deps = ["ArrayInterface", "Compat", "IfElse", "LinearAlgebra", "PrecompileTools", "Static"]
git-tree-sha1 = "96381d50f1ce85f2663584c8e886a6ca97e60554"
uuid = "0d7ed370-da01-4f52-bd93-41d350b8b718"
version = "1.8.0"
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
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

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

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "725421ae8e530ec29bcbdddbe91ff8053421d023"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.1"

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

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.SymbolicIndexingInterface]]
deps = ["Accessors", "ArrayInterface", "RuntimeGeneratedFunctions", "StaticArraysCore"]
git-tree-sha1 = "d6c04e26aa1c8f7d144e1a8c47f1c73d3013e289"
uuid = "2efcf032-c050-4f8e-a9bb-153293bab1f5"
version = "0.3.38"

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
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

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
git-tree-sha1 = "3832505b94c1868baea47764127e6d36b5c9f29e"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.27"

    [deps.TimerOutputs.extensions]
    FlameGraphsExt = "FlameGraphs"

    [deps.TimerOutputs.weakdeps]
    FlameGraphs = "08572546-2f56-4bcf-ba4e-bab62c3a3f89"

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
weakdeps = ["ConstructionBase", "InverseFunctions"]

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

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

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c1a7aa6219628fcd757dede0ca95e245c5cd9511"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.0.0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "ee6f41aac16f6c9a8cab34e2f7a200418b1cc1e3"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "7d1671acbe47ac88e981868a078bd6b4e27c5191"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.42+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56c6604ec8b2d82cc4cfe01aa03b00426aac7e1f"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.6.4+1"

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
git-tree-sha1 = "055a96774f383318750a1a5e10fd4151f04c29c5"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.46+0"

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
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.5.0+2"

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
# ╟─07559c60-063b-11f0-1a5c-37ed11f4209e
# ╠═8f7caf16-306c-41e3-a38a-fc8f681a3626
# ╠═17a7b231-19fb-455b-a93a-687251df87fb
# ╟─d6b41872-bd8e-45d1-baa2-fa0cc36b6177
# ╠═d9ef5002-70d7-40a8-81fa-7a07567eb613
# ╠═a76599c7-563d-4647-8fda-36869d07ff71
# ╟─87f54aa2-861a-44f7-b331-1198f522d1e4
# ╠═c8c3daf0-4e63-49b6-bc07-6ba37f817c5e
# ╟─678f44cb-e7fa-403d-bb45-7ece4195b88b
# ╠═6131d42a-38c5-4af5-b065-ba022852146c
# ╟─618ba8c3-8d46-4ef3-a038-5ecdb21eab03
# ╠═77be2a32-09fb-4f8e-8aca-09bad314e790
# ╟─38c60ab8-cf05-4051-a5a8-e35ffae7e50c
# ╠═335a090d-a50c-4f9c-a23a-a32b8ff6de34
# ╠═9d59c6d6-0e2e-40be-aedb-2ea21f6639a8
# ╠═4b84579b-3a9f-43e8-88bc-879cd950f657
# ╟─3e31ace1-1073-49b8-936b-1d5da789b895
# ╠═5baf5f31-eba8-42eb-9d62-96ce53c7cac8
# ╠═12d6baf4-c15b-46e8-8be3-0cc52fc9267b
# ╟─c7d034c8-d72f-461e-93e6-603a9c8f4c62
# ╟─0d0e82f3-d489-4abc-8887-3e557380d21e
# ╠═fb46cb05-f84c-4554-93cb-5491ebdc9eb0
# ╠═d90d5231-8680-4d24-ac39-be9e2d532c10
# ╠═25f56a3b-b8f8-4304-969d-7a4e49c338ea
# ╟─9be9d09b-a563-49a7-a6c8-72adcbf3a840
# ╠═b849f0aa-6391-4945-8ef3-70907a9ff1ec
# ╠═4b754590-3137-4400-a1a9-bd99135aee4d
# ╠═ef4431d6-5113-4e77-b549-62b0f6444a39
# ╠═532e2bf5-2ab9-4efb-84a3-3ab16b6ea81b
# ╠═2b098bef-934b-40fa-8da5-f08d032aa0e4
# ╠═50969d37-e674-4fa7-b28f-04833835e6a3
# ╠═7f9790ab-a1af-4de3-8375-44d11d784bf7
# ╟─04f96ffb-aa30-4bf5-918f-ba1d8528768f
# ╟─c559cb5f-a016-43a0-8596-89f006245b4f
# ╟─8026eb26-010f-487b-bd6d-e82939d09d54
# ╟─28739577-e9fd-48f2-8f55-a036b560931d
# ╠═115e9a7e-c194-4ac3-bc10-19d6d8973537
# ╠═704943ec-10e2-4c50-994b-4688a99ac6c7
# ╠═9072dc86-1f9f-48c5-8b11-31bf722223f2
# ╟─04750bc6-5e32-4182-8c58-805d902bc6b4
# ╠═9f330052-b13c-4a11-84e9-95ee1d404e9e
# ╠═ae2b717e-3102-4954-9f02-763e96794762
# ╟─25fba8e3-b444-424d-b839-836ab64d76ac
# ╠═add41f70-5744-494f-8324-726fa5d9bb27
# ╠═0c13b5ef-8a2e-4cb9-a246-69f66db9b92f
# ╠═32d4cbb9-0206-4708-85fa-f8001fda9e9b
# ╠═888b4f11-37ba-43df-984b-a887563142ff
# ╟─1be5a6b2-994a-44b0-8b13-5bbb1fffecd9
# ╠═69f762a3-9a0c-4480-a300-30c3a3914d36
# ╠═18a16755-03be-483b-8fb2-51a4fa78bf68
# ╟─1d16ebec-add7-4d22-854e-cf92d45fc2a3
# ╟─cd504799-eb4d-4518-9da6-a1ed95c9c9e6
# ╟─e531ec16-57df-4d07-b913-8bb5569a4bf9
# ╠═c159f556-4443-4077-acf2-2c11422cf86a
# ╠═e7bcb068-b1b4-45c3-a549-75d6af6dc871
# ╟─70f129d3-ffa8-4019-bd53-34185ad85356
# ╠═a3924235-a17d-463a-b1f4-4bd8f715fe5f
# ╟─5b12700f-a0ad-4f29-afc7-649ce6c1dfc4
# ╠═ae708986-6529-4069-904e-60858905f319
# ╟─0567a709-6420-44f6-908f-28c283bbaecf
# ╠═9e9f2802-c8ee-4df4-b643-ee3a271e2986
# ╠═1cb4658c-16ac-412b-8dfb-49778f7fe78a
# ╠═6468ecea-d228-4789-a8dd-74b053aa0047
# ╠═816c7fef-e74a-4628-a81a-878b53a1d9ab
# ╟─5fcf1f4b-ff6a-4458-b253-21c9a2f1f4a4
# ╟─26df6f87-cb16-49c7-b7da-b7d18f793d9d
# ╠═14daf923-a87c-4e32-853f-51aabff2794b
# ╠═693c8ac5-8d90-4427-ba1d-a787224245c4
# ╟─6949b7fb-9e9b-4cf4-a6e9-8e4f4c8a0445
# ╠═d4213288-b448-4783-a3bc-78c2fb25b4a6
# ╠═cba370b6-b8c8-44d8-970b-a178602d596f
# ╟─f87881bb-7eeb-4ded-b9e4-21a72410872e
# ╠═ff8adfc7-59ea-4f46-b102-ec09a039bd55
# ╟─cd9bc398-9f62-4a93-90bf-bf9896abbb2e
# ╟─c4bdfa4e-e4bb-4ba8-9a64-80c867a2ed99
# ╠═e0fe156d-7748-4585-bb80-c0c487af76cf
# ╟─d53fa5b1-eadb-4bc5-a00e-55308f55fac0
# ╟─cc80f43c-b0fb-4f2f-9f8f-7b3fed86405d
# ╟─aa2e3ac0-fb90-43a0-8177-c6cf1a2019b4
# ╠═49dec81f-909e-4a05-b8be-a72231b47a85
# ╠═a79b738f-90ca-4213-a89f-80e2dfce2fa5
# ╟─7b1e3dc7-423c-4c4a-9ffd-be54fe991c47
# ╠═92ab5a18-eeb0-44ff-a20a-b12b3093aa43
# ╠═23d5c748-d77c-4252-add0-deade4f4a416
# ╠═0a763717-9f1b-4c6d-98ed-95029d01f509
# ╠═40e02dbd-fcd4-4297-ab3b-bc5b3d71717a
# ╟─dff70e54-4ea9-4edf-a3ca-2f7c765b624f
# ╟─4deac195-47c6-4053-9812-cac86eb34913
# ╠═fe494a18-44d3-4342-beea-a6ac891066af
# ╠═e74c66b7-287d-46ed-9e5b-a241fe06055a
# ╟─62df7c3a-4667-41a6-98b3-aa330519a41a
# ╠═23db0b3d-f844-4889-8386-79126a19093b
# ╠═e07d5942-bb5e-41cc-9deb-369c25ef6c2e
# ╟─0c8b15b1-d848-47f3-ab7d-bd8f254970b0
# ╠═bf08b856-d9d8-4fdc-876e-9950dc549f6e
# ╠═133329d8-cd89-46ab-8691-81cbfeb72649
# ╟─f71f0b50-161e-4ca3-bbd7-73a8691ee2b6
# ╠═7a8932d4-1470-47f1-a598-192ccfa66d94
# ╟─929142bd-0ab7-4c89-b3f1-e0bc652caa09
# ╟─dc65ebaa-cd46-4763-bf96-7210f6bc620b
# ╟─deb15310-a7ef-4291-990e-c4bba8e5c176
# ╟─bb607eb8-b337-4320-8c4a-629a26796eca
# ╟─47dd8354-5778-460b-84a5-93fa8ca796a1
# ╠═80c18169-5f8d-4665-9320-270aa20e926a
# ╠═e9318a7c-125c-4db1-a220-eb0d6de00212
# ╠═5f7738d8-367c-40fc-87f0-f6732623392d
# ╟─aa1ac62e-244d-4fc3-8543-0db8104e740a
# ╠═d3dc7232-ab8b-408d-a8d4-d1cf443afe52
# ╠═777ee0ce-64fa-4dfe-91f1-ca7d8f61a7a4
# ╠═41a1dda8-275e-4090-bcd8-5670b4d005a7
# ╟─8f269b3f-90e8-4cd1-a05a-4fbc63de1cdb
# ╠═4e2cf07e-a5c6-464d-ba5e-c3ee0c7098e3
# ╟─26d51540-49e4-44b3-af4d-62478d6327e2
# ╠═41028657-878a-4f99-83dc-060a8b95a78a
# ╠═ca7d7dc1-8ec7-4480-99da-5aa0695c84dd
# ╠═be3485c9-2aec-41f3-8c05-5d6ceadd787d
# ╠═cc237b8a-f912-46b9-8ea1-b68a04bb322c
# ╠═ce4faad3-c7d1-4fa1-b907-305e1ffb0206
# ╠═eb8954a0-f8da-4825-b0a9-bc13f2b53ebe
# ╠═4f0aac7f-2b19-4a45-ad01-36626d594f42
# ╟─0f45f2a6-0aa7-4c58-9b1e-4c538584f4e9
# ╠═04b8750c-87ce-4063-a8d5-388f2e08aaa6
# ╟─43fcac01-3590-4560-aefd-5881f1fd2f76
# ╟─f2ae1eaa-0844-4c8c-9939-298661195d72
# ╠═24435be1-39d8-43d8-8ff6-cf8e4a3b954c
# ╠═78da147a-7b02-4751-b558-955217089dbd
# ╠═7ef0b6d0-b55d-4552-aeec-fada357b377d
# ╠═82768f65-3f44-4184-86dc-1715cfe5677d
# ╠═68887c8c-9346-4bab-9c76-588adecac9eb
# ╠═f033373f-1d24-4ddd-9bb8-93c6363bcbaf
# ╠═87ced096-5bba-4b5d-9ddf-247b43fd97f9
# ╟─a02429ea-3366-4d06-9c11-4044048569a6
# ╠═20c9112d-84db-42e1-aa33-5bf9f6ea016b
# ╠═3d38e9d2-7319-4b4b-ab7c-bcb3d475d17f
# ╟─65efafc2-3f58-40ac-9ecf-81bf0b133205
# ╠═4b235b39-43c0-44db-afe0-29306e59e50f
# ╟─de870ed8-944f-438e-8cf8-d951d96797d9
# ╠═e7a0bccb-d292-48b5-bcb7-3a4cb53f065f
# ╠═7fbb061f-a9ef-47bd-9989-37119e4e6b88
# ╠═88c47f03-fa83-497a-8738-a4a0f47cf966
# ╠═26513f85-c5d5-42aa-bdb2-7e8353cada30
# ╠═532a497e-0faf-450b-89ff-9e0482a94a94
# ╠═3e947f88-dfe4-4425-a0cf-cb609aa574c0
# ╟─936bad10-c8ca-4911-af6c-c8cb7926f2cf
# ╟─a68fe0b6-eb1c-4df6-9c19-e0057dfe2208
# ╠═45cd25ad-fa8c-44d3-a3d1-1a9043dbff03
# ╟─143d4eb1-3e19-4ca8-8bea-e0d35bf69761
# ╟─17c59c56-d2aa-44d9-8658-bd323b7d50b7
# ╟─a9cc0876-a907-4b39-bf8b-5c1c8f92258a
# ╟─5e2bfe78-d6ec-4bc1-bd24-460176ea2936
# ╠═12d48e84-bd6f-4efc-a265-e64234183650
# ╟─b710c3fa-a48d-4c0a-841e-bc3332cd5bf7
# ╟─cbdf5265-1c2b-4bbc-a458-18fba0c9d376
# ╠═402ead4c-b3e9-4153-baee-1048468e6080
# ╠═415a9fb5-9f65-4af1-a6bb-f8204788ff5d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

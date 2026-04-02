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

# ╔═╡ 33dacb1f-53e6-4b4d-81f5-d76999b4acb1
begin
	using Pkg; Pkg.add([
		"AeroFuse",
		"Plots",
		"DataFrames",
	])
	using AeroFuse
	using Plots
	using DataFrames
	using PlutoUI
	TableOfContents()
end

# ╔═╡ 24dde28c-f34a-11ef-197d-b16f7ef44c0a
md"
# AeroFuse: Aircraft Design Demo
"

# ╔═╡ 62902bc0-9490-4bc2-bf48-0a3c30c5ed59
gr(
	size = (900, 1000),  # INCREASE THE SIZE FOR THE PLOTS HERE.
	palette = :tab20    # Color scheme for the lines and markers in plots
)

# ╔═╡ 58b342e7-39ca-4641-88ab-ef0e2b5c7cba
begin
	ϕ_s1 			= @bind ϕ1 Slider(0:1e-2:90, default = 15)
	ψ_s1 			= @bind ψ1 Slider(0:1e-2:90, default = 30)
	ϕ_s2 			= @bind ϕ2 Slider(0:1e-2:90, default = 15)
	ψ_s2 			= @bind ψ2 Slider(0:1e-2:90, default = 30)
	ϕ_s3 			= @bind ϕ3 Slider(0:1e-2:90, default = 15)
	ψ_s3 			= @bind ψ3 Slider(0:1e-2:90, default = 30)
	ϕ_s4 			= @bind ϕ4 Slider(0:1e-2:90, default = 15)
	ψ_s4 			= @bind ψ4 Slider(0:1e-2:90, default = 30)
	ϕ_s5 			= @bind ϕ5 Slider(0:1e-2:90, default = 15)
	ψ_s5 			= @bind ψ5 Slider(0:1e-2:90, default = 30)
	ϕ_s6 			= @bind ϕ6 Slider(0:1e-2:90, default = 15)
	ψ_s6 			= @bind ψ6 Slider(0:1e-2:90, default = 30)
	ϕ_s7 			= @bind ϕ7 Slider(0:1e-2:90, default = 15)
	ψ_s7 			= @bind ψ7 Slider(0:1e-2:90, default = 30)
	ϕ_s8 			= @bind ϕ8 Slider(0:1e-2:90, default = 15)
	ψ_s8 			= @bind ψ8 Slider(0:1e-2:90, default = 30)
	wing_aero_flag 	= @bind wing_aero CheckBox(default = true)
	htail_aero_flag = @bind htail_aero CheckBox(default = true)
	vtail_aero_flag = @bind vtail_aero CheckBox(default = true)
	overall_CG_flag = @bind overall_CG CheckBox(default = true)
	comp_CG_flag 	= @bind comp_CG CheckBox(default = true)
end;

# ╔═╡ f820f529-6626-4e2c-8747-e4009c18ab3a
md"
## Aircraft Geometry

Here, we'll refer to a passenger jet (based on a Boeing 777), but you can modify it to your design specifications.

![](https://raw.githubusercontent.com/alfiyandyhr/Tutorial_for_MECH3620_Aircraft_Design_HKUST/main/figures/aircraft.png)

"

# ╔═╡ 0937de00-8855-4b16-bd75-39db98a70d77
md"
### Fuselage
"

# ╔═╡ ff7006bf-8e60-4350-b05c-1be8ff5c8068
# Fuselage definition
fuse = HyperEllipseFuselage(
    radius = 3.5/2,          # Radius, m
    length = 28,          # Length, m
    x_a    = 0.2,          # Start of cabin, ratio of length
    x_b    = 0.7,           # End of cabin, ratio of length
    c_nose = 1.8,           # Curvature of nose
    c_rear = 1.8,           # Curvature of rear
    d_nose = -0.5,          # "Droop" or "rise" of nose, m
    d_rear = -0.5,           # "Droop" or "rise" of rear, m
    position = [0.,0.,0.041]   # Set nose at origin, m
)

# ╔═╡ 220105fa-5091-4e72-bad1-1761077d726c
camera_angles1 = md"""
ϕ: $(ϕ_s1)
ψ: $(ψ_s1)
"""

# ╔═╡ adbcd62e-3892-49d2-ab07-e40aa99e3797
begin
	plot(
		xaxis = "x", yaxis = "y", zaxis = "z",
		xlim = ( 0.0, 1.0) .* fuse.length,
		ylim = (-0.5, 0.5) .* fuse.length,
		zlim = (-0.5, 0.5) .* fuse.length,
		camera = (ϕ1, ψ1),
	)
	plot!(fuse, label = "Fuselage", alpha = 0.6)
end

# ╔═╡ d5cc0a31-3498-4351-bdbe-f9bb1ca3a223
begin
	# Compute geometric properties
	ts = 0:0.1:1                # Distribution of sections for nose, cabin and rear
	S_f = wetted_area(fuse, ts) # Surface area, m²
	V_f = volume(fuse, ts)      # Volume, m³
end

# ╔═╡ 0204dbf4-6214-411b-ab08-8832fc029ce4
md"You can access the position by the `.affine.translation` attribute."

# ╔═╡ 0cc52de0-a28e-4b52-8be2-0dce6a101e66
fuse.affine.translation # Coordinates of nose

# ╔═╡ 2c1b7012-4274-4461-a851-06b9d4d4f7bf
# Get coordinates of rear end
fuse_end = fuse.affine.translation + [ fuse.length, 0., 0. ]

# ╔═╡ a4186bb5-f640-420c-bcac-1988ef3c82ca
fuse_end.x

# ╔═╡ db1d4561-3525-4f3a-89fb-41ce98500610
fuse

# ╔═╡ 01847722-9de8-4671-bbb8-e1d56c9815dd
md"
!!! warning
	You may have to change the fuselage dimensions when estimating weight, balance and stability according to the design requirements!
"

# ╔═╡ ad3737eb-55dd-47fe-a73d-ca818ce78f3c
md"
### Wing
"

# ╔═╡ 98cb649e-6cdd-452c-b732-6ac4029c4e21
begin
	# AIRFOIL PROFILES
	foil_w_r = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=b737a-il")) # Root
	foil_w_m = #read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=b737b-il")) # Midspan
	foil_w_t = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=b737c-il")) # Tip
end

# ╔═╡ b86ad3c5-1699-4a74-b1b4-86be7ceb8c0a
# Wing
wing = Wing(
    foils       = [foil_w_r, foil_w_t], # Airfoils (root to tip)
    chords      = [3.81, 1.19],          # Chord lengths
    spans       = [23.9] / 2,               # Span lengths
    dihedrals   = fill(6, 2),                     # Dihedral angles (deg)
    sweeps      = fill(35.6, 2),                  # Sweep angles (deg)
    w_sweep     = 0.,                             # Leading-edge sweep
    symmetry    = true,                           # Symmetry

	# Orientation
    angle       = 3,       						  # Incidence angle (deg)
    axis        = [0, 1, 0], 					  # Axis of rotation, x-axis
    position    = [0.35*fuse.length, 0., -2.5]
)

# ╔═╡ e2955349-67f1-4a3b-8f56-628f248d00fb
camera_angles2 = md"""
ϕ: $(ϕ_s2)
ψ: $(ψ_s2)
"""

# ╔═╡ 7232c5cc-5e20-4f4f-b8ab-8189302f08ec
begin
	plot(
		xaxis = "x", yaxis = "y", zaxis = "z",
		xlim = ( 0.0, 1.0) .* fuse.length,
		ylim = (-0.5, 0.5) .* fuse.length,
		zlim = (-0.5, 0.5) .* fuse.length,
		camera = (ϕ2, ψ2),
	)
	plot!(fuse, label = "Fuselage", alpha = 0.6)
	plot!(wing, 0.4, label = "Wing MAC 40%", mac=true)
end

# ╔═╡ 7be8b5f5-5543-43ae-ad8d-71c7e4bb69ac
b_w = span(wing) # Span length, m

# ╔═╡ cb3bb8ea-ba65-4cb3-897c-da9af590483f
S_w = projected_area(wing) # Area, m

# ╔═╡ 20c68a3d-e22d-4a74-a1e1-efe28a83d615
c_w = mean_aerodynamic_chord(wing) # Mean aerodynamic chord, m

# ╔═╡ 90eb5f42-b847-4e7c-b2d4-a922b697fcde
mac_w = mean_aerodynamic_center(wing, 0.25) # Mean aerodynamic center (25%), m

# ╔═╡ 5d3dfb79-e833-4e96-905b-8e09a4fd6cf7
mac40_wing = mean_aerodynamic_center(wing, 0.4) # Mean aerodynamic center (40%), m

# ╔═╡ 89baa943-6da2-41f8-8e64-520d6c41116b
md"
!!! warning
	You may have to change the wing size and locations when estimating weight, balance and stability!
"

# ╔═╡ 35895f47-484c-45d1-99ec-466595a72d3c
md"
### Engines
"

# ╔═╡ d93e8bf6-2ab2-4d2d-a2b0-58692980d309
md"
We can place the engines based on the wing and fuselage geometry.
"

# ╔═╡ 5ea69c20-7163-4ec0-934c-afc6729d75aa
wing_coo = coordinates(wing) # Get leading and trailing edge coordinates. First row is leading edge, second row is trailing edge.

# ╔═╡ 17affea3-545f-45dc-82c0-c58a63c2a17c
wing_coo[1,:] # Get leading edge coordinates

# ╔═╡ 0c5c5271-56c5-4ae4-b8b2-33d19b021d6f
# wing_coo has a length of 5
wing_coo[1,3]

# ╔═╡ 2b2388c4-8e89-47b9-b361-e1568945be50
begin
	# Example:
	eng_L = wing_coo[1,2] - [1, 0., 0.] # Left engine, at the kink leading edge
	eng_R = wing_coo[1,4] - [1, 0., 0.] # Right engine, at the kink leading edge
end

# ╔═╡ 56dbc2bc-4441-4e1f-9b88-d1457540ab68
md"
!!! warning
	You may have to change the engine locations when estimating weight, balance and stability!
"

# ╔═╡ 6375742c-cb16-48f2-a13c-809ec06b1a00
md"
### Stabilizers
"

# ╔═╡ 0b93bf59-9363-4223-b2aa-7f99dde5982d
md"
#### Horizontal Tail
"

# ╔═╡ 1fca478f-b79b-4acc-aea7-852ff784e756
con_foil = control_surface(naca4(0,0,1,2), hinge = 0.75, angle = -10.)

# ╔═╡ d4970954-a888-4f28-8b61-bdc0a2a06a93
htail = WingSection(
    area        = 101,  			# Area (m²). HOW DO YOU DETERMINE THIS?
    aspect      = 4.2,  			# Aspect ratio
    taper       = 0.4,  			# Taper ratio
    dihedral    = 7.,   			# Dihedral angle (deg)
    sweep       = 35.,  			# Sweep angle (deg)
    w_sweep     = 0.,   			# Leading-edge sweep
    root_foil   = con_foil, 		# Root airfoil
	tip_foil    = con_foil, 		# Tip airfoil
    symmetry    = true,

    # Orientation
    angle       = 5,  			# Incidence angle (deg). HOW DO YOU DETERMINE THIS?
    axis        = [0., 1., 0.], # Axis of rotation, y-axis
    position    = fuse_end - [ 10., 0., 0.], # HOW DO YOU DETERMINE THIS?
)

# ╔═╡ a106972a-b410-4d3a-b915-67f69e26b996
camera_angles3 = md"""
ϕ: $(ϕ_s3)
ψ: $(ψ_s3)
"""

# ╔═╡ 94ea47f1-7019-41ee-bb2c-88489a15144e
begin
	plot(
		xaxis = "x", yaxis = "y", zaxis = "z",
		xlim = (-0.05, 1.05) .* fuse.length,
		ylim = (-0.50, 0.50) .* fuse.length,
		zlim = (-0.50, 0.50) .* fuse.length,
		camera = (ϕ3, ψ3),
	)
	plot!(fuse, label = "Fuselage", alpha = 0.6)
	plot!(wing, 0.4, label = "Wing MAC 40%")
	plot!(htail, 0.4, label = "Horizontal Tail MAC 40%")
end

# ╔═╡ 55096245-926c-4949-8987-cf667044b4d7
b_h = span(htail)

# ╔═╡ 4b7efc17-6eee-4763-bc26-3cb344fd9e36
S_h = projected_area(htail)

# ╔═╡ 8977047d-cd8c-4273-93d9-d887307df4ee
c_h = mean_aerodynamic_chord(htail)

# ╔═╡ 0622a9bc-888e-42f4-a26c-fafbf19c09f1
mac_h = mean_aerodynamic_center(htail)

# ╔═╡ 6e79aaa2-dcbd-466c-91ad-6c8dafb424e8
V_h = S_h / S_w * (mac_h.x - mac_w.x) / c_w

# ╔═╡ d20c6f95-7273-416f-ae8a-a324bb6a7279
htail

# ╔═╡ f8b17518-1220-4a8f-a3b3-45650f68c8f9
md"
#### Vertical Tail
"

# ╔═╡ de2725a2-4053-4fa2-9a0d-1419b8692edd
vtail = WingSection(
    area        = 56.1, 			# Area (m²). # HOW DO YOU DETERMINE THIS?
    aspect      = 1.5,  			# Aspect ratio
    taper       = 0.4,  			# Taper ratio
    sweep       = 44.4, 			# Sweep angle (deg)
    w_sweep     = 0.,   			# Leading-edge sweep
    root_foil   = naca4(0,0,0,9), 	# Root airfoil
	tip_foil    = naca4(0,0,0,9), 	# Tip airfoil

    # Orientation
    angle       = 90.,       # To make it vertical
    axis        = [1, 0, 0], # Axis of rotation, x-axis
    position    = htail.affine.translation - [2.,0.,-1.] # HOW DO YOU DETERMINE THIS?
) # Not a symmetric surface

# ╔═╡ cafe9f2b-82ae-40de-940d-aaa8b38813e5
camera_angles4 = md"""
ϕ: $(ϕ_s4)
ψ: $(ψ_s4)
"""

# ╔═╡ 2f53da90-4476-449c-8586-9a614d740cfd
begin
	plot(
		xaxis = "x", yaxis = "y", zaxis = "z",
		xlim = (-0.05, 1.05) .* fuse.length,
		ylim = (-0.50, 0.50) .* fuse.length,
		zlim = (-0.50, 0.50) .* fuse.length,
		camera = (ϕ4, ψ4),
	)
	plot!(fuse, label = "Fuselage", alpha = 0.6)
	plot!(wing, 0.4, label = "Wing MAC 40%", mac=true)
	plot!(htail, 0.4, label = "Horizontal Tail MAC 40%")
	plot!(vtail, 0.4, label = "Vertical Tail MAC 40%")
end

# ╔═╡ 51cb45ac-f6a9-436f-a773-11b835b69a05
b_v = span(vtail)

# ╔═╡ f6fb90eb-d168-4731-90ed-5d8db19bf2d8
S_v = projected_area(vtail)

# ╔═╡ a99981ba-c29a-4757-ab7f-2067221dd927
c_v = mean_aerodynamic_chord(vtail)

# ╔═╡ 936103a9-29e5-4c51-b7de-6e45c8c1e314
mac_v = mean_aerodynamic_center(vtail)

# ╔═╡ af1d4536-eb1b-4de6-8297-9f49117be5bc
V_v = S_v / S_w * (mac_v.x - mac_w.x) / b_w

# ╔═╡ 12e2dfe3-6975-4678-9db3-269109a83c45
md"
!!! warning
	You may have to change the tail size and locations when estimating weight, balance and stability!
"

# ╔═╡ d132663f-3a0d-4b60-a322-0afc2232e90d
md"
## Aerodynamic Analysis

!!! info
	Refer to the **Aerodynamic Analysis** tutorial in the AeroFuse documentation to understand this process: [https://hkust-octad-lab.github.io/AeroFuse.jl/stable/tutorials-aircraft/](https://hkust-octad-lab.github.io/AeroFuse.jl/stable/tutorials-aircraft/)

"

# ╔═╡ 1b38aedb-2737-47c3-91d6-1f54afaaf289
md"
### Meshing
"

# ╔═╡ 1d08d0d3-fb07-4c7e-af60-6a6ac8bca4a7
wing_mesh = WingMesh(
	wing, 
	[8,16], # Number of spanwise panels
	10,     # Number of chordwise panels
    span_spacing = Uniform() # Spacing: Uniform() or Cosine()
)

# ╔═╡ 71be68b7-e3f6-4c63-ada1-b3899e636ec8
htail_mesh = WingMesh(htail, [10], 8)

# ╔═╡ 2b0c3def-51ec-4999-aa68-ac675b87a021
vtail_mesh = WingMesh(vtail, [8], 6)

# ╔═╡ 80d88a0c-df5a-47c3-a129-487a6829723a
camera_angles5 = md"""
ϕ: $(ϕ_s5)
ψ: $(ψ_s5)
"""

# ╔═╡ 31107917-7658-4e90-955e-dc6eb2399394
begin
	plot(
		xaxis = "x", yaxis = "y", zaxis = "z",
		xlim = (-0.05, 1.05) .* fuse.length,
		ylim = (-0.50, 0.50) .* fuse.length,
		zlim = (-0.50, 0.50) .* fuse.length,
		camera = (ϕ5, ψ5),
	)
	plot!(fuse, label = "Fuselage", alpha = 0.6)
	plot!(wing_mesh, label = "Wing", mac = false)
	plot!(htail_mesh, label = "Horizontal Tail", mac = false)
	plot!(vtail_mesh, label = "Vertical Tail", mac = false)
end

# ╔═╡ ee963e66-d054-44b2-b790-ea5e9bd488bc
md"
### Vortex Lattice Method
"

# ╔═╡ ffca0ec4-37d0-43f4-ae27-955cdf3a607e
md"The vortex lattice method (VLM) provides decent estimations of the aerodynamic lift and stability in the preliminary design stages."

# ╔═╡ ae53070a-6b80-4179-88aa-1eca48ddd3fb
# Define aircraft
ac = ComponentVector(# ASSEMBLE MESHES INTO AIRCRAFT
	wing  = make_horseshoes(wing_mesh),   # Wing
	htail = make_horseshoes(htail_mesh),  # Horizontal Tail
	vtail = make_horseshoes(vtail_mesh)   # Vertical Tail
)

# ╔═╡ 45e8aa28-ada1-44c9-87c9-9879ab59caeb
# Define freestream conditions
fs = Freestream(
	alpha = 0.0, # Angle of attack, deg. HOW DO YOU CHOOSE THIS?
	beta = 0.0,  # Angle of sideslip, deg.
) 

# ╔═╡ 349bfe25-f352-4c47-b4b7-250fa616dbb6
M = 0.84 # Operating Mach number.

# ╔═╡ b0a99439-467a-4533-8b7e-6ad6e8fcbfb0
# Define reference values
refs = References(
	density = 0.35, # Density at cruise altitude.
					# HOW DO YOU CALCULATE THIS BASED ON THE ALTITUDE?
	
	speed = M * 330., # HOW DO YOU DETERMINE THE SPEED?

	# Set reference quantities to wing dimensions.
	area = projected_area(wing), 			# Area, m²
	chord = mean_aerodynamic_chord(wing),   # Chord, m
	span = span(wing), 						# Span, m
	
	location = fuse.affine.translation, # From the nose as reference (origin)
)

# ╔═╡ c9209801-fe0a-4fc7-a47d-b5ee8c954906
# Run vortex lattice analysis
sys = solve_case(ac, fs, refs,
		name = "Boeing",
		compressible = true,
	)

# ╔═╡ 74fa6103-562e-4b07-b86b-ad6dc130d861
md"
### Aerodynamic Coefficients

Two methods are provided for obtaining the force and moment coefficients from the VLM analysis.
"

# ╔═╡ 5f82cc4a-3314-4ee4-8009-c70c20a8ec53
md"
#### Nearfield
"

# ╔═╡ 9ebce535-f558-4591-befc-cbe735cc6d5d
nfs = nearfield(sys) # Nearfield coefficients (force and moment coefficients)

# ╔═╡ 8a395e26-7b06-488f-ad18-6f2a4bf9c45c
nfs.CX # Induced drag coefficient (nearfield)

# ╔═╡ 0142d4a2-7a20-4a97-add0-02f3f9bb916a
nfs.CZ # Lift coefficient (nearfield)

# ╔═╡ 5439a1af-1010-42c9-b389-9beb7215d475
nfs.Cm # Pitching moment coefficient

# ╔═╡ f62b211c-2cde-4194-b165-a83f6078fca3
md"
#### Farfield
"

# ╔═╡ 9bf3fc80-dc5e-492d-ba84-77d132986b99
ffs = farfield(sys) # Farfield coefficients (no moment coefficients)

# ╔═╡ b817c2d4-339a-4d57-ab4d-36ec760eb235
ffs.CDi # Induced drag coefficient (farfield)

# ╔═╡ d5ddc08a-b890-48fc-bb80-9b3bbaffc2e5
ffs.CL # Lift coefficient (farfield)

# ╔═╡ 68e27cca-46ca-45dd-8200-f0e060a6016f
md"
!!! tip
	Use the farfield coefficients for the induced drag, as they are usually much more accurate than the nearfield coefficients.
"

# ╔═╡ 848562be-e6f8-4497-b29f-0f31cb8c9479
ffs.CL / ffs.CDi # Lift-to-induced drag ratio

# ╔═╡ 24c15474-d54d-4389-a2b0-82e6d4669688
print_coefficients(nfs, ffs)

# ╔═╡ 048c924a-8b02-40e6-867f-08fe99ef12ce
camera_angles6 = md"""
ϕ: $(ϕ_s6)
ψ: $(ψ_s6)
"""

# ╔═╡ 06a4b2dc-12b9-4d29-9568-a2001bb75612
which_stream_to_plot = md"
Wing: $(wing_aero_flag)
Htail: $(htail_aero_flag)
Vtail: $(vtail_aero_flag)
"

# ╔═╡ 342d244b-6e70-4570-a1db-2a15c9949624
begin
	p_stream = plot(
		xaxis = "x", yaxis = "y", zaxis = "z",
		zlim = (-0.50, 0.50) .* fuse.length,
		camera = (ϕ6, ψ6),
	)
	
	plot!(fuse, label = "Fuselage", alpha = 0.6)
	plot!(wing_mesh, label = "Wing", mac = false)
	plot!(htail_mesh, label = "Horizontal Tail", mac = false)
	plot!(vtail_mesh, label = "Vertical Tail", mac = false)
	
	if wing_aero
		plot!(sys, wing_mesh, 
			span = 4, # Number of points over each spanwise panel
			dist = 40., # Distance of streamlines
			num = 50, # Number of points along streamline
		)
	end
	
	if htail_aero
		plot!(sys, htail_mesh, 
			span = 3, # Number of points over each spanwise panel
			dist = 20., # Distance of streamlines
			num = 20, # Number of points along streamline
		)
	end
	
	if vtail_aero
		plot!(sys, vtail_mesh, 
			span = 3, # Number of points over each spanwise panel
			dist = 20., # Distance of streamlines
			num = 20, # Number of points along streamline
		)
	end

	p_stream # call the plot to display
end

# ╔═╡ 13d2be83-eca6-4149-bc88-6df6e8307d63
md"
## Weight and Balance Estimation

The component weights of the aircraft are some of the largest contributors to the longitudinal stability characteristics.

![](https://raw.githubusercontent.com/HKUST-OCTAD-LAB/MECH3620Materials/main/pics/777200LRMoments.svg)

Recall the definition of the center of gravity (CG):
```math
\mathbf{r}_\text{cg} = \frac{\sum_i \mathbf{M}_i}{\sum_i W_i} = \frac{\sum_i W_i \ (\mathbf{r}_{\text{cg}})_i}{\sum_i W_i}, \quad \mathbf{r} = \begin{bmatrix}
  x \\ y \\ z
\end{bmatrix}
```

where $W_i$ represents the weight for each component and $(\mathbf r_{\text{cg}})_i$ is the position vector between the origin and the CG of the $i$th component. The product in the form $W_i(\mathbf r_{\text{cg}})_i$ is also referred to as the moment $\mathbf M_i$ induced by the $i$th component.
"

# ╔═╡ 82b65de8-3628-468e-bff4-66961b4abc27
md"
### Statistical Weight Estimation
"

# ╔═╡ 8972158d-fac4-4537-9897-8e77851d38ba
# WRITE STATISTICAL WEIGHT ESTIMATION FORMULAS AND COMPUTATIONS

# ╔═╡ 43655116-1615-43ee-82a9-09b276965d5d


# ╔═╡ 6a1f64dd-ddfb-4c80-b978-a1386092c7e8
md"
#### Component Weight Build-up
Based on the statistical weight estimation method and weight estimation of other components, you can determine most of the weights and assign them to variables.
"

# ╔═╡ 9f85739e-4717-441b-9891-50477de1a03a
lb_ft2_to_kg_m2 = 4.88243 # Convert lb/ft² to kg/m²

# ╔═╡ 736f49a7-4e5a-44b8-949d-ce94a27e6e17
begin
	# Weights
	#====================================================#
	
	# THIS HAS BEEN DONE BASED ON PRELIMINARY ESTIMATION. 
	# YOU MUST REVISE IT BASED ON STATISTICAL WEIGHTS.

	TOGW 	= 347458 # Takeoff gross weight, kg
	W_other = 0.17 * TOGW # All other components

	# Engine
	W_engine 	 = 8762 # GE90-110B1 engine weight (single), kg
	W_engine_fac = 1.3 * W_engine # Scaling factor for engine weight

	# Lifting surfaces (HINT: REPLACE WITH STATISTICAL WEIGHTS)
	W_wing 	= S_w * 10 * lb_ft2_to_kg_m2
	W_htail = S_h * 5.5 * lb_ft2_to_kg_m2
	W_vtail = S_v * 5.5 * lb_ft2_to_kg_m2
	W_fuse 	= S_f * 5.0 * lb_ft2_to_kg_m2

	# Landing gear
	W_nLG = 0.043 * 0.15 * TOGW # Nose
	W_mLG = 0.043 * 0.85 * TOGW # Main landing gear

	# THERE ARE MORE COMPONENT WEIGHTS YOU NEED TO ACCOUNT FOR!!!
	# HINT: PASSENGERS??? LUGGAGE??? FUEL???
end;

# ╔═╡ 3fe30e88-0f97-4210-aeef-0d4a37787eb1
md"
### Component Locations
Now determine and modify the locations of each component sensibly.
"

# ╔═╡ 02aa2148-a1db-40c0-803a-fe35bd63275a
begin
	# Locations
	#====================================================#

	# THIS HAS BEEN DONE BASED ON PRELIMINARY ESTIMATION. 
	# YOU MUST REVISE IT FOR THE BALANCE AND STABILITY OF YOUR AIRCRAFT.
	
	r_w = mean_aerodynamic_center(wing, 0.4)   # Wing, 40% MAC
	r_h = mean_aerodynamic_center(htail, 0.4)  # HTail, 40% MAC
	r_v = mean_aerodynamic_center(vtail, 0.4)  # VTail, 40% MAC

	r_eng_L = wing_coo[1,2] - [1., 0., 0.]     # Engine, near wing LE
	r_eng_R = wing_coo[1,4] - [1., 0., 0.] 	   # Engine, near wing LE

	# Nose location 
	r_nose 	= fuse.affine.translation

	# Fuselage centroid (50% L_f)
	r_fuse 	= r_nose + [fuse.length / 2, 0., 0.]

	# All-other component centroid (40% L_f)
	r_other = r_nose + [0.4 * fuse.length, 0., 0.]

	# Nose landing gear centroid (15% L_f)
	r_nLG  	= r_nose + [0.15 * fuse.length, 0., -fuse.radius]

	# Main landing gear centroid (50% L_f)
	r_mLG 	= r_nose + [0.5 * fuse.length, 0., -fuse.radius]

	# THERE ARE MORE COMPONENT LOCATIONS YOU NEED TO ACCOUNT FOR!!!
end;

# ╔═╡ 2387da64-f729-4d7d-95da-f85247ab4384
md"
### Center of Gravity Calculation
Finally, assemble this information into a dictionary.
"

# ╔═╡ 4513744a-6153-42ee-810c-4894e94dd6e4
# Component weight and location dictionary
W_pos = Dict(
	# "Component"   => (Weight, Location)
	"Engine L CG" 	=> (W_engine_fac, r_eng_L),
	"Engine R CG" 	=> (W_engine_fac, r_eng_R),
	"Wing CG"   	=> (W_wing, r_w), 
	"HTail CG"  	=> (W_htail, r_h), 
	"VTail CG"  	=> (W_vtail, r_v),
	"Fuse CG"   	=> (W_fuse, r_fuse),
	"All-Else CG" 	=> (W_other, r_other),
	"Nose LG CG" 	=> (W_nLG, r_nLG), 
	"Main LG CG" 	=> (W_mLG, r_mLG),
);

# ╔═╡ 4fed4dad-c225-43f8-8dce-1c382b7782df
keys(W_pos) # Get keys

# ╔═╡ 87b4eac6-f449-4835-969b-7b24487ebf3f
values(W_pos) # Get values

# ╔═╡ 011d0b2d-994f-4bd7-8920-bd470f69ecfb
 # Total weight evaluation, kg
W_tot = sum(W_i for (W_i, r_i) in values(W_pos))

# ╔═╡ f5390ac1-425e-4d5d-9516-ac93e9366f3e
begin
	# Gravitational acceleration, m/s²
	g = 9.81
	
	# Total moment evaluation, N-m
	M_tot = sum(W_i * g * r_i for (W_i, r_i) in values(W_pos))
end

# ╔═╡ f0d75b59-88e5-4e44-adce-e916fa91e905
md"

!!! tip
	Check whether the sum of the weights matches the estimated total weight! It may not be exactly close because:

	1. You have used statistical estimations for many of the weights.
	2. You may not have accounted for all the relatively heavy components.

"

# ╔═╡ 0abc0343-633e-4b4f-aec3-7d81f254ceef
# CG estimation, m
r_cg = M_tot / (W_tot * g)

# ╔═╡ a4cfd3c6-5b92-467d-9ac6-af611d8cc22d
x_cg = r_cg.x  # x-component

# ╔═╡ 0c15d3d8-5e16-4a63-aafa-cb72280b0d89
camera_angles7 = md"""
ϕ: $(ϕ_s7)
ψ: $(ψ_s7)
"""

# ╔═╡ d58dc1da-bde1-4500-9a6b-b0cf645ee0b7
which_CG_to_plot = md"
Overall: $(overall_CG_flag)
Component: $(comp_CG_flag)
"

# ╔═╡ 753d041a-6b9c-4777-8015-4329278163f4
begin
	p_CG = plot(
		xaxis = "x", yaxis = "y", zaxis = "z",
		xlim = (-0.05, 1.05) .* fuse.length,
		ylim = (-0.50, 0.50) .* fuse.length,
		zlim = (-0.50, 0.50) .* fuse.length,
		camera = (ϕ7, ψ7),
	)
	plot!(fuse, label = "Fuselage", alpha = 0.6)
	plot!(wing_mesh, label = "Wing", mac = false)
	plot!(htail_mesh, label = "Horizontal Tail", mac = false)
	plot!(vtail_mesh, label = "Vertical Tail", mac = false)

	# Overall CG location
	if overall_CG
		scatter!(Tuple(r_cg), label = "Center of Gravity (CG)")
	end
	
	# Component CG location
	if comp_CG
		# Iterate over the dictionary
		[ scatter!(Tuple(pos), label = key) for (key, (W, pos)) in W_pos ]
	end
	
	p_CG # call the plot to display
end

# ╔═╡ 68da981f-cf30-4333-97a8-7d0bb969c7df
md"
## Stability Analysis

!!! info
	Refer to the **Aerodynamic Stability Analysis** tutorial in the AeroFuse documentation to understand this process: [https://hkust-octad-lab.github.io/AeroFuse.jl/stable/tutorials-stability/](https://hkust-octad-lab.github.io/AeroFuse.jl/stable/tutorials-stability/)

"

# ╔═╡ 8537b9e6-54fc-44a6-8526-bd7e7a14f107
md"
### Static Margin Estimation

In addition to the weights, the aerodynamic forces depicted are also major contributors to the stability of a conventional aircraft configuration.

![](https://raw.githubusercontent.com/HKUST-OCTAD-LAB/MECH3620Materials/main/pics/777200LR.svg)

**CAD Source:** [https://grabcad.com/library/boeing-777-200](https://grabcad.com/library/boeing-777-200)

This interrelationship between aerodynamics and weights on stability is expressed via the static margin.

```math
\text{Static Margin} = \frac{x_{np} - x_{cg}}{\bar c} 
```

We need to determine both of these locations: the center of gravity $x_{cg}$ and the neutral point $x_{np}$.
"

# ╔═╡ c7c8e3b0-c580-4fd4-91be-d6152589f3d3
md"

#### Neutral Point

The neutral point is:
```math
\frac{x_{np}}{\bar c} = -\left(\frac{\partial C_m}{\partial C_L} + \frac{\partial C_{m_f}}{\partial C_L}\right)
```
where $\partial C_m / \partial C_L$ is the moment-lift derivative excluding the fuselage contribution, and $\partial C_{m_f} / \partial C_L$ is the moment-lift derivative contributed by the fuselage.

"

# ╔═╡ 9f7ca823-0df2-4662-af6a-8414d762b13d
md"
First, we need to compute the aerodynamic stability derivatives:
```math
	\frac{\partial C_m}{\partial C_L} \approx \frac{C_{m_\alpha}}{C_{L_\alpha}}
```
"

# ╔═╡ dd849516-182d-43d6-8598-6f8457625251
# Evaluate the aerodynamic stability derivatives
dvs = freestream_derivatives(
	sys, 					 # Input the aerodynamics (VortexLatticeSystem)
	# print_components = true, # Print derivatives for all components
	print = true, 		 # Print derivatives for only the aircraft
	farfield = true, 		 # Farfield derivatives (usually unnecessary)
)

# ╔═╡ 9189d1ae-461f-4743-af90-bc73ad64f3f0
md""" ##### Fuselage Contribution
The moment-lift derivative of the fuselage is estimated via slender-body theory, which primarily depends on the volume of the fuselage. 

```math
\frac{\partial C_{m_f}}{\partial C_L} \approx \frac{2\mathcal V_f}{S_w \bar{c}C_{L_{\alpha_w}}} 
```

!!! tip 
	For estimating the volume without using [AeroFuse](https://github.com/GodotMisogi/AeroFuse.jl), you can initially approximate the fuselage as a square prism of length $L_f$ with maximum width $w_f$ (hence, $\mathcal V_f \approx w_f^2 L_f$) and introduce a form factor $K_f$ as a correction factor for the volume of the actual shape.
	```math
	\frac{\partial C_{m_f}}{\partial C_L} \approx \frac{K_f w_f^2 L_f}{S_w \bar{c}C_{L_{\alpha_w}}}
	```

	Your notes provide the empirical estimation of $K_f$.
"""

# ╔═╡ 4adf977e-0496-42da-aed8-6a1b9c089308
# FUSELAGE CM-CL DERIVATIVE
function fuse_Cm_CL(
		V_f, 	# Fuselage volume
		S_w, 	# Wing area 
		c_bar, 	# Mean aerodynamic chord
		CL_a_w 	# Lift curve slope
	)

	# Compute fuselage moment-lift derivative
	dCMf_dCL = 2 * V_f / (S_w * c_bar * CL_a_w)
	
	return dCMf_dCL
end

# ╔═╡ fcbe47f7-e0c8-4e19-b198-844d99fcbb0a
begin
	## Calculate longitudinal stability quantities
	#==============================================#
	
	ac_dvs = dvs.aircraft # Access the derivatives of the aircraft
	
	# Fuselage correction (COMPUTED USING FUSELAGE VOLUME AT THE BEGINNING)
	Cm_fuse_CL = fuse_Cm_CL(V_f, S_w, c_w, dvs.wing.CZ_al) # Fuselage Cm/CL
	
	x_np = -refs.chord * (ac_dvs.Cm_al / ac_dvs.CZ_al + Cm_fuse_CL) # Neutral point
	x_cp = -refs.chord * ac_dvs.Cm / ac_dvs.CZ # Center of pressure
	
	# Stability position vectors
	r_np = refs.location + [x_np, 0, 0]
	r_cp = refs.location + [x_cp, 0, 0]
	
	SM = (r_np - r_cg).x / refs.chord * 100 # Static margin (%)
end

# ╔═╡ 7839322b-456c-4f38-9e52-d06e6e01da4b
camera_angles8 = md"""
ϕ: $(ϕ_s8)
ψ: $(ψ_s8)
"""

# ╔═╡ b21a0df1-4512-486d-8fb5-8d248e9910ec
begin
	p_stability = plot(
		xaxis = "x", yaxis = "y", zaxis = "z",
		xlim = (-0.05, 1.05) .* fuse.length,
		ylim = (-0.50, 0.50) .* fuse.length,
		zlim = (-0.50, 0.50) .* fuse.length,
		camera = (ϕ8, ψ8),
	)
	plot!(fuse, label = "Fuselage", alpha = 0.6)
	plot!(wing_mesh, label = "Wing", mac = false)
	plot!(htail_mesh, label = "Horizontal Tail", mac = false)
	plot!(vtail_mesh, label = "Vertical Tail", mac = false)

	# Component CG location
	scatter!(Tuple(r_np), label = "Neutral Point (SM = $(round(SM; digits = 2))%)")
	# scatter!(Tuple(r_np_lat), label = "Lat. Neutral Point)")
	scatter!(Tuple(r_cp), label = "Center of Pressure")
	
	# p_stability # call the plot to display
end

# ╔═╡ 6b953f71-28a5-4e67-85a1-48a976212782
# savefig(plt_vlm, "my_aircraft.png") # TO SAVE THE FIGURE

# ╔═╡ 248c103d-c885-4faf-9f2d-65c7630cd833
md"
### Dynamic Stability
"

# ╔═╡ d4b5952c-be9e-4a09-8f5e-e2527e61b00e
begin
	Ixx = span(wing) / √12 
	Iyy = chords(wing)[1] / √12 # Moment of inertia in x-z plane
	Izz = span(wing) / √12
end

# ╔═╡ 738aa150-41c8-435b-8d7e-dc435a3253fc
lon_dvs = longitudinal_stability_derivatives(ac_dvs, refs.speed, W_tot, Iyy, dynamic_pressure(refs), refs.area, refs.chord)

# ╔═╡ e149d4c1-e9cc-45e0-ae4f-25c13e68aebf
A_lon = longitudinal_stability_matrix(lon_dvs..., refs.speed, g)

# ╔═╡ 5de92065-cc5c-4cbb-aefb-6d0c62e9da21
lat_dvs = lateral_stability_derivatives(ac_dvs, refs.speed, W_tot, Ixx, Izz, dynamic_pressure(refs), refs.area, refs.span)

# ╔═╡ 3f8ea09e-6d80-4463-a716-0548be5f29db
A_lat = lateral_stability_matrix(lat_dvs..., refs.speed, g)

# ╔═╡ 136a5a53-b5a6-4317-9466-c76731cd9ad7
md"
## Drag Estimation
"

# ╔═╡ ca7eac11-c65f-4106-963d-f4a4b32b03d1
md"

The total drag coefficient can be estimated by breaking down the drag contributions from the components:

```math
C_{D_0} = C_{D_{0,f}} + C_{D_{0,w}} + C_{D_{0,ht}} + C_{D_{0,vt}} + C_{D_{0,LG}} + C_{D_{0,N}} + C_{D_{0,S}} + C_{D_{0, HLD}} + \dots
```

"

# ╔═╡ 9cdbd51f-e5a3-4ce7-b84b-14393c2530a2
md">AeroFuse provides the following `parasitic_drag_coefficient` function for estimating $C_{D_0}$ of the fuselage and wing components.
>
> This estimation can depend on whether the flow is laminar or turbulent. For high Reynolds numbers (i.e., $Re \geq 2\times 10^6$), the flow over all surfaces is usually fully turbulent."

# ╔═╡ 43b7ae0b-371d-48cf-a8dc-f61f35838a54
x_tr = 0.0 # Transition location to turbulent flow as ratio of chord length. 
# 0 = fully turbulent, 1 = fully laminar

# ╔═╡ a2e56edd-9c9c-4d67-9b06-4fab5b22e797
CD0_fuse = parasitic_drag_coefficient(fuse, refs, x_tr) # Fuselage

# ╔═╡ 5f95dee3-9e12-45ee-bfb5-334989765cdd
CD0_wing = parasitic_drag_coefficient(wing_mesh, refs, x_tr) # Wing

# ╔═╡ c501e5ed-fef6-41fd-83d8-a6ad488df321
CD0_htail = parasitic_drag_coefficient(htail_mesh, refs, x_tr) # HTail

# ╔═╡ 59e4f269-4b89-4d5e-b189-17964dde45bb
CD0_vtail = parasitic_drag_coefficient(vtail_mesh, refs, x_tr) # VTail

# ╔═╡ f50d4848-3ac8-46da-af34-05d77d45dbef
# Summed. YOU MUST ADD MORE BASED ON YOUR COMPONENTS (NACELLE, ETC.)
CD0 = CD0_fuse + CD0_wing + CD0_htail + CD0_vtail

# ╔═╡ 53fef8bf-fdca-4755-ab07-147405bc72a4
CD = CD0 + ffs.CDi # Evaluate total drag coefficient

# ╔═╡ 994a2236-1a45-481f-8ea0-fb7f91eedc0c
md"""
!!! danger "Alert!"
	You will have to determine the parasitic drag coefficients of the other terms (landing gear, high-lift devices, etc.) for your design on your own following the lecture notes and references.

	The summation also does not account for interference between various components, e.g. wing and fuselage junction. You may have to consider "correction factors" ($K_c$ in the notes) as multipliers following the references.
"""

# ╔═╡ 44a61c54-9624-41e5-b8e4-957fc4f66bfe
md"Based on this total drag coefficient, we can estimate the revised lift-to-drag ratio."

# ╔═╡ d7589882-b08c-40a6-af7f-f200a7f87cfe
LD_visc = ffs.CL / CD # Evaluate lift-to-drag ratio

# ╔═╡ eeae6c89-af27-4507-8e75-6ec0afd0af27


# ╔═╡ f2b39ba0-89c5-453c-bed5-6db6480f6d35
# The end

# ╔═╡ Cell order:
# ╟─24dde28c-f34a-11ef-197d-b16f7ef44c0a
# ╠═33dacb1f-53e6-4b4d-81f5-d76999b4acb1
# ╠═62902bc0-9490-4bc2-bf48-0a3c30c5ed59
# ╠═58b342e7-39ca-4641-88ab-ef0e2b5c7cba
# ╟─f820f529-6626-4e2c-8747-e4009c18ab3a
# ╟─0937de00-8855-4b16-bd75-39db98a70d77
# ╠═ff7006bf-8e60-4350-b05c-1be8ff5c8068
# ╟─220105fa-5091-4e72-bad1-1761077d726c
# ╠═adbcd62e-3892-49d2-ab07-e40aa99e3797
# ╠═d5cc0a31-3498-4351-bdbe-f9bb1ca3a223
# ╟─0204dbf4-6214-411b-ab08-8832fc029ce4
# ╠═0cc52de0-a28e-4b52-8be2-0dce6a101e66
# ╠═2c1b7012-4274-4461-a851-06b9d4d4f7bf
# ╠═a4186bb5-f640-420c-bcac-1988ef3c82ca
# ╠═db1d4561-3525-4f3a-89fb-41ce98500610
# ╟─01847722-9de8-4671-bbb8-e1d56c9815dd
# ╟─ad3737eb-55dd-47fe-a73d-ca818ce78f3c
# ╠═98cb649e-6cdd-452c-b732-6ac4029c4e21
# ╠═b86ad3c5-1699-4a74-b1b4-86be7ceb8c0a
# ╟─e2955349-67f1-4a3b-8f56-628f248d00fb
# ╟─7232c5cc-5e20-4f4f-b8ab-8189302f08ec
# ╠═7be8b5f5-5543-43ae-ad8d-71c7e4bb69ac
# ╠═cb3bb8ea-ba65-4cb3-897c-da9af590483f
# ╠═20c68a3d-e22d-4a74-a1e1-efe28a83d615
# ╠═90eb5f42-b847-4e7c-b2d4-a922b697fcde
# ╠═5d3dfb79-e833-4e96-905b-8e09a4fd6cf7
# ╟─89baa943-6da2-41f8-8e64-520d6c41116b
# ╟─35895f47-484c-45d1-99ec-466595a72d3c
# ╟─d93e8bf6-2ab2-4d2d-a2b0-58692980d309
# ╠═5ea69c20-7163-4ec0-934c-afc6729d75aa
# ╠═17affea3-545f-45dc-82c0-c58a63c2a17c
# ╠═0c5c5271-56c5-4ae4-b8b2-33d19b021d6f
# ╠═2b2388c4-8e89-47b9-b361-e1568945be50
# ╟─56dbc2bc-4441-4e1f-9b88-d1457540ab68
# ╟─6375742c-cb16-48f2-a13c-809ec06b1a00
# ╟─0b93bf59-9363-4223-b2aa-7f99dde5982d
# ╠═1fca478f-b79b-4acc-aea7-852ff784e756
# ╠═d4970954-a888-4f28-8b61-bdc0a2a06a93
# ╟─a106972a-b410-4d3a-b915-67f69e26b996
# ╟─94ea47f1-7019-41ee-bb2c-88489a15144e
# ╠═55096245-926c-4949-8987-cf667044b4d7
# ╠═4b7efc17-6eee-4763-bc26-3cb344fd9e36
# ╠═8977047d-cd8c-4273-93d9-d887307df4ee
# ╠═0622a9bc-888e-42f4-a26c-fafbf19c09f1
# ╠═6e79aaa2-dcbd-466c-91ad-6c8dafb424e8
# ╠═d20c6f95-7273-416f-ae8a-a324bb6a7279
# ╟─f8b17518-1220-4a8f-a3b3-45650f68c8f9
# ╠═de2725a2-4053-4fa2-9a0d-1419b8692edd
# ╟─cafe9f2b-82ae-40de-940d-aaa8b38813e5
# ╟─2f53da90-4476-449c-8586-9a614d740cfd
# ╠═51cb45ac-f6a9-436f-a773-11b835b69a05
# ╠═f6fb90eb-d168-4731-90ed-5d8db19bf2d8
# ╠═a99981ba-c29a-4757-ab7f-2067221dd927
# ╠═936103a9-29e5-4c51-b7de-6e45c8c1e314
# ╠═af1d4536-eb1b-4de6-8297-9f49117be5bc
# ╟─12e2dfe3-6975-4678-9db3-269109a83c45
# ╟─d132663f-3a0d-4b60-a322-0afc2232e90d
# ╟─1b38aedb-2737-47c3-91d6-1f54afaaf289
# ╠═1d08d0d3-fb07-4c7e-af60-6a6ac8bca4a7
# ╠═71be68b7-e3f6-4c63-ada1-b3899e636ec8
# ╠═2b0c3def-51ec-4999-aa68-ac675b87a021
# ╟─80d88a0c-df5a-47c3-a129-487a6829723a
# ╟─31107917-7658-4e90-955e-dc6eb2399394
# ╟─ee963e66-d054-44b2-b790-ea5e9bd488bc
# ╟─ffca0ec4-37d0-43f4-ae27-955cdf3a607e
# ╠═ae53070a-6b80-4179-88aa-1eca48ddd3fb
# ╠═45e8aa28-ada1-44c9-87c9-9879ab59caeb
# ╟─349bfe25-f352-4c47-b4b7-250fa616dbb6
# ╠═b0a99439-467a-4533-8b7e-6ad6e8fcbfb0
# ╠═c9209801-fe0a-4fc7-a47d-b5ee8c954906
# ╟─74fa6103-562e-4b07-b86b-ad6dc130d861
# ╟─5f82cc4a-3314-4ee4-8009-c70c20a8ec53
# ╠═9ebce535-f558-4591-befc-cbe735cc6d5d
# ╠═8a395e26-7b06-488f-ad18-6f2a4bf9c45c
# ╠═0142d4a2-7a20-4a97-add0-02f3f9bb916a
# ╠═5439a1af-1010-42c9-b389-9beb7215d475
# ╟─f62b211c-2cde-4194-b165-a83f6078fca3
# ╠═9bf3fc80-dc5e-492d-ba84-77d132986b99
# ╠═b817c2d4-339a-4d57-ab4d-36ec760eb235
# ╠═d5ddc08a-b890-48fc-bb80-9b3bbaffc2e5
# ╟─68e27cca-46ca-45dd-8200-f0e060a6016f
# ╠═848562be-e6f8-4497-b29f-0f31cb8c9479
# ╠═24c15474-d54d-4389-a2b0-82e6d4669688
# ╟─048c924a-8b02-40e6-867f-08fe99ef12ce
# ╟─06a4b2dc-12b9-4d29-9568-a2001bb75612
# ╟─342d244b-6e70-4570-a1db-2a15c9949624
# ╟─13d2be83-eca6-4149-bc88-6df6e8307d63
# ╟─82b65de8-3628-468e-bff4-66961b4abc27
# ╠═8972158d-fac4-4537-9897-8e77851d38ba
# ╠═43655116-1615-43ee-82a9-09b276965d5d
# ╟─6a1f64dd-ddfb-4c80-b978-a1386092c7e8
# ╠═9f85739e-4717-441b-9891-50477de1a03a
# ╠═736f49a7-4e5a-44b8-949d-ce94a27e6e17
# ╟─3fe30e88-0f97-4210-aeef-0d4a37787eb1
# ╠═02aa2148-a1db-40c0-803a-fe35bd63275a
# ╟─2387da64-f729-4d7d-95da-f85247ab4384
# ╠═4513744a-6153-42ee-810c-4894e94dd6e4
# ╠═4fed4dad-c225-43f8-8dce-1c382b7782df
# ╠═87b4eac6-f449-4835-969b-7b24487ebf3f
# ╠═011d0b2d-994f-4bd7-8920-bd470f69ecfb
# ╠═f5390ac1-425e-4d5d-9516-ac93e9366f3e
# ╟─f0d75b59-88e5-4e44-adce-e916fa91e905
# ╠═0abc0343-633e-4b4f-aec3-7d81f254ceef
# ╠═a4cfd3c6-5b92-467d-9ac6-af611d8cc22d
# ╟─0c15d3d8-5e16-4a63-aafa-cb72280b0d89
# ╟─d58dc1da-bde1-4500-9a6b-b0cf645ee0b7
# ╟─753d041a-6b9c-4777-8015-4329278163f4
# ╟─68da981f-cf30-4333-97a8-7d0bb969c7df
# ╟─8537b9e6-54fc-44a6-8526-bd7e7a14f107
# ╟─c7c8e3b0-c580-4fd4-91be-d6152589f3d3
# ╟─9f7ca823-0df2-4662-af6a-8414d762b13d
# ╠═dd849516-182d-43d6-8598-6f8457625251
# ╟─9189d1ae-461f-4743-af90-bc73ad64f3f0
# ╠═4adf977e-0496-42da-aed8-6a1b9c089308
# ╠═fcbe47f7-e0c8-4e19-b198-844d99fcbb0a
# ╟─7839322b-456c-4f38-9e52-d06e6e01da4b
# ╟─b21a0df1-4512-486d-8fb5-8d248e9910ec
# ╠═6b953f71-28a5-4e67-85a1-48a976212782
# ╟─248c103d-c885-4faf-9f2d-65c7630cd833
# ╠═d4b5952c-be9e-4a09-8f5e-e2527e61b00e
# ╠═738aa150-41c8-435b-8d7e-dc435a3253fc
# ╠═e149d4c1-e9cc-45e0-ae4f-25c13e68aebf
# ╠═5de92065-cc5c-4cbb-aefb-6d0c62e9da21
# ╠═3f8ea09e-6d80-4463-a716-0548be5f29db
# ╟─136a5a53-b5a6-4317-9466-c76731cd9ad7
# ╟─ca7eac11-c65f-4106-963d-f4a4b32b03d1
# ╟─9cdbd51f-e5a3-4ce7-b84b-14393c2530a2
# ╠═43b7ae0b-371d-48cf-a8dc-f61f35838a54
# ╠═a2e56edd-9c9c-4d67-9b06-4fab5b22e797
# ╠═5f95dee3-9e12-45ee-bfb5-334989765cdd
# ╠═c501e5ed-fef6-41fd-83d8-a6ad488df321
# ╠═59e4f269-4b89-4d5e-b189-17964dde45bb
# ╠═f50d4848-3ac8-46da-af34-05d77d45dbef
# ╠═53fef8bf-fdca-4755-ab07-147405bc72a4
# ╟─994a2236-1a45-481f-8ea0-fb7f91eedc0c
# ╟─44a61c54-9624-41e5-b8e4-957fc4f66bfe
# ╠═d7589882-b08c-40a6-af7f-f200a7f87cfe
# ╠═eeae6c89-af27-4507-8e75-6ec0afd0af27
# ╠═f2b39ba0-89c5-453c-bed5-6db6480f6d35

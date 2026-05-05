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
        using Markdown
        gr(size = (800,600))
        TableOfContents(depth = 4)
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
    end

  

# ╔═╡ d6b41872-bd8e-45d1-baa2-fa0cc36b6177
    md"""### Wing
    First, you can define the wing from your preliminary wing sizing. Here, we'll choose a supercritical airfoil for the wing section. **This is not the same one as used in the Boeing 777-200LR.**
    """

  

# ╔═╡ d9ef5002-70d7-40a8-81fa-7a07567eb613
    begin
    foil_w_root = read_foil("C:\\Users\\kychandv\\MECH3620\\3620_project\\Airfoil\\NASA SC(2)-0714.txt") # Read the root airfoil
    foil_w_tip  = read_foil("C:\\Users\\kychandv\\MECH3620\\3620_project\\Airfoil\\NASA SC(2)-0714.txt")#Read the tip airfoil
    end

  

# ╔═╡ a76599c7-563d-4647-8fda-36869d07ff71
    plot(foil_w_root, aspect_ratio = 1)

  

# ╔═╡ 87f54aa2-861a-44f7-b331-1198f522d1e4
    md"""Here, we'll define a two-section wing planform that we'll use in this notebook."""

  

# ╔═╡ c8c3daf0-4e63-49b6-bc07-6ba37f817c5e
    wing = Wing(
        foils       = [foil_w_root, foil_w_root, foil_w_tip],              # Airfoils
        chords 		= [4.787, 3.540, 1.565],  	# Chord lengths 
        spans       = [4.937, 7.813],
        dihedrals   = [5.0, 7.0],               # Dihedral angles (deg)
        sweeps      = [30.0, 30.0],             # Sweep angles (deg )
        w_sweep     = 0.0,                      # Leading-edge sweep
        position    = [11, 0.0, -1.0],      	 # HOW DO YOU DETERMINE THIS?
        symmetry    = true,                      # Symmetry
        angle       = 5,
        axis        = [0, 1, 0]
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
    begin
            df_outer = 3.21
            l_fuse   = 32.98
            l_nose   = 4.91 
            l_tail   = 8.99 # nose / diameter ratio = 2.8
            l_cabin  = 19.08

            x_a_cabin = l_nose / l_fuse
            x_b_cabin = (l_nose + l_cabin) / l_fuse

            fuse = HyperEllipseFuselage(
                radius   = df_outer / 2,   # 1.605 m
                length   = l_fuse,         # 28.83 m
                x_a      = x_a_cabin,      # start of cabin
                x_b      = x_b_cabin,      # end of cabin
                c_nose   = 1.3,
                c_rear   = 1.2,
                d_nose   = -0.379, 			#22deg 
                d_rear   = 0.636, 			#14deg
                position = [0.0, 0.0, 0.0]
            )
        end

  

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

# ╔═╡ 4d5e821d-ef92-4f84-92c6-27aa12308be9
 con_foil = naca4(0, 0, 1, 2) 

# ╔═╡ 704943ec-10e2-4c50-994b-4688a99ac6c7
    htail = WingSection(
            area        = 16.5,  # HOW DO YOU DETERMINE THIS?--> Area~12.5-25% S_wing
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


  

# ╔═╡ a95b7c43-2db3-45fa-8bcb-9eab971fe0af
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
            area        = 10, # HOW DO YOU DETERMINE THIS?
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
    # ============================================================
    # Reference quantities
    # ============================================================
    TOGW = 33614.1          # Takeoff gross weight, kg
    W_engine = 1179.0       # GE CF34-8E dry weight per engine, kg

    # Unit conversions
    kg_to_lb = 2.20462262185
    lb_ft2_to_kg_m2 = 4.88243

    # ============================================================
    # Ultimate load factor
    # FAR / transport-aircraft style preliminary estimate:
    # n_limit = min(2.1 + 24000/(W_lb + 10000), 3.8)
    # n_ult   = 1.5 * n_limit
    # ============================================================
    TOGW_lb = TOGW * kg_to_lb
    n_limit_pos = min(2.1 + 24000.0 / (TOGW_lb + 10000.0), 3.8)
    n_ult = 1.5 * n_limit_pos
end;


  

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
    weight_position_raw = Dict(	
        "engine" 	=> (1.3 * 2 * W_engine, 			eng_L.x), 	# Engines (2 × weight)
        "wing"   	=> (S_w * 10  * lb_ft2_to_kg_m2, 	mac40_w.x), # Wing, 40% MAC
        "htail"  	=> (S_h * 5.5 * lb_ft2_to_kg_m2, 	mac40_h.x), # HTail, 40% MAC
        "vtail"  	=> (S_v * 5.5 * lb_ft2_to_kg_m2, 	mac40_v.x), # VTail, 40% MAC
        "fuse"   	=> (S_f * 5.0 * lb_ft2_to_kg_m2, 	x_fuse), 	# Fuse, centroid
        "all-else" 	=> (0.17 	* 		 TOGW, 			x_other),
        "noseLG" 	=> (0.043 	* 0.15 * TOGW, 			x_nLG), 
        "mainLG" 	=> (0.043 	* 0.85 * TOGW, 			x_mLG),
    );

   

# ╔═╡ a8ff3d5c-53cf-47a7-a074-f1a9a9a085e7
 # ============================================================
    # NORMALISE AIRFRAME WEIGHTS TO FINAL REFINED EMPTY WEIGHT
    # Engine mass is kept fixed.
    # ============================================================
begin
    fuel_fraction_final = 0.28658

    W_payload_final = 7350.0
    W_crew_final = 360.0
    W_fuel_final = fuel_fraction_final * TOGW

    # Empty weight target required by final MTOW and round-trip fuel
    W_empty_target = TOGW - W_payload_final - W_crew_final - W_fuel_final

    # Keep engine fixed because it comes from selected engine data
    fixed_components = ["engine"]

    W_fixed = sum(weight_position_raw[name][1] for name in fixed_components)

    W_scalable_current = sum(
        w for (name, (w, x)) in weight_position_raw
        if !(name in fixed_components)
    )

    W_scalable_target = W_empty_target - W_fixed

    airframe_scale = W_scalable_target / W_scalable_current
end
    
  

# ╔═╡ 0850f920-ae2e-49b7-baad-4be55fb1e917
begin
println("Target empty weight       = ", round(W_empty_target, digits=2), " kg")
    println("Fixed engine weight       = ", round(W_fixed, digits=2), " kg")
    println("Scalable current weight   = ", round(W_scalable_current, digits=2), " kg")
    println("Scalable target weight    = ", round(W_scalable_target, digits=2), " kg")
    println("Airframe scale factor     = ", round(airframe_scale, digits=4))
end
    

# ╔═╡ 249e14f7-caaf-4e52-9698-d402fd83e67f
begin

weight_position = Dict()
if airframe_scale <= 0
    error("Target scalable airframe weight is non-positive. Check MTOW, payload, crew, fuel, and engine mass.")
    end

    weight_position = Dict(
        name => begin
            w, x = wx
            if name in fixed_components
                (w, x)
            else
                (w * airframe_scale, x)
            end
        end
        for (name, wx) in weight_position
    )
end


# ╔═╡ 54fd4ba7-39eb-40a2-9006-5813437cdfb2


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
        M = 0.78 # operating cruise Mach number
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
    x_np = mac25_w.x + x_np_by_c * c_w 		# Translate from the wing MAC

  

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
        speed = M * 295.,
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
    # Use Cm-CL slope directly from VLM alpha sweep
    # This follows lecture alternative form:
    # x_np/c = -(dCm/dCL + dCmf/dCL)

    fit_mask = abs.(df_M2.al) .<= 4
    df_fit = df_M2[fit_mask, :]

    X = hcat(ones(nrow(df_fit)), df_fit.CL)
    β = X \ df_fit.Cm

    dCm_dCL_VLM = β[2]

    CLα_wing_VLM = abs(dvs.wing.CZ_al)
    Cm_fuse_CL = fuse_Cm_CL(V_f, S_w, c_w, CLα_wing_VLM)

    x_np_vlm = refs.location[1] - refs.chord * (dCm_dCL_VLM + Cm_fuse_CL)

  

# ╔═╡ 7fbb061f-a9ef-47bd-9989-37119e4e6b88


  

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
    @bind plot_vlm CheckBox(default = false)

  

# ╔═╡ 17c59c56-d2aa-44d9-8658-bd323b7d50b7
    @bind plot_streamlines CheckBox(default = false)

  

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


    begin
        using CSV
        using Dates
        using ZipFile

        x_LEMAC_export = mac25_w.x - 0.25 * c_w

        function pctMAC_export(x)
            return 100 * (x - x_LEMAC_export) / c_w
        end

        function cg_export(items)
            W = sum(w for (w, x) in values(items))
            M = sum(w * x for (w, x) in values(items))
            xcg = M / W
            return (W = W, xcg = xcg, pctMAC = pctMAC_export(xcg))
        end

        # Existing neutral points from your file
        x_np_DATCOM_export = x_np
        x_np_VLM_export = r_np_vlm.x

        # ============================================================
        # 1) ORIGINAL CG + SM RESULTS FROM YOUR FILE
        # ============================================================

        original_results = DataFrame(
            Method = ["DATCOM", "VLM"],
            x_cg_m = [x_cg, x_cg],
            CG_percent_MAC = [pctMAC_export(x_cg), pctMAC_export(x_cg)],
            x_np_m = [x_np_DATCOM_export, x_np_VLM_export],
            Static_margin_percent = [100 * SM, 100 * SM_VLM],
            MAC_m = [c_w, c_w],
            x_LEMAC_m = [x_LEMAC_export, x_LEMAC_export]
        )

# ============================================================
# 2) WEIGHT & BALANCE LOADING CASES, MISSION CG, AND PLOTS
# ============================================================

# ------------------------------------------------------------
# Useful loads based on project assumptions
# ------------------------------------------------------------
W_pax_each  = 90.0
W_bag_each  = 15.0
W_crew_each = 90.0

n_crew = 4
n_pax  = 70

W_crew_export = n_crew * W_crew_each
x_crew_export = 0.55 * l_nose

W_baggage_export = n_pax * W_bag_each
x_baggage_export = l_nose + 0.70 * l_cabin

# Passenger groups for CG calculations
n_pax_groups = 14
pax_per_group = fill(n_pax ÷ n_pax_groups, n_pax_groups)
for i in 1:(n_pax - sum(pax_per_group))
    pax_per_group[i] += 1
end

x_pax_groups = [
    l_nose + (i - 0.5) / n_pax_groups * l_cabin
    for i in 1:n_pax_groups
]

W_pax_total = n_pax * W_pax_each
x_pax_total = sum((pax_per_group[i] * W_pax_each) * x_pax_groups[i] for i in 1:n_pax_groups) / W_pax_total

# Fuel CG near wing MAC 40%
x_fuel_export = mac40_w.x

# ------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------
function pctMAC_export(x)
    return 100 * (x - x_LEMAC_export) / c_w
end

function cg_export(items)
    W = sum(w for (w, x) in values(items))
    M = sum(w * x for (w, x) in values(items))
    xcg = M / W
    return (W = W, xcg = xcg, pctMAC = pctMAC_export(xcg))
end

function sm_datcom_from_xcg(xcg)
    return 100 * (x_np_DATCOM_export - xcg) / c_w
end

function sm_vlm_from_xcg(xcg)
    return 100 * (x_np_VLM_export - xcg) / c_w
end

function passenger_items_dict()
    return Dict(
        "pax_group_$(i)" => (pax_per_group[i] * W_pax_each, x_pax_groups[i])
        for i in 1:n_pax_groups
    )
end

function add_items!(items, more_items)
    for (name, wx) in more_items
        items[name] = wx
    end
    return items
end

# ------------------------------------------------------------
# Existing neutral points
# ------------------------------------------------------------
x_np_DATCOM_export = x_np
x_np_VLM_export = r_np_vlm.x

# ------------------------------------------------------------
# Original empty/component CG + SM
# ------------------------------------------------------------
original_results = DataFrame(
    Method = ["DATCOM", "VLM"],
    x_cg_m = [x_cg, x_cg],
    CG_percent_MAC = [pctMAC_export(x_cg), pctMAC_export(x_cg)],
    x_np_m = [x_np_DATCOM_export, x_np_VLM_export],
    Static_margin_percent = [100 * SM, 100 * SM_VLM],
    MAC_m = [c_w, c_w],
    x_LEMAC_m = [x_LEMAC_export, x_LEMAC_export]
)

# ------------------------------------------------------------
# Zero-fuel and full-fuel weights
# ------------------------------------------------------------
zero_fuel_items = copy(weight_position)
zero_fuel_items["crew"] = (W_crew_export, x_crew_export)
zero_fuel_items["baggage"] = (W_baggage_export, x_baggage_export)
add_items!(zero_fuel_items, passenger_items_dict())

zero_fuel_cg = cg_export(zero_fuel_items)
W_zero_fuel = zero_fuel_cg.W

W_fuel_export = TOGW - W_zero_fuel

if W_fuel_export < 0
    error("Zero-fuel weight exceeds TOGW. Reduce OEW/payload or increase TOGW.")
end

println("Zero-fuel weight = ", round(W_zero_fuel, digits=2), " kg")
println("Fuel allowed by TOGW = ", round(W_fuel_export, digits=2), " kg")
println("Fuel fraction = ", round(W_fuel_export / TOGW * 100, digits=2), " %")

# ------------------------------------------------------------
# Loading groups
# ------------------------------------------------------------
load_groups = Dict(
    "Crew" => Dict("crew" => (W_crew_export, x_crew_export)),
    "Fuel" => Dict("fuel" => (W_fuel_export, x_fuel_export)),
    "Payload" => merge(
        Dict("baggage" => (W_baggage_export, x_baggage_export)),
        passenger_items_dict()
    )
)

function loading_sequence_export(sequence_name, sequence)
    items = copy(weight_position)

    df = DataFrame(
        Sequence = String[],
        Step_No = Int[],
        Step = String[],
        Weight_kg = Float64[],
        x_cg_m = Float64[],
        CG_percent_MAC = Float64[],
        SM_DATCOM_percent = Float64[],
        SM_VLM_percent = Float64[]
    )

    cg = cg_export(items)
    push!(df, (
        sequence_name,
        0,
        "Empty weight",
        cg.W,
        cg.xcg,
        cg.pctMAC,
        sm_datcom_from_xcg(cg.xcg),
        sm_vlm_from_xcg(cg.xcg)
    ))

    step_no = 1
    for group_name in sequence
        add_items!(items, load_groups[group_name])
        cg = cg_export(items)

        push!(df, (
            sequence_name,
            step_no,
            "Add " * group_name,
            cg.W,
            cg.xcg,
            cg.pctMAC,
            sm_datcom_from_xcg(cg.xcg),
            sm_vlm_from_xcg(cg.xcg)
        ))
        step_no += 1
    end

    return df
end

# Representative loading sequence
loading_main = loading_sequence_export(
    "Empty → Crew → Fuel → Payload",
    ["Crew", "Fuel", "Payload"]
)

# Several loading cases for CG limit search
loading_scenarios = vcat(
    loading_sequence_export("Crew-Fuel-Payload", ["Crew", "Fuel", "Payload"]),
    loading_sequence_export("Crew-Payload-Fuel", ["Crew", "Payload", "Fuel"]),
    loading_sequence_export("Fuel-Crew-Payload", ["Fuel", "Crew", "Payload"]),
    loading_sequence_export("Fuel-Payload-Crew", ["Fuel", "Payload", "Crew"]),
    loading_sequence_export("Payload-Crew-Fuel", ["Payload", "Crew", "Fuel"]),
    loading_sequence_export("Payload-Fuel-Crew", ["Payload", "Fuel", "Crew"])
)

# ------------------------------------------------------------
# Mission CG excursion due to fuel burn
# TWO-WAY MISSION WITHOUT REFUELING
# Beta is calculated by cumulative multiplication of stage fractions
# ------------------------------------------------------------

stage_fractions = [
    ("Warm-up", 0.99),
    ("Taxi",    0.99),
    ("Takeoff", 0.995),
    ("Climb",   0.98),
    ("Cruise",  0.9316807095272559),
    ("Loiter",  0.976835024950062),
    ("Descent", 0.99),
    ("Landing", 0.992)
]

mission_beta = Tuple{String, Float64}[]

let beta = 1.0
    push!(mission_beta, ("Outbound - Start of leg", beta))

    for leg in 1:2
        leg_name = leg == 1 ? "Outbound" : "Return"

        if leg == 2
            push!(mission_beta, ("Return - Start of leg", beta))
        end

        for (phase, frac) in stage_fractions
            beta = beta * frac
            push!(mission_beta, ("$(leg_name) - After $(phase)", beta))
        end
    end
end

mission_cg = DataFrame(
    Phase = String[],
    Beta = Float64[],
    Fuel_mass_kg = Float64[],
    Weight_kg = Float64[],
    x_cg_m = Float64[],
    CG_percent_MAC = Float64[],
    SM_DATCOM_percent = Float64[],
    SM_VLM_percent = Float64[]
)

for (phase, beta_phase) in mission_beta
    items = copy(weight_position)

    # Full useful load remains onboard during mission
    items["crew"] = (W_crew_export, x_crew_export)
    items["baggage"] = (W_baggage_export, x_baggage_export)
    add_items!(items, passenger_items_dict())

    # Total aircraft weight from beta
    W_phase = beta_phase * TOGW

    # Fuel mass is whatever is needed to make total weight = beta * TOGW
    fuel_mass = W_phase - W_zero_fuel

    if fuel_mass < -1e-6
        @warn "Mission beta gives aircraft weight below zero-fuel weight. Check stage fractions." phase beta_phase W_phase W_zero_fuel
        fuel_mass = 0.0
    end

    items["fuel"] = (fuel_mass, x_fuel_export)

    cg = cg_export(items)

    push!(mission_cg, (
        phase,
        beta_phase,
        fuel_mass,
        cg.W,
        cg.xcg,
        cg.pctMAC,
        sm_datcom_from_xcg(cg.xcg),
        sm_vlm_from_xcg(cg.xcg)
    ))
end

mission_cg[!, :Mission_progress] = collect(range(0.0, 1.0, length=nrow(mission_cg)))
# ------------------------------------------------------------
# Good boarding method potato plot
# Use a balanced-zone boarding order, plus unloading
# ------------------------------------------------------------
n_board_zones = 6
pax_per_zone_board = fill(n_pax ÷ n_board_zones, n_board_zones)
for i in 1:(n_pax - sum(pax_per_zone_board))
    pax_per_zone_board[i] += 1
end

x_zone_board = [
    l_nose + (i - 0.5) / n_board_zones * l_cabin
    for i in 1:n_board_zones
]

good_boarding_order = [3, 4, 2, 5, 1, 6]   # balanced-zone style

function good_boarding_trace()
    items = copy(weight_position)

    # Start from OEW + crew + full fuel
    items["crew"] = (W_crew_export, x_crew_export)
    items["fuel"] = (W_fuel_export, x_fuel_export)

    df = DataFrame(
        Method = String[],
        Step_No = Int[],
        Step = String[],
        Weight_kg = Float64[],
        x_cg_m = Float64[],
        CG_percent_MAC = Float64[],
        SM_DATCOM_percent = Float64[],
        SM_VLM_percent = Float64[]
    )

    function push_state!(df, items, method_name, step_no, step_name)
        cg = cg_export(items)
        push!(df, (
            method_name,
            step_no,
            step_name,
            cg.W,
            cg.xcg,
            cg.pctMAC,
            sm_datcom_from_xcg(cg.xcg),
            sm_vlm_from_xcg(cg.xcg)
        ))
    end

    step_no = 0
    push_state!(df, items, "Balanced-zone boarding", step_no, "Start: OEW + crew + fuel")

    step_no += 1
    items["baggage"] = (W_baggage_export, x_baggage_export)
    push_state!(df, items, "Balanced-zone boarding", step_no, "Add baggage")

    for idx in good_boarding_order
        step_no += 1
        items["board_zone_$(idx)"] = (
            pax_per_zone_board[idx] * W_pax_each,
            x_zone_board[idx]
        )
        push_state!(df, items, "Balanced-zone boarding", step_no, "Board zone $(idx)")
    end

    for idx in reverse(good_boarding_order)
        step_no += 1
        delete!(items, "board_zone_$(idx)")
        push_state!(df, items, "Balanced-zone boarding", step_no, "Unload zone $(idx)")
    end

    step_no += 1
    delete!(items, "baggage")
    push_state!(df, items, "Balanced-zone boarding", step_no, "Unload baggage")

    return df
end

boarding_cg = good_boarding_trace()

# ------------------------------------------------------------
# Gather all CG cases and determine limits
# ------------------------------------------------------------
mission_cases = DataFrame(
    Source = fill("Mission fuel burn", nrow(mission_cg)),
    Case = mission_cg.Phase,
    Weight_kg = mission_cg.Weight_kg,
    x_cg_m = mission_cg.x_cg_m,
    CG_percent_MAC = mission_cg.CG_percent_MAC,
    SM_DATCOM_percent = mission_cg.SM_DATCOM_percent,
    SM_VLM_percent = mission_cg.SM_VLM_percent
)

boarding_cases = DataFrame(
    Source = fill("Boarding potato plot", nrow(boarding_cg)),
    Case = boarding_cg.Method .* " - " .* boarding_cg.Step,
    Weight_kg = boarding_cg.Weight_kg,
    x_cg_m = boarding_cg.x_cg_m,
    CG_percent_MAC = boarding_cg.CG_percent_MAC,
    SM_DATCOM_percent = boarding_cg.SM_DATCOM_percent,
    SM_VLM_percent = boarding_cg.SM_VLM_percent
)

loading_cases = DataFrame(
    Source = fill("Loading scenarios", nrow(loading_scenarios)),
    Case = loading_scenarios.Sequence .* " - " .* loading_scenarios.Step,
    Weight_kg = loading_scenarios.Weight_kg,
    x_cg_m = loading_scenarios.x_cg_m,
    CG_percent_MAC = loading_scenarios.CG_percent_MAC,
    SM_DATCOM_percent = loading_scenarios.SM_DATCOM_percent,
    SM_VLM_percent = loading_scenarios.SM_VLM_percent
)

all_cg_cases = vcat(loading_cases, mission_cases, boarding_cases)

fwd_idx = argmin(all_cg_cases.CG_percent_MAC)
aft_idx = argmax(all_cg_cases.CG_percent_MAC)

cg_limits = DataFrame(
    Limit = ["Forward CG limit from cases", "Aft CG limit from cases"],
    Source = [all_cg_cases.Source[fwd_idx], all_cg_cases.Source[aft_idx]],
    Critical_case = [all_cg_cases.Case[fwd_idx], all_cg_cases.Case[aft_idx]],
    Weight_kg = [all_cg_cases.Weight_kg[fwd_idx], all_cg_cases.Weight_kg[aft_idx]],
    x_cg_m = [all_cg_cases.x_cg_m[fwd_idx], all_cg_cases.x_cg_m[aft_idx]],
    CG_percent_MAC = [all_cg_cases.CG_percent_MAC[fwd_idx], all_cg_cases.CG_percent_MAC[aft_idx]],
    SM_DATCOM_percent = [all_cg_cases.SM_DATCOM_percent[fwd_idx], all_cg_cases.SM_DATCOM_percent[aft_idx]],
    SM_VLM_percent = [all_cg_cases.SM_VLM_percent[fwd_idx], all_cg_cases.SM_VLM_percent[aft_idx]]
)

# Reference CG range from lecture slide
fwd_cg_limit_pct = 12.0
aft_cg_limit_pct = 32.0

cg_reference_check = DataFrame(
    Quantity = ["Minimum CG", "Maximum CG", "Forward reference", "Aft reference", "Within 12–32% MAC?"],
    Value = Any[
        minimum(all_cg_cases.CG_percent_MAC),
        maximum(all_cg_cases.CG_percent_MAC),
        fwd_cg_limit_pct,
        aft_cg_limit_pct,
        minimum(all_cg_cases.CG_percent_MAC) >= fwd_cg_limit_pct &&
        maximum(all_cg_cases.CG_percent_MAC) <= aft_cg_limit_pct
    ]
)

println(cg_limits)
println(cg_reference_check)

# ============================================================
# 7) PLOTS
# ============================================================
x_min_plot = min(minimum(all_cg_cases.CG_percent_MAC) - 2, fwd_cg_limit_pct - 2)
x_max_plot = max(maximum(all_cg_cases.CG_percent_MAC) + 2, aft_cg_limit_pct + 2)
y_min_plot = minimum(all_cg_cases.Weight_kg) - 1000
y_max_plot = maximum(all_cg_cases.Weight_kg) + 1000

# ------------------------------------------------------------
# Representative loading-case CG curve
# ------------------------------------------------------------
loading_cases_plot = plot(
    loading_main.CG_percent_MAC,
    loading_main.Weight_kg,
    marker = :square,
    linewidth = 2.5,
    xlabel = "CG location (%MAC)",
    ylabel = "Aircraft weight (kg)",
    title = "CG in Representative Loading Cases",
    label = "Empty → Crew → Fuel → Payload",
    grid = true,
    legend = :topright
)

vline!(loading_cases_plot, [fwd_cg_limit_pct], linestyle = :dash, linewidth = 2, label = "Forward CG ref. limit")
vline!(loading_cases_plot, [aft_cg_limit_pct], linestyle = :dash, linewidth = 2, label = "Aft CG ref. limit")

for i in 1:nrow(loading_main)
    annotate!(
        loading_cases_plot,
        loading_main.CG_percent_MAC[i],
        loading_main.Weight_kg[i],
        text(loading_main.Step[i], 7, :left)
    )
end

# ------------------------------------------------------------
# Mission CG curve with annotations
# ------------------------------------------------------------
mission_cg_plot = plot(
    mission_cg.CG_percent_MAC,
    mission_cg.Weight_kg,
    marker = :circle,
    linewidth = 2.5,
    xlabel = "CG location (%MAC)",
    ylabel = "Aircraft weight (kg)",
    title = "Mission CG Excursion Due to Fuel Burn (Two-Way Mission)",
    label = "Mission fuel burn",
    grid = true,
    legend = :topright
)

vline!(mission_cg_plot, [fwd_cg_limit_pct], linestyle = :dash, linewidth = 2, label = "Forward CG ref. limit")
vline!(mission_cg_plot, [aft_cg_limit_pct], linestyle = :dash, linewidth = 2, label = "Aft CG ref. limit")

mission_labels = Dict(
    "Outbound - Start of leg" => "HKG departure",
    "Outbound - After climb" => "Outbound climb",
    "Outbound - After cruise" => "Outbound cruise",
    "Outbound - After landing" => "Outstation landing",
    "Return - After takeoff" => "Return takeoff",
    "Return - After cruise" => "Return cruise",
    "Return - After landing" => "Final landing"
)

for i in 1:nrow(mission_cg)
    phase = mission_cg.Phase[i]
    if haskey(mission_labels, phase)
        annotate!(
            mission_cg_plot,
            mission_cg.CG_percent_MAC[i],
            mission_cg.Weight_kg[i],
            text(mission_labels[phase], 7, :left)
        )
    end
end

mission_only_plot = mission_cg_plot

# ------------------------------------------------------------
# Potato plot: good boarding method with loading + unloading
# ------------------------------------------------------------
first_unload_idx = findfirst(s -> startswith(s, "Unload"), boarding_cg.Step)
full_load_idx = first_unload_idx - 1

load_rows = 1:full_load_idx
unload_rows = first_unload_idx:nrow(boarding_cg)

potato_plot = plot(
    xlabel = "CG location (%MAC)",
    ylabel = "Aircraft weight (kg)",
    title = "Boarding Potato Plot — Balanced-Zone Boarding",
    legend = :topright,
    grid = true
)

plot!(
    potato_plot,
    boarding_cg.CG_percent_MAC[load_rows],
    boarding_cg.Weight_kg[load_rows],
    marker = :circle,
    linewidth = 2.5,
    label = "Loading"
)

plot!(
    potato_plot,
    boarding_cg.CG_percent_MAC[unload_rows],
    boarding_cg.Weight_kg[unload_rows],
    marker = :diamond,
    linewidth = 2.5,
    label = "Unloading"
)

vline!(potato_plot, [fwd_cg_limit_pct], linestyle = :dot, linewidth = 2, label = "Forward CG ref. limit")
vline!(potato_plot, [aft_cg_limit_pct], linestyle = :dot, linewidth = 2, label = "Aft CG ref. limit")

annotate!(potato_plot, boarding_cg.CG_percent_MAC[1], boarding_cg.Weight_kg[1], text("Start", 8, :right))
annotate!(potato_plot, boarding_cg.CG_percent_MAC[full_load_idx], boarding_cg.Weight_kg[full_load_idx], text("Full load", 8, :left))
annotate!(potato_plot, boarding_cg.CG_percent_MAC[end], boarding_cg.Weight_kg[end], text("Unload complete", 8, :left))

# ------------------------------------------------------------
# Potato plot: points-only version
# Shows each calculated loading/unloading state as a point
# ------------------------------------------------------------

# Short labels for each point: A, B, C, ...
point_labels = [string(Char('A' + i - 1)) for i in 1:nrow(boarding_cg)]

potato_points_label_table = DataFrame(
    Label = point_labels,
    Step_No = boarding_cg.Step_No,
    Step = boarding_cg.Step,
    Weight_kg = boarding_cg.Weight_kg,
    CG_percent_MAC = boarding_cg.CG_percent_MAC,
    SM_DATCOM_percent = boarding_cg.SM_DATCOM_percent,
    SM_VLM_percent = boarding_cg.SM_VLM_percent
)

# Split loading and unloading points
first_unload_idx_points = findfirst(s -> startswith(s, "Unload"), boarding_cg.Step)
full_load_idx_points = first_unload_idx_points - 1

loading_point_rows = 1:full_load_idx_points
unloading_point_rows = first_unload_idx_points:nrow(boarding_cg)

potato_points_plot = plot(
    xlabel = "CG location (%MAC)",
    ylabel = "Aircraft weight (kg)",
    title = "Boarding Potato Plot — Points Only",
    legend = :topright,
    grid = true
)

# Loading points only
scatter!(
    potato_points_plot,
    boarding_cg.CG_percent_MAC[loading_point_rows],
    boarding_cg.Weight_kg[loading_point_rows],
    markersize = 6,
    label = "Loading points"
)

# Unloading points only
scatter!(
    potato_points_plot,
    boarding_cg.CG_percent_MAC[unloading_point_rows],
    boarding_cg.Weight_kg[unloading_point_rows],
    markersize = 6,
    marker = :diamond,
    label = "Unloading points"
)

# Forward/aft CG reference limits
vline!(
    potato_points_plot,
    [fwd_cg_limit_pct],
    linestyle = :dot,
    linewidth = 2,
    label = "Forward CG ref. limit"
)

vline!(
    potato_points_plot,
    [aft_cg_limit_pct],
    linestyle = :dot,
    linewidth = 2,
    label = "Aft CG ref. limit"
)

# Label each point with A, B, C, ...
for i in 1:nrow(boarding_cg)
    annotate!(
        potato_points_plot,
        boarding_cg.CG_percent_MAC[i],
        boarding_cg.Weight_kg[i],
        text(point_labels[i], 8, :left)
    )
end

# ------------------------------------------------------------
# Static margin during loading cases
# ------------------------------------------------------------
sm_loading_plot = plot(
    loading_main.Step_No,
    loading_main.SM_DATCOM_percent,
    marker = :circle,
    linewidth = 2,
    xlabel = "Loading step",
    ylabel = "Static Margin (%)",
    title = "Static Margin During Representative Loading Cases",
    label = "DATCOM",
    xticks = (loading_main.Step_No, loading_main.Step),
    xrotation = 20,
    grid = true
)

plot!(
    sm_loading_plot,
    loading_main.Step_No,
    loading_main.SM_VLM_percent,
    marker = :diamond,
    linewidth = 2,
    label = "VLM"
)

# ------------------------------------------------------------
# Static margin during mission
# ------------------------------------------------------------
sm_mission_plot = plot(
    mission_cg.Mission_progress,
    mission_cg.SM_DATCOM_percent,
    marker = :circle,
    linewidth = 2,
    xlabel = "Mission progress (0 = departure, 1 = final landing)",
    ylabel = "Static Margin (%)",
    title = "Static Margin During Two-Way Mission",
    label = "DATCOM",
    grid = true
)

plot!(
    sm_mission_plot,
    mission_cg.Mission_progress,
    mission_cg.SM_VLM_percent,
    marker = :diamond,
    linewidth = 2,
    label = "VLM"
)

# ------------------------------------------------------------
# Combined CG excursion plot (tidier)
# ------------------------------------------------------------
cg_excursion_plot = plot(
    xlim = (x_min_plot, x_max_plot),
    ylim = (y_min_plot, y_max_plot),
    xlabel = "CG location (%MAC)",
    ylabel = "Aircraft weight (kg)",
    title = "CG Excursion / Envelope Plot",
    legend = :topright,
    grid = true
)

vline!(cg_excursion_plot, [fwd_cg_limit_pct], linestyle = :dash, linewidth = 2, label = "Forward CG ref. limit")
vline!(cg_excursion_plot, [aft_cg_limit_pct], linestyle = :dash, linewidth = 2, label = "Aft CG ref. limit")

plot!(
    cg_excursion_plot,
    loading_main.CG_percent_MAC,
    loading_main.Weight_kg,
    marker = :square,
    linewidth = 2,
    label = "Representative loading cases"
)

plot!(
    cg_excursion_plot,
    mission_cg.CG_percent_MAC,
    mission_cg.Weight_kg,
    marker = :circle,
    linewidth = 2,
    label = "Two-way mission fuel burn"
)

plot!(
    cg_excursion_plot,
    boarding_cg.CG_percent_MAC,
    boarding_cg.Weight_kg,
    marker = :diamond,
    linewidth = 2,
    label = "Boarding / unloading"
)

        # ============================================================
        # WEIGHT AND BALANCE TABLE FOR REPORT EXPORT
        # Does NOT change original x_cg, SM, or VLM SM
        # ============================================================

        g0 = 9.81

        weight_balance_table = DataFrame(
            Component = String[],
            Weight_kg = Float64[],
            Weight_N = Float64[],
            x_cg_m = Float64[],
            Moment_kg_m = Float64[],
            Moment_N_m = Float64[]
        )

        for name in sort(collect(keys(weight_position)))
            W, x = weight_position[name]
            push!(weight_balance_table, (
                name,
                W,
                W * g0,
                x,
                W * x,
                W * g0 * x
            ))
        end

        # Add useful loads for reporting only
# Add useful loads for reporting only
extra_loads = Dict(
    "crew_report" => (W_crew_export, x_crew_export),
    "fuel_full_report" => (W_fuel_export, x_fuel_export),
    "baggage_report" => (W_baggage_export, x_baggage_export),
    "passengers_total_report" => (W_pax_total, x_pax_total)
)

for name in sort(collect(keys(extra_loads)))
    W, x = extra_loads[name]
    push!(weight_balance_table, (
        name,
        W,
        W * g0,
        x,
        W * x,
        W * g0 * x
    ))
end

kg_to_lb = 2.20462262185
m_to_ft = 3.280839895

function group_row(group, component, W, x; note="")
    return (
        group,
        component,
        W,
        x,
        W * x,
        W * kg_to_lb,
        x * m_to_ft,
        W * kg_to_lb * x * m_to_ft,
        note
    )
end

summary_group_weight_statement = DataFrame(
    Group = String[],
    Component = String[],
    Weight_kg = Float64[],
    Loc_m = Float64[],
    Moment_kg_m = Float64[],
    Weight_lb = Float64[],
    Loc_ft = Float64[],
    Moment_ft_lb = Float64[],
    Notes = String[]
)

# Structures group
for comp in ["wing", "htail", "vtail", "fuse", "noseLG", "mainLG"]
    W, x = weight_position[comp]
    push!(summary_group_weight_statement, group_row("Structures", comp, W, x; note="Raymer quick-and-dirty / geometry-based CG"))
end

# Propulsion group
W_eng_installed, x_eng = weight_position["engine"]
push!(summary_group_weight_statement, group_row("Propulsion", "installed engines", W_eng_installed, x_eng; note="1.3 × dry engine weight × 2"))

# Equipment / all-else group
W_other, x_other_group = weight_position["all-else"]
push!(summary_group_weight_statement, group_row("Equipment", "all-else empty", W_other, x_other_group; note="Raymer quick-and-dirty allowance"))

# Useful load group
push!(summary_group_weight_statement, group_row("Useful load", "crew", W_crew_export, x_crew_export; note="4 crew assumed"))
push!(summary_group_weight_statement, group_row("Useful load", "fuel usable", W_fuel_export, x_fuel_export; note="fuel mass from TOGW minus zero-fuel weight"))
push!(summary_group_weight_statement, group_row("Useful load", "passengers", W_pax_total, x_pax_total; note="70 pax × 90 kg"))
push!(summary_group_weight_statement, group_row("Useful load", "baggage", W_baggage_export, x_baggage_export; note="70 pax × 15 kg"))

summary_group_totals = combine(
    groupby(summary_group_weight_statement, :Group),
    :Weight_kg => sum => :Weight_kg,
    :Moment_kg_m => sum => :Moment_kg_m,
    :Weight_lb => sum => :Weight_lb,
    :Moment_ft_lb => sum => :Moment_ft_lb
)

summary_group_totals.Loc_m = summary_group_totals.Moment_kg_m ./ summary_group_totals.Weight_kg
summary_group_totals.Loc_ft = summary_group_totals.Moment_ft_lb ./ summary_group_totals.Weight_lb

# Overall full takeoff loading summary
full_takeoff_items = copy(weight_position)
full_takeoff_items["crew"] = (W_crew_export, x_crew_export)
full_takeoff_items["fuel"] = (W_fuel_export, x_fuel_export)
full_takeoff_items["baggage"] = (W_baggage_export, x_baggage_export)
add_items!(full_takeoff_items, passenger_items_dict())
full_takeoff_cg = cg_export(full_takeoff_items)

        weight_balance_plot = scatter(
            weight_balance_table.x_cg_m,
            weight_balance_table.Weight_kg,
            xlabel = "x-location from nose (m)",
            ylabel = "Weight / mass used in CG calculation (kg)",
            title = "Weight and Balance Component Locations",
            label = false,
            markersize = 5
        )

        for i in 1:nrow(weight_balance_table)
            annotate!(
                weight_balance_table.x_cg_m[i],
                weight_balance_table.Weight_kg[i],
                text(weight_balance_table.Component[i], 7)
            )
        end

        # ============================================================
        # AERODYNAMIC / STABILITY DERIVATIVES SUMMARY
        # ============================================================

        function fmt_val(x; digits=6)
            try
                return string(round(Float64(x), digits=digits))
            catch
                return string(x)
            end
        end

        aero_derivatives_summary = DataFrame(
            Quantity = String[],
            Value = String[],
            Notes = String[]
        )

        push!(aero_derivatives_summary, (
            "Aircraft Cm_alpha (VLM)",
            fmt_val(ac_dvs.Cm_al),
            "Pitching moment derivative with respect to angle of attack"
        ))

        push!(aero_derivatives_summary, (
            "Aircraft CZ_alpha (VLM)",
            fmt_val(ac_dvs.CZ_al),
            "Aircraft vertical-force/lift-related derivative from VLM"
        ))

        push!(aero_derivatives_summary, (
            "Wing CZ_alpha (VLM)",
            fmt_val(dvs.wing.CZ_al),
            "Wing lift-related derivative from VLM"
        ))

        push!(aero_derivatives_summary, (
            "Horizontal tail CZ_alpha (VLM)",
            fmt_val(dvs.htail.CZ_al),
            "Horizontal-tail lift-related derivative from VLM"
        ))

        push!(aero_derivatives_summary, (
            "Wing CL_alpha (DATCOM)",
            fmt_val(CL_α_w),
            "DATCOM wing lift-curve slope"
        ))

        push!(aero_derivatives_summary, (
            "Horizontal tail CL_alpha (DATCOM)",
            fmt_val(CL_α_h),
            "DATCOM horizontal-tail lift-curve slope with downwash correction"
        ))

        push!(aero_derivatives_summary, (
            "dCm/dCL from VLM alpha sweep",
            fmt_val(dCm_dCL_VLM),
            "Linear fit of Cm against CL using low-angle range"
        ))

        push!(aero_derivatives_summary, (
            "Fuselage dCmf/dCL used with DATCOM",
            fmt_val(Cm_f_CL),
            "Fuselage moment-lift derivative using DATCOM wing slope"
        ))

        push!(aero_derivatives_summary, (
            "Fuselage dCmf/dCL used with VLM",
            fmt_val(Cm_fuse_CL),
            "Fuselage moment-lift derivative using VLM wing slope"
        ))

        push!(aero_derivatives_summary, (
            "DATCOM neutral point x_np",
            fmt_val(x_np),
            "Neutral point from DATCOM-style estimate, m from nose"
        ))

        push!(aero_derivatives_summary, (
            "VLM neutral point x_np",
            fmt_val(r_np_vlm.x),
            "Neutral point from VLM Cm-CL slope, m from nose"
        ))

        push!(aero_derivatives_summary, (
            "Empty/component DATCOM static margin",
            fmt_val(100 * SM),
            "Static margin using empty/component CG, %MAC"
        ))

        push!(aero_derivatives_summary, (
            "Empty/component VLM static margin",
            fmt_val(100 * SM_VLM),
            "Static margin using empty/component CG, %MAC"
        ))

        aero_derivatives_summary

        # ============================================================
        # 5) EXPORT
        # ============================================================

        timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
        outdir = "cg_sm_export_" * timestamp
        mkpath(outdir)

        # ============================================================
        # EXPORT FULL VLM DERIVATIVES TABLE AS TEXT FILE
        # ============================================================

        derivatives_file = joinpath(outdir, "vlm_derivatives_full_table.txt")

        open(derivatives_file, "w") do io
            redirect_stdout(io) do
                println("VLM FREESTREAM DERIVATIVES")
                println("="^80)
                println()

                # Re-print the full component derivative tables
                freestream_derivatives(
                    sys,
                    print_components = true,
                    farfield = true
                )

                println()
                println("AIRCRAFT DERIVATIVES ONLY")
                println("="^80)
                println()

                print_derivatives(dvs.aircraft; farfield = true)
            end
        end

        CSV.write(joinpath(outdir, "original_cg_sm_results.csv"), original_results)
        CSV.write(joinpath(outdir, "mission_cg_excursion.csv"), mission_cg)
        CSV.write(joinpath(outdir, "boarding_potato_data.csv"), boarding_cg)
        CSV.write(joinpath(outdir, "weight_balance_table.csv"), weight_balance_table)
        CSV.write(joinpath(outdir, "all_cg_cases.csv"), all_cg_cases)
        CSV.write(joinpath(outdir, "cg_limits.csv"), cg_limits)
        CSV.write(joinpath(outdir, "aero_derivatives_summary.csv"), aero_derivatives_summary)
        CSV.write(joinpath(outdir, "loading_scenarios.csv"), loading_scenarios)
        CSV.write(joinpath(outdir, "summary_group_weight_statement.csv"), summary_group_weight_statement)
        CSV.write(joinpath(outdir, "summary_group_totals.csv"), summary_group_totals)
        CSV.write(joinpath(outdir, "cg_reference_check.csv"), cg_reference_check)
        CSV.write(joinpath(outdir, "potato_points_label_table.csv"), potato_points_label_table)

        open(joinpath(outdir, "aero_derivatives_summary.txt"), "w") do dio
            println(dio, "AERODYNAMIC AND STABILITY DERIVATIVES SUMMARY")
            println(dio, repeat("=", 60))
            println(dio)
            show(dio, aero_derivatives_summary; allrows=true, allcols=true)
            println(dio)
        end


        savefig(loading_cases_plot, joinpath(outdir, "loading_cases_cg_curve.png"))
        savefig(mission_cg_plot, joinpath(outdir, "mission_cg_excursion.png"))
        savefig(mission_only_plot, joinpath(outdir, "mission_only_cg_excursion.png"))
        savefig(potato_plot, joinpath(outdir, "boarding_potato_plot.png"))
        savefig(sm_loading_plot, joinpath(outdir, "static_margin_loading_cases.png"))
        savefig(sm_mission_plot, joinpath(outdir, "static_margin_mission.png"))
        savefig(cg_excursion_plot, joinpath(outdir, "cg_excursion_envelope_plot.png"))
        savefig(weight_balance_plot, joinpath(outdir, "weight_balance_component_locations.png"))
        savefig(potato_points_plot, joinpath(outdir, "boarding_potato_points_only.png"))

        open(joinpath(outdir, "summary.txt"), "w") do io

    function section(title)
        println(io)
        println(io, title)
        println(io, repeat("=", 80))
    end

    function subsection(title)
        println(io)
        println(io, title)
        println(io, repeat("-", 80))
    end

    function print_table(df)
        show(io, df; allrows=true, allcols=true)
        println(io)
        println(io)
    end

    section("CG, STATIC MARGIN, AND LOAD FACTOR SUMMARY")

    println(io, "Empty/component CG          = ", round(pctMAC_export(x_cg), digits=2), " %MAC")
    println(io, "Empty/component DATCOM SM   = ", round(100 * SM, digits=2), " %")
    println(io, "Empty/component VLM SM      = ", round(100 * SM_VLM, digits=2), " %")
    println(io, "DATCOM neutral point        = ", round(x_np_DATCOM_export, digits=4), " m")
    println(io, "VLM neutral point           = ", round(x_np_VLM_export, digits=4), " m")
    println(io, "MAC                         = ", round(c_w, digits=4), " m")
    println(io, "x_LEMAC                     = ", round(x_LEMAC_export, digits=4), " m")

    subsection("Ultimate Load Factor")
    println(io, "TOGW                        = ", round(TOGW, digits=2), " kg")
    println(io, "TOGW                        = ", round(TOGW_lb, digits=2), " lb")
    println(io, "Positive limit load factor  = ", round(n_limit_pos, digits=4))
    println(io, "Ultimate load factor        = ", round(n_ult, digits=4))

    subsection("Mission CG and Static Margin Ranges")
    println(io, "Mission CG range            = ",
        round(minimum(mission_cg.CG_percent_MAC), digits=2), " to ",
        round(maximum(mission_cg.CG_percent_MAC), digits=2), " %MAC")

    println(io, "Mission DATCOM SM range     = ",
        round(minimum(mission_cg.SM_DATCOM_percent), digits=2), " to ",
        round(maximum(mission_cg.SM_DATCOM_percent), digits=2), " %")

    println(io, "Mission VLM SM range        = ",
        round(minimum(mission_cg.SM_VLM_percent), digits=2), " to ",
        round(maximum(mission_cg.SM_VLM_percent), digits=2), " %")

    subsection("Forward and Aft CG Limits")
    print_table(cg_limits)

    subsection("CG Reference Check")
    print_table(cg_reference_check)

    subsection("Full Takeoff Summary")
    println(io, "Full takeoff weight         = ", round(full_takeoff_cg.W, digits=2), " kg")
    println(io, "Full takeoff x_cg           = ", round(full_takeoff_cg.xcg, digits=4), " m")
    println(io, "Full takeoff CG             = ", round(full_takeoff_cg.pctMAC, digits=2), " %MAC")
    println(io, "Full takeoff DATCOM SM      = ", round(sm_datcom_from_xcg(full_takeoff_cg.xcg), digits=2), " %")
    println(io, "Full takeoff VLM SM         = ", round(sm_vlm_from_xcg(full_takeoff_cg.xcg), digits=2), " %")

    subsection("Weight Balance Table")
    print_table(weight_balance_table)

    subsection("Summary Group Totals")
    print_table(summary_group_totals)

    subsection("Summary Group Weight Statement")
    print_table(summary_group_weight_statement)

    subsection("Representative Loading Cases")
    print_table(loading_main)

    subsection("All Loading Scenarios")
    print_table(loading_scenarios)

    subsection("Mission CG Excursion")
    print_table(mission_cg)

    subsection("Boarding Potato Data")
    print_table(boarding_cg)

    subsection("Aerodynamic and Stability Derivatives")
    print_table(aero_derivatives_summary)

    subsection("Boarding Potato Points Label Table")
    print_table(potato_points_label_table)
end

        zipname = outdir * ".zip"
        z = ZipFile.Writer(zipname)

        for file in readdir(outdir; join=true)
            f = ZipFile.addfile(z, basename(file), method=ZipFile.Deflate)
            write(f, read(file))
        end

        close(z)

        println("Export folder created: ", outdir)
        println("ZIP file created: ", zipname)

        original_results, mission_cg, boarding_cg, cg_limits, mission_cg_plot, sm_mission_plot, sm_loading_plot, potato_plot
    end



  

# ╔═╡ 402ead4c-b3e9-4153-baee-1048468e6080
    # The End

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AeroFuse = "477c59f4-51f5-487f-bf1e-8db39645b227"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
AeroFuse = "~0.4.12"
DataFrames = "~1.8.1"
Plots = "~1.41.6"
PlutoUI = "~0.7.80"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.5"
manifest_format = "2.0"
project_hash = "1a60a09201b30836a905f0656174d26f0afae164"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "2eeb2c9bef11013efc6f8f97f32ee59b146b09fb"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.44"

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
git-tree-sha1 = "d8928e9169ff76c6281f39a659f9bca3a573f24c"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.8.1"

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
git-tree-sha1 = "66381d7059b5f3f6162f28831854008040a4e905"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "8.0.1+1"

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
git-tree-sha1 = "70329abc09b886fd2c5d94ad2d9527639c421e3e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.14.3+1"

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
git-tree-sha1 = "44716a1a667cb867ee0e9ec8edc31c3e4aa5afdc"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.24"

    [deps.GR.extensions]
    IJuliaExt = "IJulia"

    [deps.GR.weakdeps]
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "be8a1b8065959e24fdc1b51402f39f3b6f0f6653"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.24+0"

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
version = "2025.11.4"

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
version = "3.5.4+0"

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
git-tree-sha1 = "fbc875044d82c113a9dee6fc14e16cf01fd48872"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.80"

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
git-tree-sha1 = "d7a4bff94f42208ce3cf6bc8e4e7d1d663e7ee8b"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.10.2+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll", "Qt6Svg_jll"]
git-tree-sha1 = "d5b7dd0e226774cbd87e2790e34def09245c7eab"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.10.2+1"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "4d85eedf69d875982c46643f6b4f66919d7e157b"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.10.2+1"

[[deps.Qt6Svg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "81587ff5ff25a4e1115ce191e36285ede0334c9d"
uuid = "6de9746b-f93d-5813-b365-ba18ad4a9cf3"
version = "6.10.2+0"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "672c938b4b4e3e0169a07a5f227029d4905456f2"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.10.2+1"

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
git-tree-sha1 = "b2f70f34eb9973572d55c332933c6a04c911f549"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.2.14"

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
git-tree-sha1 = "2700b235561b0335d5bef7097a111dc513b8655e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.7.2"
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
git-tree-sha1 = "fa95b3b097bcef5845c142ea2e085f1b2591e92c"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.7.1"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
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
git-tree-sha1 = "58972370b81423fc546c56a60ed1a009450177c3"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.19.0+0"

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
git-tree-sha1 = "e2a7072fc0cdd7949528c1455a3e5da4122e1153"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.56+0"

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
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"

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
# ╠═8f7caf16-306c-41e3-a38a-fc8f681a3626
# ╠═07559c60-063b-11f0-1a5c-37ed11f4209e
# ╠═17a7b231-19fb-455b-a93a-687251df87fb
# ╠═d6b41872-bd8e-45d1-baa2-fa0cc36b6177
# ╠═d9ef5002-70d7-40a8-81fa-7a07567eb613
# ╠═a76599c7-563d-4647-8fda-36869d07ff71
# ╠═87f54aa2-861a-44f7-b331-1198f522d1e4
# ╠═c8c3daf0-4e63-49b6-bc07-6ba37f817c5e
# ╠═678f44cb-e7fa-403d-bb45-7ece4195b88b
# ╠═6131d42a-38c5-4af5-b065-ba022852146c
# ╠═618ba8c3-8d46-4ef3-a038-5ecdb21eab03
# ╠═77be2a32-09fb-4f8e-8aca-09bad314e790
# ╠═38c60ab8-cf05-4051-a5a8-e35ffae7e50c
# ╠═335a090d-a50c-4f9c-a23a-a32b8ff6de34
# ╠═9d59c6d6-0e2e-40be-aedb-2ea21f6639a8
# ╠═4b84579b-3a9f-43e8-88bc-879cd950f657
# ╠═3e31ace1-1073-49b8-936b-1d5da789b895
# ╠═5baf5f31-eba8-42eb-9d62-96ce53c7cac8
# ╠═12d6baf4-c15b-46e8-8be3-0cc52fc9267b
# ╠═c7d034c8-d72f-461e-93e6-603a9c8f4c62
# ╠═0d0e82f3-d489-4abc-8887-3e557380d21e
# ╠═fb46cb05-f84c-4554-93cb-5491ebdc9eb0
# ╠═d90d5231-8680-4d24-ac39-be9e2d532c10
# ╠═25f56a3b-b8f8-4304-969d-7a4e49c338ea
# ╠═9be9d09b-a563-49a7-a6c8-72adcbf3a840
# ╠═b849f0aa-6391-4945-8ef3-70907a9ff1ec
# ╠═4b754590-3137-4400-a1a9-bd99135aee4d
# ╠═ef4431d6-5113-4e77-b549-62b0f6444a39
# ╠═532e2bf5-2ab9-4efb-84a3-3ab16b6ea81b
# ╠═2b098bef-934b-40fa-8da5-f08d032aa0e4
# ╠═7f9790ab-a1af-4de3-8375-44d11d784bf7
# ╠═04f96ffb-aa30-4bf5-918f-ba1d8528768f
# ╠═c559cb5f-a016-43a0-8596-89f006245b4f
# ╠═8026eb26-010f-487b-bd6d-e82939d09d54
# ╠═28739577-e9fd-48f2-8f55-a036b560931d
# ╠═4d5e821d-ef92-4f84-92c6-27aa12308be9
# ╠═704943ec-10e2-4c50-994b-4688a99ac6c7
# ╠═a95b7c43-2db3-45fa-8bcb-9eab971fe0af
# ╠═9072dc86-1f9f-48c5-8b11-31bf722223f2
# ╠═04750bc6-5e32-4182-8c58-805d902bc6b4
# ╠═9f330052-b13c-4a11-84e9-95ee1d404e9e
# ╠═ae2b717e-3102-4954-9f02-763e96794762
# ╠═25fba8e3-b444-424d-b839-836ab64d76ac
# ╠═add41f70-5744-494f-8324-726fa5d9bb27
# ╠═0c13b5ef-8a2e-4cb9-a246-69f66db9b92f
# ╠═888b4f11-37ba-43df-984b-a887563142ff
# ╠═1be5a6b2-994a-44b0-8b13-5bbb1fffecd9
# ╠═69f762a3-9a0c-4480-a300-30c3a3914d36
# ╠═18a16755-03be-483b-8fb2-51a4fa78bf68
# ╠═1d16ebec-add7-4d22-854e-cf92d45fc2a3
# ╠═cd504799-eb4d-4518-9da6-a1ed95c9c9e6
# ╠═e531ec16-57df-4d07-b913-8bb5569a4bf9
# ╠═c159f556-4443-4077-acf2-2c11422cf86a
# ╠═70f129d3-ffa8-4019-bd53-34185ad85356
# ╠═a3924235-a17d-463a-b1f4-4bd8f715fe5f
# ╠═5b12700f-a0ad-4f29-afc7-649ce6c1dfc4
# ╠═ae708986-6529-4069-904e-60858905f319
# ╠═0567a709-6420-44f6-908f-28c283bbaecf
# ╠═9e9f2802-c8ee-4df4-b643-ee3a271e2986
# ╠═a8ff3d5c-53cf-47a7-a074-f1a9a9a085e7
# ╠═0850f920-ae2e-49b7-baad-4be55fb1e917
# ╠═249e14f7-caaf-4e52-9698-d402fd83e67f
# ╠═54fd4ba7-39eb-40a2-9006-5813437cdfb2
# ╠═1cb4658c-16ac-412b-8dfb-49778f7fe78a
# ╠═6468ecea-d228-4789-a8dd-74b053aa0047
# ╠═816c7fef-e74a-4628-a81a-878b53a1d9ab
# ╠═5fcf1f4b-ff6a-4458-b253-21c9a2f1f4a4
# ╠═26df6f87-cb16-49c7-b7da-b7d18f793d9d
# ╠═14daf923-a87c-4e32-853f-51aabff2794b
# ╠═693c8ac5-8d90-4427-ba1d-a787224245c4
# ╠═6949b7fb-9e9b-4cf4-a6e9-8e4f4c8a0445
# ╠═d4213288-b448-4783-a3bc-78c2fb25b4a6
# ╠═cba370b6-b8c8-44d8-970b-a178602d596f
# ╠═f87881bb-7eeb-4ded-b9e4-21a72410872e
# ╠═ff8adfc7-59ea-4f46-b102-ec09a039bd55
# ╠═cd9bc398-9f62-4a93-90bf-bf9896abbb2e
# ╠═c4bdfa4e-e4bb-4ba8-9a64-80c867a2ed99
# ╠═e0fe156d-7748-4585-bb80-c0c487af76cf
# ╠═d53fa5b1-eadb-4bc5-a00e-55308f55fac0
# ╠═cc80f43c-b0fb-4f2f-9f8f-7b3fed86405d
# ╠═aa2e3ac0-fb90-43a0-8177-c6cf1a2019b4
# ╠═49dec81f-909e-4a05-b8be-a72231b47a85
# ╠═a79b738f-90ca-4213-a89f-80e2dfce2fa5
# ╠═7b1e3dc7-423c-4c4a-9ffd-be54fe991c47
# ╠═92ab5a18-eeb0-44ff-a20a-b12b3093aa43
# ╠═23d5c748-d77c-4252-add0-deade4f4a416
# ╠═0a763717-9f1b-4c6d-98ed-95029d01f509
# ╠═40e02dbd-fcd4-4297-ab3b-bc5b3d71717a
# ╠═dff70e54-4ea9-4edf-a3ca-2f7c765b624f
# ╠═4deac195-47c6-4053-9812-cac86eb34913
# ╠═fe494a18-44d3-4342-beea-a6ac891066af
# ╠═e74c66b7-287d-46ed-9e5b-a241fe06055a
# ╠═62df7c3a-4667-41a6-98b3-aa330519a41a
# ╠═23db0b3d-f844-4889-8386-79126a19093b
# ╠═e07d5942-bb5e-41cc-9deb-369c25ef6c2e
# ╠═0c8b15b1-d848-47f3-ab7d-bd8f254970b0
# ╠═bf08b856-d9d8-4fdc-876e-9950dc549f6e
# ╠═133329d8-cd89-46ab-8691-81cbfeb72649
# ╠═f71f0b50-161e-4ca3-bbd7-73a8691ee2b6
# ╠═7a8932d4-1470-47f1-a598-192ccfa66d94
# ╠═929142bd-0ab7-4c89-b3f1-e0bc652caa09
# ╠═dc65ebaa-cd46-4763-bf96-7210f6bc620b
# ╠═deb15310-a7ef-4291-990e-c4bba8e5c176
# ╠═bb607eb8-b337-4320-8c4a-629a26796eca
# ╠═47dd8354-5778-460b-84a5-93fa8ca796a1
# ╠═80c18169-5f8d-4665-9320-270aa20e926a
# ╠═e9318a7c-125c-4db1-a220-eb0d6de00212
# ╠═5f7738d8-367c-40fc-87f0-f6732623392d
# ╠═aa1ac62e-244d-4fc3-8543-0db8104e740a
# ╠═d3dc7232-ab8b-408d-a8d4-d1cf443afe52
# ╠═777ee0ce-64fa-4dfe-91f1-ca7d8f61a7a4
# ╠═41a1dda8-275e-4090-bcd8-5670b4d005a7
# ╠═8f269b3f-90e8-4cd1-a05a-4fbc63de1cdb
# ╠═4e2cf07e-a5c6-464d-ba5e-c3ee0c7098e3
# ╠═26d51540-49e4-44b3-af4d-62478d6327e2
# ╠═41028657-878a-4f99-83dc-060a8b95a78a
# ╠═ca7d7dc1-8ec7-4480-99da-5aa0695c84dd
# ╠═be3485c9-2aec-41f3-8c05-5d6ceadd787d
# ╠═cc237b8a-f912-46b9-8ea1-b68a04bb322c
# ╠═ce4faad3-c7d1-4fa1-b907-305e1ffb0206
# ╠═eb8954a0-f8da-4825-b0a9-bc13f2b53ebe
# ╠═4f0aac7f-2b19-4a45-ad01-36626d594f42
# ╠═0f45f2a6-0aa7-4c58-9b1e-4c538584f4e9
# ╠═04b8750c-87ce-4063-a8d5-388f2e08aaa6
# ╠═43fcac01-3590-4560-aefd-5881f1fd2f76
# ╠═f2ae1eaa-0844-4c8c-9939-298661195d72
# ╠═24435be1-39d8-43d8-8ff6-cf8e4a3b954c
# ╠═78da147a-7b02-4751-b558-955217089dbd
# ╠═7ef0b6d0-b55d-4552-aeec-fada357b377d
# ╠═82768f65-3f44-4184-86dc-1715cfe5677d
# ╠═68887c8c-9346-4bab-9c76-588adecac9eb
# ╠═f033373f-1d24-4ddd-9bb8-93c6363bcbaf
# ╠═87ced096-5bba-4b5d-9ddf-247b43fd97f9
# ╠═a02429ea-3366-4d06-9c11-4044048569a6
# ╠═20c9112d-84db-42e1-aa33-5bf9f6ea016b
# ╠═3d38e9d2-7319-4b4b-ab7c-bcb3d475d17f
# ╠═65efafc2-3f58-40ac-9ecf-81bf0b133205
# ╠═4b235b39-43c0-44db-afe0-29306e59e50f
# ╠═de870ed8-944f-438e-8cf8-d951d96797d9
# ╠═e7a0bccb-d292-48b5-bcb7-3a4cb53f065f
# ╠═7fbb061f-a9ef-47bd-9989-37119e4e6b88
# ╠═88c47f03-fa83-497a-8738-a4a0f47cf966
# ╠═26513f85-c5d5-42aa-bdb2-7e8353cada30
# ╠═532a497e-0faf-450b-89ff-9e0482a94a94
# ╠═3e947f88-dfe4-4425-a0cf-cb609aa574c0
# ╠═936bad10-c8ca-4911-af6c-c8cb7926f2cf
# ╠═a68fe0b6-eb1c-4df6-9c19-e0057dfe2208
# ╠═45cd25ad-fa8c-44d3-a3d1-1a9043dbff03
# ╠═143d4eb1-3e19-4ca8-8bea-e0d35bf69761
# ╠═17c59c56-d2aa-44d9-8658-bd323b7d50b7
# ╠═a9cc0876-a907-4b39-bf8b-5c1c8f92258a
# ╠═5e2bfe78-d6ec-4bc1-bd24-460176ea2936
# ╠═12d48e84-bd6f-4efc-a265-e64234183650
# ╠═b710c3fa-a48d-4c0a-841e-bc3332cd5bf7
# ╠═cbdf5265-1c2b-4bbc-a458-18fba0c9d376
# ╠═402ead4c-b3e9-4153-baee-1048468e6080
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

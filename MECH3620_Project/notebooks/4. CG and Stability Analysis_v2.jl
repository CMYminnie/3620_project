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
    end;

    # ╔═╡ d6b41872-bd8e-45d1-baa2-fa0cc36b6177
    md"""### Wing
    First, you can define the wing from your preliminary wing sizing. Here, we'll choose a supercritical airfoil for the wing section. **This is not the same one as used in the Boeing 777-200LR.**
    """

    # ╔═╡ d9ef5002-70d7-40a8-81fa-7a07567eb613
    begin
    foil_w_root = read_foil("Airfoil\\NASA SC(2)-0714.txt") # Read the root airfoil
    foil_w_tip  = read_foil("Airfoil\\NASA SC(2)-0714.txt")#Read the tip airfoil
    end

    # ╔═╡ a76599c7-563d-4647-8fda-36869d07ff71
    plot(foil_w_root, aspect_ratio = 1)

    # ╔═╡ 87f54aa2-861a-44f7-b331-1198f522d1e4
    md"""Here, we'll define a two-section wing planform that we'll use in this notebook."""

    # ╔═╡ c8c3daf0-4e63-49b6-bc07-6ba37f817c5e
    wing = Wing(
        foils       = [foil_w_root, foil_w_root, foil_w_tip],              # Airfoils
        chords 		= [5.1655749037, 3.427880928, 1.690012819],  	# Chord lengths 
        spans       = [5.0, 7.915],             # Span lengths
        dihedrals   = [5.0, 7.0],               # Dihedral angles (deg)
        sweeps      = [30.0, 30.0],             # Sweep angles (deg )
        w_sweep     = 0.0,                      # Leading-edge sweep
        position    = [10, 0.0, -1.0],      	 # HOW DO YOU DETERMINE THIS?
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
            l_fuse   = 28.83
            l_nose   = 4.94
            l_tail   = 4.80
            l_cabin  = 18.62

            x_a_cabin = l_nose / l_fuse
            x_b_cabin = (l_nose + l_cabin) / l_fuse

            fuse = HyperEllipseFuselage(
                radius   = df_outer / 2,   # 1.605 m
                length   = l_fuse,         # 28.83 m
                x_a      = x_a_cabin,      # start of cabin
                x_b      = x_b_cabin,      # end of cabin
                c_nose   = 1.3,
                c_rear   = 1.2,
                d_nose   = -0.09,
                d_rear   = -0.37,
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

    # ╔═╡ 704943ec-10e2-4c50-994b-4688a99ac6c7
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
        TOGW = 33614.1 # Takeoff gross weight, kg
        W_engine = 1179 # GE90-110B1 engine weight (single), kg
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

    # ============================================================
    # NORMALISE AIRFRAME WEIGHTS TO FINAL REFINED EMPTY WEIGHT
    # Engine mass is kept fixed.
    # ============================================================

    fuel_fraction_final = 0.28658

    W_payload_final = 7350.0
    W_crew_final = 360.0
    W_fuel_final = fuel_fraction_final * TOGW

    # Empty weight target required by final MTOW and round-trip fuel
    W_empty_target = TOGW - W_payload_final - W_crew_final - W_fuel_final

    # Keep engine fixed because it comes from selected engine data
    fixed_components = ["engine"]

    W_fixed = sum(weight_position[name][1] for name in fixed_components)

    W_scalable_current = sum(
        w for (name, (w, x)) in weight_position
        if !(name in fixed_components)
    )

    W_scalable_target = W_empty_target - W_fixed

    airframe_scale = W_scalable_target / W_scalable_current

    println("Target empty weight       = ", round(W_empty_target, digits=2), " kg")
    println("Fixed engine weight       = ", round(W_fixed, digits=2), " kg")
    println("Scalable current weight   = ", round(W_scalable_current, digits=2), " kg")
    println("Scalable target weight    = ", round(W_scalable_target, digits=2), " kg")
    println("Airframe scale factor     = ", round(airframe_scale, digits=4))

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
        # 2) MISSION CG EXCURSION
        # Uses mission result: total fuel fraction with trapped = 28.658%
        # ============================================================

        x_fuel_export = mac40_w.x
        # ============================================================
        # FUEL WEIGHT CONSISTENT WITH TOGW
        # ============================================================

        zero_fuel_items = copy(weight_position)

        zero_fuel_items["crew"] = (W_crew_export, x_crew_export)
        zero_fuel_items["baggage"] = (W_baggage_export, x_baggage_export)
        zero_fuel_items["pax_forward"] = (W_pax_fwd, x_pax_fwd)
        zero_fuel_items["pax_middle"] = (W_pax_mid, x_pax_mid)
        zero_fuel_items["pax_aft"] = (W_pax_aft, x_pax_aft)

        zero_fuel_cg = cg_export(zero_fuel_items)
        W_zero_fuel = zero_fuel_cg.W

        W_fuel_export = TOGW - W_zero_fuel

        if W_fuel_export < 0
            error("Zero-fuel weight exceeds TOGW. Reduce OEW/payload or increase TOGW.")
        end

        println("Zero-fuel weight = ", round(W_zero_fuel, digits=2), " kg")
        println("Fuel allowed by TOGW = ", round(W_fuel_export, digits=2), " kg")
        println("Fuel fraction = ", round(W_fuel_export / TOGW * 100, digits=2), " %")

        final_beta = 0.8541905037739782

        mission_defs = [
            ("Start / full fuel",               1.0000000000),
            ("After warm-up",                  0.9900000000),
            ("After taxi",                     0.9801000000),
            ("After takeoff",                  0.9751995000),
            ("After climb",                    0.9556955100),
            ("After outbound cruise",          0.8904030708),
            ("After loiter",                   0.8697770000),
            ("After descent",                  0.8610790000),
            ("After landing",                  0.8541905038)
        ]

        # ============================================================
        # USEFUL LOAD DEFINITIONS
        # ============================================================

        W_pax_each = 90.0
        W_bag_each = 15.0
        W_crew_each = 90.0

        n_crew = 4   # change if your design assumes 2, 3, or 4 crew

        W_crew_export = n_crew * W_crew_each
        x_crew_export = 0.55 * l_nose

        W_pax_fwd = 20 * W_pax_each
        W_pax_mid = 25 * W_pax_each
        W_pax_aft = 25 * W_pax_each
        W_baggage_export = 70 * W_bag_each

        x_pax_fwd = l_nose + 0.20 * l_cabin
        x_pax_mid = l_nose + 0.50 * l_cabin
        x_pax_aft = l_nose + 0.80 * l_cabin
        x_baggage_export = l_nose + 0.70 * l_cabin

        mission_cg = DataFrame(
            Phase = String[],
            Beta = Float64[],
            Fuel_remaining_fraction = Float64[],
            Weight_kg = Float64[],
            x_cg_m = Float64[],
            CG_percent_MAC = Float64[],
            SM_DATCOM_percent = Float64[],
            SM_VLM_percent = Float64[]
        )

        for (phase, beta) in mission_defs
            items = copy(weight_position)

            # Add payload and crew for the flight mission
            items["crew"] = (W_crew_export, x_crew_export)
            items["baggage"] = (W_baggage_export, x_baggage_export)
            items["pax_forward"] = (W_pax_fwd, x_pax_fwd)
            items["pax_middle"] = (W_pax_mid, x_pax_mid)
            items["pax_aft"] = (W_pax_aft, x_pax_aft)

            # Add remaining mission fuel
            fuel_remaining_fraction = (beta - final_beta) / (1.0 - final_beta)
            fuel_remaining_fraction = clamp(fuel_remaining_fraction, 0.0, 1.0)

            items["fuel"] = (W_fuel_export * fuel_remaining_fraction, x_fuel_export)

            cg = cg_export(items)

            push!(mission_cg, (
                phase,
                beta,
                fuel_remaining_fraction,
                cg.W,
                cg.xcg,
                cg.pctMAC,
                100 * (x_np_DATCOM_export - cg.xcg) / c_w,
                100 * (x_np_VLM_export - cg.xcg) / c_w
            ))
        end

        # ============================================================
        # 3) BOARDING POTATO PLOT
        # Uses existing l_nose and l_cabin from your file
        # ============================================================

        W_pax_each = 90.0
        W_bag_each = 15.0

        W_pax_fwd = 20 * W_pax_each
        W_pax_mid = 25 * W_pax_each
        W_pax_aft = 25 * W_pax_each
        W_baggage_export = 70 * W_bag_each

        x_pax_fwd = l_nose + 0.20 * l_cabin
        x_pax_mid = l_nose + 0.50 * l_cabin
        x_pax_aft = l_nose + 0.80 * l_cabin
        x_baggage_export = l_nose + 0.70 * l_cabin

        base_boarding = copy(weight_position)
        base_boarding["fuel"] = (W_fuel_export, x_fuel_export)
        base_boarding["baggage"] = (W_baggage_export, x_baggage_export)
        base_boarding["crew"] = (W_crew_export, x_crew_export)

        function boarding_export(sequence_name, sequence)
            items = copy(base_boarding)

            df = DataFrame(
                Sequence = String[],
                Step = String[],
                Weight_kg = Float64[],
                x_cg_m = Float64[],
                CG_percent_MAC = Float64[]
            )

            cg = cg_export(items)
            push!(df, (sequence_name, "Start: crew + fuel + baggage", cg.W, cg.xcg, cg.pctMAC))

            for (step_name, pax_item) in sequence
                items[step_name] = pax_item
                cg = cg_export(items)
                push!(df, (sequence_name, step_name, cg.W, cg.xcg, cg.pctMAC))
            end

            return df
        end

        front_to_back = boarding_export("Front to back", [
            ("Forward cabin", (W_pax_fwd, x_pax_fwd)),
            ("Middle cabin",  (W_pax_mid, x_pax_mid)),
            ("Aft cabin",     (W_pax_aft, x_pax_aft))
        ])

        back_to_front = boarding_export("Back to front", [
            ("Aft cabin",     (W_pax_aft, x_pax_aft)),
            ("Middle cabin",  (W_pax_mid, x_pax_mid)),
            ("Forward cabin", (W_pax_fwd, x_pax_fwd))
        ])

        boarding_cg = vcat(front_to_back, back_to_front)

                # ============================================================
        # FORWARD AND AFT CG LIMITS FROM CONSIDERED CASES
        # Mission fuel-burn + boarding potato plot
        # ============================================================

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
            Case = boarding_cg.Sequence .* " - " .* boarding_cg.Step,
            Weight_kg = boarding_cg.Weight_kg,
            x_cg_m = boarding_cg.x_cg_m,
            CG_percent_MAC = boarding_cg.CG_percent_MAC,
            SM_DATCOM_percent = 100 .* (x_np_DATCOM_export .- boarding_cg.x_cg_m) ./ c_w,
            SM_VLM_percent = 100 .* (x_np_VLM_export .- boarding_cg.x_cg_m) ./ c_w
        )

        all_cg_cases = mission_cases

        # Smaller %MAC = forward CG, larger %MAC = aft CG
        fwd_idx = argmin(all_cg_cases.CG_percent_MAC)
        aft_idx = argmax(all_cg_cases.CG_percent_MAC)

        cg_limits = DataFrame(
            Limit = ["Forward CG limit", "Aft CG limit"],
            Source = [all_cg_cases.Source[fwd_idx], all_cg_cases.Source[aft_idx]],
            Critical_case = [all_cg_cases.Case[fwd_idx], all_cg_cases.Case[aft_idx]],
            Weight_kg = [all_cg_cases.Weight_kg[fwd_idx], all_cg_cases.Weight_kg[aft_idx]],
            x_cg_m = [all_cg_cases.x_cg_m[fwd_idx], all_cg_cases.x_cg_m[aft_idx]],
            CG_percent_MAC = [all_cg_cases.CG_percent_MAC[fwd_idx], all_cg_cases.CG_percent_MAC[aft_idx]],
            SM_DATCOM_percent = [all_cg_cases.SM_DATCOM_percent[fwd_idx], all_cg_cases.SM_DATCOM_percent[aft_idx]],
            SM_VLM_percent = [all_cg_cases.SM_VLM_percent[fwd_idx], all_cg_cases.SM_VLM_percent[aft_idx]]
        )

        cg_limits

        # ============================================================
        # 4) PLOTS
        # ============================================================

        mission_cg_plot = plot(
            mission_cg.CG_percent_MAC,
            mission_cg.Weight_kg,
            marker = :circle,
            xlabel = "CG (%MAC)",
            ylabel = "Aircraft Weight (kg)",
            title = "Mission CG Excursion",
            label = "Fuel burn"
        )

        sm_plot = plot(
            mission_cg.CG_percent_MAC,
            mission_cg.SM_DATCOM_percent,
            marker = :circle,
            xlabel = "CG (%MAC)",
            ylabel = "Static Margin (%)",
            title = "Static Margin During Mission",
            label = "DATCOM"
        )

        plot!(
            mission_cg.CG_percent_MAC,
            mission_cg.SM_VLM_percent,
            marker = :diamond,
            label = "VLM"
        )

        potato_plot = plot(
            front_to_back.CG_percent_MAC,
            front_to_back.Weight_kg,
            marker = :circle,
            xlabel = "CG (%MAC)",
            ylabel = "Aircraft Weight (kg)",
            title = "Boarding Potato Plot",
            label = "Front to back"
        )

        plot!(
            back_to_front.CG_percent_MAC,
            back_to_front.Weight_kg,
            marker = :diamond,
            label = "Back to front"
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
        extra_loads = Dict(
            "crew_report" => (W_crew_export, x_crew_export),
            "fuel_full_report" => (W_fuel_export, x_fuel_export),
            "baggage_report" => (W_baggage_export, x_baggage_export),
            "pax_forward_report" => (W_pax_fwd, x_pax_fwd),
            "pax_middle_report" => (W_pax_mid, x_pax_mid),
            "pax_aft_report" => (W_pax_aft, x_pax_aft)
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

        open(joinpath(outdir, "aero_derivatives_summary.txt"), "w") do dio
            println(dio, "AERODYNAMIC AND STABILITY DERIVATIVES SUMMARY")
            println(dio, repeat("=", 60))
            println(dio)
            show(dio, aero_derivatives_summary; allrows=true, allcols=true)
            println(dio)
        end
        savefig(weight_balance_plot, joinpath(outdir, "weight_balance_component_locations.png"))

        savefig(mission_cg_plot, joinpath(outdir, "mission_cg_excursion.png"))
        savefig(sm_plot, joinpath(outdir, "static_margin_during_mission.png"))
        savefig(potato_plot, joinpath(outdir, "boarding_potato_plot.png"))

        open(joinpath(outdir, "summary.txt"), "w") do io

            function section(title)
                println(io)
                println(io, title)
                println(io, repeat("=", 60))
            end

            function subsection(title)
                println(io)
                println(io, title)
                println(io, repeat("-", 60))
            end

            function print_table(df)
                show(io, df; allrows=true, allcols=true)
                println(io)
                println(io)
            end

            section("CG AND STATIC MARGIN SUMMARY")

            println(io, "Empty/component CG       = ", round(pctMAC_export(x_cg), digits=2), " %MAC")
            println(io, "Empty/component DATCOM SM = ", round(100 * SM, digits=2), " %")
            println(io, "Empty/component VLM SM    = ", round(100 * SM_VLM, digits=2), " %")

            println(io)
            println(io, "Mission CG range          = ",
                round(minimum(mission_cg.CG_percent_MAC), digits=2), " to ",
                round(maximum(mission_cg.CG_percent_MAC), digits=2), " %MAC")

            println(io, "Mission DATCOM SM range   = ",
                round(minimum(mission_cg.SM_DATCOM_percent), digits=2), " to ",
                round(maximum(mission_cg.SM_DATCOM_percent), digits=2), " %")

            println(io, "Mission VLM SM range      = ",
                round(minimum(mission_cg.SM_VLM_percent), digits=2), " to ",
                round(maximum(mission_cg.SM_VLM_percent), digits=2), " %")
            println(io, "DATCOM NP    = ", round(x_np_DATCOM_export, digits=4), " m")
            println(io, "VLM NP       = ", round(x_np_VLM_export, digits=4), " m")
            println(io, "MAC          = ", round(c_w, digits=4), " m")
            println(io, "x_LEMAC      = ", round(x_LEMAC_export, digits=4), " m")

            subsection("Forward and Aft CG Limits")
            print_table(cg_limits)

            subsection("Mission CG Excursion")
            print_table(mission_cg)

            subsection("Boarding Potato Plot Data")
            print_table(boarding_cg)

            subsection("Weight and Balance Table")
            print_table(weight_balance_table)

            subsection("Aerodynamic and Stability Derivatives")
            print_table(aero_derivatives_summary)

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

        original_results, mission_cg, boarding_cg, cg_limits, mission_cg_plot, sm_plot, potato_plot
    end




    # ╔═╡ 402ead4c-b3e9-4153-baee-1048468e6080
    # The End.
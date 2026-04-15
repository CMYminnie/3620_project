# ================================================
# MECH3620 Notebook 初始化
# 每次打开 notebook 运行一次（不重复安装）
# ================================================

println("="^60)
println("MECH3620 Loading modules...")
println("="^60)

# 1. 导入已安装的包
using PyCall
using DataFrames
using Plots


# 2. 检查 PyCall 配置
if !@isdefined(PyCall) || PyCall.python == ""
    println("[WARN] PyCall not configured! Please run setup.bat first")
else
    println("[OK] PyCall: $(PyCall.python)")
end

# 3. 添加 Python 模块路径
project_root = dirname(@__DIR__)
ta_code_path = joinpath(project_root, "TA_code")
println("TA_code path: $ta_code_path")
println("TA_code exists: $(isdir(ta_code_path))")

py"""
import sys
import os

ta_code_path = $(ta_code_path)

if os.path.exists(ta_code_path) and ta_code_path not in sys.path:
    sys.path.insert(0, ta_code_path)
    print(f"Added path: {ta_code_path}\n")
"""

# 4. 导入函数（修正版）
println("\nImporting functions...")

# 先尝试直接导入模块
try
    global mech3620 = pyimport("mech3620_models")
    println("[OK] Imported mech3620_models module")
    
    # 检查模块中有哪些可用函数/类
    println("Available in mech3620_models:")
    for name in names(mech3620)
        if !startswith(string(name), "_")
            println("  - ", name)
        end
    end
    
catch e
    println("[ERROR] Cannot import mech3620_models: $e")
end

# 导入具体函数（根据实际名称）
if @isdefined(mech3620)
    # 尝试获取 calc_thrust_lapse
    if hasproperty(mech3620, :calc_thrust_lapse)
        global calc_thrust_lapse = mech3620.calc_thrust_lapse
        println("[OK] calc_thrust_lapse loaded")
    else
        println("[WARN] calc_thrust_lapse not found")
    end
    
    # 尝试获取 US_Standard_1976_Atmosphere（注意大小写）
    if hasproperty(mech3620, :US_Standard_1976_Atmosphere)
        global US_Standard_1976_Atmosphere = mech3620.US_Standard_1976_Atmosphere
        println("[OK] US_Standard_1976_Atmosphere loaded")
    elseif hasproperty(mech3620, :US_Standard_1976_Atmosphere)
        global atmosphere = US_Standard_1976_Atmosphere() 
        println("[OK] US_Standard_1976_Atmosphere loaded")
    else
        println("[WARN] US_Standard_1976_Atmosphere not found")
    end
    
    try
        global calculate_time_to_climb = pyimport("mech3620_sanity_check").calculate_time_to_climb
        println("[OK] calculate_time_to_climb loaded")
    catch e
        println("[WARN] calculate_time_to_climb not found: $e")
    end
    # 尝试获取 calc_TOP_given_BFL_requirement
    if hasproperty(mech3620, :calc_TOP_given_BFL_requirement)
        global calc_TOP = mech3620.calc_TOP_given_BFL_requirement
        println("[OK] calc_TOP_given_BFL_requirement loaded")
    elseif hasproperty(mech3620, :calc_TOP)
        global calc_TOP = mech3620.calc_TOP
        println("[OK] calc_TOP loaded")
    else
        println("[WARN] calc_TOP function not found")
    end
end

# 5. 创建大气实例（如果类存在）
if @isdefined(US_Standard_1976_Atmosphere)
    global atmosphere = US_Standard_1976_Atmosphere()
    println("[OK] Atmosphere instance created")
else
    println("[WARN] Cannot create atmosphere instance")
end

println("\n" * "="^60)
println("Initialization complete!")
println("="^60)

# 显示可用的函数
println("\nAvailable functions/variables:")
if @isdefined(calc_thrust_lapse)
    println("  ✓ calc_thrust_lapse")
end
if @isdefined(US_Standard_1976_Atmosphere)
    println("  ✓ US_Standard_1976_Atmosphere (class)")
end
if @isdefined(atmosphere)
    println("  ✓ atmosphere (instance)")
end
if @isdefined(calc_TOP)
    println("  ✓ calc_TOP")
end
println("="^60)
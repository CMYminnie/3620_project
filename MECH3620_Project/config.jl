# config.jl - 自动配置，用户无需修改
using PyCall

println("🔧 Loading MECH3620 configuration...")

# 查找 mech3620_models 模块
function find_module()
    search_paths = [
        pwd(),
        @__DIR__,
        joinpath(@__DIR__, "notebooks"),
        joinpath(homedir(), "MECH3620_Project"),
    ]
    
    for path in search_paths
        if isfile(joinpath(path, "mech3620_models.py"))
            return path
        end
    end
    return nothing
end

module_path = find_module()

if module_path === nothing
    println("❌ Cannot find mech3620_models.py")
    println("Please make sure the file is in:")
    println("  - Current folder")
    println("  - The folder where you extracted the project")
    error("Module not found")
end

# 添加路径并导入
py"""
import sys
sys.path.insert(0, $module_path)
import mech3620_models
"""
calc_thrust_lapse = pyimport("mech3620_models").calc_thrust_lapse

println("✅ Configuration loaded successfully!")
println("   Module found at: $module_path")
println("   Ready to use calc_thrust_lapse()")
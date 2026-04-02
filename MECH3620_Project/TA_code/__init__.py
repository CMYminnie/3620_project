# python_modules/__init__.py
"""
MECH3620 Python Modules Package
"""

# 导入所有模块，方便统一使用
from .mech3620_models import (
    calc_thrust_lapse,
    US_Standard_1976_Atmosphere,        # 👈 添加这个类
    calc_TOP_given_BFL_requirement      # 👈 添加这个函数
)
from .mech3620_sanity_check import calculate_time_to_climb  # 👈 添加

# 定义包暴露的内容
__all__ = [
    'calc_thrust_lapse',
    'US_Standard_1976_Atmosphere',       # 👈 添加
    'calc_TOP_given_BFL_requirement',    # 👈 添加
    'lift_coefficient', 
    'drag_coefficient',
    'thrust',
    'specific_impulse',
    'helper_function'
]
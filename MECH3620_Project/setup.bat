@echo off
setlocal enabledelayedexpansion

echo ========================================
echo MECH3620 Environment Setup
echo ========================================
echo.

cd /d "%~dp0"
echo 📁 Working directory: %cd%
echo.

if not exist "environment.yml" (
    echo ❌ environment.yml not found!
    pause
    exit /b 1
)

REM ============================================
REM 自动查找 Conda
REM ============================================
set CONDA_PATH=

where conda >nul 2>nul
if !errorlevel! equ 0 (
    for /f "delims=" %%i in ('where conda') do (
        set CONDA_PATH=%%i
        goto :found_conda
    )
)

set "USER_CONDA=C:\Users\%USERNAME%\miniconda3\Scripts\conda.exe"
if exist "!USER_CONDA!" set CONDA_PATH=!USER_CONDA! & goto :found_conda

set "USER_CONDA=C:\Users\%USERNAME%\anaconda3\Scripts\conda.exe"
if exist "!USER_CONDA!" set CONDA_PATH=!USER_CONDA! & goto :found_conda

set "PROG_CONDA=C:\ProgramData\miniconda3\Scripts\conda.exe"
if exist "!PROG_CONDA!" set CONDA_PATH=!PROG_CONDA! & goto :found_conda

set "PROG_CONDA=C:\ProgramData\anaconda3\Scripts\conda.exe"
if exist "!PROG_CONDA!" set CONDA_PATH=!PROG_CONDA! & goto :found_conda

echo ❌ Conda not found!
echo Please install Miniconda from: https://docs.conda.io/en/latest/miniconda.html
pause
exit /b 1

:found_conda
echo ✅ Found Conda: !CONDA_PATH!
echo.

REM 检查 Julia
where julia >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Julia not found!
    echo Please install Julia from: https://julialang.org/downloads/
    pause
    exit /b 1
)

echo ✅ Found Julia
echo.

REM ============================================
REM 创建环境
REM ============================================
echo 📦 Setting up conda environment...

"!CONDA_PATH!" env list | find "mech3620" >nul
if !errorlevel! equ 0 (
    echo ⚠️  Environment exists, removing...
    "!CONDA_PATH!" env remove -n mech3620 -y
)

echo 📦 Creating new environment...
"!CONDA_PATH!" env create -f environment.yml -y

if !errorlevel! neq 0 (
    echo ❌ Failed to create environment
    pause
    exit /b 1
)

echo ✅ Environment created
echo.

REM ============================================
REM 安装 Python 包（numpy, scipy, matplotlib 等）
REM ============================================
echo 📦 Installing Python packages (numpy, scipy, matplotlib)...
"!CONDA_PATH!" run -n mech3620 pip install numpy scipy matplotlib -q

if !errorlevel! equ 0 (
    echo ✅ Python packages installed
) else (
    echo ⚠️  Some packages may already be installed
)
echo.

REM ============================================
REM 获取 Python 路径
REM ============================================
echo 🔧 Getting Python path...

set PYTHON_PATH=
for /f "delims=" %%i in ('"!CONDA_PATH!" run -n mech3620 python -c "import sys; print(sys.executable)" 2^>nul') do (
    set PYTHON_PATH=%%i
)

if "!PYTHON_PATH!"=="" (
    set "PYTHON_PATH=C:\Users\%USERNAME%\miniconda3\envs\mech3620\python.exe"
    if not exist "!PYTHON_PATH!" (
        set "PYTHON_PATH=C:\Users\%USERNAME%\anaconda3\envs\mech3620\python.exe"
    )
)

set PYTHON_PATH_FIXED=!PYTHON_PATH:\=/!
echo ✅ Python: !PYTHON_PATH_FIXED!
echo.

REM ============================================
REM 安装 Julia 包
REM ============================================
echo 📦 Installing Julia packages...
julia -e "using Pkg; Pkg.add([\"PyCall\", \"DataFrames\", \"Plots\", \"IJulia\"])"

echo 🔧 Configuring PyCall...
julia -e "ENV[\"PYTHON\"] = \"!PYTHON_PATH_FIXED!\"; using Pkg; Pkg.build(\"PyCall\")"

echo.
echo ========================================
echo ✅ Setup complete!
echo ========================================
echo.
echo Next steps:
echo 1. Restart your computer
echo 2. Double-click start.bat
echo.
pause
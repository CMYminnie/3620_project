# MECH3620 Project Setup

## 🚀 Quick Start

### Windows Users:
1. **Install Prerequisites** (if not already installed):
   - [Julia](https://julialang.org/downloads/) (version 1.10 or later)
   - [Miniconda](https://docs.conda.io/en/latest/miniconda.html) (Python 3.10)

2. **Run Setup**:
   - Double-click `setup.bat`
   - Wait for installation to complete (5-10 minutes)
   - Restart your computer

3. **Start Working**:
   - Double-click `start.bat`
   - Your browser will open with Jupyter
   - Navigate to `your_notebooks/` folder
   - Open `2. Preliminary_Weight_Estimation.ipynb`

## 📁 Project Structure
MECH3620_Project/
├── setup.bat # One-click installer
├── start.bat # Launch Jupyter
├── config.jl # Auto-configuration
├── mech3620_models.py # Required Python module
├── your_notebooks/ # Your notebooks here
└── README.md # This file


## 🔧 Troubleshooting

### "conda not found"
- Install Miniconda from: https://docs.conda.io/en/latest/miniconda.html
- Restart your computer after installation

### "julia not found"
- Install Julia from: https://julialang.org/downloads/
- Add Julia to PATH during installation

### "Module not found" error in notebook
- Make sure `mech3620_models.py` is in the same folder as the notebook
- Restart the kernel and run the first cell again

## 📞 Need Help?
Contact: [your email or contact info]

## ✅ Verification
After setup, run the test notebook to verify everything works.
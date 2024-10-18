#!/bin/bash

export FRONTISTR_SRC=$HOME/WelSimLLC-github/FrontISTR
export WELSIM_LIBPACK=$HOME/WelSimLLC/CodeDV/libPack/Linux
export WELSIM_EXEC=$HOME/WelSimLLC/executable30
export INTEL_DIR=$HOME/mySys/intel/oneapi/compiler/2024.2
export MKL_DIR=$HOME/mySys/intel/oneapi/mkl/2024.2


echo "Run CodeBlocks..."
codeblocks FemSolver2.workspace
echo "End of CodeBlocks."


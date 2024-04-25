#!/bin/bash

#export WELSIM_SRC=$HOME/WelSimLLC/CodeDV/WelSim/gitbucket/welsim
export FrontISTR_SRC=$HOME/WelSimLLC-github/FrontISTR
export WELSIM_LIBPACK=$HOME/WelSimLLC/CodeDV/libPack/Linux
export WELSIM_EXEC=$HOME/WelSimLLC/executable29
export INTEL_DIR=$HOME/mySys/intel/compilers_and_libraries_2018.5.274/linux


echo "Run CodeBlocks..."
codeblocks FemSolver2.workspace
echo "End of CodeBlocks."


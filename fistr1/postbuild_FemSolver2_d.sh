#!/bin/bash
source ../../../env_var.sh

#patchelf --set-rpath '$ORIGIN':'$ORIGIN'/qt5:'$ORIGIN'/qt5/plugins:'$ORIGIN'/qt5/plugins/platforms:'$ORIGIN'/vtk6:'$ORIGIN'/occ6:'$ORIGIN'/boost:'$ORIGIN'/intel bin/Debug/WelSimFemSolver2_d


cp -Rfv bin/Debug/WelSimFemSolver2_d $WELSIM_EXEC
cp -Rfv bin/Debug/WelSimFemSolver2_d $WELSIM_LIBPACK/bin/WelSim




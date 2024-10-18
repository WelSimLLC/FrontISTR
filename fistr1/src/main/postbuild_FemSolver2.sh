#!/bin/bash
#source ../../../env_var.sh

#patchelf --set-rpath '$ORIGIN':'$ORIGIN'/qt5:'$ORIGIN'/qt5/plugins:'$ORIGIN'/qt5/plugins/platforms:'$ORIGIN'/vtk6:'$ORIGIN'/occ6:'$ORIGIN'/boost:'$ORIGIN'/intel bin/Release/WelSimFemSolver2

cp -Rfv bin/Release/WelSimFemSolver2 $WELSIM_EXEC
cp -Rfv bin/Release/WelSimFemSolver2 $WELSIM_LIBPACK/bin/WelSim


REM call ../../env_var.bat

REM femSolver2 source code folder, all files are in $(WELSIM_SRC)\solver\WelSim.FemSolver2 
set WELSIM_SRC=D:\WelSimLLC\CodeDV\WelSim\bitbucket\welsim

REM 3rd party and femSolver2 libs, bins, and includes
set WELSIM_LIBPACK=D:\WelSimLLC\CodeDV\libPack

REM output folder for exetuable files
set WELSIM_EXEC=D:\WelSimLLC\executable26

"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" /run FemSolver2.sln
@REM start "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" FemSolver2.sln
REM call ../../env_var.bat 


XCOPY x64\Debug\WelSimFemSolver2_d.exe %WELSIM_LIBPACK%\bin\FemSolver2 /C /S /Y /I
XCOPY x64\Debug\WelSimFemSolver2_d.pdb %WELSIM_LIBPACK%\bin\FemSolver2 /C /S /Y /I

XCOPY x64\Debug\WelSimFemSolver2_d.exe %WELSIM_EXEC% /C /S /Y /I
XCOPY x64\Debug\WelSimFemSolver2_d.pdb %WELSIM_EXEC% /C /S /Y /I

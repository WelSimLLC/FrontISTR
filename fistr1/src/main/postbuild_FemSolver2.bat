REM call ../../env_var.bat 


XCOPY x64\Release\WelSimFemSolver2.exe %WELSIM_LIBPACK%\bin\FemSolver2 /C /S /Y /I

XCOPY x64\Release\WelSimFemSolver2.exe %WELSIM_EXEC% /C /S /Y /I
